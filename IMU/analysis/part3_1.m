%% part 3.1 (use the first several circles to do some calibrate)
mag = xlsread('mag_calib.xlsx');
mag = mag(740:2050,:);
mag_x = mag(:,5);
mag_y = mag(:,6);
mag_z = mag(:,7);
mag_xyz = [mag_x,mag_y,mag_z];
[a,b,expmf]=magcal(mag_xyz);
cal_mag_xyz = (mag_xyz - b)*a;
y=lowpass(mag_x,1,40);
y = y/0.25;
%%
subplot(2,1,1)
plot(mag_x)
title('mag_x before calibration')
subplot(2,1,2)
plot(mag_y)
title('mag_y before calibration')
figure(2)
subplot(2,1,1)
plot(cal_mag_xyz(:,1))
title('mag_x after calibration')
subplot(2,1,2)
plot(cal_mag_xyz(:,2))
title('mag_y after calibration')
%%
imu = xlsread('imu_calib.xlsx');
imu = imu(720:2050,:);
wz = imu(:,20);
time = imu(:,1);
ax = imu(:,30);
ay = imu(:,31);
yaw_rate_time = [wz,time];
yaw = func(yaw_rate_time);
subplot(2,1,1)
plot(yaw)
title('yaw')
subplot(2,1,2)
plot(cos(yaw))
title('cos(yaw)')
z=highpass(cos(yaw),1,40);