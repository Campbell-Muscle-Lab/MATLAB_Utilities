function [grad,intercept,r]=fit_robust_line(x_data,y_data);

no_of_points=length(x_data);
if (length(y_data)~=no_of_points)
    error('No of points in x and y data sets differ (robust_regression)');
end

if (x_data(no_of_points)~=x_data(1))
    guess_gradient=(y_data(no_of_points)-y_data(1))/(x_data(no_of_points)-x_data(1));
else
    guess_gradient=1;
end


guess_intercept=y_data(1)-(x_data(1)*guess_gradient);

p=[guess_gradient guess_intercept];
p=fminsearch(@robust_linear_fit,p,[],x_data,y_data);

grad=p(1);
intercept=p(2);

x_mean=mean(x_data);
y_mean=mean(y_data);
r=(sum((x_data-x_mean).*(y_data-y_mean)))/sqrt((sum((x_data-x_mean).^2))*(sum((y_data-y_mean).^2)));

% figure(gcf+1);
% x_fit=[min(x_data) max(x_data)];
% y_fit=intercept+(grad*x_fit);
% plot(x_data,y_data,'ro',x_fit,y_fit,'b-');

function error = robust_linear_fit(p,x,y)

fit=p(1)*x+p(2);
error=sum(abs(fit-y));
