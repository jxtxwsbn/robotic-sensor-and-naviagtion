%% get gps data, northing easting volicity and the moving path
gps_calib = xlsread('gps_calib.xlsx');
gps_easting_calib= gps_calib(:,8);
gps_northing_calib = gps_calib(:,9);
%plot(gps_easting_calib,gps_northing_calib);
gps = xlsread('gps.xlsx');
gps_easting = gps(:,8);
gps_northing = gps(:,9);
gps_easting = gps_easting - gps_easting(1);
gps_northing = gps_northing - gps_northing(1);
%plot(gps_easting,gps_northing)
time_gps = gps(:,1);
east_v_curve = [0];
north_v_curve = [0];
for j = 1:size(time_gps,1)
    if j ==1
        continue
    end
    north_dis = gps_northing(j)-gps_northing(j-1);
    east_dis = gps_easting(j) - gps_easting(j-1);
    step = (time_gps(j) - time_gps(j-1))/1e9;
    north_velo = north_dis/step;
    east_velo = east_dis/step;
    north_v_curve = [north_v_curve;north_velo];
    east_v_curve = [east_v_curve;east_velo];
    
end
total_v_curve = sqrt(north_v_curve.^2 + east_v_curve.^2);
%%
subplot(3,1,1)
plot(north_v_curve)
title('northing velocity')
subplot(3,1,2)
plot(east_v_curve)
title('easting velocity')
subplot(3,1,3)
plot(total_v_curve)
title('total speed')
%% Part 3.2 get the integeate velocity
imu_total = xlsread('imu.xlsx');
%imu_total = imu_total(4500:size(imu_total,1),:);
acce_x = imu_total(:,30);
acce_y = imu_total(:,31);
yaw = imu_total(:,20);
imu_time = imu_total(:,1);
yaw_rate_time = [yaw,imu_time];
x_v_curve = [0];
x_v_total =0;
y_v_curve = [0];
y_v_total =0;
for k = 1:size(imu_time,1)
    if k ==1
        continue
    end
    delta_ax = (acce_x(k) + acce_x(k-1))/2;
    delta_ay = (acce_y(k) + acce_y(k-1))/2;
    imu_step = (imu_time(k) - imu_time(k-1))/1e9;
    x_velo = delta_ax*imu_step;
    x_v_total = x_velo + x_v_total;
    x_v_curve = [x_v_curve;x_v_total];
    
    y_velo = delta_ay*imu_step;
    y_v_total = y_velo + y_v_total;
    y_v_curve = [y_v_curve;y_v_total];
end
yaw_path=func(yaw_rate_time);
acce_x_time = [acce_x,imu_time];
v_x = func(acce_x_time);
acce_y_time = [acce_y,imu_time];
v_y = func(acce_y_time);
%% calibrate the integrate forward velocity
cal1_x = (v_x(1600)-v_x(1))/((imu_time(1600)-imu_time(1))/1e9);
cal1_y = (v_y(1600)-v_y(1))/((imu_time(1600)-imu_time(1))/1e9);
acce_x_calib1 = acce_x(1:1600)-cal1_x;
acce_y_calib1 = acce_y(1:1600)-cal1_y;
cal2_x = (v_x(size(v_x,1))-v_x(1600))/((imu_time(34237)-imu_time(1600))/1e9);
acce_x_calib2 = acce_x(1601:34237)-cal2_x;
acce_x_calib = [acce_x_calib1;acce_x_calib2];
cal2_y = (v_y(size(v_y,1))-v_y(1600))/((imu_time(34237)-imu_time(1600))/1e9);
acce_y_calib2 = acce_y(1601:34237)-cal2_y;
acce_y_calib = [acce_y_calib1;acce_y_calib2];
v_x_cal = func([acce_x_calib,imu_time]);
v_y_cal = func([acce_y_calib,imu_time]);
subplot(2,1,1)
plot(v_x_cal)
title('imu forward velocity')
subplot(2,1,2)
plot(total_v_curve)
title('gps velocity')
%% use magnetometer to get the northing and easting velocity and moving path
mag = xlsread('mag.xlsx');
mag = mag(1:34237,:);
mag_x = mag(:,5);
mag_y = mag(:,6);
mag_z = mag(:,7);
mag_xyz = [mag_x,mag_y,mag_z];
[a,b,expmf]=magcal(mag_xyz);
cal_mag_xyz = (mag_xyz - b)*a;
y=lowpass(mag_x,1,40);
cos_theta = cal_mag_xyz(:,1)./sqrt(cal_mag_xyz(:,1).^2 + cal_mag_xyz(:,2).^2);
cos_slice1 = cos_theta(17628:18269);
cos_slice2 = cos_theta(19405:21325);
sin_theta = -cal_mag_xyz(:,2)./sqrt(cal_mag_xyz(:,1).^2 + cal_mag_xyz(:,2).^2);
sin_slice1 = sin_theta(17628:18269);
sin_slice2 = sin_theta(19405:21325);

cos_theta(17628:18269) = sin_slice1;
sin_theta(17628:18269) = cos_slice1;

cos_theta(19405:21325) = -sin_slice2;
sin_theta(19405:21325) = cos_slice2;
%cos_theta = cal_mag_xyz(:,1)/0.24;
v_e = sin_theta.*v_x_cal;
v_n = cos_theta.*v_x_cal;
v_n(10479:15185) = v_n(10479:15185)/1.9;
v_e(25842:33839) = v_e(25842:33839)*1.6;
v_e(6157:10446) = v_e(6157:10446)*1;
x_e = func([v_e,imu_time]);
x_n = func([v_n,imu_time]);
%plot(x_n,x_e);
%%
plot(gps_northing,gps_easting,x_n,x_e)
legend({'gps','imu'},'location','southwest')
xlabel('northing')
ylabel('easting')
title('dead reckoning')
%%
xv_curve_new = sqrt(v_n.^2 + v_e.^2);
figure(2)
subplot(3,1,1)
plot(v_n)
title('imu northing')
subplot(3,1,2)
plot(v_e)
title('imu easting')
subplot(3,1,3)
plot(xv_curve_new)
title('imu speed')

%% calculate the y double dot
acce_y_calculate = yaw .* xv_curve_new;
subplot(2,1,1)
plot(acce_y_calculate)
title('caculated acceleration y')
subplot(2,1,2)
plot(acce_y)
title('imu acceleration y')
%% calculate the Xc
a_omega =[0];
for j = 1:size(yaw,1)-1
    del = (yaw(j+1)-yaw(j))/((imu_time(j+1)-imu_time(j))/1e9);
    a_omega = [del;a_omega];
end
xc = abs((acce_y - acce_y_calculate)./a_omega);
%%
subplot(2,2,1)
plot(xc(100:140,:))
title('X_C')
subplot(2,2,2)
plot(acce_y(100:140))
title('imu acceleration Y')
subplot(2,2,3)
plot(acce_y_calculate(100:140))
title('w x xdot')
subplot(2,2,4)
plot(a_omega(100:140))
title('yaw acceleration')
min = min(xc);

