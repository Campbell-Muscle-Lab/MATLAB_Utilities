function out = jitter_plot(varargin)

params.data=[];
params.spread_width=0.7;
params.bar_names=[];
params.group_names=[];
params.sub_names=[];
params.group_spacing=1;
params.y_axis_label='';
params.y_label_font_size=12;
params.y_label_text_interpreter='tex';
params.y_tick_decimal_places=[];
params.symbols={'o','s','d'};
params.symbols_over_rides=[];
params.marker_edge_colors=zeros(5,3);
params.marker_face_colors=[0 0 1;1 0 0;0 1 0];
params.marker_line_width=1;
params.marker_size=8;
params.marker_transparency = [];
params.x_axis_end_padding=0.5;
params.y_sub_label_offset=0.01;
params.x_sub_label_offset = [];
params.y_main_label_offset=0.2;
params.font_name='Arial';
params.mean_line_breadth=0.7;
params.mean_line_width=2;
params.mean_line_color=[0 0 0];
params.mean_line_front=0;
params.sub_font_size=10;
params.sub_font_rotation=45;
params.sub_font_horizontal_alignment='right';
params.sub_font_interpreter='none';
params.main_font_size=12;
params.main_font_rotation=0;
params.main_font_interpreter='none';
params.y_label_offset=-0.025;
params.title='';
params.title_text_interpreter='none';
params.title_x_offset=NaN; % NaN is center, number defines placement
params.title_y_offset=1.1;
params.title_v_Align='middle';
params.title_h_Align='center';
params.title_font_size=12;
params.y_ticks=[];
params.y_tick_labels=[];
params.y_tick_label_positions=[];
params.y_tick_label_horizontal_offset=-0.04;
params.y_tick_length=0.025;
params.y_axis_offset=0.025;
params.tick_font_size=12;
params.n_y_bins=20;
params.max_n_per_row=5;
params.y_from_zero=1;
params.join_linked_points=0;
params.link_line_width=1;
params.link_line_color=0.5*[1 1 1];
params.link_line_front=0;
params.link_line_style='-';
params.face_color_over_rides=[];
params.sub_name_over_rides = [];
params.y_label_rotation=0;
params.x_axis_off = 0;

% Update
params=parse_pv_pairs(params,varargin);

% Check
if (isempty(params.sub_names))
    temp=params.data(1);
    params.sub_names=repmat({''},[1 numel(temp.points)]);
end
if (isempty(params.group_names))
    params.group_names=repmat({''},[1 numel(params.data)]);
end

% Rename for simplicity
d=params.data;

% Find out how many groups there are
% Find how many groups there are
no_of_main_groups=length(d);
no_of_sub_groups=[];
for group_counter=1:no_of_main_groups
    p=d(group_counter).points;
    no_of_sub_groups=[no_of_sub_groups length(p)];
end

% Some error checking
[no_of_marker_face_colors,~]=size(params.marker_face_colors);
if (max(no_of_sub_groups)>no_of_marker_face_colors)
    params.marker_face_colors=jet(max(no_of_sub_groups));
end

[no_of_marker_edge_colors,~]=size(params.marker_edge_colors);
if (max(no_of_sub_groups)>no_of_marker_edge_colors)
    params.marker_edge_colors=zeros(max(no_of_sub_groups),3);
end

no_of_symbols=numel(params.symbols);
if (max(no_of_sub_groups)>no_of_symbols)
    params.symbols=repmat({'o'},[1 max(no_of_sub_groups)]);
end

% Deduce x axis length
x_axis_length=(2*params.x_axis_end_padding) + ...
    (no_of_main_groups-1)*params.group_spacing + ...
    sum(no_of_sub_groups);

if (isempty(params.y_ticks))
    % Deduce the y-axis length by extracting the y data, 
    % plotting it and getting the y lim
    % Note that the plot is invisible
    y_data=[];
    for main_counter=1:no_of_main_groups
        for sub_counter=1:no_of_sub_groups(main_counter)
            y_temp=d(main_counter).points{sub_counter};
            [rows,cols]=size(y_temp);
            if (cols>rows)
                y_temp=y_temp';
            end
            y_data=[y_data ; y_temp];
        end
    end
    x_temp=ones(length(y_data),1);
    plot(x_temp,y_data,'Marker','none','LineStyle','none');
    y_limits=ylim;
    if (params.y_from_zero==1)
        if (y_limits(2)<=0)
            params.y_ticks = [y_limits(1) 0];
        else
            params.y_ticks=[0 y_limits(2)];
        end
    else
        params.y_ticks=[y_limits(1) y_limits(2)];
    end
end

% Clear the axis and set the scales
xlim([0 x_axis_length]);
ylim([params.y_ticks(1) params.y_ticks(end)]);
hold on;
set(gca,'XLimMode','manual');

% Loop through data plotting as we go
y_bins=linspace(params.y_ticks(1),params.y_ticks(end), ...
    params.n_y_bins+1);
x_holder=1;
for main_counter=1:no_of_main_groups
    
    % First deduce the size of the matrix to hold the points
    max_points=0;
    for sub_counter=1:no_of_sub_groups(main_counter)
        yy=d(main_counter).points{sub_counter};
        [rows,cols]=size(d(main_counter).points{sub_counter});
        max_points=max([max_points rows cols]);
    end
    
    % Set arrays to hold the plotted points
    x_link=NaN*ones(max_points,no_of_sub_groups(main_counter));
    y_link=x_link;
    
    % Set arrays to hold the means
    x_mean=[];
    y_mean=[];
    
    for sub_counter=1:no_of_sub_groups(main_counter)
        y_plot=d(main_counter).points{sub_counter};
        % Flip if necesary
        [rows,cols]=size(y_plot);
        if (rows<cols)
            y_plot=y_plot';
        end
        x_plot=NaN*ones(length(y_plot),1);
        plot_order=[];
        for bin_counter=1:params.n_y_bins
            vi=find((y_plot>(y_bins(bin_counter)-eps))& ...
                (y_plot<=y_bins(bin_counter+1)));
            if (~isempty(vi))
                % Spread the x_values
                x_spread=linspace(0, ...
                    (min([params.max_n_per_row,length(vi)])/ ...
                            params.max_n_per_row)* ...
                        params.spread_width,length(vi));
                x_spread=x_holder+x_spread-mean(x_spread);
                x_plot(vi)=x_spread;
            end
        end
        
        % Deduce the marker face color
        if (isempty(params.face_color_over_rides))
            marker_face_color = params.marker_face_colors(sub_counter,:);
        else
            marker_face_color = cell2mat( ...
                params.face_color_over_rides(main_counter,sub_counter));
        end
        
        % Deduce the marker symbols
        if (isempty(params.symbols_over_rides))
            symbols = params.symbols{sub_counter};
        else
            symbols = cell2mat( ...
                params.symbols_over_rides(main_counter,sub_counter));
        end

        if (isempty(params.marker_transparency))

            % Plot markers in two steps to ensure that we can see
            % overlapping symbols

            % Plot fill but not edges
            to_front(main_counter).faces{sub_counter}=plot(x_plot,y_plot, ...
                'Marker',symbols, ...
                'MarkerFaceColor',marker_face_color, ...
                'MarkerEdgeColor',params.marker_edge_colors(sub_counter,:), ...
                'MarkerSize',params.marker_size, ...
                'LineStyle','none');

            % Plot edges with no fill
            to_front(main_counter).edges{sub_counter}=plot(x_plot,y_plot, ...
                'Marker',symbols, ...
                'MarkerEdgeColor',params.marker_edge_colors(sub_counter,:), ...
                'MarkerSize',params.marker_size, ...
                'LineWidth',params.marker_line_width, ...
                'LineStyle','none');
            
        else
            scatter(x_plot,y_plot, ...
                'Marker',symbols, ...
                'MarkerEdgeColor',params.marker_edge_colors(sub_counter,:), ...
                'MarkerFaceColor',marker_face_color, ...
                'MarkerFaceAlpha',params.marker_transparency, ...
                'SizeData',params.marker_size);
        end

        
        % Hold x and y coordinates in case we want to link points
        x_link(1:length(x_plot),sub_counter)=x_plot;
        y_link(1:length(y_plot),sub_counter)=y_plot;
        
        % Hold mean_values
        x_mean=[x_mean x_holder];
        y_mean=[y_mean mean(y_plot(~isnan(y_plot)))];
        
        % Advance to the next group
        x_holder=x_holder+1;
    end
    % Advance to the next group

    % Draw links
    if (params.join_linked_points)
        [no_of_points,~]=size(x_link);
        for sub_counter=1:(no_of_sub_groups(main_counter)-1)
            for i=1:no_of_points
                xx=x_link(i,sub_counter+[0 1]);
                yy=y_link(i,sub_counter+[0 1]);
                if (all(~isnan(xx)))
                    if (all(~isnan(yy)))
                        plot(xx,yy, ...
                            'LineWidth',params.link_line_width, ...
                            'Color',params.link_line_color, ...
                            'LineStyle',params.link_line_style);
                    end
                end
            end
        end
    end
    
    % Draw mean lines
    if (params.mean_line_width>0)
        for i=1:no_of_sub_groups(main_counter)
            mean_lines_front(main_counter).other{i}=plot(x_mean(i)+params.mean_line_breadth*[-0.5 0.5], ...
                    y_mean(i)*[1 1],'-', ...
                    'Color',params.mean_line_color, ...
                    'LineWidth',params.mean_line_width);
        end
    end

    % Advance to the next group

    if (main_counter<no_of_main_groups)
        x_holder=x_holder+params.group_spacing;
    end
   
end

% % Charles added ui links to change order of plots.
% if (~params.link_line_front)
%     for main_counter=1:no_of_main_groups
%         for sub_counter=1:no_of_sub_groups(main_counter)
%             uistack(to_front(main_counter).faces{sub_counter},'top');
%             uistack(to_front(main_counter).edges{sub_counter},'top');
%         end
%     end
% end

if (params.mean_line_front)
    % brings mean line to the front
    for main_counter=1:no_of_main_groups
        for i=1:no_of_sub_groups(main_counter)
            uistack(mean_lines_front(main_counter).other{i},'top');
        end
    end
end

% Display
x_axis_ticks = [0.5-params.x_axis_end_padding ...
            x_holder+params.x_axis_end_padding-0.5];
improve_axes( ...
    'x_ticks', x_axis_ticks, ...
    'x_axis_label','', ...
    'x_axis_offset',0, ...
    'x_tick_length',0, ...
    'x_tick_label_positions',1, ...
    'x_tick_labels',{''}, ...
    'x_axis_off',params.x_axis_off, ...
    'y_ticks',params.y_ticks, ...
    'y_tick_labels',params.y_tick_labels, ...
    'y_tick_label_positions',params.y_tick_label_positions, ...
    'y_axis_label',params.y_axis_label, ...
    'y_label_text_interpreter',params.y_label_text_interpreter, ...
    'y_tick_decimal_places',params.y_tick_decimal_places, ...
    'y_label_offset',params.y_label_offset, ...
    'y_label_rotation',params.y_label_rotation, ...
    'y_axis_offset',params.y_axis_offset, ...
    'title',params.title, ...
    'title_x_offset',params.title_x_offset, ...
    'title_y_offset',params.title_y_offset, ...
    'title_v_Align',params.title_v_Align, ...
    'title_h_Align',params.title_h_Align, ...
    'title_font_size',params.title_font_size, ...
    'tick_font_size',params.tick_font_size, ...
    'label_font_size',params.y_label_font_size, ...
    'title_text_interpreter',params.title_text_interpreter, ...
    'y_tick_length',params.y_tick_length, ...
    'y_tick_label_horizontal_offset',params.y_tick_label_horizontal_offset);


% Add labels
y_limits=ylim;
x_holder=1;
if (~params.x_axis_off)
    for main_counter=1:no_of_main_groups
        x_start_index=x_holder;
        for sub_counter=1:no_of_sub_groups(main_counter)

            if (isempty(params.sub_name_over_rides))
                sub_name = params.sub_names{sub_counter};
            else
                sub_name = params.sub_name_over_rides{main_counter,sub_counter};
            end
            
            if (isempty(params.x_sub_label_offset))
                x_adjust = 0;
            else
                x_adjust = params.x_sub_label_offset(sub_counter);
            end

            text(x_holder + x_adjust, ...
                y_limits(1)-params.y_sub_label_offset*diff(y_limits), ...
                sub_name, ...
                'FontName',params.font_name, ...
                'FontSize',params.sub_font_size, ...
                'Rotation',params.sub_font_rotation, ...
                'HorizontalAlignment',params.sub_font_horizontal_alignment, ...
                'VerticalAlignment','top', ...
                'Interpreter',params.sub_font_interpreter);
            x_holder=x_holder+1;
        end
        x_stop_index=x_holder-1;
        x_holder=x_holder+params.group_spacing;

        % Main group label
        text(mean([x_start_index x_stop_index]), ...
            y_limits(1)-params.y_main_label_offset*diff(y_limits), ...
            params.group_names{main_counter}, ...
            'FontName',params.font_name, ...
            'FontSize',params.main_font_size, ...
            'Rotation',params.main_font_rotation, ...
            'Interpreter',params.main_font_interpreter, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','top');
    end
else
    plot(x_axis_ticks, [0 0], 'LineWidth', 1.5);
end

% Return data
out.y_ticks = params.y_ticks;