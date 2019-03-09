function [x_means,y_means,x_errors,y_errors,n]= ...
    return_bin_data(x_data,y_data,x_bin_centers,error_mode);

% Code takes two_arrays, x_data and y_data and a further array
% providing the x positions of the bin centers, alocates the x_data to
% the appropriate bin and returns the mean x and mean y for each bin group
% and the appropriate x and y errors. Error mode 0 means SD, Error mode 1
% means SEM

no_of_bins=length(x_bin_centers);
temp=diff(x_bin_centers);
bin_width=abs(temp(1));
flag=zeros(1,length(x_data));

for bin_counter=1:no_of_bins
    matching_indices=find( ...
        (x_data > (x_bin_centers(bin_counter)-(0.5*bin_width))) & ...
        (x_data <= (x_bin_centers(bin_counter)+(0.5*bin_width))));
    
    stats = summary_stats(x_data(matching_indices));
    x_means(bin_counter) = stats.mean;
    if (error_mode==0)
        x_errors(bin_counter) = stats.sd;
    else
        x_errors(bin_counter) = stats.sem;
    end
    n(bin_counter) = stats.n;
    
    stats = summary_stats(y_data(matching_indices));
    y_means(bin_counter) = stats.mean;
    if (error_mode==0)
        y_errors(bin_counter) = stats.sd;
    else
        y_errors(bin_counter) = stats.sem;
    end
    flag(matching_indices)=1;
end

n=n

discarded_n=numel(x_data)-sum(n);
if (discarded_n>0)
    temp_string=sprintf('%i from %i points discarded', ...
        discarded_n,length(x_data));
    disp('Warning from Kens return_bin_data');
    disp(temp_string);
    discarded_x_data=x_data(find(flag==0));
end
    



