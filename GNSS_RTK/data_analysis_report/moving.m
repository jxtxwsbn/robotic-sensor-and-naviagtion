%% moving data
clear;
moving1 = xlsread('moving.xlsx','isec_moving');
utm_easting = moving1(:,8);
utm_northing = moving1(:,9);
figure(1)
subplot(2,1,1)
plot(utm_easting,utm_northing)
title('moving utm1')
ylabel('northing')
xlabel('easting')
subplot(2,1,2)
plot(utm_easting-min(utm_easting),utm_northing-min(utm_northing))
title('moving utm2')
ylabel('northing')
xlabel('easting')
figure(2)
scatter(utm_easting-min(utm_easting),utm_northing-min(utm_northing),5)
title('moving utm scatter')
ylabel('northing')
xlabel('easting')

path = [utm_easting-min(utm_easting),utm_northing-min(utm_northing)];

rtk_fix = sum(moving1(:,12)==4);
rtk_float = sum(moving1(:,12)==5);
gnss_fix = sum(moving1(:,12)==1);
ratio = [rtk_fix,rtk_float,gnss_fix];
labels = {'rtk fix','rtk float','gnss fix'};
figure(3)
pie(ratio)
title('the distribution of different fix quality')
legend(labels)
%%
rtk_fix_a = find(moving1(:,10)==4);
rtk_float_a = find(moving1(:,10)==5);
gnss_a = find(moving1(:,10)==1);
rtk_fix_utm = moving1(rtk_fix_a',[8,9]);
rtk_float_utm = moving1(rtk_float_a',[8,9]);
gnss_utm = moving1(gnss_a',[8,9]);
%%
e = [6,19,27,40,45];
s = [1,6,19,27,40];
y_fits = [];
figure(4)
for i =1:5
line = path(s(i):e(i),:);
%x =linspace(min(line1(:,1)),max(line1(:,1)),245);
x = line(:,1);
y = line(:,2);
[p,S] = polyfit(x,y,1);
[y_fit,delta] = polyval(p,x,S);
y_fits = [y_fits;y_fit];
plot(line(:,1),line(:,2),'b')
hold on
plot(x,y_fit,'r-')
%plot(x,y_fit +2*delta,'m--',x,y_fit-2*delta,'m--')
end 
title('linear fit of data')
legend('Data','linear fit')
fits = [path(:,1),y_fits];
RMSE = sqrt(sum(((fits -path).^2),'all')/size(path,1));