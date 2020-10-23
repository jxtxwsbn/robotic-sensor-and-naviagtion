%% plot the stationary data
mag = xlsread('1_1.xlsx');
mag_x = mag(:,5);
mag_y = mag(:,6);
mag_z = mag(:,7);
%%
imu = xlsread('1.xlsx');
imu = imu(2:1083,:);
yaw_rate = imu(:,20);
pitch_rate = imu(:,19);
roll_rate = imu(:,18);
time = imu(:,1);
ay = imu(:,31);
az = imu(:,32);
ax = imu(:,30);
%%
hist(ax,30)
mean(ax)
var(ax)