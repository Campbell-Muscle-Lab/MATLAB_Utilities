function [od,jd,bd] = extract_two_way_data(varargin)

% Parse inputs
p = inputParser;
addOptional(p,'excel_file_string','');
addOptional(p,'excel_sheet','Sheet 1');
addOptional(p,'data_structure',[]);
addOptional(p,'table',[]);
addOptional(p,'parameter_string','');
addOptional(p,'factor_1','');
addOptional(p,'factor_1_strings','');
addOptional(p,'factor_2','');
addOptional(p,'factor_2_num2str_format',[]);
addOptional(p,'factor_2_strings','');
addOptional(p,'conditions',[]);
addOptional(p,'grouping_string','');
addOptional(p,'convert_grouping_numbers_to_strings',0);
addOptional(p,'exclude_NaNs',1);

parse(p,varargin{:});

p.Results

% Code

% Load input data
if (isempty(p.Results.data_structure))
    if (isempty(p.Results.table))
        d = table2struct(readtable(p.Results.excel_file_string, ...
                'Sheet',p.Results.excel_sheet), ...
                'ToScalar',1);
    else
        d = table2struct(p.Results.table,'ToScalar',1);
    end
else
    
    d = p.Results.data_structure;
end

% Convert factor 2 to strings if required
if (~isempty(p.Results.factor_2_num2str_format))
    d.(p.Results.factor_2) = ...
        cellstr(num2str(d.(p.Results.factor_2),p.Results.factor_2_num2str_format));
end

% Reformat grouping numbers as strings if required
if (p.Results.convert_grouping_numbers_to_strings)
    if (isnumeric(d.(p.Results.grouping_string)))
        d.(p.Results.grouping_string) = ...
            cellstr(num2str(d.(p.Results.grouping_string)));
    end
end

% Deduce factor_1_strings
if (isempty(p.Results.factor_1_strings))
    factor_1_strings = unique(d.(p.Results.factor_1));
else
    factor_1_strings = p.Results.factor_1_strings;
end

% Deduce factor_2_strings
if (isempty(p.Results.factor_2_strings))
    factor_2_strings = unique(d.(p.Results.factor_2))
else
    factor_2_strings = p.Results.factor_2_strings;
end
 
% Now organize the data
counter = 0;
for i=1:numel(factor_1_strings)
    for j=1:numel(factor_2_strings)
       
        vi = find( ...
                strcmp(d.(p.Results.factor_1),factor_1_strings{i}) & ...
                strcmp(d.(p.Results.factor_2),factor_2_strings{j}));
        if (~isempty(p.Results.conditions))
            vi = intersect(vi, ...
                find(strcmp(d.(p.Results.conditions{1}), ...
                    p.Results.conditions{2})));
        end
        % Exclude NaNs if required
        if (p.Results.exclude_NaNs)
            y_temp = d.(p.Results.parameter_string)(vi);
            vi = vi(find(~isnan(y_temp)));
        end
        for k=1:numel(vi)
            counter=counter+1;
            od.(p.Results.factor_1){counter}=factor_1_strings{i};
            od.(p.Results.factor_2){counter}=factor_2_strings{j};
            if (~isempty(p.Results.grouping_string))
                od.(p.Results.grouping_string){counter} = ...
                    d.(p.Results.grouping_string){vi(k)};
            end
            if (~isempty(p.Results.conditions))
                od.(p.Results.conditions{1}){counter} = ...
                    d.(p.Results.conditions{1}){vi(k)};
            end
            od.(p.Results.parameter_string)(counter) = ...
                d.(p.Results.parameter_string)(vi(k));
        end
        if (numel(vi)>0)
            jd(i).points{j} = d.(p.Results.parameter_string)(vi);
        end
    end
end

jd(1).f1_strings = factor_1_strings;
jd(1).f2_strings = factor_2_strings;
