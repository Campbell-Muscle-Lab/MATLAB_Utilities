function [sin_mag,cos_mag,freq,r_squared,x_fit,y_fit] = fit_sin_plus_cos(x,y,freq)

% Guess p
mean_y = mean(y);
c = y(1)-mean_y;
% Cos should be zero at 2*pi*freq*x = pi/2
x0 = 1/(4*freq);
[~,i0]=min(abs(x-x0));
s = y(i0)-mean_y;
p = [s c freq mean_y];

p = fminsearch(@calculate_error,p,[],x,y);

y_fit = calculate_y_fit(p,x);

sin_mag = p(1);
cos_mag = p(2);
freq = p(3);
r_squared = calculate_r_squared(y,y_fit);
x_fit = x;

end

function y_fit = calculate_y_fit(p,x)
    for i=1:numel(x)
        y_fit(i) = p(1)*sin(2*pi*p(3)*x(i)) + p(2)*cos(2*pi*p(3)*x(i)) + p(4);
    end
end

function e = calculate_error(p,x,y)
    y_fit = calculate_y_fit(p,x);
    e=0;
    for i=1:numel(x)
        e = e+(y_fit(i)-y(i))^2;
    end
%     
%     figure(15);
%     clf
%     hold on;
%     plot(x,y,'b-');
%     plot(x,y_fit,'r-');
%     drawnow;
%     error('ken')
end
