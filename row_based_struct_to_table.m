function t = row_based_struct_to_table(s)
% Converts struct with data arranged in rows to table

field_names = fieldnames(s);
for i = 1 : numel(field_names)
    s.(field_names{i}) =s.(field_names{i})';
end
t = struct2table(s);