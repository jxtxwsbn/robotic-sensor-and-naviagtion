#!/usr/bin/env python
#-*-coding: utf-8-*-
import rospy
import serial
from std_msgs.msg import *
from lab3.msg import rtk
import utm
import re


def extract_message(line):
    '''split the line and get the message attributes'''
    matrix = re.split(b',',line)
    la_raw = matrix[2]
    lo_raw = matrix[4]
    at_raw = matrix[9]    #print(matrix)
    quality_raw = matrix[6]
    la = float(la_raw[0:2]) + float(la_raw[2:])/60
    lo = float(lo_raw[0:3]) + float(lo_raw[3:])/60
    at = float(at_raw)
    quality = int(quality_raw)
    if matrix[3] =='S':
        la = -la
    if matrix[5] =='W':
        lo = -lo

    trans = utm.from_latlon(la,lo)
    rtk_1 = rtk()
    rtk_1.header.stamp = rospy.Time.now()
    rtk_1.latitude = la
    rtk_1.longitude = lo
    rtk_1.attitude = at
    rtk_1.utm_easting = trans[0]
    rtk_1.utm_northing = trans[1]
    rtk_1.quality = quality
    return rtk_1


if __name__ == '__main__':
    pub = rospy.Publisher('rtk_topic',rtk,queue_size = 5)
    rospy.init_node('rtk_puck', anonymous = True)
    rate = rospy.Rate(10)
    serial_port = rospy.get_param('~port','/dev/ttyACM1')
    serial_baud = rospy.get_param('~baudrate',115200)
    port = serial.Serial(serial_port,serial_baud,timeout =3)
    rospy.logdebug('connected to the gps_puck')
    try:
        rospy.loginfo('publish the message')
        while not rospy.is_shutdown():
            line = port.readline()
            if line == '':
                rospy.logwarn('No data')
            else:
                if line.startswith('$GNGGA'):
                    try:

                        rtk_true = extract_message(line)
                    except:
                        rospy.logwarn('data exception:'+ line)
                        rtk_true = extract_message(line)
                        continue
                    pub.publish(rtk_true)
                    rospy.loginfo(rtk_true)
                    rate.sleep()
    except rospy.ROSInterruptException:
        rospy.loginfo('port closed')
        port.close()
    #except serial.serialutil.SerialExcepton:
    #rospy.loginfo('shutting down gps node')
