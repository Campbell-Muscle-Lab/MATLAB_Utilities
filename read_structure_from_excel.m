function s = read_structure_from_excel(varargin)
% Written by Ken
% Code reads in a structure from an Excel file and converts
% NaN strings to numeric NaNs


params.filename = '';
params.sheet = 'Sheet1';
params.strip_tails=0;
params.treat_NaNs_as_strings=0;
params.progress_bar=0;
params.debug_mode=0;
params.suppress_output=0;

% Update
params=parse_pv_pairs(params,varargin);

% If there is only one sheet, use it
% Try to make an intelligent decision about the path
temp_string = params.filename;
if (temp_string(2)~=':')
    params.filename = fullfile(cd,params.filename);
else
    params.file_name = params.filename;
end
[~,sheet_names] = xlsfinfo(params.filename);
if (numel(sheet_names)==1)
    params.sheet = sheet_names{1};
end

display_string = sprintf('Reading from %s: %s', ...
    params.filename,params.sheet);
if (~params.suppress_output)
    disp(display_string);
end

% Read in
s = xls2struct(params.filename,params.sheet);

field_names=fieldnames(s);

if (params.progress_bar)
    progress_bar(0);
end

% We have to do some scanning here to correct for bad options
for field_counter=1:length(field_names)
    
    % Display
    display_string=sprintf('Loading excel field: %s',field_names{field_counter});
    if (params.debug_mode)
        disp(display_string);
    end
       
    if (params.progress_bar)
        progress_bar(field_counter/length(field_names), ...
            display_string);
    end
    
    column_data = s.(field_names{field_counter});
    
    if (~params.treat_NaNs_as_strings)
        % Convert string NaNs to digits
        n=numel(s.(field_names{field_counter}));
        vi=strcmp(s.(field_names{field_counter}),'NaN');
        if (any(vi))
            % Make a new temp vector
            x_temp=NaN*ones(n,1);
            % Do a str to number conversion on the numbers
            vi=~vi;
            x_temp(vi)=cell2mat(column_data(vi));
            s.(field_names{field_counter})=x_temp;
        end
    end
    
    % If the column is a cell array of strings
    % Strip leading '_' from text strings
    % Convert numbers to strings
    if (iscell(s.(field_names{field_counter})(1)))
        numeric_indices=cellfun(@isnumeric,s.(field_names{field_counter}));
        % Convert numbers to strings
        ni = find(numeric_indices);
        if (~isempty(ni))
            s.(field_names{field_counter})(ni) = ...
                cellfun(@num2str,s.(field_names{field_counter})(ni), ...
                    'UniformOutput',0);
        end
        % Strip leading _ from strings
        si = find(cellfun(@ischar,s.(field_names{field_counter})));
        if (~isempty(si))
            s.(field_names{field_counter})(si) =  ...
                regexprep(s.(field_names{field_counter})(si), ...
                '^_','','emptymatch');
        end
    end
    
    % Deal with logicals
    if (iscell(s.(field_names{field_counter})(1)))
        logical_i = find(cellfun(@islogical,s.(field_names{field_counter})));
        if (~isempty(logical_i))
            logical_values=cell2mat(s.(field_names{field_counter})(logical_i));
            true_i = find(logical_values);
            if (~isempty(true_i))
                s.(field_names{field_counter})(logical_i(true_i)) = ...
                    repmat({'TRUE'},[numel(true_i) 1]);
            end
            false_i = find(~logical_values);
            if (~isempty(false_i))
                s.(field_names{field_counter})(logical_i(false_i)) = ...
                    repmat({'FALSE'},[numel(false_i) 1]);
            end
        end
    end
    
    % Strip tailing NaNs from numeric fields
    % and empty strings from cell fields
    if (params.strip_tails)
        d=s.(field_names{field_counter});
        if (isnumeric(d))
            nan_indices=find(isnan(d));
            keep_going=1;
            while (keep_going)
                if (any(nan_indices==length(d)))
                    d=d(1:(end-1));
                else
                    keep_going=0;
                end
            end
            s.(field_names{field_counter})=d;
        end
        if (iscell(d))
            counter=length(d);
            keep_going=1;
            while (keep_going)
                temp=s.(field_names{field_counter})(counter);
                if (isnan(cell2mat(temp)))
                    d=d(1:(end-1));
                    counter=counter-1;
                else
                    keep_going=0;
                end
            end
            s.(field_names{field_counter})=d;
        end
    end
end

end
