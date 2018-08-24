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
% [h] = compression_estimate(input_data)
%
% This is an estimate of min_entropy for non-IID noise sources as specified
% in NIST SP-800-90B section 6.3.4(January 2018). 
%
% input_data : input_data of binary digits
%
% h : consists of an estimate of the min-entropy of a non-IID entropy source 
function [h] = compression_estimate(input_data)

    % Defining some parameters
    b = 6;                                  % Number of bits considered at once
    c = 0.5907;                             % Used for the std deviation
    d = 1000;                               % Data that will produce the dictionnary ('d' in the publication')
    L = length(input_data);
    dict = zeros(1, 2^b); 
    v = floor(L/b)-d;
    D = zeros(1, v); 
    inc = 1/1000;                           % can be changed to increase level of precision

    % Discarding the last extra bits if L is not a multiple of 6
    L = L - mod(L, b); 

    % Creating decimal values that are equivalent to the 6-bit blocks
    input_data   = input_data(1:L); 
    s_prime      = transpose(reshape(input_data, [b, L/b]));
    s_prime_test = s_prime * transpose(2.^(0:b-1)); % contains both the test values and the dict values
    s_prime_dict = s_prime_test(1:d);

    % Creating the dictionnary by finding the last occurrence of each value
    for i = 1:2^b
    	index_last_item = find(s_prime_dict == i-1, 1, 'last');
        if ~isempty(index_last_item)
            dict(i) = index_last_item;
        end
    end

    % Running the test data against the dictionnary
    for i =(d+1):d+v
        index = s_prime_test(i) + 1; % the +1 takes Matlab's indexing into account
        tmp = dict(index);
        if tmp ~= 0
            D(i-d) = i - tmp;
            dict(index) = i;
        else
            dict(index) = i;
            D(i-d) = i;
        end
    end

    % Average and standard deviation
    X = mean(log2(D));
    sigma = c*sqrt(sumsqr(log2(D))/(v-1)-X^2);

    % Calculating the lower-bound of the confidence interval for the mean
    X_prime = X - 2.576*sigma/sqrt(v);

    % Solving equation for parameter p with a certain level of precision
    p = 2^-b:inc:1;
    q = (1-p)./(2^b-1);

    % Creating two vectors and measuring the minimum level of difference.
    equation_vec2 = ones(1, length(p)) * X_prime;
    equation_vec1 = G(p, v, d)+(2^b-1)*G(q, v, d);
    [~, best_p_index] = min(abs(equation_vec2-equation_vec1));

    % Best_p_index was actually the index of best value for p
    best_p = p(best_p_index);

    % Measuring the min-entropy
    h = -log2(best_p)/b;
end
