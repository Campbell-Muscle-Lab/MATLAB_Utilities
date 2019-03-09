function hh = kens_errorbar(varargin)

% Check and set input arguments
default_symbol='ko';
default_marker_size=6;
default_marker_line_width=1.0;

no_of_arguments=length(varargin);

switch no_of_arguments
    case {1}
        error('Invalid number (%i) of arguments for kens_errorbar. At least 4 are required',no_of_arguments);
    case {2}
        error('Invalid number (%i) of arguments for kens_errorbar. At least 4 are required',no_of_arguments);
    case {3}
        error('Invalid number (%i) of arguments for kens_errorbar. At least 4 are required',no_of_arguments);
    case {4}
        x=varargin{1}(:);
        y=varargin{2}(:);
        xe=varargin{3}(:);
        ye=varargin{4}(:);
        symbol=default_symbol;
        marker_size=default_marker_size;
        marker_line_width=default_marker_line_width
    case {5}
        x=varargin{1}(:);
        y=varargin{2}(:);
        xe=varargin{3}(:);
        ye=varargin{4}(:);
        symbol=varargin{5}(:);
        marker_size=default_marker_size;
        marker_line_width=default_marker_line_width;
    case {6}
        x=varargin{1}(:);
        y=varargin{2}(:);
        xe=varargin{3}(:);
        ye=varargin{4}(:);
        symbol=varargin{5}(:);
        marker_size=varargin{6}(:);
        marker_line_width=default_marker_line_width;
    case {7}
        x=varargin{1}(:);
        y=varargin{2}(:);
        xe=varargin{3}(:);
        ye=varargin{4}(:);
        symbol=varargin{5}(:);
        marker_size=varargin{6}(:);
        marker_line_width=varargin{7}(:);
    otherwise
        error('Invalid number (%i) of arguments for kens_errorbar. At least 4 are required',no_of_arguments);
end
  
hold_state=ishold;
hold on;

% Relative distance from center of data point
% to start drawing the error line
marker_safety_factor=1.3;


h=plot(x,y,symbol,'MarkerSize',marker_size,'LineWidth',marker_line_width);
x_limits=xlim;
y_limits=ylim;

marker_size=get(h,'MarkerSize');
set(gca,'Units','Points');
[temp]=get(gca,'Position');
x_axis_points=temp(3);
y_axis_points=temp(4);

[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end

for point_counter=1:length(x)
    y_marker_equivalent_size=(y_limits(2)-y_limits(1))* ...
        (marker_size/y_axis_points);
    if (ye(point_counter) > marker_safety_factor*y_marker_equivalent_size/2)
        % Draw y error bars if they are larger than the symbol

        % Error line
        plot([x(point_counter) x(point_counter)], ...
            [y(point_counter)-ye(point_counter) ...
                y(point_counter)-marker_safety_factor*y_marker_equivalent_size/2], ...
            [col '-'],'LineWidth',1,'Clipping','off');
        plot([x(point_counter) x(point_counter)], ...
            [y(point_counter)+marker_safety_factor*y_marker_equivalent_size/2 ...
                y(point_counter)+ye(point_counter)], ...
            [col '-'],'LineWidth',1,'Clipping','off');
        % Bars
        y_bar_length=(x_limits(2)-x_limits(1))* ...
            (marker_size/x_axis_points);
        plot([x(point_counter)-y_bar_length/2 ...
                x(point_counter)+y_bar_length/2], ...
            [y(point_counter)+ye(point_counter) ...
                y(point_counter)+ye(point_counter)], ...
            [col '-'],'LineWidth',1,'Clipping','off');
        plot([x(point_counter)-y_bar_length/2 ...
                x(point_counter)+y_bar_length/2], ...
            [y(point_counter)-ye(point_counter) ...
                y(point_counter)-ye(point_counter)], ...
            [col '-'],'LineWidth',1,'Clipping','off');
    end
    
    x_marker_equivalent_size=(x_limits(2)-x_limits(1))* ...
        (marker_size/x_axis_points);
    if (xe(point_counter) > marker_safety_factor*x_marker_equivalent_size/2)
	  % Draw x error bars if they are larger than the symbol
        % Error line as two parts
        plot([x(point_counter)-xe(point_counter) ...
                x(point_counter)-marker_safety_factor*x_marker_equivalent_size/2], ...
            [y(point_counter) y(point_counter)], ...
            [col '-'],'LineWidth',1,'Clipping','off');
        plot([x(point_counter)+marker_safety_factor*x_marker_equivalent_size/2 ...
                x(point_counter)+xe(point_counter)], ...
            [y(point_counter) y(point_counter)], ...
            [col '-'],'LineWidth',1,'Clipping','off');

        % Bars
        x_bar_length=(y_limits(2)-y_limits(1))* ...
            (marker_size/y_axis_points);
        plot([x(point_counter)-xe(point_counter) ...
                x(point_counter)-xe(point_counter)], ...
            [y(point_counter)-x_bar_length/2 ...
                y(point_counter)+x_bar_length/2], ...
            [col '-'],'LineWidth',1,'Clipping','off');
        plot([x(point_counter)+xe(point_counter) ...
                x(point_counter)+xe(point_counter)], ...
            [y(point_counter)-x_bar_length/2 ...
                y(point_counter)+x_bar_length/2], ...
            [col '-'],'LineWidth',1,'Clipping','off');
    end
end

% Tidy up
set(gca,'Units','normalized');
if (~hold_state)
    hold off;
end

hh=[h];