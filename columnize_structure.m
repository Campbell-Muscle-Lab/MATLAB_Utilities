function out = columnize_structure(s)
% Function ensures structure fields are columns

field_names = fieldnames(s);
for i=1:numel(field_names)
    s_fn = size(s.(field_names{i}));
    if (s_fn(1) < s_fn(2))
        s.(field_names{i}) = (s.(field_names{i}))';
    end
end

out = s;