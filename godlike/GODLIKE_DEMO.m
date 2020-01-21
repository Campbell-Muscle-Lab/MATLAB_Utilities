function GODLIKE_DEMO
% GODLIKE_DEMO
%
% type 'GODLIKE_DEMO' to run a demonstration of the
% GODLIKE algorithm.


% Please report bugs and inquiries to:
%
% Name    : Rody P.S. Oldenhuis
% E-mail  : oldenhuis@gmail.com
% Licence : 2-clause BSD (See License.txt)


% If you find this work useful, please consider a donation:
% https://www.paypal.me/RodyO/3.5

    % initialize
    clc

    %% Himmelblau
    % --------------------------------------------------------------------------

    fprintf(1, ['The first demonstration will show the algorithm\n',...
                'optmizing the 2-D Himmelblau test-function, defined as\n\n',...
                '      f(x1, x2) = (x1� + x2 - 11)� + (x1 + x2� - 7)�\n\n', ...
                ' which has four minima where the function value is zero.\n\n',...
                ' This optimization is called by issuing the commands\n\n',...
                ' himmel = @(x) (x(:, 1).^2 + x(:, 2) - 11).^2 + ...\n',...
                '               (x(:, 1) + x(:, 2).^2 - 7).^2;\n',...
                ' [sol,fval] = GODLIKE(himmel, [-5, -5], [5, 5])\n\n',...
                'Press any key to start a demonstration of GODLIKE \n',...
                'with this single-objective optimization...\n\n']);
    pause

    % do it (no display)
    clc
    himmelblau = @(x) (x(:, 1).^2 + x(:, 2) - 11).^2 + (x(:, 1) + x(:, 2).^2 - 7).^2;
    [sol,fval] = GODLIKE(himmelblau,...
                         [-5 -5], [+5 +5]) %#ok
    pause(1)

    % do it (with display)
    fprintf(1, ['\nEt voil' char(224) '�: The global optimum has been found.\n\n',...
                'With the ''display'' setting set to ''plot'', the\n',...
                'optimization is rather slow, but provides a much better\n',...
                'insight in how each algorithm behaves. Now we issue the \n',...
                'same commands, but then with the display option set to\n',...
                '''plot'':\n\n',...
                ' [sol,fval] = GODLIKE(himmel, ...\n',...
                '                      [-5, -5], [5, 5],...\n',...
                '                      [],...\n',...
                '                      ''display'', ''plot'')\n\n',...
                'Press any key to start this demonstration...\n\n']);
    pause, clc
    [sol,fval] = GODLIKE(himmelblau,...
                         [-5 -5], [+5, +5],...
                         [],...
                         'display', 'plot') %#ok
    pause(1)


    %% Kursawe problem
    % --------------------------------------------------------------------------

    % multi-objective optimization
    fprintf(1, ['Now a demonstration of multi-objective optimization.\n',...
                'For multi-objective optimization, we''ll optimize the\n',...
                '2-objective Kursawe problem, defined as \n\n',...
                ' fun1 = sum( -10(exp(-0.2*sqrt(x_i� + x_(i+1)�))) )\n',...
                ' fun2 = sum( abs(x_i)^0.8 + 5*sin(x_i�), 2 )\n\n',...
                'summed over all x_i. This problem has a discontinuous \n',...
                'Pareto front, which makes it somewhat of a challenge to \n',...
                'locate. However, with GODLIKE, this is no problem. For\n',...
                'this demonstration, we issue the commands\n\n',...
                '  fun1 = @(x) sum( -10*(exp(-0.2*sqrt(x(:, 1:end-1).^2 +...\n',...
                '                    x(:, 2:end).^2))), 2);\n',...
                '  fun2 = @(x) sum( abs(x).^0.8 + 5*sin(x.^3), 2);\n\n',...
                '  [sol,fvals] = GODLIKE({fun1,fun2},...\n',...
                '                        [-5 -5 -5], [+5 +5 +5], ...\n',...
                '                        [],...\n',...
                '                        ''algorithms'', {''DE'';''GA'';''ASA''},...\n',...
                '                        ''display''   , ''plot'',...)\n',...
                '                        ''popsize''   , 500);\n\n',...
                'Press any key to start this demonstration...\n\n']);
    pause, clc

    % do it (plot)
    KUR_1 = @(x) sum( -10*(exp(-0.2*sqrt(x(:, 1:end-1).^2 + x(:, 2:end).^2))), 2);
    KUR_2 = @(x) sum( abs(x).^0.8 + 5*sin(x.^3), 2);
    [sol,fvals] = GODLIKE({KUR_1,KUR_2},...
                          [-5 -5 -5], [+5 +5 +5],...
                          [],...
                          'algorithms', {'DE' 'GA' 'ASA'},...
                          'display'   , 'plot',...
                          'popsize'   , 500)%#ok
    pause(1)

    % with print display
    fprintf(1, ['\n\nNote that alternatively, the display setting may be \n',...
                'set to just ''on''. In that case, GODLIKE will just\n',...
                'print relevant information on the screen about the \n',...
                'current progress of the optimization. To show what \n',...
                'that looks like, we''ll re-run the previous optimization\n',...
                'with the display setting set to ''on''.\n\n',...
                'Press any key to start this demonstration...\n\n']);
    pause, clc
    [sol,fvals] = GODLIKE({KUR_1,KUR_2},...
                          [-5 -5 -5], [+5 +5 +5],...
                          [],...
                          'algorithms', {'DE';'GA';'ASA'},...
                          'display'   ,'on',...
                          'popsize'   , 500)%#ok
    pause(1)

    %% Output functions
    % --------------------------------------------------------------------------

    function stop = outFcn(x, optimValues, state)

        stop = false;

        switch lower(state)
            case 'init'
                disp('output function initialization')
            case 'interrupt'
                fprintf(1, 'Algorithm loop, algorithm = %s, optimum so far = %f\n',...
                        optimValues.optimizer.algorithm,...
                        optimValues.best_fval);
            case 'iter'
                fprintf(1, 'GODLIKE iteration, globally best point so far: = (%f, %f)\n\n',...
                        x(1), x(2));
            case 'done'
                fprintf(1, 'Custom output function: all done!\n\n');
        end

    end

    fprintf(1, ['\n\nGODLIKE will now optimize the H' char(246) 'lder table function,\n',...
                'another difficult to optimize single-objective function.\n',...
                'Its 4 global minima are located at (' char(177) '8.05502, ' char(177) '9.66459)\n',...
                'where the function value equals -19.2085.\n\n',...
                'This time, GODLIKE will use a custom output function to display\n',...
                'its progress. \n\n',...
                'Press any key to start this demonstration...\n\n']);
    pause, clc
    holdertable = @(x) -abs( sin(x(:,1)) .* cos(x(:,2)) .* exp(abs(1 - sqrt(sum(x.^2,2))/pi)) );
    [sol,fval] = GODLIKE(holdertable,...
                         -10*[1 1], +10*[1 1],...
                         [],...
                         'outputFcn', @outFcn) %#ok
    pause(1)

    %% Viennet problem
    % --------------------------------------------------------------------------

    fprintf(1, ['\n\nAn example of a 3 objective optimization problem is the \n',...
                'Viennet problem. This should give a 2-part discontinuous Pareto\n',...
                'front, of which 1 part is ''wavy'' and the other a near-parabolic\n',...
                'curve. The following commands accomplish this:\n\n',...
                '  VIE_1 = @(x) 0.5 * (x(:,1).^2 + x(:,2).^2) + sin(x(:,1).^2 + x(:,2).^2);\n',...
                '  VIE_2 = @(x) 15 + ( (3*x(:,1) - 2*x(:,2) + 4).^2)/8 + ( (x(:,1)-x(:,2) + 1).^2)/27;\n',...
                '  VIE_3 = @(x) 1./(x(:,1).^2 + x(:,2).^2 + 1) - 1.1*exp(-(x(:,1).^2 + x(:,2).^2));\n\n',...
                '  [sol, fvals, Paretos, ParetoFuns, exitflag, output] = ...\n',...
                '      GODLIKE({VIE_1,VIE_2,VIE_3},...\n',...
                '              -10 * [1 1 1], +10 * [1 1 1],...\n',...
                '              {''DE'' ''GA'' ''ASA''},...\n',...
                '              ''display'', ''plot'',...\n',...
                '              ''popsize'', 750);\n\n',...
                'Press any key to start this demonstration...\n\n']);
    pause, clc

    % do it (in full)
    VIE_1 = @(x) 0.5 * (x(:,1).^2 + x(:,2).^2) + sin(x(:,1).^2 + x(:,2).^2);
    VIE_2 = @(x) 15 + ( (3*x(:,1) - 2*x(:,2) + 4).^2)/8 + ( (x(:,1)-x(:,2) + 1).^2)/27;
    VIE_3 = @(x) 1./(x(:,1).^2 + x(:,2).^2 + 1) - 1.1*exp(-(x(:,1).^2 + x(:,2).^2));

    [sol,fvals,Paretos,ParetoFuns,exitflag,output] = ...
        GODLIKE({VIE_1, VIE_2, VIE_3},...
                -10 * [1 1 1], +10 * [1 1 1],...
                [],...
                'algorithms' , {'DE' 'GA' 'ASA'},...
                'display'    , 'plot',...
                'popsize'    , 750,...
                'MaxFunEvals', 1e6)%#ok

output.message

    % concluding remarks
    fprintf(1, ['\n\nThis concludes this simple demonstration. Take a look in \n',...
                'the manual.pdf and background.pdf files in the documentation\n',...
                'directory to get a better idea about the extensive options \n',...
                'GODLIKE offers. Or just experiment with how GODLIKE works\n',...
                'on your own functions.\n']);

end
