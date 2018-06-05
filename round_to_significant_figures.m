function x=round_to_significant_figures(x,sig_figs);
% Functions round to significant figures

kens_power = -floor(log10(abs(x)))+sig_figs-1;
x = (round(x*10^kens_power) * 10^(-kens_power) );