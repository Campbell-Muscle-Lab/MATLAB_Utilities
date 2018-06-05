function stat_lines(varargin)

params.axis_handle=gca;
params.line_data=[];
params.rel_y_length=0.02;
params.line_width=1;
params.line_style='-';
params.line_color='k';
params.font_size=8;
params.label_y_offset=0.02;


params=parse_pv_pairs(params,varargin);

line_data = params.line_data;

% Code
no_of_lines=numel(line_data);

% Loop
y_axis_length = diff(ylim);

for line_counter=1:no_of_lines
    x=[line_data(line_counter).data{1} line_data(line_counter).data{1} ...
        line_data(line_counter).data{2} line_data(line_counter).data{2}];
    y=line_data(line_counter).data{4} + ...
        params.rel_y_length*y_axis_length*[-1 0 0 -1];
    
    plot(x,y, ...
        'LineStyle',params.line_style, ...
        'Color',params.line_color, ...
        'LineWidth',params.line_width, ...
        'Clipping','off');
    
    text(mean(x)+line_data(line_counter).data{5},...
        max(y)+params.label_y_offset*y_axis_length, ...
        line_data(line_counter).data{3}, ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'FontSize',params.font_size);
end



