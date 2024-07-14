function rgb = return_matplotlib_default_colors()

% Function returns matplotlib default colors
hex_strings = {'#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', ...
    '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf'};

rgb = hex2rgb(hex_strings);

