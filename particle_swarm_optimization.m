function [global_best_p,global_lowest_error] = ...
    particle_swarm_optimization2(fh,varargin)

params.initial_p=[];
params.no_of_particles=[];
params.max_velocity=0.1;
params.min_velocity=0.01;
params.velocity_factor=0.95;
params.global_attractor=3;
params.local_attractor=1;
params.initial_spread=0.5;
params.max_iterations=Inf;
params.increase_velocity_after_n_failed_iterations=10;
params.failed_iteraction_factor=0.99;
params.stop_after_n_failed_iterations=100;
params.initial_global_error=1.0e100;
params.lower_bounds=[];
params.upper_bounds=[];
params.display_dimensions=[1 2];
params.throw_out_iterations=Inf;
params.throw_out_n=[];
params.sub_search_n=Inf;
params.stop_function_handle=[];

params.figure_number=0;
params.display_surface=[];
params.figure_parameters=0;

% Update
params=parse_pv_pairs(params,varargin);

% Set value
params.function_handle = fh;

% Set plausible values
if (isempty(params.no_of_particles))
    no_of_particles=round(1.5*length(params.initial_p));
else
    no_of_particles=params.no_of_particles;
end
if (isempty(params.throw_out_n))
    params.throw_out_n = round(0.3*no_of_particles);
end
no_of_dimensions=length(params.initial_p);
max_v=params.max_velocity;
global_lowest_error=params.initial_global_error;
f_handle=params.function_handle;
if (isempty(params.lower_bounds))
    params.lower_bounds=-Inf*ones(no_of_dimensions,1);
end
if (isempty(params.upper_bounds))
    params.upper_bounds=Inf*ones(no_of_dimensions,1);
end

% Define storage_variables
best_error_values=[];
best_error_iterations=[];

% Initialise
for i=1:no_of_particles
    
    particle(i).max_velocity = params.max_velocity;
    particle(i).min_velocity = params.min_velocity;
    
    for j=1:no_of_dimensions
        particle(i).x(j) = params.initial_p(j) + ...
            (2*params.initial_spread * (rand-0.5));
        
        % Overwrite first case
        if (i==1)
            particle(i).x(j)=params.initial_p(j);
        end
        
        particle(i).x(j) = keep_in_bounds(particle(i).x(j),j);
        
        particle(i).v(j) = 2 * particle(i).max_velocity * (rand-0.5);
    end
    
    particle(i).lowest_error=f_handle(particle(i).x);
    particle(i).best_p = particle(i).x;
    
    % Check the stop function
    if (~isempty(params.stop_function_handle))
        if (params.stop_function_handle())
            return;
        end
    end
    
    % Global values
    if (particle(i).lowest_error<global_lowest_error)
        global_lowest_error=particle(i).lowest_error;
        global_best_p = particle(i).best_p;
    end
end

% Display initial swarm
draw_plot();
drawnow;

% Iterations
iteration_counter=0;
failed_iteration_counter=0;

max_v=[];
min_v=[];

while (iteration_counter<=params.max_iterations)

    failed_iteration_flag=1;
    
    if (params.sub_search_n<no_of_dimensions)
        search_dimensions=randi(no_of_dimensions,params.sub_search_n);
    else
        search_dimensions=1:no_of_dimensions;
    end
    
    for i=1:no_of_particles
        for j=1:length(search_dimensions)
            % Update the velocity
            particle(i).v(search_dimensions(j)) = ...
                particle(i).v(search_dimensions(j)) + ...
                params.global_attractor * rand * ...
                    (global_best_p(search_dimensions(j)) - ...
                        particle(i).x(search_dimensions(j))) + ...
                params.local_attractor * rand * ...
                    (particle(i).best_p(search_dimensions(j)) - ...
                        particle(i).x(search_dimensions(j)));
            % Limit it
            if (particle(i).v(search_dimensions(j))<0)
                particle(i).v(search_dimensions(j)) = ...
                    max([particle(i).v(search_dimensions(j)) ...
                        -particle(i).max_velocity]);
            else
                particle(i).v(search_dimensions(j)) = ...
                    min([particle(i).v(search_dimensions(j)) ...
                        particle(i).max_velocity]);
            end
        end
        
        % Calculate the new values
        for j=1:length(search_dimensions)
            particle(i).x(search_dimensions(j)) = ...
                particle(i).x(search_dimensions(j)) + ...
                    particle(i).v(search_dimensions(j));
        end
        
        % Limit it
        for j=1:no_of_dimensions
            particle(i).x(j) = keep_in_bounds(particle(i).x(j),j);
        end
        
        test_value=f_handle(particle(i).x);
        
        % Check the stop function
        if (~isempty(params.stop_function_handle))
            if (params.stop_function_handle())
                return;
            end
        end
        
        if (test_value<particle(i).lowest_error)
            particle(i).lowest_error = test_value;
            particle(i).best_p = particle(i).x;
        end
        
        if (test_value<global_lowest_error)
            iteration_counter=iteration_counter
            global_lowest_error = test_value
            global_best_p = particle(i).x
   
            if (length(best_error_values)>1)
                if (test_value<(params.failed_iteraction_factor * ...
                        best_error_values(end-1)))
                
                    failed_iteration_flag=0;
                    failed_iteration_counter=0;
                end
            end
            
            best_error_values=[best_error_values global_lowest_error];
            best_error_iterations=[best_error_iterations iteration_counter];
        end
        
        % Adjust velocity by slowing down
        particle(i).max_velocity = max([params.min_velocity ...
            particle(i).max_velocity * params.velocity_factor]);
    end
    
    % Decide whether to increase the velocity
    if (failed_iteration_flag==1)

        failed_iteration_counter=failed_iteration_counter+1;

        if ((params.increase_velocity_after_n_failed_iterations>0) && ...
                (failed_iteration_counter> ...
                    params.increase_velocity_after_n_failed_iterations))
                
                % Reset the first time in
                if ((failed_iteration_counter - ...
                    params.increase_velocity_after_n_failed_iterations)==1)
                    for k=1:no_of_particles
                        particle(k).max_velocity=params.max_velocity;
                        particle(k).min_velocity=params.min_velocity;
                    end
                end
                
                for k=1:round(no_of_particles/2)
                    particle(k).max_velocity = ...
                        particle(k).max_velocity * ...
                            ((1/params.velocity_factor)^2);
                end

                for k=(round(no_of_particles/2)+1):no_of_particles
                    particle(k).max_velocity = particle(k).max_velocity * ...
                        params.velocity_factor;
                    particle(k).min_velocity = particle(k).min_velocity * ...
                        params.velocity_factor;
                end
        end
        
        if ((params.increase_velocity_after_n_failed_iterations>0) && ...
                (failed_iteration_counter> ...
                    params.stop_after_n_failed_iterations))
            disp('Particle_swarm_optimization stopped after n failed iterations');
            return
        end
        
    end
    
    % Display
    draw_plot();
    drawnow;
    
    % Throw out
    if (mod(iteration_counter,params.throw_out_iterations)==0)
        % Throw out some particles
        for i=1:params.throw_out_n
            thrown_n=randi(no_of_particles);
            for j=1:no_of_dimensions
                % Throw out the dimension
                particle(thrown_n).x(j) = particle(thrown_n).x(j) + ...
                    2*params.initial_spread*(rand-0.5);
                % Limit it
                particle(thrown_n).x(j) = keep_in_bounds( ...
                    particle(thrown_n).x(j),j);
            end
            
            % Reset variables
            particle(thrown_n).best_p = particle(thrown_n).x;
            particle(thrown_n).lowest_error = params.initial_global_error;
            particle(thrown_n).max_velocity = max([params.max_velocity ...
                particle(thrown_n).max_velocity]);
        end
    end
    
%     figure(2);
%     clf;
%     max_v=[max_v max([particle(:).max_velocity])];
%     min_v=[min_v min([particle(:).max_velocity])];
%     plot(max_v,'r-');
%     hold on;
%     plot(min_v,'g-');
    
    % Loop back
    iteration_counter=iteration_counter+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Nested function
    function xx=keep_in_bounds(xx,zz)

        if (xx<params.lower_bounds(zz))
            xx=params.lower_bounds(zz)+abs(params.lower_bounds(zz)-xx);
            if (xx>params.upper_bounds(zz))
                xx = params.upper_bounds(zz) + ...
                    rand*(params.upper_bounds(zz)-params.lower_bounds(zz));
            end
        end
        
        if (xx>params.upper_bounds(zz))
            xx=params.upper_bounds(zz)-abs(xx-params.upper_bounds(zz));
            if (xx<params.lower_bounds(zz))
                xx = params.upper_bounds(zz) + ...
                    rand*(params.upper_bounds(zz)-params.lower_bounds(zz));
            end
        end
        
        % Last chance
        xx=max([params.lower_bounds(zz)+eps xx]); 
        xx=min([params.upper_bounds(zz)-eps xx]);
    end

    function draw_plot
        if (params.figure_number)
            figure(params.figure_number);
            clf;
            if (~isempty(params.display_surface))
                imagesc(params.display_surface.x_limits, ...
                    params.display_surface.y_limits, ...
                    params.display_surface.surface);
                colorbar;
            end
            hold on;
            plot(global_best_p(params.display_dimensions(1)), ...
                global_best_p(params.display_dimensions(2)),'ms', ...
                'MarkerFaceColor','m');
            for ii=1:no_of_particles
                plot(particle(ii).x(params.display_dimensions(1)), ...
                    particle(ii).x(params.display_dimensions(2)),'wo');
            end
           
            
            if (~isempty(params.display_surface))
                xlim(params.display_surface.x_limits);
                ylim(params.display_surface.y_limits);
            else
                xlim([-0.25 1.25]);
                ylim([-0.25 1.25]);
            end
        end
        
        if (params.figure_parameters)
            figure(params.figure_parameters);
            clf;
            subplot(3,1,1);
            hold on;
            for ii=1:no_of_particles
                    plot(1:no_of_dimensions, ...
                        [particle(ii).x(:)],'go');
            end
            ylim([-0.5 1.5]);
            for jj=1:no_of_dimensions
                plot(jj,global_best_p(jj),'ms');
            end
            
            if (~isempty(params.lower_bounds) && ...
                    ~isempty(params.upper_bounds))
                if (all(isfinite(params.lower_bounds)) && ...
                        all(isfinite(params.upper_bounds)))
                    ylim([min(params.lower_bounds) ...
                        max(params.upper_bounds)]);
                end
            end
            
            subplot(3,1,2);
            cla;
            plot(best_error_iterations,log10(best_error_values),'b-');
            
            subplot(3,1,3);
            cla;
            hold on;
            plot(1:no_of_particles,log10([particle(:).min_velocity]),'bo-');
            plot(1:no_of_particles,log10([particle(:).max_velocity]),'rs-');
            ylim([-8 3]);
            
        end
    end
end