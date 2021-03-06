function out = bar_chart(varargin)

params.data=[];
params.width=1;
params.bar_names=[];
params.group_names=[];
params.sub_names=[];
params.group_spacing=1;
params.y_axis_label='';
params.y_label_font_size=12;
params.y_tick_decimal_places=0;
params.y_tick_labels=[];
params.y_tick_label_positions=[];
params.y_tick_label_horizontal_offset=-0.04;
params.y_tick_length=0.025;
params.bar_colors=[];
params.line_width=1;
params.error_bar_width=0.5;
params.x_axis_end_padding=0.5;
params.y_sub_label_offset=0.01;
params.y_main_label_offset=0.2;
params.x_sub_label_offset=0;
params.y_axis_off=0;
params.font_name='Helvetica';
params.sub_font_size=10;
params.sub_font_rotation=45;
params.sub_font_interpreter='tex';
params.main_font_size=12;
params.main_font_rotation=0;
params.y_label_offset=-0.025;
params.title='';
params.title_x_offset=NaN;
params.title_y_offset=1.1;
params.title_v_Align='middle';
params.title_h_Align='center';
params.title_text_interpreter='none';
params.title_font_size=12;
params.y_ticks=[];
params.tick_font_size=12;
params.color_over_rides=[];
params.bars_from_zero=0;
params.transparency = 0;
params.error_mode='sem';

% Update
params=parse_pv_pairs(params,varargin);

% Rename for simplicity
d=params.data;

% Bars are centered on integers and
% separated by params.group_spacing
x_patch=((params.width)/2)*[-1 -1 1 1];
y_patch=[0 1 1 0];

% Find how many groups there are
no_of_main_groups=numel(params.data);
max_sub_groups=0;
for group_counter=1:no_of_main_groups
    if (isfield(d,'values'))
        n=numel(d(group_counter).values);
    else
        n=numel(d(group_counter).points);
    end
    max_sub_groups=max([n max_sub_groups]);
end

% Use bar data with points
if (isfield(d,'points'))
    for main_counter=1:no_of_main_groups
        for sub_counter=1:max_sub_groups
            [m,sd,sem,n]=mean_sd_sem_and_n( ...
                cell2mat(d(main_counter).points(sub_counter)));
            d(main_counter).values(sub_counter)=m;
            if (strcmp(params.error_mode,'sem'))
                d(main_counter).error_values(sub_counter)=sem;
            else
                d(main_counter).error_values(sub_counter)=sd;
            end
        end
    end
end
   
% Loop through the main groups
x_holder=1;
for main_counter=1:no_of_main_groups
    
    y_data=d(main_counter).values;
    y_error=d(main_counter).error_values;
 
    for sub_counter=1:length(y_data)
        if ((isempty(params.y_ticks))||(params.bars_from_zero))
            patch(x_holder+x_patch, ...
                y_data(sub_counter)*y_patch, ...
                return_bar_color(main_counter,sub_counter), ...
                'LineWidth',params.line_width, ...
                'FaceAlpha',params.transparency);
        else
            patch(x_holder+x_patch, ...
                [params.y_ticks(1) y_data(sub_counter)*[1 1], ...
                    params.y_ticks(1)], ...
                return_bar_color(main_counter,sub_counter), ...
                'LineWidth',params.line_width, ...
                'FaceAlpha',params.transparency);
        end

        % Draw error_bar
        if (y_error(sub_counter)~=0)
            line(x_holder*[1 1], ...
                y_data(sub_counter)+[0 y_error(sub_counter)], ...
                'Color','k', ...
                'LineWidth',params.line_width);
            line(x_holder+(0.5*params.error_bar_width)*[-1 1], ...
                y_data(sub_counter)+y_error(sub_counter)*[1 1], ...
                'Color','k', ...
                'LineWidth',params.line_width);
        end
        
        x_holder=x_holder+1;
    end
    
    if (main_counter<no_of_main_groups)
        x_holder=x_holder+params.group_spacing;
    end
end

% Display
improve_axes( ...
    'x_ticks', ...
        [0.5-params.x_axis_end_padding ...
            x_holder-0.5+params.x_axis_end_padding], ...
    'x_axis_label','', ...
    'x_axis_offset',0, ...
    'x_tick_length',0, ...
    'omit_x_tick_labels',1, ...
    'y_ticks',params.y_ticks, ...
    'y_tick_labels',params.y_tick_labels, ...
    'y_tick_label_positions',params.y_tick_label_positions, ...
    'y_axis_label',params.y_axis_label, ...
    'y_tick_decimal_places',params.y_tick_decimal_places, ...
    'y_label_offset',params.y_label_offset, ...
    'title',params.title, ...
    'title_x_offset',params.title_x_offset, ...
    'title_y_offset',params.title_y_offset, ...
    'title_v_Align',params.title_v_Align, ...
    'title_h_Align',params.title_h_Align, ...
    'title_font_size',params.title_font_size, ...
    'title_text_interpreter',params.title_text_interpreter, ...
    'tick_font_size',params.tick_font_size, ...
    'label_font_size',params.y_label_font_size, ...
    'y_axis_off',params.y_axis_off, ...
    'y_tick_length',params.y_tick_length, ...
    'y_tick_label_horizontal_offset',params.y_tick_label_horizontal_offset);

% Add labels
y_limits=ylim;
x_holder=1;
for main_counter=1:no_of_main_groups
    y_data=d(main_counter).values;
    x_start_index=x_holder;
    for sub_counter=1:length(y_data)
        if (~isempty(params.sub_names))
            switch params.sub_font_rotation
                case 90
                    horizontal_alignment='right';
                    vertical_alignment='middle';
                case 0
                    horizontal_alignment='center';
                    vertical_alignment='top';
                otherwise
                    horizontal_alignment='right';
                    vertical_alignment='top';
            end
               
            text(x_holder+params.x_sub_label_offset, ...
                y_limits(1)-params.y_sub_label_offset*diff(y_limits), ...
                params.sub_names{sub_counter}, ...
                'FontName',params.font_name, ...
                'FontSize',params.sub_font_size, ...
                'Rotation',params.sub_font_rotation, ...
                'HorizontalAlignment',horizontal_alignment, ...
                'VerticalAlignment',vertical_alignment, ...
                'Interpreter',params.sub_font_interpreter);
        end
        x_holder=x_holder+1;
    end
    x_stop_index=x_holder-1;
    x_holder=x_holder+params.group_spacing;
    
    
    if (~isempty(params.group_names))
        % Main group label
        text(mean([x_start_index x_stop_index]), ...
            y_limits(1)-params.y_main_label_offset*diff(y_limits), ...
            params.group_names{main_counter}, ...
           'FontName',params.font_name, ...
           'FontSize',params.main_font_size, ...
            'Rotation',params.main_font_rotation, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','top');
    end        
end

% Return data
out.y_ticks = params.y_ticks;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nested function

    function bar_color=return_bar_color(main_index,sub_index)
        if (isempty(params.color_over_rides))
            % Generate colors if necessary
            if (isempty(params.bar_colors))
                if (max_sub_groups>1)
                    bar_color = ((sub_index-1)/(max_sub_groups-1))* ...
                        ones(1,3);
                else
                    bar_color=0.7*ones(1,3);
                end
            else
                a = params.bar_colors
                bar_color=params.bar_colors(sub_index,1:3);
            end
        else
            bar_color=cell2mat(params.color_over_rides(...
                main_index,sub_index))
        end
    end

end