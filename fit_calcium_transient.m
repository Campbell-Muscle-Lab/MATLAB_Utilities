function [function_parameters,y_fit,r_squared] = ...
    fit_calcium_transient(varargin)

% Fits a 'calcium-like transient' using the formula in Jeremy Rice's paper
% http://www.sciencedirect.com/science/article/pii/S000634950878384X
% John Jeremy Rice, Fei Wang, Donald M. Bers, Pieter P. de Tombe,
% Approximate Model of Cooperative Activation and Crossbridge Cycling in Cardiac Muscle Using Ordinary Differential Equations, Biophysical Journal, Volume 95, Issue 5, 1 September 2008, Pages 2368-2390, ISSN 0006-3495, 10.1529/biophysj.107.119487.
% (http://www.sciencedirect.com/science/article/pii/S000634950878384X)

params.t=[];
params.y=[];
params.Ca_diastolic=[];
params.Ca_amp=[];
params.tau_1=[];
params.tau_2=[];
params.t_start=[];
params.constrain_t_start=0;
params.figure_number=[];

% Update
params = parse_pv_pairs(params,varargin);

% Set up some guesses but don't overwrite supplied data
if (isempty(params.Ca_diastolic))
    params.Ca_diastolic=min(params.y);
end
if (isempty(params.Ca_amp))
    params.Ca_amp=max(params.y)-params.Ca_diastolic;
end
if (isempty(params.tau_1))
    params.tau_1=0.01;
end
if (isempty(params.tau_2))
    params.tau_2=0.03;
end
if (isempty(params.t_start))
    params.t_start=min(params.t)+0.1*(max(params.t)-min(params.t));
end

% Initialise the p vector
p=[params.Ca_diastolic params.Ca_amp ...
    params.tau_1 params.tau_2 params.t_start];

% Set up for bound optimisation
lower_bounds=[-inf 0 -inf 0 min(params.t)];
upper_bounds=[+inf +inf +inf +inf max(params.t)];
if (params.constrain_t_start)
    lower_bounds(5)=params.t_start;
    upper_bounds(5)=params.t_start;
    p(5)=params.t_start;
end

p=p
lb = lower_bounds
ub = upper_bounds
pt = params.t
py = params.y
pf = params.figure_number

% Minimize
p=fminsearchbnd(@calcium_transient_error,p, ...
    lower_bounds,upper_bounds, ...
    [],params.t,params.y,params.figure_number);

% Unpack
function_parameters = p;
y_fit = calculate_transient(params.t,p);
r_squared=calculate_r_squared(params.y,y_fit);

end

function error_value = calcium_transient_error(p,t,y,figure_number)

    y_fit = calculate_transient(t,p);

    error_value = sum((y-y_fit').^2);

    if (figure_number>0)
        old_figure=gcf;
        figure(figure_number);
        clf;
        plot(t,y,'b-');
        hold on;
        plot(t,y_fit,'r-');
    end
end
    
function y_fit = calculate_transient(t,p)
    
    beta = (p(3)/p(4))^(-1/(p(3)/p(4)-1)) - ...
            (p(3)/p(4))^(-1/(1-p(4)/p(3)));
        
    for i=1:length(t)
        if (t(i)<p(5))
            y_fit(i)=p(1);
        else
            y_fit(i)=((p(2)-p(1))/beta) * ...
                (exp(-(t(i)-p(5))/p(3)) - exp(-(t(i)-p(5))/p(4))) + ...
                p(1);
        end
    end
end
    