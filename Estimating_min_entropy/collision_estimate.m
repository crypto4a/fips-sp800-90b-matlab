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
% [h] = collision_estimate(input_data)
%
% This function determines the min entropy of a non-IID sample as described
% in NIST SP-800-90B (January 2018) section 6.3.2. 
%
% input_data:   vector of input element (only binary). The vector can be
%               horizontal or vertical
%
% h:            min-entropy estimate
%
function [h] = collision_estimate(input_data)

    % Setting some parameters 
    L = length(input_data);
    v = 0;
    index = 1;
    t = ones(1, L/2)*-1;           % we first give t the biggest length possible
    j = 2;
    inc = 1/1000;                 % can be changed to increase level of precision

    % Building the t vector
    while j <= L
        % Found another occurence. Since data is binary, it is obvious there
        % should be another occurence after no more than 2 steps
        if ( input_data(index) == input_data(j) ) || ( j-index >= 2 )
            v = v + 1;
            t(v) = j-index+1;
            index = j + 1;
            j = index + 1;
        else
            j = j +1;
        end
    end

    % We reduce the length of vector t to make sure it matches length v. We
    % could also write : t = t(1:find(t == -1, 1)-1);
    t = t(1:v);


    % Calculating the mean and variance of the data
    X = mean(t);
    sigma = std(t);

    % Calculating the lower-bound of the confidence interval (99% confidence)
    X_prime = X - 2.576*sigma/sqrt(v);

    % Solving equation for parameter p with a certain level of precision
    p = 0.5:inc:1;
    q = 1-p;

    % Creating two vectors and measuring the minimum level of difference.
    equation_vec2 = ones(1, length(p)) * X_prime;
    equation_vec1 = p.*q.^(-2).*(1+(1./p - 1./q)./2).*gammainc(1./q, 3,...
                   'upper')*gamma(3).*q.^3.*exp(1./q) - p./q.*(1./p - 1./q)./2;
    [~, best_p_index] = min(abs(equation_vec2-equation_vec1));

    % Best_p_index was actually the index of best value for p
    best_p = p(best_p_index);

    % Measuring the min-entropy
    h = -log2(best_p);
end
