%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2018 Crypto4a Technologies Inc.
%
% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the "Software"),
% to deal in the Software without restriction, including without limitation 
% the rights to use, copy, modify, merge, publish and/or distribute copies 
% of the Software, and to permit persons to whom the Software is 
% furnished to do so subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
% USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function finds the value y of a function associated to a point x 
% based on Lagrange's interpolation.
%
% x_m:	    Values of x associated to known points where the function
%           passes
%
% y_m:      Values of y associated to known points where the function
%           passes
%
% x:	    Value of x that we want to evaluate
%
% y: 	    Value of y associated to x in the interpolated function
%
function y = lagrange_interpolation( x_m, y_m, x )

    % Simply checking inputs to avoid some errors
    if size(x_m, 1) > size(x_m, 2)
        x_m = transpose(x_m);
    end

    if size(y_m, 1) > size(y_m, 2)
        y_m = transpose(y_m);
    end

    % Making sure that there are as many values of x_m as y_m
    if size(x_m, 2) ~= size(y_m, 2)
        error('x_m and y_m must have the same dimension');
    end

    % Finding y using Lagrange's interpolation
    y = 0;
    for i = 1:length(x_m)
        polynomial_term = 1;
        for j = 1:length(x_m)
            if j ~= i
                polynomial_term = polynomial_term * (x - x_m(j)) / (x_m(i) - x_m(j));
            end
        end
        y = y + polynomial_term * y_m(i);
    end
end
