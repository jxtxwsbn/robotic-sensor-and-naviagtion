%% stationary data
clear;
static1 = xlsread('static.xlsx','isec_static');
utm_easting = static1(:,8);
utm_northing = static1(:,9);
figure(1)
subplot(2,2,1)
scatter(utm_easting,utm_northing)
title('static utm1')
ylabel('northing')
xlabel('easting')
subplot(2,2,2)
scatter(utm_easting-min(utm_easting),utm_northing-min(utm_northing))
title('static utm2')
ylabel('northing')
xlabel('easting')
subplot(2,2,3)
hist(utm_easting,100)
title('utm easting histogram')
ylabel('number')
xlabel('number of bin= 100')
subplot(2,2,4)
hist(utm_northing,100)
title('utm northing histogram')
ylabel('number')
xlabel('number of bin= 100')

normalize_n = normalize(utm_northing);
normalize_e = normalize(utm_easting);
figure(2)
scatter(normalize_e,normalize_n,1)
title('normalized utm data')
ylabel('normalized northing')
xlabel('normalized easting')

rtk_fix = sum(static1(:,12)==4);
rtk_float = sum(static1(:,12)==5);
gnss_fix = sum(static1(:,12)==1);
ratio = [rtk_fix,rtk_float,gnss_fix];
labels = {'rtk fix','rtk float','gnss fix'};
figure(3)
pie(ratio)
title('the distribution of different fix quality')
legend(labels)

rtk_fix_a = find(static1(:,12)==4);
rtk_float_a = find(static1(:,12)==5);
gnss_a = find(static1(:,12)==1);
rtk_fix_utm = static1(rtk_fix_a',[8,9]);
rtk_float_utm = static1(rtk_float_a',[8,9]);
gnss_utm = static1(gnss_a',[8,9]);

