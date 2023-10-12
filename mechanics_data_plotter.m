function mechanics_data_plotter

% Data plotter for analyzed mechanics data. 


% Utku's computer paths. Please keep these lines
% addpath(genpath('../../../GitHub/MATLAB_Utilities'))
% excel_file_string = '5155D.xlsx';

addpath(genpath('../../Documents/GitHub/MATLAB_Utilities'))
excel_file_string = 'OD/Analysis/OD.xlsx';

data_prep = readtable(excel_file_string,'Sheet','prep_data');
data_trace = readtable(excel_file_string,'Sheet','trace_data');

per_diff_4pt5_9pt0 = data_prep.f_min./data_prep.f_max;

panels_wide = 4;

if ismember('ktr',data_prep.Properties.VariableNames)
    panels_high = 4;
else
    panels_high = 4;
end

x_break_point = 6.75;
x_break_width = 0.04;
x_break_spacing = 0.075;
x_break_line_width = 1.5;
x_break_rel_height = 0.03;

omit_panels = [3:4 6:8 10:12 14:16];
bottom_subplot_adjustments = zeros(1, panels_wide*panels_high);
bottom_subplot_adjustments(2) = 3.45;
% bottom_subplot_adjustments([1 5 8 11]) = 0.25;
right_subplot_adjustments = zeros(1, panels_wide*panels_high);
right_subplot_adjustments(2) = -1.35;
right_subplot_adjustments([1 5 9 13]) = -0.25;

height_subplot_adjustments = zeros(1, panels_wide*panels_high);
height_subplot_adjustments([1 2 5 9 13]) = 0.25;
left_subplot_adjustments = zeros(1, panels_wide*panels_high);
left_subplot_adjustments(2) = 0.1;
left_pads = repmat(0.3,[panels_wide panels_high]);
right_pads = repmat(0.1,[panels_wide panels_high]);
right_pads([2 6 10 14]) = 0.4;
left_pads(2) =0.6;
p = initialise_publication_quality_figure( ...
    'no_of_panels_wide', panels_wide, ...
    'no_of_panels_high', panels_high, ...
    'top_margin', 0.2, ...
    'bottom_margin', 0.2, ...
    'right_margin', 0.05, ...
    'individual_padding', 1, ...
    'left_pads', left_pads, ...
    'right_pads', right_pads, ...
    'axes_padding_top', 0.2, ...
    'axes_padding_bottom',0.5, ...
    'panel_label_font_size', 0, ...
    'figure_handle',1,'x_to_y_axes_ratio',3,'omit_panels',omit_panels,...
    'bottom_subplot_adjustments',bottom_subplot_adjustments,...
    'right_subplot_adjustments',right_subplot_adjustments,...
    'height_subplot_adjustments',height_subplot_adjustments,...
    'left_subplot_adjustments',left_subplot_adjustments);

label_rotation = 90;

if numel(data_prep.prep) <= 5
    marker_size_panels = 8;
    label_font_size = 9;
    font_size_text = 8;
elseif numel(data_prep.prep) > 5 && numel(data_prep.prep) <= 10
    marker_size_panels = 6;
    label_font_size = 7;
    font_size_text = 4;
else
    marker_size_panels = 6;
    label_font_size = 5;
    font_size_text = 4;
end

cm = parula(numel(data_prep.prep));
markers = {'o','s','^','v','>','<','p','h'};

mult = size(data_prep,1)/numel(markers);

mult = ceil(mult);

markers = repmat(markers, [1 mult]);

subplot(p(1))
for i = 1:numel(data_prep.pCa_50)
    plot(i,data_prep.pCa_50(i),markers{i},'LineWidth',1,'MarkerEdgeColor',cm(i,:),'MarkerSize',marker_size_panels)
end
xlim([0.7 numel(data_prep.pCa_50)+0.3])
ylim([min(data_prep.pCa_50)-0.05 max(data_prep.pCa_50)+0.05])
x_labels = data_prep.prep;
x_labels_positions = 1:numel(data_prep.pCa_50);


improve_axes('axis_handle',p(1),...
    'y_axis_label',{'pCa_{50}'}, ...
    'y_tick_decimal_places',0,...
    'y_label_offset',-0.1,...
    'x_label_offset',-0.2,...
    'label_font_size',label_font_size,...
    'x_tick_decimal_places',0,...
    'y_tick_decimal_places',2,...
    'x_tick_length',0,...
    'x_tick_labels',x_labels,'x_tick_label_positions',x_labels_positions, ...
    'x_axis_label','',...
    'omit_x_tick_labels',1,'y_label_rotation',label_rotation,'tick_font_size',label_font_size);

subplot(p(5))
for i = 1:numel(data_prep.n_H)
    plot(i,data_prep.n_H(i),markers{i},'LineWidth',1,'MarkerEdgeColor',cm(i,:),'MarkerSize',marker_size_panels)
end
xlim([0.7 numel(data_prep.n_H)+0.3])
ylim([0 round(max(data_prep.n_H))+0.5])
x_labels = data_prep.prep;
x_labels_positions = 1:numel(data_prep.n_H);

improve_axes('axis_handle',p(5),...
    'y_axis_label',{'n_H'}, ...
    'y_tick_decimal_places',2,...
    'y_label_offset',-0.1,...
    'x_label_offset',-0.2,...
    'label_font_size',label_font_size,...
    'x_tick_decimal_places',0,...
    'x_tick_length',0,...
    'x_tick_labels',x_labels,'x_tick_label_positions',x_labels_positions, ...
    'x_axis_label','',...
    'omit_x_tick_labels',1,'y_label_rotation',label_rotation,'tick_font_size',label_font_size);


subplot(p(9))
for i = 1:numel(per_diff_4pt5_9pt0)
    plot(i,per_diff_4pt5_9pt0(i),markers{i},'LineWidth',1,'MarkerEdgeColor',cm(i,:),'MarkerSize',marker_size_panels)
end

xlim([0.7 numel(per_diff_4pt5_9pt0)+0.3])
ylim([0 max(per_diff_4pt5_9pt0)+0.1])
x_labels = data_prep.prep;
x_labels_positions = 1:numel(per_diff_4pt5_9pt0);

improve_axes('axis_handle',p(9),...
    'y_axis_label',{'F_{9.0}/F_{4.5}'}, ...
    'y_tick_decimal_places',0,...
    'y_label_offset',-0.1,...
    'x_label_offset',-0.2,...
    'label_font_size',label_font_size,...
    'y_ticks',[0 max(per_diff_4pt5_9pt0)+0.1],...
    'x_tick_decimal_places',0,...
    'y_tick_decimal_places',1,...
    'x_tick_length',0,...
    'x_tick_labels',x_labels,'x_tick_label_positions',x_labels_positions, ...
    'x_axis_label','',...
    'x_tick_label_rotation',45,'y_label_rotation',label_rotation,'omit_x_tick_labels',1,'tick_font_size',label_font_size);

if ismember('ktr',data_prep.Properties.VariableNames)
    subplot(p(13))
    for i = 1:numel(data_prep.ktr)
        plot(i,data_prep.ktr(i),markers{i},'LineWidth',1,'MarkerEdgeColor',cm(i,:),'MarkerSize',marker_size_panels)
    end
    xlim([0.7 numel(data_prep.ktr)+0.3])
    ylim([0 round(max(data_prep.ktr))+1])
    x_labels = data_prep.prep;
    x_labels_positions = 1:numel(data_prep.ktr);
    
    for i = 1 : numel(data_prep.ktr)
        str = sprintf('%.2f',data_prep.ktr(i));
        text(i-0.2,data_prep.ktr(i)-3,str,'FontSize',font_size_text)
    end
    improve_axes('axis_handle',p(13),...
        'y_axis_label',{'k_{tr}'}, ...
        'y_tick_decimal_places',0,...
        'y_label_offset',-0.1,...
        'x_label_offset',-0.2,...
        'label_font_size',label_font_size,...
        'x_tick_decimal_places',0,...
        'x_tick_length',0,...
        'x_tick_labels',x_labels,'x_tick_label_positions',x_labels_positions, ...
        'x_axis_label','',...
        'x_tick_label_rotation',45,...
        'x_tick_label_font_size',label_font_size,...
        'y_label_rotation',label_rotation,...
        'tick_font_size',label_font_size);
    
    
end

prep_ids = data_prep.prep;
pd = [];

% ix_9 = find(data_trace.pCa == 9);
% data_trace.pCa(ix_9) = 7; 
for i = 1:numel(prep_ids)
    
    vi = find(strcmp(data_trace.prep,prep_ids(i)));
    ix = find(strcmp(data_trace.prep,prep_ids(i)) & data_trace.pCa == 4.5);
    
    last_45(i) = ix(end);
    first_45(i) = ix(1);
    pd(i).pCa = data_trace.pCa(vi,:);
    pd(i).y = data_trace.force(vi,:);
    pCa = [];
    force = [];
    pCa = pd(i).pCa;
    pCa(pCa == 9) = 7;
    force = pd(i).y;
    pd(i).y_error = zeros(numel(pd(i).y),1);
    [fd(i).pCa_50, fd(i).n_H, ...
        fd(i).f_min, fd(i).f_amp, ...
        fd(i).pCa_r_sq, ...
        pd(i).x_fit, pd(i).y_fit] = ...
        fit_Hill_curve(pd(i).pCa, pd(i).y);
    
    fd(i).f_max = fd(i).f_min + ...
        fd(i).f_amp;
    
   figs(i) = plot(p(2),pCa,force,markers{i},'linewidth',1,'markersize',7,'markeredgecolor',cm(i,:));

    
end

x_ticks =[7 6.5 6 5.5 5 4.5];

for i=1:numel(prep_ids)
    % plot line in two parts
    for j=1:2
        if (j==1)
            vi = find( (pd(i).x_fit<max(x_ticks)) & ...
                (pd(i).x_fit>(x_break_point+x_break_spacing)));
        else
            vi = find( (pd(i).x_fit<(x_break_point-x_break_spacing)) & ...
                (pd(i).x_fit>min(x_ticks)));
        end
        
        if (isempty(vi))
            % Deals with special case where there are no points
            % in a part of the curve
            continue;
        end
        
        h_line(i) = plot(p(2),pd(i).x_fit(vi),pd(i).y_fit(vi),'-', ...
            'LineWidth',2, ...
            'Color',cm(i,:));
    end
end
for i=numel(prep_ids):-1:1
    uistack(h_line(i),'bottom');
end

for i = 1 : numel(last_45)
    
    plot(p(2),data_trace.pCa(last_45(i)),data_trace.force(last_45(i)),markers{i},'linewidth',1,'markersize',10,'markeredgecolor','k','markerfacecolor',cm(i,:));
    plot(p(2),data_trace.pCa(first_45(i)),data_trace.force(first_45(i)),markers{i},'linewidth',1,'markersize',10,'markeredgecolor',cm(i,:));
end

y_limit = max(data_trace.force);
y_limit = ceil(y_limit/(5*10^(round(log10(y_limit))-1)))*(5*10^(round(log10(y_limit))-1));

y_ticks = [0 y_limit];
labels1 = prep_ids';
for i = 1:numel(prep_ids)
    labels2{i} = sprintf('%.3f',fd(i).pCa_50);
    labels3{i} = sprintf('%.3f',fd(i).n_H);
    labels4{i} = sprintf('%.3f',data_prep.ktr(i));

    prep_str_length(i) = length(labels1{i});
end

formatting{1} = '%12s%12s%12s';
for i = 2 : numel(prep_ids)
    
    formatting{i} = sprintf('%s%s%s%i%s%s%s','%12','s','%',12+(prep_str_length(1)-prep_str_length(i)),'s','%12','s');

end


for i = 1:numel(prep_ids)
    leg_labels{i} = sprintf(formatting{i},labels1{i},labels2{i},labels3{i},labels4{i});
end


titles = {'pCa_5_0', 'n_H','k_t_r'};
titles = sprintf('%32s%12s%18s', titles{:});

legendflex(figs, leg_labels, ...
    'xscale',0.5, ...
    'anchor',{'ne','ne'}, ...
    'buffer',[260 1], ...
    'padding',[1 1 15], ...
    'FontSize',8, ...
    'text_y_padding', -2,...
    'title',titles);



x_tick_label_positions = [7 6.5 6 5.5 5 4.5];
x_tick_labels_pos = [9 6.5 6 5.5 5 4.5];


for i = 1:numel(x_tick_label_positions)
    
    x_tick_labels{i} = sprintf('%.1f',x_tick_labels_pos(i));
    
end


axes_data = improve_axes('axis_handle',p(2),...
    'y_axis_label',{'Force (N/m^{2})'}, ...
    'y_tick_decimal_places',0,...
    'y_label_offset',-0.1,...
    'x_label_offset',-0.12,...
    'label_font_size',12,...
    'x_tick_decimal_places',1,...
    'x_ticks',x_ticks,...
    'y_ticks',y_ticks,...
    'x_tick_labels',x_tick_labels,...
    'x_tick_label_positions',x_tick_label_positions,'x_axis_label','pCa',...
    'y_label_rotation',90,'y_axis_offset',-0.05,'x_axis_offset',0.05,...
    'x_tick_length',0.03);

if (x_break_point<max(x_ticks))
    xb=x_break_point+x_break_width*[1 -1];
    yb_axis=x_break_rel_height*(max(y_ticks)-min(y_ticks))*[-1 1];
    plot(p(2),x_break_point+[0 x_break_spacing], ...
        axes_data.x_axis_y_location*[1 1], ...
        'w-','LineWidth',axes_data.axis_line_width+1);
    for i=1:2
        plot(p(2),xb,yb_axis + axes_data.x_axis_y_location, ...
                'k-','LineWidth',x_break_line_width);
        xb=xb+x_break_spacing;
    end
end

fname = excel_file_string;
fname = erase(excel_file_string,'.xlsx');
figure_export('output_file_string',fname, ...
    'output_type','png')
    
end