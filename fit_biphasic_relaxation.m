function [params, r_squared, y_fit] = fit_biphasic_relaxation(x, y, varargin)
% Function fits piecewise linear slope + exponential decay to trace

% Handle inputs
p = inputParser;
addRequired(p, 'x');
addRequired(p, 'y');
addOptional(p, 'figure_handle', 1)

parse(p, x, y, varargin{:});

p = p.Results

% Code

% Try to get the x and y with the right orientation
sx = size(p.x);
if (sx(1) < sx(2))
    p.x = p.x';
end

sy = size(p.y);
if (sy(1) < sy(2))
    p.y = p.y';
end


% Loop through all possible breakpoints
sum_of_squares = NaN * ones(numel(p.x), 1);
for i = 3 : (numel(p.x)-2)
    y_out = calculate_y_profile(p.x, p.y, i, 0);
    sum_of_squares(i) = sum((p.y - y_out).^2);
end

% Pull off the best break index
% Recalculate profile
[~, best_break_index] = min(sum_of_squares);
[y_fit, profile_params] = ...
    calculate_y_profile(p.x, p.y, best_break_index, p.figure_handle);

% Store the params
params.x_break = p.x(best_break_index);
field_names = fieldnames(profile_params);
for i = 1 : numel(field_names)
    params.(field_names{i}) = profile_params.(field_names{i});
end

% And the other params
r_squared = calculate_r_squared(p.y, y_fit);

end

function [y_fit, profile_params] = ...
    calculate_y_profile(x, y, break_point, fig_number)
% Returns an array of the best fit for a straight line to the break point
% plus an exponential decay afterwards

% Break x into linear and exponential portions
lin_vi = 1 : break_point;
x_lin = x(lin_vi);
y_lin = y(lin_vi);

exp_vi = (break_point+1):(numel(x));
x_exp = x(exp_vi) - x(exp_vi(1));
y_exp = y(exp_vi);

% Create array to hold fit
y_fit = NaN * ones(numel(x), 1);

% Fit linear phase
lin_model = fit_linear_model(x_lin, y_lin);
y_fit(lin_vi) = lin_model.intercept + lin_model.slope * x_lin;

% Fit exponential phase
[exp_offset, exp_amplitude, exp_rate, ~, y_exp_fit] = fit_single_exponential(x_exp, y_exp);
y_fit(exp_vi) = y_exp_fit;

% Set the return values
profile_params.lin_slope = lin_model.slope;
profile_params.lin_intercept = lin_model.intercept;
profile_params.exp_offset = exp_offset;
profile_params.exp_amplitude = exp_amplitude;
profile_params.exp_rate = exp_rate;

% Draw if required
if (fig_number > 0)
    figure(fig_number);
    clf
    hold on;

    plot(x, y, 'b')
    plot(x, y_fit, 'r-');
end

end


