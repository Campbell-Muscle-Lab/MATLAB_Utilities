function plot_pCa_data_with_y_errors(d,varargin)

p=inputParser;
addRequired(p,'d');
addOptional(p,'axis_handle',[]);
addOptional(p,'y_axis_label',{'Stress','(kN m^{-2}'});
addOptional(p,'pCa90_replacement_value',7.0);
addOptional(p,'x_limits',[4.5 7]);
addOptional(p,'x_break_point',6.75);
addOptional(p,'x_break_width',0.04);
addOptional(p,'x_break_spacing',0.075);
addOptional(p,'x_break_line_width',1.5);
addOptional(p,'draw_data_break',1);
addOptional(p,'marker_face_colors',[]);
addOptional(p,'marker_symbols',{'o','^','s','d'});
addOptional(p,'marker_size',10);
parse(p,d,varargin{:});
p=p.Results;

% Code
if (isempty(p.axis_handle))
    figure;
    clf;
else
    subplot(p.axis_handle);
end

if (isempty(p.marker_face_colors))
    p.marker_face_colors = jet(numel(d));
end

% Replace pCa 9.0 values
if (~isempty(p.pCa90_replacement_value))
    vi = find(d.pCa == 9.0);
    d.pCa(vi) = p.pCa90_replacement_value;
end

% Set up data
for i=1:numel(d)
    x_data(i).mean_values = d(i).pCa;
    x_data(i).error_values = 0*d(i).pCa;
    y_data(i).mean_values = d(i).y;
    y_data(i).error_values = d(i).y_error;
end

plot_with_errorr_bars( ...
    'x_data',x_data, ...
    'y_data',y_data, ...
    'y_limits',p.y_limits, ...
    'marker_face_color',p.marker_face_colors, ...
    'marker_symbols',p.marker_symbols, ...
    'marker_size',p.marker_size);

end
    
    






