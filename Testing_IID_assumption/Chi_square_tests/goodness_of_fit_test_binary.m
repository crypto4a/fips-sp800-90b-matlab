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
% goodness_of_fit_test_binary(input_data)
%
% This function checks for independance using a chi-square test as
% prescribed in NIST SP-800-90B(January 2018). There is no output to this
% function, simply a displayed message.
%
% input_data: vector of binary elements (binary only). Can handle both
%             vertical and horizontal vectors
%
function goodness_of_fit_test_binary(input_data)

    % Setting some parameters 
    T = 0;
    L = length(input_data);
    p1 = sum(input_data)/L;
    qty_per_part = floor(L/10);
    e0 = (1-p1)*qty_per_part;
    e1 = p1 * qty_per_part;

    for d = 1:10
        partition = input_data((d-1)*qty_per_part+1:d*qty_per_part);
        o1 = sum(partition);
        o0 = qty_per_part-o1;
        T = T+(o0-e0)^2/e0 + (o1-e1)^2/e1;
    end

    % Calculating the chi square critical value with 9 degrees of liberty and a
    % probability of 0.999
    chi2_value = chi2inv(0.999, 9);

    % Displaying results
    if chi2_value < T
        disp('Test failed. The critical value was:');
        disp(chi2_value);
        disp('And the value from the test was:');
        disp(T);
    else
        disp('Test passed. The critical value was:');
        disp(chi2_value);
        disp('And the value from the test was:');
        disp(T); 
    end
end


