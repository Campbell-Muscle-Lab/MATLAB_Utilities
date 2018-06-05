function out_struct = keep_struct_indices(in_struct,vi)

field_names = fieldnames(in_struct);
for i=1:numel(field_names)
    out_struct.(field_names{i}) = in_struct.(field_names{i})(vi);
end