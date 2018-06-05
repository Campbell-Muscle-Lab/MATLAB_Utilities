function [best_p,best_e] = successive_line_search(fh,initial_p,varargin)

params.stop_function_handle = [];

params = parse_pv_pairs(params,varargin);

% Code
n=numel(initial_p);
best_p = initial_p';
counter = 0;


keep_going = 1;
while (keep_going)
    nn=randi(n,1);
    vi = randperm(n,nn);
    x = zeros(n,1);
    for i=1:numel(vi)
        x(vi(i)) = rand-0.5;
    end
    
    [z,best_e,exit_flag] = fminbnd(@xx,-0.5,0.5)
    if (exit_flag>0)
        best_p = best_p + z*x;
    end
    counter = counter+1
end

    function e = xx(z)
        e = fh(best_p + z*x);
        
        % Check the stop function
        if (~isempty(params.stop_function_handle))
            if (params.stop_function_handle())
                keep_going=0;
                return;
            end
        end
    end
    
end

    


