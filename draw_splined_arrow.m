function draw_splined_arrow(varargin);

params.x=[];
params.y=[];
params.line_width=1.5;
params.line_color='k';
params.n_points=25;
params.rel_arrow_size=0.12;
params.tip_angle=pi/4;
params.figure_handle=2;
params.draw_defining_points=0;

params=parse_pv_pairs(params,varargin);

% Some error checking
if (length(params.x)~=3)
    error('Draw_splined_arrow: x must have 3 points');
end
if (length(params.y)~=3)
    error('Draw_splined_arrow: y must have 3 points');
end

% Code
% Take the input points and fit a spline to them

theta=atan((params.y(3)-params.y(1))/(params.x(3)-params.x(1)));

rot_matrix=[cos(theta) sin(theta);-sin(theta) cos(theta)];

z1=rot_matrix*[params.x(1);params.y(1)];
z2=((rot_matrix*[params.x(2);params.y(2)])-z1)';
z3=((rot_matrix*[params.x(3);params.y(3)])-z1)';
z1=(z1-z1)';

zz_x=linspace(0,z3(1),params.n_points);
zz_y=spline([z1(1) z2(1) z3(1)],[z1(2) z2(2) z3(2)],zz_x);

back_rot_matrix=[cos(-theta) sin(-theta);-sin(-theta) cos(-theta)];
for i=1:length(zz_x)
    temp=(back_rot_matrix*[zz_x(i);zz_y(i)]);
    sp_x(i)=temp(1)+params.x(1);
    sp_y(i)=temp(2)+params.y(1);
end

% Now try to work out the arrow tip
img_i=sqrt(-1);
main_angle=angle([sp_x(end)+img_i*sp_y(end)]- ...
    [sp_x(end-1)+img_i*sp_y(end-1)]);

x_scale_length=params.rel_arrow_size*diff(xlim);

% Arrow points
t1=return_dx_dy(0.5*params.rel_arrow_size,main_angle+params.tip_angle);
t2=return_dx_dy(0.5*params.rel_arrow_size,main_angle-params.tip_angle);
t3=return_dx_dy(0.5*params.rel_arrow_size,main_angle+pi);

arrow_points_x=sp_x(end)+[t3(1) t1(1) t2(1) t3(1)];
arrow_points_y=sp_y(end)+[t3(2) t1(2) t2(2) t3(2)];

% Now that you have all the coordinates, scale and offset to the axis
% limits

x_limits=xlim;
y_limits=ylim;

% Adjust for non-square axes
old_units=get(gca,'Units');
set(gca,'Units','Inches');
temp=get(gca,'Position');
set(gca,'Units',old_units);
% x_limits=x_limits*temp(4)/temp(3);

% Spline curve
new_sp_x=x_limits(1)+sp_x*diff(x_limits);
new_sp_y=y_limits(1)+sp_y*diff(y_limits);

new_arrow_points_x=x_limits(1)+arrow_points_x*(diff(x_limits));
new_arrow_points_y=y_limits(1)+arrow_points_y*(diff(y_limits));

% Draw the spline
plot(new_sp_x,new_sp_y,'-', ...
    'LineWidth',params.line_width, ...
    'Color',params.line_color, ...
    'Clipping','off');

% Draw the arrow head
patch(new_arrow_points_x,new_arrow_points_y, ...
    params.line_color, ...
    'LineStyle','none', ...
    'Clipping','off');

if (params.draw_defining_points)
    defining_points_x=x_limits(1)+params.x*diff(x_limits);
    defining_points_y=y_limits(1)+params.y*diff(y_limits);
    plot(defining_points_x,defining_points_y,'ro', ...
        'Clipping','off');
    
    defining_points_y
end

% plot(new_arrow_points_x(1),new_arrow_points_y(1), ...
%     'cx', ...
%     'LineStyle','none', ...
%     'Clipping','off');
% plot(new_arrow_points_x(2),new_arrow_points_y(2), ...
%     'mx', ...
%     'LineStyle','none', ...
%     'Clipping','off');
% plot(new_arrow_points_x(3),new_arrow_points_y(3), ...
%     'gp', ...
%     'LineStyle','none', ...
%     'Clipping','off');






function d=return_dx_dy(arrow_length,angle)

% Constrain the angle to +-pi
orig_angle=angle;
if (angle>pi)
    angle=angle-2*pi;
end
if (angle<-pi)
    angle=angle+2*pi;
end
new_angle=angle;

dx=arrow_length*cos(angle);
dy=arrow_length*sin(angle);

if ((angle>=0)&&(angle<=pi/2))
    dx=-dx;
    dy=-dy;
end
if ((angle>pi/2)&&(angle<=pi))
    dx=-dx;
    dy=-dy;
end
if (angle<-pi/2)
    dx=-dx;
    dy=-dy;
end
if ((angle<0)&&(angle>=-pi/2))
    dx=-dx;
    dy=-dy;
end

angle;
d=[dx dy];
