function result = autocorrelation(y)

[a,b]=size(y);
if (min(a,b)>1)
	error('Autocorrelation does not work for >1 dimensional matrices');
end
if (a>b)
	y=y';
end

% Pre-allocation
result=zeros(1,length(y));

% Calculation
for i=1:length(y)
	result(i)=sum(y.*circshift(y,[0 i-1]));
end
