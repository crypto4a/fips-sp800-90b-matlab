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
% [h] = t_tuple_estimate(input_data)
%
% This is an estimate of min_entropy for non-IID noise sources as specified
% in NIST SP-800-90B section 6.3.5 (January 2018). 
%
% input_data:   vector of input bits (only binary). Can handle both 
%               horizontal and vertical vectors
%
% h:            min-entropy estimate
%
function [h] = t_tuple_estimate(input_data)

    % Defining some parameters
    L = length(input_data);
    n = 35;                               % Number of t-bit sequence occurences


    % Reshaping the data for the find_repeated_str function
    if size(input_data, 1) > size(input_data, 2)
        input_data = transpose(input_data);
    end

    % Finding the maximum length t such that a t-bit sequence appears at least
    % 35 times accross the dataset. Through experimenting, it has been
    % found that u = 16 gives a good starting estimate.
    t = 16; 
    previous_pattern = 0;

    while t < 100                       % We stop after an arbitrarily chosen value of 100 for speed purposes
    
        % Represents all t-bit sequences and N represents the number of
        % occurrences for every tuple
        [~, ~, N] = find_repeated_str(input_data, t);

        % Counts the maximum number of occurrences of a t-bit sequence
        max_nbr_occurrences = max(N);
    
        %Checking if we need to increase or decrease t or not reiterate
        if max_nbr_occurrences < n && previous_pattern ~= 1
            t = t - 1;
            previous_pattern = -1;
        elseif max_nbr_occurrences >= n && previous_pattern ~= -1
            t = t + 1;
            previous_pattern = 1;
        elseif max_nbr_occurrences >= n && previous_pattern ~= 1
            break;
        elseif max_nbr_occurrences < n && previous_pattern ~= -1
            t = t - 1;
            break;
        end
    end

    % Initialize and filling array Q
    Q = zeros(1, t);
    Q(t) = max_nbr_occurrences;
    Q(1:t-1) = fast_Q_filling(input_data, t);

    % Generating array P and Pmax
    P = zeros(1, t);
    Pmax = zeros(1, t);
    for i = 1:t
        P(i) = Q(i)/(L-i+1);
        Pmax(i) = P(i)^(1/i);
    end

    % Calculating an upper bound on the probability of the most common value pu
    P_super_max = max(Pmax);
    pu = min(1, P_super_max + 2.576 * sqrt((P_super_max*(1-P_super_max))/(L-1)));

    % Calculating the min entropy
    h = -log2(pu);        
end

