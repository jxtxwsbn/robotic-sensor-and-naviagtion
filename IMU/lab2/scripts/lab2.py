#!/usr/bin/env python
#-*-coding: utf-8-*-
import rospy
import serial
from std_msgs.msg import *
from sensor_msgs.msg import Imu,MagneticField
import re
from math import sin,cos,pi


def extract_message(line):
    '''split the line and get the message attributes'''
    matrix = re.split(',',line)
    print(matrix)

    #get the data y p r
    yaw = float(matrix[1].strip())*pi/180
    pitch = float(matrix[2].strip())*pi/180
    roll = float(matrix[3].strip())*pi/180
    #angular velocity
    wz = matrix[12].split('*')
    wz_0 = float(wz[0].strip())
    wx = float(matrix[10].strip())
    wy = float(matrix[11].strip())
    wz = float(wz_0)
    #linear accelaration
    ax =float(matrix[7].strip())
    ay =float(matrix[8].strip())
    az =float(matrix[9].strip())

    # caculate quaternion
    cy = cos(yaw*0.5)
    sy = sin(yaw*0.5)
    cp = cos(pitch*0.5)
    sp = sin(pitch*0.5)
    cr = cos(roll*0.5)
    sr = sin(roll*0.5)
    qw = cy*cp*cr + sy*sp*sr
    qx = cy*cp*sr - sy*sp*cr
    qy = sy*cp*sr + cy*sp*cr
    qz = sy*cp*cr - cy*cp*sr

    #the imu gps_message
    imu_message = Imu()
    imu_message.header.stamp = rospy.Time.now()
    imu_message.orientation.x = qx
    imu_message.orientation.y = qy
    imu_message.orientation.z = qz
    imu_message.orientation.w = qw
    imu_message.angular_velocity.x= wx
    imu_message.angular_velocity.y= wy
    imu_message.angular_velocity.z= wz
    imu_message.linear_acceleration.x = ax
    imu_message.linear_acceleration.y = ay
    imu_message.linear_acceleration.z = az


    return imu_message

def extract_mag(line):
    '''split the line and get the message attributes'''
    matrix = re.split(',',line)
    magx = float(matrix[4].strip())
    magy = float(matrix[5].strip())
    magz = float(matrix[6].strip())
    #the MagneticField msg
    mag_msg = MagneticField()
    mag_msg.header.stamp = rospy.Time.now()
    mag_msg.magnetic_field.x = magx
    mag_msg.magnetic_field.y = magy
    mag_msg.magnetic_field.z = magz

    return mag_msg

if __name__ == '__main__':
    pub1 = rospy.Publisher('imu_topic/imu',Imu,queue_size = 10)
    pub2 = rospy.Publisher('imu_topic/mag',MagneticField,queue_size = 10)

    rospy.init_node('imu_puck', anonymous = True)
    rate = rospy.Rate(60)
    serial_port = rospy.get_param('~port','/dev/ttyUSB1')
    serial_baud = rospy.get_param('~baudrate',115200)
    port = serial.Serial(serial_port,serial_baud,timeout = 5)
    rospy.logdebug('connected to the imu_puck')
    try:
        rospy.loginfo('publish the imu message')
        while not rospy.is_shutdown():
            line = port.readline()
            if line == '':
                rospy.logwarn('No data')
            else:
                if line.startswith('$VNYMR'):
                    try:
                        imu_message_read = extract_message(line)
                        mag_msg_read = extract_mag(line)
                    except rospy.ROSInterruptException:
                        rospy.logwarn('data exception:'+ line)
                        imu_message_read = extract_message(line)
                        mag_msg_read = extract_mag(line)
                        continue
                    pub1.publish(imu_message_read)
                    pub2.publish(mag_msg_read)
                    rospy.loginfo(imu_message_read)
                    rospy.loginfo(mag_msg_read)
                    rate.sleep()
    except rospy.ROSInterruptException:
        rospy.loginfo('imu port closed')
        port.close()
    #except serial.serialutil.SerialExcepton:
    #rospy.loginfo('shutting down gps node')
