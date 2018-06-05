function plot_pCa_curves_from_excel_sheets(varargin)

% Defaults
params.excel_file_strings='';
params.excel_sheet='averaged_tag';
params.y_tag='P_ss';
params.y_error_tag='SEM';
params.max_y_value=[];
params.output_figure=1;
params.pCa90_replacement_value=7.0;
params.x_limits=[4.5 7.0];
params.x_break_point=6.75;
params.x_break_width=0.04;
params.x_break_rel_height=0.03;
params.x_break_spacing=0.075;
params.x_break_line_width=1.5;
params.draw_data_break=0;
params.draw_Hill_fits=1;
params.x_axis_label='pCa';
params.y_axis_label={'Force','(kN m^-^2)'};
params.label_font_size=12;
params.tick_font_size=10;
params.y_label_offset=-0.25;
params.y_tick_decimal_places=0;
params.marker_size=6.5;
params.marker_edge_colors=[0 0 0; 0 0 0; 0 0 0; 0 0 0];
params.marker_face_colors=[0.7 0 0;0 0.7 0];
params.marker_symbols={'s','s'};
params.y_tick_labels=[];
params.y_scaling_factor=0.001;

% Update
params=parse_pv_pairs(params,varargin);

% Set the ticks
x_ticks=[params.pCa90_replacement_value 6.5:-0.5:4.5];

% Code

% Get the number of excel files
if (~iscell(params.excel_file_strings))
    error('plot_pCa_curves_from_Excel_sheets: excel_file_strings should be a cell array');
end
no_of_excel_files=length(params.excel_file_strings);

% Loop through the files
max_y_value=0;
pCa90_y_values=[];
for file_counter=1:no_of_excel_files
    
    % Read excel file
    excel_data=read_structure_from_excel(...
        'filename',params.excel_file_strings{file_counter}, ...
        'sheet',params.excel_sheet);
    
    % Load y data
    % First, work out which data exist
    n_tag=['n_' params.y_tag];
    n_values=excel_data.(n_tag);
    vi=find(n_values>0);
    
    % Now read in the values you want   
    y_data_tag=['Mean_' params.y_tag];
    y_data(file_counter).mean_values=excel_data.(y_data_tag)(vi);
    y_error_tag=[params.y_error_tag '_' params.y_tag];
    y_data(file_counter).error_values=excel_data.(y_error_tag)(vi);
    
  % Hold the max value
   y_tops=y_data(file_counter).mean_values + ...
       y_data(file_counter).error_values;
    if (max(y_tops)>max_y_value)
       max_y_value=max(y_tops);
    end
    
    % Load pCa data
    pCa_data(file_counter).mean_values=excel_data.pCa(vi);
    pCa_data(file_counter).error_values=zeros(length(vi),1);
    
    % Store fit data if required
    if (params.draw_Hill_fits)
        [~,~,~,~,~,x_fit{file_counter}.values, ...
                y_fit{file_counter}.values]= ...
            fit_Hill_curve(pCa_data(file_counter).mean_values, ...
                y_data(file_counter).mean_values);
    end
    
    % Remap the pCa 9.0 value and store the y_values
    if (~isempty(params.pCa90_replacement_value))
        vi=find(pCa_data(file_counter).mean_values==9.0);
        pCa_data(file_counter).mean_values(vi)= ...
            params.pCa90_replacement_value;
        pCa90_y_values=[pCa90_y_values ...
            y_data(file_counter).mean_values(vi)];
    end
end

% Calculate a good y value
if (isempty(params.max_y_value))
   max_y_value=multiple_greater_than( ...
       max_y_value,10^floor(log10(max_y_value)));
else
   max_y_value=params.max_y_value;
end

% Generate the labels
label_string=sprintf('%%.%.0ff',params.y_tick_decimal_places)
y_ticks=[0 max_y_value];
for i=1:numel(y_ticks)
    labels{i}=sprintf(label_string,y_ticks(i)*params.y_scaling_factor);
end

% Draw the figure
plot_with_error_bars('x_data',pCa_data, ...
    'y_data',y_data, ...
    'x_limits',params.x_limits, ...
    'y_limits',[0 max_y_value],...
    'marker_edge_color',params.marker_edge_colors,...
    'marker_face_color',params.marker_face_colors,...
    'marker_symbols',params.marker_symbols);

hold on;
% Draw Hill fits if required
if (params.draw_Hill_fits)
    for file_counter=1:no_of_excel_files
        if (params.draw_data_break)
            % Draw the lines in two halves
            vi=find((x_fit{file_counter}.values<max(x_ticks)) & ...
                (x_fit{file_counter}.values> ...
                    (params.x_break_point+params.x_break_spacing)));
            plot(x_fit{file_counter}.values(vi), ...
                y_fit{file_counter}.values(vi),'k-');
            vi=find((x_fit{file_counter}.values< ...
                    params.x_break_point) & ...
                (x_fit{file_counter}.values>min(x_ticks)));
            plot(x_fit{file_counter}.values(vi), ...
                y_fit{file_counter}.values(vi),'k-');
        else
            vi=find((x_fit{file_counter}.values<max(x_ticks)) & ...
                (x_fit{file_counter}.values>min(x_ticks)));
            plot(x_fit{file_counter}.values(vi), ...
                y_fit{file_counter}.values(vi),'k-');
        end
    end
end

% Generate x_tick_labels
for i=1:length(x_ticks)
    if (x_ticks(i)==params.pCa90_replacement_value)
        x_tick_labels{i}='9.0';
    else
        x_tick_labels{i}=sprintf('%.1f',x_ticks(i));
    end
end

axes_data = improve_axes(...
    'x_ticks',x_ticks, ...
    'x_tick_label_positions',x_ticks, ...
    'x_tick_labels',x_tick_labels, ...
    'x_axis_label',params.x_axis_label, ...
    'y_axis_label',params.y_axis_label, ...
    'label_font_size',params.label_font_size, ...
    'tick_font_size',params.tick_font_size, ...
    'y_label_offset',params.y_label_offset, ...
    'y_axis_offset',-0.05, ...
    'y_tick_decimal_places',params.y_tick_decimal_places, ......
    'y_tick_labels',labels, ...
    'y_tick_label_positions',y_ticks,...
    'x_tick_length',0.03);

% Add in a break
xb=params.x_break_point+params.x_break_width*[1 -1];
yb_axis=params.x_break_rel_height*max_y_value*[-1 1];
yb_data=yb_axis+mean(pCa90_y_values);
% Draw over the axis
plot(params.x_break_point+[0 params.x_break_spacing], ...
    axes_data.x_axis_y_location*[1 1], ...
    'w-','LineWidth',axes_data.axis_line_width+1);
% Now draw lines
for i=1:2
    plot(xb,yb_axis + axes_data.x_axis_y_location, ...
            'k-','LineWidth',params.x_break_line_width);
    if (params.draw_data_break)
        plot(xb,yb_data, ...
            'k-','LineWidth',params.x_break_line_width);
    end
    xb=xb+params.x_break_spacing;
end
