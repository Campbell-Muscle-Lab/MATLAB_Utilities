function s = create_struct_from_xml_file(xml_file_string)
% Turns an XML file into a MATLAB structure
% Can cope with nested strucures using recursion

s = xml2struct(xml_file_string);
field_names = fieldnames(s);
s = s.(field_names{1});
s = RemoveTextFlag(s);

end

function s = RemoveTextFlag(s)
    % Loops through the structure, parsing the text
    field_names = fieldnames(s);
    for i=1:numel(field_names)
        if (strcmp(field_names{i},'Text'))
            s = ParseText(s.(field_names{i}));
        else
            s.(field_names{i}) = RemoveTextFlag(s.(field_names{i}));
        end
    end
end

function stringname = ParseText(stringname)
    x = str2num(stringname);
    if (~isempty(x))
        stringname = x;
    end
end

