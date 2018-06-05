function hist_plot(d,field_name,title_string)
        y = d.(field_name);
%         for i=1:numel(y)
%             try
%                 y_num(i) = str2num(y{i});
%             catch
%                 y_num(i) = NaN;
%             end
%         end
%         y = y_num
        y = y(~isnan(y))
        x = linspace(min(y),max(y),50);
        [n,x]=hist(y,x);
        cla
        bar(x,n);
        xlabel(title_string);
        snapnow
    end