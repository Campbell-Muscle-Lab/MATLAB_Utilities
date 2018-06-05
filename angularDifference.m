function zOut = angularDifference(controlZ,minuend,subtrahend)

% Function for calculating differences between angles
% Written by Edmund Brekke during Autumn 2010
% Edited March 2011, May 2011 and May 2014
% @controlZ:    A point such that the intervals of interest dont intersect it
% @minuend:     x in x-y
% @subtrahend:  y in x-y
% >zOut:        Angular difference

c = mod(controlZ,2*pi);
minuendShifted = mod(minuend - c,2*pi);
subtrahendShifted = mod(subtrahend - c,2*pi);
zOut = minuendShifted - subtrahendShifted;
z2 = subtrahendShifted - minuendShifted;
otherwayBool = zOut > minuendShifted;
zOut(otherwayBool) = z2(otherwayBool);