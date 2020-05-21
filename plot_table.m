function plot_table(varargin)

p = inputParser;
addOptional(p,'x',[]);
addOptional(p,'y',[]);
addOptional(p,'text_strings',[]);
addOptional(p,'marker_symbols',[]);
addOptional(p,'marker_face_colors',[]);
addOptional(p,'marker_edge_colors',[]);
addOptional(p,'marker_transparency',[]);
addOptional(p,'marker_sizes',[]);
addOptional(p,'line_handles',[]);
addOptional(p,'line_lengths',[]);
addOptional(p,'horizontal_alignment','center');
addOptional(p,'vertical_alignment','middle');
addOptional(p,'font_size',10);
addOptional(p,'text_v_offset',-0.04);
addOptional(p,'border_color',[]);
addOptional(p,'border_dx',zeros(1,2));
addOptional(p,'border_dy',zeros(1,2));
addOptional(p,'border_width',1);

parse(p,varargin{:});
p = p.Results;

% Defaults
if (isempty(p.marker_edge_colors))
    [r,c,~]=size(p.marker_face_colors);
    p.marker_edge_colors = zeros(r,c,3);
end

% Code
c = numel(p.x);
r = numel(p.y);

% Generate defaults
if (isempty(p.text_strings))
    for i=1:r
        for j=1:c
            p.text_strings{i,j}='';
        end
    end
end
if (isempty(p.marker_symbols))
    for i=1:r
        for j=1:c
            p.marker_symbols{i,j}='';
        end
    end
end

for i=1:r
    for j=1:c
        if (~isempty(p.text_strings{i,j}))
            temp_string = p.text_strings{i,j};
            vi = regexp(temp_string,'_');
            if (~isempty(vi)>0)
                v_offset = p.text_v_offset;
            else
                v_offset = 0;
            end
            text(p.x(j),p.y(i)*(1+v_offset),temp_string, ...
                'HorizontalAlignment',p.horizontal_alignment, ...
                'VerticalAlignment',p.vertical_alignment, ...
                'FontSize',p.font_size);
        end
        if (~isempty(p.marker_symbols{i,j}))
            if (isempty(p.marker_transparency))
                plot(p.x(j),p.y(i),p.marker_symbols{i,j}, ...
                    'MarkerFaceColor',squeeze(p.marker_face_colors(i,j,:))', ...
                    'MarkerSize',p.marker_sizes(i,j), ...
                    'MarkerEdgeColor',squeeze(p.marker_edge_colors(i,j,:))');
            else
                scatter(p.x(j),p.y(i),p.marker_symbols{i,j}, ...
                    'MarkerFaceColor',squeeze(p.marker_face_colors(i,j,:))', ...
                    'MarkerEdgeColor',squeeze(p.marker_edge_colors(i,j,:))', ...
                    'SizeData',p.marker_sizes(i,j), ...
                    'MarkerFaceAlpha',p.marker_transparency);
            end
        end
        if (ishandle(p.line_handles(i,j)))
            plot(p.x(j)+p.line_lengths(j,i)*[-0.5 0.5], p.y(i)*[1 1], ...
                'LineStyle', p.line_handles(i,j).LineStyle, ...
                'LineWidth', p.line_handles(i,j).LineWidth, ...
                'Color', p.line_handles(i,j).Color);
        end
    end
end

if (~isempty(p.border_color))
    x = [p.x(1) p.x(1) p.x(end) p.x(end) p.x(1)] + ...
            [p.border_dx(1) p.border_dx(1) p.border_dx(2) p.border_dx(2) p.border_dx(1)];
    y = [p.y(1) p.y(end) p.y(end) p.y(1) p.y(1)] + ...
            [p.border_dy(1) p.border_dy(2) p.border_dy(2) p.border_dy(1) p.border_dy(1)];
    plot(x,y,'-', ...
        'Color',p.border_color, ...
        'LineWidth',p.border_width);
end
    



