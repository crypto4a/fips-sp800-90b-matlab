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
% [h] = lag_prediction_estimate(input_data, k)
%
% This is an estimate of min_entropy for non-IID noise sources as specified
% in NIST SP-800-90B section 6.3.8 (January 2018). It is called the Lag
% Prediction Estimate
%
% input_data:   vector of input elements (binary or integers). Can handle
%               both vertical and horizontal vectors.
%
% k:            the number of different values present in input_data. k is
%               set to 2 by default for binary inputs
%
% h:            consists of an estimate of the min-entropy of a non-IID 
%               entropy source 
function [h] = lag_prediction_estimate(input_data, k)

    %Initializing a few parameters
    L          = length(input_data);
    D          = 128;
    N          = L-1;
    lag        = ones(1, D)*-1;  % -1 will be considered as NULL      
    winner     = 1;
    scoreboard = zeros(1, D);
    correct    = zeros(1, N);
    precision  = 0.001;         % Level of precision used in solving for P_local

    % Setting default parameter
    if nargin == 1
        k = 2;
    end

    % Going through the data (step 3)
    for i = 2 : L
    
        % Preparing predictions
        for d = 1 : D
            if d < i
                lag(d) = input_data(i-d);
            else
                lag(d) = -1;
            end
        end
    
        % Making and checking predictions
        prediction = lag(winner);
        if prediction == input_data(i)
            correct(i-1) = 1;
        end
    
        % Updating the scoreboard
        for d = 1 : D
            if lag(d) == input_data(i)
                scoreboard(d) = scoreboard(d) + 1;
                if scoreboard(d) >= scoreboard(winner)
                    winner = d;
                end
            end
        end
    end

    % Number of correct predictions
    C = sum(correct);

    % Calculating the predictor's global performance and the upper bound of the
    % 99% confidence interval
    P_global = C/N;
    if P_global == 0
        P_prime_global = 1-0.01^(1/N);
    else
        P_prime_global = min(1, P_global + 2.576 * sqrt((P_global * (1-P_global))/(N-1)));
    end

    % We now find the longest run of correct predictions
    r = 0;
    count = 1;
    for i = 1:N-1

       % Keep adding to the run
       if correct(i) == 1 && correct(i+1) == correct(i)
           count = count+1;
       % Checking for new record and resetting the counter
       else
           if count > r
               r = count;
           end
           count = 1;
       end
   
       % Dealing with the last element
       if i == N-1 && count > r
           r = count;
       end  
    end
    r = r + 1;

    % Instead of using a binary search, we use Matlab's vectors to find the 
    % minimum difference between the two sides of the equation. The x_function
    % is an iterative function.
    P_local = 0:precision:1;
    q       = 1 - P_local;
    equation_vec1 = (1 - P_local.*x_function(P_local, r))./(((r + 1 - ...
                    r.*x_function(P_local, r)).*q).*x_function(P_local...
                    , r).^(N+1));
    equation_vec2 = 0.99 * ones(1, 1/precision +1);

    [~, best_p_index] = min(abs(equation_vec2-equation_vec1));

    % Best_p_index was actually the index of best value for P_local
    best_P_local = P_local(best_p_index);

    % Measuring the min-entropy
    h = -log2(max([P_prime_global best_P_local 1/k]));
end
            

