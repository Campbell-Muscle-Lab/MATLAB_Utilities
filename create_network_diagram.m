function create_network_diagram(varargin)
% Code takes an interaction structure and creates a network diagram

% Variables
params.figure_number=[];
params.interaction_structure=[];
params.level = [];
params.r_n=0.75;
params.delta_angle=3*pi/11;
params.line_color_map = [];
params.fixed_lines = 0;
params.line_width = 1;
params.font_size = 10;
params.box_color = [0 0 0];
params.background_color = [1 1 1];
params.group_numbers = [];
params.title_string = '';
params.title_font_size = 12;
params.title_font_weight = 'normal';
params.x_limits = [];
params.y_limits = [];

% Update
params=parse_pv_pairs(params,varargin);

% Code
if (isempty(params.x_limits))
    params.x_limits = [-1.2 1.2];
end
if (isempty(params.y_limits))
    params.y_limits = [-1.2 1.5];
end

% Take the interaction_matrix and compress it to 2D
% This process lumps all activities together
matrix = params.interaction_structure.matrix;
if (isempty(params.level))
    matrix = sum(matrix,3);
else
    matrix = matrix(:,:,params.level);
end

% Find the people
people = params.interaction_structure.people;
no_of_people = numel(people);

% Calculate the total number of interactions for each person
person_interactions = sum(matrix,2);

% Sort by the number of interactions for each person
[person_interactions,sort_order] = sort(person_interactions,'descend');

% Reorder matrix and people
matrix = matrix(sort_order,sort_order);
people = people(sort_order);

% Calculate the x y coordinate for each person
% Radius scales to the power r_n with person interactions
% Angle increases by delta_angle for each person
for i=1:no_of_people
    radius(i) = ((person_interactions(1)-person_interactions(i))/ ...
                    person_interactions(1))^params.r_n;
    theta(i) = i * params.delta_angle;
    xy(i,:) = radius(i).*[cos(theta(i)) sin(theta(i))];
end

% Create a figure
if (isempty(params.figure_number))
    f = figure;
else
    figure(params.figure_number);
end
clf;
subplots=initialise_publication_quality_figure( ...
    'no_of_panels_wide',1, ...
    'no_of_panels_high',1, ...
    'top_margin',0, ...
    'bottom_margin',0, ...
    'axes_padding_top',0.0, ...
    'axes_padding_bottom',0.0, ...
    'left_margin',0.5, ...
    'right_margin',2.5, ...
    'x_to_y_axes_ratio',1, ...
    'axes_padding_left',0.1, ...
    'axes_padding_right',0.1, ...
    'panel_label_font_size',0);

% Draw the lines

% First set the colors
if (isempty(params.line_color_map))
    cm=jet(max(matrix(:)));
else
    cm=params.line_color_map;
end
if (params.fixed_lines)
    cm = repmat([0 0 1],[max(matrix(:)) 1]);
end

% Now draw the lines for the top half of the matrix
hold on;
for i=1:no_of_people
    for j=1:no_of_people
        if (matrix(i,j)>0)
            if (params.fixed_lines)
                lw = params.line_width;
            else
                lw = matrix(i,j)*params.line_width;
            end
            plot([xy(i,1) xy(j,1)],[xy(i,2) xy(j,2)], ...
                '-', ...
                'Color',cm(matrix(i,j),:), ...
                'LineWidth',lw);
        end
    end
end

% Now add in the people
if (isempty(params.group_numbers))
    params.group_numbers = ones(no_of_people,1);
end
params.group_numbers = params.group_numbers(sort_order);
gn = params.group_numbers
p = people

for i=1:no_of_people
    text(xy(i,1),xy(i,2),people{i}, ...
        'FontSize',params.font_size, ...
        'LineWidth',1.0, ...
        'EdgeColor',params.box_color, ...
        'BackgroundColor',params.background_color( ...
            params.group_numbers(i),:), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle');
end

% Limit axes
xlim(params.x_limits);
ylim(params.y_limits);
axis('off');

text(0,params.y_limits(end),params.title_string, ...
    'FontSize',params.title_font_size, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','top', ...
    'FontWeight',params.title_font_weight);






