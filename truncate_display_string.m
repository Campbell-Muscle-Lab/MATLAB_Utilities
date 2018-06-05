function truncated_string=truncate_display_string(input_string,max_line_length);
% Removes middle of string for display purposes

input_string=deblank(input_string);

[a,b]=size(input_string);
if (a>b)
    input_string=input_string';
end

if (length(input_string)>max_line_length)
    truncated_string=[input_string(1:3) ' ... ' ...
            input_string(length(input_string)-max_line_length+9:end)];
else
    truncated_string=input_string;
end
