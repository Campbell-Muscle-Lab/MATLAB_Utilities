 function ab = BrokenStickRegression(xx, yy, nstick)
%BrokenStickRegression  piecewise linear regression. Fits a line
% consisting of connected straight sections to a cloud of data points.
%
% AB = BrokenStickRegression(XX, YY, NSTICK); XX and YY are the data 
% points; NSTICK is the number of connected straight sections. AB(:, 1)
% are the x-coordinates of endpoints and breakpoints in ascending order. 
% AB(:, 2) are the corresponding y-coordinates. XX need not be in a
% monotonic order.
%
% AB = BrokenStickRegression(XX, YY, BREAKPOINTS); BREAKPOINTS is a 
% vector of at least two abscissa values chosen as starting breakpoints. 
% NUMEL(BREAKPOINTS) + 1 is the number of straight sections of the 
% fitting curve. Choosing starting breakpoints helps in some cases to
% obtain better fits.
%
% Example 1:
% --------- 
%    nstick = 4;
%    nn = 800;
%    xx = linspace(1.0, 11.5, nn)';
%    y0 = sin(xx);
%    yy = y0 + randn(nn, 1) * 0.4;
%    ab = BrokenStickRegression(xx, yy, nstick);
%    plot(xx, yy, 'b.', xx, y0, 'k', ab(:, 1), ab(:, 2), 'r-o')
%    title(['BrokenStickRegression(x, sin(x) + noise, ', ...
%          int2str(nstick), ')'])
%
% Example 2:
% ---------
%    xx = 0:100;
%    yy = [ones(1, 70), 1:10, 11:-1:];
%    yy = [yy, zeros(1, 101 - length(yy))] + 0.8 * randn(1, 101);
%    bp = [65, 75, 90];                  % trial breakpoints.
%    subplot(2, 1, 1)
%    plot(xx, yy)
%    hold on
%    ab = BrokenStickRegression(xx, yy, numel(bp) + 1));
%    plot(ab(:, 1), ab(:, 2), 'r-o')
%    subplot(2, 1, 2)
%    plot(xx, yy)
%    hold on
%    ab = BrokenStickRegression(xx, yy, bp);
%    plot(ab(:, 1), ab(:, 2), 'r-o')
%
% See also: POLYFIT.

% The algorithm uses POLYFIT, FMINBND and FMINSEARCH.
%
% pmwnave@yahoo.de
% 2010-11-05, started.
% 2010-11-16, simplified. 
% 2010-12-02, case recognized in which polyfit is supplied with only one
%             data point; case recognized in which the first breakpoint 
%             slips to the left of the minimum data point. Both bugs
%             were discovered by Carlos Romero, EPFL, Lausanne. Thanks! 
%----------------------------------------------------------------------O
% Initialize the coordinates ab of the end- and breakpoints. 
%
  xx = xx(:);
  yy = yy(:);  
  a0 = [];                               % breakpoints.

  if numel(xx) ~= numel(yy),
     error(' ### %s: XX and YY are not equally long.', mfilename)
  end
   
  if (nargin == 2) || isempty(nstick),
     nstick = 1;
  end
  if numel(nstick) > 1,
     a0 = nstick;
     nstick = numel(a0) + 1;
  end
  if numel(xx) < nstick + 1,
     error(' ### %s: too few data points.', mfilename)
  end
  
  ab         = zeros(nstick + 1, 2);
  ab(1, 1)   = min(xx);
  ab(end, 1) = max(xx);
    
  if nstick == 1,
%
% Normal linear regression.
%
     pp       = polyfit(xx, yy, 1);   
     ab(:, 2) = pp(1) * ab(:, 1) + pp(2);
    
  elseif nstick == 2,
%
% Two sticks. Find the breakpoint that minimizes the residuals.
%
     aa = fminbnd(@MinRes, ab(1, 1), ab(3, 1));
     
  else        
%
% Three or more sticks. Find the breakpoints that minimize the 
% residuals. The appropriate function would be FMINCON which is part of
% the optimization toolbox, which not everybody owns. A work-around 
% consists in applying penalties whenever constraints are violated. The
% penalties are defined in MinRes. A and B define constraints: A 
% solution point X is admissible if A * X < B. a0 is the start point of
% the search process.
%
     A  = zeros(nstick, nstick - 1);
     A(1:nstick + 1:end) = -1;             
     A(2:nstick + 1:end) =  1;
     B  = zeros(nstick, 1);
     B(1)      = -ab(1, 1);
     B(nstick) =  ab(end, 1);
     if isempty(a0),
        a0 = (ab(end, 1) - ab(1, 1)) / nstick * (1:nstick - 1)' + ...
           ab(1, 1);
     end
     aa = fminsearch(@MinRes, a0);
  end

function rr = MinRes(aa)                 % nested function.
%MinRes  calculates the residuals rr for given breakpoints aa.

%----------------------------------------------------------------------O
  ab(2:nstick, 1) = aa;
  if nstick > 2 && any(A * ab(2:nstick, 1) >= B),
     rr = 1e20; 
     return
  end
%
% Regression on the leftmost section.
%
  kk = find(xx <= ab(2, 1));
  kt = numel(kk);
  if kt == 1,
     tmp = 0;
  else
     pp  = polyfit(xx(kk), yy(kk), 1);
     ab(1:2, 2) = pp(1) * ab(1:2, 1) + pp(2);
     tmp = yy(kk) - pp(1) * xx(kk) - pp(2);
  end
%
% All other sections.
%
  for ii = 2:nstick,
     kk = find((xx > ab(ii, 1)) & (xx <= ab(ii + 1, 1)));
     lh = xx(kk) - ab(ii, 1);
     rh = (yy(kk) - ab(ii, 2)) * (ab(ii + 1, 1) - ab(ii, 1)) + ...
          ab(ii, 2) * (xx(kk) - ab(ii, 1));
     ab(ii + 1, 2) = lh' * rh / (lh' * lh);
     slope = (ab(ii + 1, 2) - ab(ii, 2)) / (ab(ii + 1, 1) - ab(ii, 1));
     tmp   = [tmp; yy(kk) - slope * (xx(kk) - ab(ii, 1)) - ab(ii, 2)];  
  end
  rr = tmp' * tmp;
%
% Impose a penalty for violating constraining conditions. This approach
% can possibly be improved. Other constraints may be added also as 
% penalties.
%
  if nstick > 2 && any(A * ab(2:nstick, 1) >= B),
     rr = rr + 1e20;
  end
end % MinRes.
end % BrokenStickRegression.
% EOF BrokenStickRegression.
