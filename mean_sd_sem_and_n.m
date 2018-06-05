function [mean_value,sd_value,sem_value,n]=mean_sd_sem_and_n(values);

h=[];
for i=1:length(values)
    if (~isnan(values(i)))
        h=[h values(i)];
    end
end

n=length(h);
if n==0
    mean_value=NaN;
    sd_value=NaN;
    sem_value=NaN;
else
    mean_value=(mean(h));
    sd_value=std(h,0);
    sem_value=sd_value/sqrt(n);
end
