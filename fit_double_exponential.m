function [amps,rates,offset,r_squared,y_fit] = fit_double_exponential(x,y,varargin)
% Fit double exponential

p = inputParser;
addRequired(p,'x');
addRequired(p,'y');
addOptional(p,'figure_number',0);

parse(p,x,y,varargin{:});
p=p.Results;

% Code
pv(1) = 0.2*max(y);
pv(2) = 0.2*(1/max(x));
pv(3) = 0.8*max(y);
pv(4) = 0.8*(1/max(x));
pv(5) = y(end);

pv = fminsearchbnd(@double_exponential_fit,pv, ...
        [0 0 0 0 -inf],[inf inf inf inf inf], ...
        [],p.x,p.y);

amps = [pv(1) pv(3)];
rates = [pv(2) pv(4)];
offset = pv(5);

y_fit = pv(1)*exp(-pv(2)*x) + pv(3)*exp(-pv(4)*x) + pv(5);
r_squared = calculate_r_squared(y,y_fit);


function e = double_exponential_fit(pv,x,y)

fit = pv(1)*exp(-pv(2)*x) + pv(3)*exp(-pv(4)*x) + pv(5);
e = sum((fit-y).^2);
