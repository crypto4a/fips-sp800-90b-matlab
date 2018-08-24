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
% [T] = excursion_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in section
% 5.1.1. This test calculates how far the running sum of samples differs
% from its mean at every point This test can work with both binary or
% non-binary inputs
% 
% input_data:   vector of input bits (or input real numbers). Can handle 
%               both horizontal and vertical vectors
%
% T:            Result of the test, correspond to the maximum difference
%               between the running sum and the mean
%
function[T] = excursion_test(input_data)

    % Declaring some parameters
    L           = length(input_data);
    X           = mean(input_data);
    diff        = zeros(1, L);
    running_sum = 0;
    
    % Calculating the difference between the running sum and the mean
    for i=1:L
        running_sum = running_sum + input_data(i);
        diff(i)     = abs(running_sum - i * X);
    end
    
    % Returning the maximum distance
    T = max(diff);
end
