function jd = extract_two_way_data_with_grouping( ...
    d,parameter_string,f1,f1_strings,f2,f2_strings,conditions)

for i=1:numel(f1_strings)
    for j=1:numel(f2_strings)
        vi = find( ...
                strcmp(d.(f1),f1_strings{i}) & ...
                strcmp(d.(f2),f2_strings{j}));
        if (~isempty(conditions))
            vi = intersect(vi, ...
                find(strcmp(d.(conditions{1}),conditions{2})));
        end
        jd(i).points{j} = d.(parameter_string)(vi);
    end
end
