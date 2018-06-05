function [log10_alpha,beta,r_squared,x_fit,y_fit] = fit_exp_tension(x,y,varargin)

params.log10_alpha = -5;
params.beta = 100;
params.x_fit = linspace(min(x),max(x),100);
params.figure_display = 0;

params = parse_pv_pairs(params,varargin);

% Check orientation
[rx,cx]=size(x);
if (rx<cx)
    x=x';
end
[ry,cy]=size(y);
if (ry<cy)
    y=y';
end
if (size(x)~=size(y))
    error('x and y are not the same size');
end


% Initialise fit
p=[params.log10_alpha params.beta];

% Perform fit
[p,~,status]=fminsearchbnd(@error_value, ...
    p, ...
    [-inf 0],[inf inf],[], ...
    x,y,params.figure_display);

y_fit = 10^p(1) * (exp(p(2)*x) - 1);
r_squared = calculate_r_squared(y_fit,y);

x_fit = params.x_fit;
y_fit = 10^p(1) * (exp(p(2)*x_fit) - 1);
log10_alpha = p(1);
beta = p(2);

end



function e = error_value(p,x,y,figure_display)

    y_fit = 10^p(1) * (exp(p(2) * x) - 1);
    e = sum((y_fit-y).^2);
    
    if (figure_display)
        figure(figure_display);
        clf;
        plot(x,y,'b-');
        hold on;
        plot(x,y_fit,'r-');
    end
end