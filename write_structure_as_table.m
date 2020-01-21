function write_structure_as_table(varargin)

p = inputParser;
addRequired(p,'structure');
addRequired(p,'excel_file_string');
addOptional(p,'sheet','Sheet1');
addOptional(p,'delete_existing_file',1);

parse(p,varargin{:});
p = p.Results;

% Code

% Convert structure to table
field_names = fieldnames(p.structure);
% Check to see if data need to be transposed
temp = p.structure.(field_names{1});
[r,c] = size(temp);
if (r<c)
    % Transpose
    for i=1:numel(field_names)
        p.structure.(field_names{i}) = (p.structure.(field_names{i}))';
    end
end
t = struct2table(p.structure);

% Clean old file
if (p.delete_existing_file)
    try
        delete(p.excel_file_string);
    end
end

% Write
writetable(t,p.excel_file_string,'Sheet',p.sheet);

% Delete other sheets
if (p.delete_existing_file)
    if (~strcmp(p.sheet,'Sheet1'))
        delete_excel_sheets('filename',p.excel_file_string);
    end
end

