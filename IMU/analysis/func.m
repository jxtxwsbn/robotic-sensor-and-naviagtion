function yaw = yaw_angle(yaw_rate)
    number = size(yaw_rate,1);
    angle_total = 0;
    yaw = [];
    for i =1:number
        if i == 1
            continue;
        end
        time_step = (yaw_rate(i,2)-yaw_rate(i-1,2))/1e9;
        angle =(yaw_rate(i-1,1)+yaw_rate(i,1))/2*time_step;
        yaw = [yaw;angle_total];
        angle_total = angle_total+angle;
    end
    yaw = [yaw;angle_total];
end