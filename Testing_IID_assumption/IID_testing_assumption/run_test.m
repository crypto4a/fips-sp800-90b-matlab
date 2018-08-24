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
% [T] = run_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in section
% 5.1.5. This test calculates the number of increasing or decreasing runs.
%
% input_data:   vector of input bits (binary only). Can handle only 
%               horizontal vectors.
%
% T:            Result of the test, which corresponds to the number of 
%               increasing or decreasing runs
%
function[T] = run_test(input_data)
    % Converts the binary list in integers between 0 and 8
    input_data_conv = convert1(input_data, 8); 
    
    % Defining some parameters
    L       = length(input_data_conv);
    s_prime = zeros(1, L-1);
    runs    = 1;                          % initial value for the first run
    
    % Calculating the amount of runs
    for i = 1:L-1
       
       % Creating the vector s_prime
       if input_data_conv(i) > input_data_conv(i+1)
           s_prime(i) = -1;
       else
           s_prime(i) = 1;    
       end

       % Adding a run if the value s_prime(i) differs from the previous value
       if i > 1
           if s_prime(i) ~= s_prime(i-1)
               runs = runs + 1;
           end
       end
    end
    
    % Returning the amount of runs
    T = runs;
end
