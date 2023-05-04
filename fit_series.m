function fit_series

data = readtable('series.xlsx');

x = data.x;
y2 = data.y2;


[log10_alpha,beta,r_squared,x_fit,y_fit] = fit_exp_tension(x,y2);

log10_alpha
beta


end