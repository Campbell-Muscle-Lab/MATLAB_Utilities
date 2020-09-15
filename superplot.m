function out = superplot(params)

arguments
    params.data_table table;
    params.axis_handle = [];
    params.plot_variable = [];
    params.y_scaling_factor = 1;
    params.grouping_variable = [];
    params.design_type = 'one_way';
    params.factor_1 = [];
    params.factor_1_strings = [];
    params.tag_colors = [];
    params.raw_width = 0.5;
    params.raw_marker_size = 40;
    params.raw_face_alpha = 0.4;
    params.marker_symbols = {'s','o','^','v','d'};
    params.tag_index = [];
    params.y_axis_label = '';
    params.y_ticks = [];
    params.y_tick_decimal_places = 3;
    params.y_from_zero = 0;
    params.title = '';
    params.title_y_offset = 1.2;
end

if (~isempty(params.axis_handle))
    subplot(params.axis_handle);
else
    figure;
end
hold on;

% Code

if (strcmp(params.design_type, 'one_way'))
    if (isempty(params.factor_1_strings))
        params.factor_1_strings = unique( ...
            params.data_table.(params.factor_1));
    end
end

% Get the unique values of the grouping variable
unique_grouping_variables = unique(params.data_table. ...
    (params.grouping_variable));

if (isempty(params.tag_colors))
    params.tag_colors = paruly(numel(unique_grouping_variables));
end

if (isempty(params.tag_index))
    for i=1:numel(unique_grouping_variables)
        params.tag_index(i) = randi(numel(params.marker_symbols));
    end
end

% Correct data for scaling factor
params.data_table.(params.plot_variable) = ...
    params.y_scaling_factor * params.data_table.(params.plot_variable);

% Plot

for level_counter = 1:2
    x_c = 1;
    for i=1:numel(params.factor_1_strings)
        for tag_counter = 1:numel(unique_grouping_variables)

            vi = find( ...
                    strcmp(params.data_table.(params.factor_1), ...
                        params.factor_1_strings{i}) & ...
                    strcmp(params.data_table.(params.grouping_variable), ...
                        unique_grouping_variables{tag_counter}));
            x = x_c + params.raw_width * (rand(numel(vi),1)-0.5);
            y = params.data_table.(params.plot_variable)(vi);

            if (level_counter == 1)
                % Plot raw data
                scatter(x, y, params.raw_marker_size, ...
                    params.tag_colors(tag_counter,:), ...
                    'MarkerEdgeColor', params.tag_colors(tag_counter,:), ...
                    'Marker', params.marker_symbols{params.tag_index(tag_counter)}, ...
                    'MarkerFaceAlpha', params.raw_face_alpha);
            else
                % Plot mean data
                scatter(x_c + 0.3 * params.raw_width *(rand(1,1)-0.5), mean(y),3*params.raw_marker_size, ...
                    params.tag_colors(tag_counter,:), ...
                    'filled', ...
                    'Marker', params.marker_symbols{params.tag_index(tag_counter)}, ...
                    'MarkerFaceAlpha', 1, ...
                    'MarkerEdgeColor', 'k');
            end
        end

        x_c = x_c + 1;
    end
end

% Try to set plausible y axis limits
y_all = params.data_table.(params.plot_variable);

y_mag = ceil(max(log10(abs(y_all))));

if (params.y_from_zero ~= 1)
    y_ticks = [0  multiple_greater_than(max(y_all), 0.2*(10^y_mag))];
else
    y_ticks = [multiple_less_than(min(y_all), 0.05*(10^y_mag)) ...
                multiple_greater_than(max(y_all), 0.05*(10^y_mag))];
end

f1 = params.factor_1_strings;

% Set x labels
x_ticks = [0.5 1:(x_c-1) x_c-0.5];
x_tick_labels = repmat({''},[numel(x_ticks),1]);
for i=2:(numel(x_ticks)-1)
    x_tick_labels{i} = params.factor_1_strings{i-1};
end

improve_axes( ...
    'x_ticks', x_ticks, ...
    'x_tick_label_positions', x_ticks, ...
    'x_tick_labels', x_tick_labels, ...
    'x_axis_label', '', ...
    'y_ticks', y_ticks, ...
    'y_axis_label', params.y_axis_label, ...
    'y_tick_decimal_places', params.y_tick_decimal_places, ...
    'title', params.title, ...
    'title_y_offset', params.title_y_offset);

% Hold output
out.y_ticks = ylim;