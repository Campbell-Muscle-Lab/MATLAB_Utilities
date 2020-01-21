function out=make_rows_of_a_table_of_equal_lengths(input)
 %developed by Faruk Moonschi
 %this function will add 'NaN' at the end of a row numbers and empty cells at
 %the end of cell to make them of the same sizes 

 field_names = fieldnames(input);
 
 row_lengths =[];
 
 for field_counter = 1: numel(field_names)
     if ischar(input.(field_names{field_counter}))
         row_lengths = [row_lengths; 1];
     else
     row_lengths = [row_lengths;...
         numel(input.(field_names{field_counter}))];
     end 
 end 
 
 max_length_row=max(row_lengths);
 
 for field_counter = 1: numel(field_names)
     if ischar(input.(field_names{field_counter}))
         cur_row_length=1; 
     else
         cur_row_length = numel(input.(field_names{field_counter}));
     end 
     
     if cur_row_length<max_length_row
         % row can be cell or array 
         if ischar(input.(field_names{field_counter}))
            out.(field_names{field_counter})=...
                [input.(field_names{field_counter});...
                cell(max_length_row - cur_row_length, 1)]
         elseif iscell(input.(field_names{field_counter}))
            out.(field_names{field_counter})=...
                [input.(field_names{field_counter});...
                cell(max_length_row - cur_row_length, 1)];
         else
             out.(field_names{field_counter})=...
                [input.(field_names{field_counter});...
                NaN*zeros(max_length_row - cur_row_length, 1)];
         end 
         
     else
         out.(field_names{field_counter})= ...
             input.(field_names{field_counter});
     end 
 end 
 
end 

