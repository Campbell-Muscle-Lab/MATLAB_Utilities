function gui_make_jitter_plot(varargin);

% Default arguments
default_string='';
excel_file_string='';
excel_sheet='';
data=[];
field_names=[];
id_strings=[];

% Setup the figure
f=figure;
set(f,'Position',[100 100 550 300]);

% Add controls
x_anchor=10;
x_spacing=10;
x_text=75;
x_edit=250;
x_push=75;
x_popup=100;
y_height=20;
y_spacing=20;

% Excel file
y_anchor=270;
h_excel_file_text=uicontrol('Style','text', ...
    'Position',[x_anchor y_anchor x_text y_height], ...
    'HorizontalAlignment','left', ...
    'String','Excel file');
h_excel_file_edit=uicontrol('Style','edit', ...
    'Position',[x_anchor + x_spacing + x_text y_anchor x_edit y_height], ...
    'HorizontalAlignment','left', ...
    'String',default_string);
h_excel_file_select=uicontrol('Style','push', ...
    'Position',[x_anchor + 2*x_spacing + x_text + x_edit ...
                    y_anchor x_push y_height], ...
    'String','Select', ...
    'Callback',{@excel_file_select});
% h_excel_file_load=uicontrol('Style','push', ...
%     'Position',[x_anchor + 3*x_spacing + x_text + x_edit + x_push ...
%                     y_anchor x_push y_height], ...
%     'String','Load', ...
%     'Callback',{@excel_file_load});

% Popups
y_anchor = y_anchor-y_spacing-y_height;
h_sheets_text = uicontrol('Style','text', ...
    'Position',[x_anchor y_anchor x_text y_height], ...
    'HorizontalAlignment','left', ...
    'String','Excel sheets');
h_sheets_popup = uicontrol('Style','popup', ...
    'Position',[x_anchor + x_spacing + x_text y_anchor x_popup y_height], ...
    'String',{''});
h_sheets_select=uicontrol('Style','push', ...
    'Position',[x_anchor + 2*x_spacing + x_text + x_popup ...
                    y_anchor x_push y_height], ...
    'String','Select', ...
    'Callback',{@sheets_select});

y_anchor = y_anchor-y_spacing-y_height;
h_sub_text = uicontrol('Style','text', ...
    'Position',[x_anchor y_anchor x_text y_height], ...
    'HorizontalAlignment','left', ...
    'String','Sub group');
h_sub_popup = uicontrol('Style','popup', ...
    'Position',[x_anchor + x_spacing + x_text y_anchor x_popup y_height], ...
    'String',{''});

y_anchor = y_anchor-y_spacing-y_height;
h_main_text = uicontrol('Style','text', ...
    'Position',[x_anchor y_anchor x_text y_height], ...
    'HorizontalAlignment','left', ...
    'String','Main group');
h_main_popup = uicontrol('Style','popup', ...
    'Position',[x_anchor + x_spacing + x_text y_anchor x_popup y_height], ...
    'String',{''});

y_anchor = y_anchor-y_spacing-y_height;
h_data_text = uicontrol('Style','text', ...
    'Position',[x_anchor y_anchor x_text y_height], ...
    'HorizontalAlignment','left', ...
    'String','Data column');
h_data_popup = uicontrol('Style','popup', ...
    'Position',[x_anchor + x_spacing + x_text y_anchor x_popup y_height], ...
    'String',{''});

y_anchor = y_anchor-y_spacing-y_height;
h_id_text = uicontrol('Style','text', ...
    'Position',[x_anchor y_anchor x_text y_height], ...
    'HorizontalAlignment','left', ...
    'String','ID column');
h_id_popup = uicontrol('Style','popup', ...
    'Position',[x_anchor + x_spacing + x_text y_anchor x_popup y_height], ...
    'String',{''});

y_anchor = y_anchor-y_spacing-y_height;
h_sheets_select=uicontrol('Style','push', ...
    'Position',[x_anchor y_anchor x_push y_height], ...
    'String','Plot', ...
    'Callback',{@plot_graph});

    % Callbacks
    function excel_file_select(source,eventdata)
        % Select the file
        [file_string,pathname]=uigetfile2( ...
            {'*.xls;*.xlsx','Excel files'}, ...
            'Select file');
        if (pathname~=0)
            temp=fullfile(pathname,file_string);
            set(h_excel_file_edit,'String',temp);
            
            excel_file_load();
        end
    end
        
    function excel_file_load(source,eventdata)
        % Open the file
        excel_file_string=get(h_excel_file_edit,'String');
        try
            [status,sheets,format]=xlsfinfo(excel_file_string)
            set(h_sheets_popup,'String',sheets);
        catch
            warndlg('File could not be opened');
            set(h_sheets_popup,'String','');
            return
        end
    end

    function sheets_select(source,eventdata)
        % Get the excel sheet
        excel_sheet=get(h_sheets_popup,'String');
        excel_sheet=char(excel_sheet{get(h_sheets_popup,'Value')})
        
        % Load the structure
        data=read_structure_from_excel( ...
            'filename',excel_file_string, ...
            'sheet',excel_sheet);
        
        % Workout the fields
        field_names=fieldnames(data);
        id_strings={'' field_names{:}};
        field_names={field_names{:} ''};
        
        % Update the controls
        set(h_sub_popup,'String',field_names);
        set(h_main_popup,'String',field_names);
        set(h_data_popup,'String',field_names);
        set(h_id_popup,'String',id_strings);
    end

    function plot_graph(source,eventdata)
        
        main_group = char(field_names{get(h_main_popup,'Value')})
        sub_group = char(field_names{get(h_sub_popup,'Value')})
        data_header = char(field_names{get(h_data_popup,'Value')})
        id_group = char(id_strings{get(h_id_popup,'Value')})

        if (strcmp(main_group,''))
            no_of_main_groups = 1;
        else
            main_groups = unique(data.(main_group));
            no_of_main_groups = numel(main_groups);
        end
        
        if (strcmp(sub_group,''))
            no_of_sub_groups = 1;
        else
            sub_groups = unique(data.(sub_group));
            no_of_sub_groups = numel(sub_groups);
        end
        
        if (numel(id_group)>0)
            ids = data.(id_group);
        else
            ids = [];
        end
        
        no_of_main_groups = no_of_main_groups
        no_of_sub_groups = no_of_sub_groups
        
        % Loop through the data
        for main_counter=1:no_of_main_groups
            if (no_of_main_groups==1)
                vi = 1:numel(data.(data_header));
            else
                vi = find(strcmp(data.(main_group), ...
                    main_groups{main_counter}));
            end
            
            if (numel(ids)>0)
                vi=vi;
                main_ids = ids(vi);
                unique_ids = unique(main_ids);
                no_of_ids = numel(unique_ids);
                join_linked_points = 1;
            else
                no_of_ids = 0;
                join_linked_points = 0;
            end
            
            for sub_counter=1:no_of_sub_groups
                if (no_of_ids == 0)
                    % No data links
                    if (no_of_sub_groups==1)
                        vi2 = vi;
                    else
                        vi2 = vi(find(strcmp(data.(sub_group)(vi), ...
                                    sub_groups{sub_counter})));
                    end
                    
                    plot_data(main_counter).points{sub_counter} = ...
                        data.(data_header)(vi2);
                else
                    % Find each of the ids
                    holder=[];
                    for id_counter=1:no_of_ids
                        ind = find( ...
                                (strcmp(data.(sub_group)(vi), ...
                                    sub_groups{sub_counter}) & ...
                                (strcmp(data.(id_group)(vi), ...
                                    unique_ids{id_counter}))));
                        if (isempty(ind))
                            value = NaN;
                        else
                            if (numel(ind)>1)
                                errordlg('More than one data point for each ID tag');
                            else
                                value = data.(data_header)(vi(ind));
                            end
                        end
                        
                        holder=[holder value];
                    end
                    
                    plot_data(main_counter).points{sub_counter} = ...
                        holder;
                end
            end
        end
        
        % Make the figure
        figure(2);
        subplots=initialise_publication_quality_figure( ...
            'left_margin',1, ...
            'right_margin',2, ...
            'bottom_margin',0.5, ...
            'no_of_panels_wide',1, ...
            'no_of_panels_high',1, ...
            'axes_padding_left',1.5);
        subplot(subplots(1));
        jitter_plot('data',plot_data, ...
            'group_names',main_groups, ...
            'sub_names',sub_groups, ...
            'y_axis_label',data_header, ...
            'y_label_offset',-0.22, ...
            'y_tick_decimal_places',2, ...
            'join_linked_points',join_linked_points, ...
            'y_label_text_interpreter','none');
    end
end
