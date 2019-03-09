function [x0,a,b,r_squared,x_fit,y_fit,max_power,rel_x_at_max_power] = ...
    fit_power_curve(x,y,varargin);
% Fits a curve of the form y = x*b*(((x0+a)/(x+a))-1)

% Defaults
params.x0_guess = [];
params.a_guess = [];
params.b_guess = [];
params.x0_min = [];
params.x0_max = [];
params.x_fit = [];
params.figure_display = 0;


% Update
params=parse_pv_pairs(params,varargin);

% Some defaults
if (isempty(params.x_fit))
    params.x_fit = linspace(min(x),max(x),100);
end

% Deduce some starting values
if (isempty(params.x0_guess))
    params.x0_guess=max(x);
end

if (isempty(params.a_guess))
    params.a_guess = 0.2*max(x);
end

if (isempty(params.b_guess))
    params.b_guess = 1e-3;
end

if (isempty(params.x0_min))
    lower_bounds=[0 min(x)+eps 0];
else
    lower_bounds=[params.x0_min min(x)+eps 0];
end
if (isempty(params.x0_max))
    upper_bounds=Inf*ones(3,1);
else
    upper_bounds=[params.x0_max Inf Inf];
end

% Set p
p = [params.x0_guess params.a_guess params.b_guess];

[p,~,status]=fminsearchbnd(@power_error, ...
    p, ...
    lower_bounds, upper_bounds, ...
    optimset('MaxFunEvals',5000), ...
    x,y,params.figure_display);

% Calculate y_fit
x0=p(1);
a=p(2);
b=p(3);
for i=1:numel(x)
    y_fit(i) = power_value(x(i),x0,a,b);
end
r_squared=calculate_r_squared(y,y_fit);

% Calculate fit curve
x_fit = params.x_fit;
for i=1:length(x_fit)
    y_fit(i)=power_value(x_fit(i),x0,a,b);
end

% Create a function handle and interpolate to get the max power
fh = @(x)negative_power_value(x,x0,a,b);
[force_at_max_power,neg_power]=fminbnd(fh,min(x_fit),max(x_fit));
max_power = -neg_power;
rel_x_at_max_power = force_at_max_power/x0;

end


function error_value = power_error(p,x,y,figure_display)

    for i=1:length(x)
        y_fit(i) = power_value(x(i),p(1),p(2),p(3));
    end
    [r1,c1]=size(y);
    [r2,c2]=size(y_fit);
    if (r1>r2)
        y=y';
    end
    error_value = sum((y-y_fit).^2);
    
    if (figure_display)
        figure(figure_display);
        clf;
        plot(x,y,'bo');
        hold on;
        x_plot=linspace(min(x),max(x),100);
        for i=1:length(x_plot)
            y_plot(i)=power_value(x_plot(i),p(1),p(2),p(3));
        end
        plot(x_plot,y_plot,'r-');
        drawnow;
    end
end

function y=power_value(x,x0,a,b)
    y = x*b*(((x0+a)/(x+a))-1);
end

function y = negative_power_value(x,x0,a,b);
    y = -power_value(x,x0,a,b);
end