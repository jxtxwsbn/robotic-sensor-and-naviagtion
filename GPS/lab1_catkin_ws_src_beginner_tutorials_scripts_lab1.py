#!/usr/bin/env python
#-*-coding: utf-8-*-
import rospy
import serial
from std_msgs.msg import *
from beginner_tutorials.msg import gps_message
import utm
import re


def extract_message(line):
    '''split the line and get the message attributes'''
    matrix = re.split(b',',line)
    la_raw = matrix[2]
    lo_raw = matrix[4]
    at_raw = matrix[9]
    #print(matrix)
    la = float(la_raw[0:2]) + float(la_raw[2:])/60
    lo = float(lo_raw[0:3]) + float(lo_raw[3:])/60
    at = float(at_raw)
    if matrix[3] =='S':
        la = -la
    if matrix[5] =='W':
        lo = -lo

    trans = utm.from_latlon(la,lo)
    gps_message_1 = gps_message()
    gps_message_1.header.stamp = rospy.Time.now()
    gps_message_1.latitude = la
    gps_message_1.longitude = lo
    gps_message_1.attitude = at
    gps_message_1.utm_easting = trans[0]
    gps_message_1.utm_northing = trans[1]
    gps_message_1.zone_num = trans[2]
    gps_message_1.zone_letter =trans[3]
    return gps_message_1


if __name__ == '__main__':
    pub = rospy.Publisher('gps_topic',gps_message,queue_size = 5)
    rospy.init_node('gps_puck', anonymous = True)
    rate = rospy.Rate(5)
    serial_port = rospy.get_param('~port','/dev/ttyACM0')
    serial_baud = rospy.get_param('~baudrate',4800)
    port = serial.Serial(serial_port,serial_baud,timeout =3)
    rospy.logdebug('connected to the gps_puck')
    try:
        rospy.loginfo('publish the message')
        while not rospy.is_shutdown():
            line = port.readline()
            if line == '':
                rospy.logwarn('No data')
            else:
                if line.startswith('$GPGGA'):
                    try:

                        gps_message_true = extract_message(line)
                    except:
                        rospy.logwarn('data exception:'+ line)
                        gps_message_true = extract_message(line)
                        continue
                    pub.publish(gps_message_true)
                    rospy.loginfo(gps_message_true)
                    rate.sleep()
    except rospy.ROSInterruptException:
        rospy.loginfo('port closed')
        port.close()
    #except serial.serialutil.SerialExcepton:
    #rospy.loginfo('shutting down gps node')
