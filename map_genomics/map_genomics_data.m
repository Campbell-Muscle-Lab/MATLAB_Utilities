function map_genomics_data

% This your data
excel_file_string = 'Genomics_Data.xlsx';

box_map_template = '9_9_box_map_template.xlsx';
g = readtable(excel_file_string);


% Specify number of variables in the template
opts = spreadsheetImportOptions("NumVariables", 10);

% Specify template sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A3:J16";

template = readtable(box_map_template,opts);

output_excel_file_base_string = '9by9_output';

room_u = unique(g.Room);

if numel(room_u) == 1 
    mg.room_number = room_u;
else
    error('There are multiple Room Number entries')
end

% Map the room number to template, hardcoded because of the template
template.Var1(2) = mg.room_number;

freezer_u = unique(g.Freezer);

if numel(freezer_u) == 1 
    mg.freezer = freezer_u;
else
    error('There are multiple Room Number entries')
end

template.Var2(2) = mg.freezer;

rack_u = unique(g.Rack);

if numel(rack_u) == 1 
    mg.rack = rack_u;
else
    error('There are multiple Room Number entries')
end

template.Var3(2) = num2cell(mg.rack);

row_u = sort(unique(g.Row));
k = 1;
m = 1;

for i = 1 : length(g.Room)
    if strcmp(g.NucleicAcid(i),'DNA')
        excel_map.dna.(g.Row{i})(k) = g.UniqueSpecimenNo(i);
        k = k + 1;
        mg.box(1) = g.BoxNumber(i);
    else
        excel_map.rna.(g.Row{i})(m) = g.UniqueSpecimenNo(i);
        m = m + 1;
        mg.box(2) = g.BoxNumber(i);
    end
end

nuc = fieldnames(excel_map);
for m = 1 : length(nuc)
ix = [];
    for i = 1 : length(row_u)

        len = length(excel_map.(nuc{m}).(row_u{i}));

        for j = 1 : len
            if isempty(excel_map.(nuc{m}).(row_u{i}){1,j})
                ix(j) = j;
            end
        end
        if ~isempty(ix)
            excel_map.(nuc{m}).(row_u{i})(1:ix(end)) = [];
        end
        len = length(excel_map.(nuc{m}).(row_u{i}));

        nam = template.Properties.VariableNames;

        for u = 1 : len
            template{i+5,u+1} = num2cell(template{i,u+1});
            template{i+5,u+1} = excel_map.(nuc{m}).(row_u{i})(u);
        end
    end
template.Var4(2) = num2cell(mg.box(m));

output_excel_file = sprintf('%s_%s.xlsx',output_excel_file_base_string,string(nuc(m)));

writetable(template,output_excel_file,'WriteVariableNames',0)

end
 
end