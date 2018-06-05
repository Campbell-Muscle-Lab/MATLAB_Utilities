function [gauss,y_fit,r_squared]= ...
    fit_single_gaussian(varargin);

params.x=[];
params.y=[];
params.gauss_base=[];
params.gauss_center=[];
params.gauss_amplitude=[];
params.gauss_width=[];

% Update values
params=parse_pv_pairs(params,varargin);

% Error checking
if (length(params.x)==0)
    error('No x data specified');
end
if (length(params.y)==0)
    error('No y data specified');
end
if (length(params.x)~=length(params.y))
    error('x and y data are unequal lengths');
end

% Deduce plausible initial values
if (length(params.gauss_base)==0)
    params.gauss_base=mean(params.y([1 end]));
end
if (length(params.gauss_center)==0)
    params.gauss_center=0.75*mean(params.x);
end
if (length(params.gauss_amplitude)==0)
    params.gauss_amplitude=0.95*(max(params.y)-min(params.y));
end
if (length(params.gauss_width)==0)
    params.gauss_width=0.2*mean(params.x);
end

% Initialise p array
p=[params.gauss_base params.gauss_center ...
        params.gauss_amplitude params.gauss_width]

% Minimize
p=fminsearch(@single_gaussian_error,p,[],params.x,params.y);

% Unpack
gauss.base=p(1);
gauss.center=p(2);
gauss.amplitude=p(3);
gauss.width=p(4);

% Calculate final fit
gauss_fit=gauss.base+gauss.amplitude* ...
    exp(-0.5*((params.x-gauss.center)./gauss.width).^2);

y_fit=gauss_fit;

r_squared=calculate_r_squared(params.y,y_fit);


% Sub function

function error=single_gaussian_error(p,x,y);

% Unpack
g1_base=p(1);
g1_center=p(2);
g1_amplitude=p(3);
g1_width=p(4);

gauss1=g1_base+g1_amplitude*exp(-0.5*((x-g1_center)./g1_width).^2);

y_fit=(gauss1);

error=sum((y_fit-y).^2);
