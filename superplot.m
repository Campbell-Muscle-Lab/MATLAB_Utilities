function out = superplot(params)

arguments
    params.data_table table;
    params.axis_handle = [];
    params.plot_variable = [];
    params.y_scaling_factor = 1;
    params.grouping_variable = [];
    params.design_type = 'one_way';
    params.factor = [];
    params.factor_strings = [];
    params.factor_labels = [];
    params.factor_1 = [];
    params.factor_1_strings = [];
    params.factor_1_labels = [];
    params.factor_1_labels_y_offset = 0.45;
    params.factor_1_labels_fontsize = 11;
    params.factor_2 = [];
    params.factor_2_strings = [];
    params.factor_2_labels = [];
    params.factor_2_labels_y_offset = -0.07;
    params.factor_2_labels_fontsize = 11;
    params.tag_colors = [];
    params.row_colors = [];
    params.row_symbols = [];
    params.raw_width = 0.4;
    params.raw_marker_size = 40;
    params.raw_face_alpha = 0.4;
    params.raw_edge_color = 'k';
    params.marker_symbols = {'s','o','^','v','d','<','>'};
    params.y_axis_label = '';
    params.y_label_offset = -0.25;
    params.y_label_text_interpreter = 'tex';
    params.y_ticks = [];
    params.y_tick_label_positions = [];
    params.y_tick_labels = [];
    params.y_tick_decimal_places = 3;
    params.y_from_zero = 1;
    params.title = '';
    params.title_y_offset = 1.2;
    params.y_main_label_offset = 0.5;
    params.main_label_font_size = 12;
    params.link_line_width = 1.5
    params.x_tick_length = 0.05;
    params.x_end_cap = 0.5;
end

if (~isempty(params.axis_handle))
    subplot(params.axis_handle);
else
    figure;
end
hold on;

% Code

% Convert factors to strings if required

if ((~isempty(params.factor)) & ...
        (isnumeric(params.data_table.(params.factor))))
    for i=1:size(params.data_table,1)
        params.data_table.temp{i} = ...
            sprintf('%g', params.data_table.(params.factor)(i));
    end
    params.data_table.(params.factor_2) = params.data_table.temp;
    params.data_table.temp = [];
end

if ((~isempty(params.factor_2)) & ...
        (isnumeric(params.data_table.(params.factor_2))))
    for i=1:size(params.data_table,1)
        params.data_table.temp{i} = ...
            sprintf('%g', params.data_table.(params.factor_2)(i));
    end
    params.data_table.(params.factor_2) = params.data_table.temp;
    params.data_table.temp = [];
end

% Update the unique grouping values

if (strcmp(params.design_type, 'one_way'))
    if (isempty(params.factor_strings))
        params.factor_2 = params.factor;
        params.factor_2_strings = unique( ...
            params.data_table.(params.factor_2));
        params.factor_2_labels = params.factor_labels;
    end
    params.factor_1_strings = {''};
end

if (strcmp(params.design_type, 'two_way'))
    if (isempty(params.factor_1_strings))
        params.factor_1_strings = unique( ...
            params.data_table.(params.factor_1));
    end
    if (isempty(params.factor_2_strings))
        params.factor_2_strings = unique( ...
            params.data_table.(params.factor_2));
    end
end

% Update factor_2_labels
if (isempty(params.factor_2_labels))
    params.factor_2_labels = params.factor_2_strings;
end

% Get the unique values of the grouping variable
unique_grouping_variables = unique(params.data_table. ...
    (params.grouping_variable));

if (isempty(params.tag_colors))
    params.tag_colors = paruly(numel(unique_grouping_variables));
end

% Deduce the tag symbols
for i = 1 : numel(unique_grouping_variables)
    vi = mod(i, numel(params.marker_symbols));
    if (vi==0)
        vi = numel(params.marker_symbols);
    end
    tag_symbols{i} = params.marker_symbols{vi};
end

% Correct data for scaling factor
params.data_table.(params.plot_variable) = ...
    params.y_scaling_factor * params.data_table.(params.plot_variable);

% Plot

for level_counter = 1:2
    % First time around, plot all data with transparency
    % Second time around, plot mean data on top
    
    x_c = 1;
    x_tick_labels = [];
    x_tick_label_positions = [];
    
    % Loop through once if one-way design or for each factor_1_string
    for i = 1 : max([1 numel(params.factor_1_strings)])
        % Holders for joining linked means
        x_link = NaN*ones(numel(unique_grouping_variables), ...
                    numel(params.factor_2_strings));
        y_link = x_link;
        % loop through factor 2 strings
        for j=1:numel(params.factor_2_strings)
            for tag_counter = 1:numel(unique_grouping_variables)
                % Prune the table to the tag
                vi = find(strcmp(params.data_table.(params.grouping_variable), ...
                        unique_grouping_variables{tag_counter}));
                t_tag = params.data_table(vi, :);
                vi_colors = vi;
                
                % If it is 2-way design, prune to the first factor
                if (strcmp(params.design_type, 'two_way'))
                    vi = find(strcmp(t_tag.(params.factor_1), ...
                        params.factor_1_strings{i}));
                    t_tag = t_tag(vi,:);
                    vi_colors = vi_colors(vi);
                end
                
                % Now prune to the second factor
                vi = find(strcmp(t_tag.(params.factor_2), ...
                        params.factor_2_strings{j}));
                t_tag = t_tag(vi,:);
                vi_colors = vi_colors(vi);
                            
                if (isempty(t_tag))
                    continue
                end
                    
                x = x_c + params.raw_width * (rand(numel(vi),1)-0.5);
                y = t_tag.(params.plot_variable);
                
                % Deduce the colors
                if (isempty(params.row_colors))
                    colors = params.tag_colors(tag_counter,:);
                else
                    colors = params.row_colors(vi_colors,:);
                end
                
                % Deduce the symbols
                if (isempty(params.row_symbols))
                    if (isempty(params.factor_1))
                        symbols = tag_symbols(tag_counter);
                    else
                        symbols = tag_symbols(tag_counter,:);
                    end
                else
                    symbols = params.row_symbols(vi_colors,:);
                end
               
                if (level_counter == 1)
                    scatter(x, y, params.raw_marker_size, ...
                        colors, ...
                        'filled', ...
                        tag_symbols{tag_counter}, ...
                        'MarkerFaceAlpha', params.raw_face_alpha, ...
                        'MarkerEdgeColor', params.raw_edge_color, ...
                        'LineWidth', 0.1);
                else
                    % Plot mean data
                    x_plot = mean(x);
                    y_plot = mean(y);
                    scatter(x_plot, y_plot, 2.5*params.raw_marker_size, ...
                        colors(1,:), ...
                        'filled', ...
                        tag_symbols{tag_counter}, ...
                        'MarkerFaceAlpha', 1, ...
                        'MarkerEdgeColor', 'k');
                    % Update holders
                    x_link(tag_counter,j) = x_plot;
                    y_link(tag_counter,j) = y_plot;
                end
            end

            switch (params.design_type)
                case 'one_way'
                    x_tick_labels = [x_tick_labels {params.factor_2_labels{j}}];
                    x_tick_label_positions = [x_tick_label_positions x_c];
                case 'two_way'
                    x_tick_labels = [x_tick_labels {params.factor_2_labels{j}}];
                    x_tick_label_positions = [x_tick_label_positions x_c];
            end

            if (j <= numel(params.factor_2_strings))
                x_c = x_c + 1;
            end
        end
                    
        for k=1:numel(unique_grouping_variables)
            plot(x_link(k,:),y_link(k,:),'k-', ...
                'LineWidth', params.link_line_width);
        end
        
        if (i < numel(params.factor_1_strings))
            x_c = x_c + 1;
        end
    end
end

% Try to set plausible y axis limits
y_all = params.data_table.(params.plot_variable);

y_mag = ceil(max(log10(abs(y_all))));

if (isempty(params.y_ticks))
    if (params.y_from_zero == 1)
        params.y_ticks = [0  multiple_greater_than(max(y_all), 0.2*(10^y_mag))];
    else
        params.y_ticks = [multiple_less_than(min(y_all), 0.02*(10^y_mag)) ...
                    multiple_greater_than(max(y_all), 0.02*(10^y_mag))];
    end
end

% Set x labels
x_ticks = [params.x_end_cap 1:x_c x_c-params.x_end_cap];

ax_out = improve_axes( ...
    'x_ticks', x_ticks, ...
    'omit_x_tick_labels', 1, ...
    'x_tick_length', 0, ...
    'x_axis_label', '', ...
    'y_ticks', params.y_ticks, ...
    'y_tick_label_positions', params.y_tick_label_positions, ...
    'y_tick_labels', params.y_tick_labels, ...
    'y_axis_label', params.y_axis_label, ...
    'y_label_offset', params.y_label_offset, ...
    'y_label_text_interpreter', params.y_label_text_interpreter, ...
    'y_tick_decimal_places', params.y_tick_decimal_places, ...
    'title', params.title, ...
    'title_y_offset', params.title_y_offset);

% Add in factor_2
for i = 1 : numel(x_tick_labels)
    plot(x_tick_label_positions(i)*[1 1], ...
        ax_out.bottom + [0 -params.x_tick_length * ...
            (ax_out.y_ticks(end) - ax_out.y_ticks(1))], ...
        'k-', 'LineWidth', ax_out.axis_line_width, ...
        'Clipping', 'off');
    text(x_tick_label_positions(i), ...
        ax_out.bottom + params.factor_2_labels_y_offset * ...
            (ax_out.y_ticks(end) - ax_out.y_ticks(1)), ...
        x_tick_labels{i}, ...
        'Rotation', 45, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', params.factor_2_labels_fontsize);
end

% Add in main level
if (isempty(params.factor_1_labels))
    params.factor_1_labels = params.factor_1_strings;
end

if (strcmp(params.design_type, 'two_way'))
    for i=1:numel(params.factor_1_strings)
        x = mean([1 numel(params.factor_2_strings)]) + ...
                ((i-1)*(numel(params.factor_2_strings)+1));
            
        text(x, (params.y_ticks(1) - params.factor_1_labels_y_offset * ...
                (params.y_ticks(end) - params.y_ticks(1))), ...
            params.factor_1_labels{i}, ...
            'FontSize', params.factor_1_labels_fontsize, ...
            'Interpreter', 'none', ...
            'HorizontalAlignment','center');
    end
end


% Hold output
out.y_ticks = ylim;