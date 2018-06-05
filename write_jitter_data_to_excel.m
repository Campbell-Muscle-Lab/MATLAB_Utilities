function write_jitter_data_to_excel(jd, ...
    f1,f1_strings,f2,f2_strings,excel_file_string,excel_sheet)

if (nargin==6)
    excel_sheet='Data';
end

counter=0;
for i=1:numel(f1_strings)
    for j=2:numel(f2_strings)
        y = jd(i).points{j};
        for k=1:numel(y)
            counter=counter+1;
            d(i).(f1){counter} = f1_strings{i};
            d(i).(f2){counter} = f2_strings{j};
            d(i).y(counter) = y(k);
        end
    end
end

d

write_structure_to_excel( ...
    'filename',excel_file_string, ...
    'sheet',excel_sheet, ...
    'structure',d);