function [mid_x,nearest_point,m1,b1,m2,b2,best_r_squared,y_fit]=fit_two_straight_lines(x,y,min_points);
% Function returns the best fit of two straight lines to x and y data

no_of_points=length(x);
best_r_squared=0;

% Cycle through points in turn
for i=min_points:(no_of_points-min_points+1)
    
    % Fit first segment
    p1=polyfit(x(1:i),y(1:i),1);
    temp_y1=polyval(p1,x(1:i));
    % Fit second segment
    p2=polyfit(x(i+1:no_of_points),y(i+1:no_of_points),1);
    temp_y2=polyval(p2,x(i+1:no_of_points));
    
    % Compare fit to real data
    temp_y=[temp_y1;temp_y2];
    fit=calculate_r_squared(y,temp_y);
    
    % Pick off best values
    if (fit>best_r_squared)
        best_r_squared=fit;
        m1=p1(1);
        b1=p1(2);
        m2=p2(1);
        b2=p2(2);
        % Deduce mid_point as the intersection
        % of the straight lines
        mid_x=(b2-b1)/(m1-m2);
        [nearest_point,nearest_point]=min(abs(x-mid_x));
        y_fit = temp_y;
    end
end
    
    
    
    

