% function for calculate tooth amplitude on timevector
% input
%   t - timevector for calculate
%   A - max tooth amplitude
%   tMax - time when tooth has max value
%   t1 - time beginning of exposure on plot
%   t2 - time ending of exposure on plot

function toothValues = toothCalc(t, A, tMax, t1, t2)
valuesToTMax = A * exp( - ( (t(t <= tMax) - tMax) .*(t(t <= tMax) - tMax) * 3 * 3) / ( 2 * (tMax - t1) * (tMax - t1) ));
valuesAfterTMax = A * exp( - ( (t(t > tMax) - tMax) .*(t(t > tMax) - tMax) * 3 * 3) / (2 * (t2 - tMax) * (t2 - tMax)));
toothValues = [valuesToTMax, valuesAfterTMax];
end