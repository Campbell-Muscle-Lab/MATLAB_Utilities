function out = pull_table_strings_from_html(in_file_string,tag_string,n)

out = [];

in_file = fopen(in_file_string,'r');

if (numel(n)==1)
    repeats = 1;
    table_strings = n;
else
    table_strings = n(1);
    repeats = n(2);
end

keep_going = 1;
while (keep_going)
    repeat_counter=0;
    while (repeat_counter<repeats)
        line_string = fgetl(in_file);
        tag_string = tag_string;
        if (numel(regexp(line_string,tag_string))>0)
            repeat_counter=repeat_counter+1;
            counter=0;
            while (counter<table_strings)
                line_string = fgetl(in_file);
                expression = '>.*<';
                [t,m]=regexp(line_string,expression,'tokens','match');
                m=char(m);
                m=m(2:(end-1));
                if (numel(m)>0)
                    counter=counter+1;
                    out{repeat_counter,counter}=m;
                end
            end
        end
        repeat_counter=repeat_counter;
    end
    keep_going=0;
end
fclose(in_file);
        