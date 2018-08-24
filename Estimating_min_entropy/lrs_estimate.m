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
% [h] = lrs_estimate(input_data)
%
% This is an estimate of min_entropy for non-IID noise sources as specified
% in NIST SP-800-90B section 6.3.6 (January 2018). 
%
% input_data:   vector of input bits (only binary). Can handle both 
%               horizontal and vertical vectors
%
% h:            consists of an estimate of the min-entropy of a non-IID 
%               entropy source
%
function [h] = lrs_estimate(input_data)

    % Defining some parameters
    L = length(input_data);
    n = 35;                 % Number of t-bit sequence occurences

    % Transposing the data
    if size(input_data,1) > size(input_data,2)
        input_data = transpose(input_data);
    end

    % Finding the minimum length u such that a u-bit sequence appears less than
    % 35 times accross the dataset. Through experimenting, it has been
    % found that u = 16 gives a good starting estimate.
    u = 16;
    previous_pattern = 0;

    while u < 100           % We set a upper limit of 100 strictly for speed purposes

        % Represents all t-bit sequences and N represents the number of
        % occurrences for every tuple
        [~,~,N] = find_repeated_str(input_data,u);

        % Counts the maximum number of occurrences of a t-bit sequence
        max_nbr_occurrences = max(N);

        % Checking if we need to increase or decrease t or not reiterate
        if max_nbr_occurrences < n && previous_pattern ~= 1
            u = u - 1;
            previous_pattern = -1;
        elseif max_nbr_occurrences >= n && previous_pattern ~= -1
            u = u + 1;
            previous_pattern = 1;
        elseif max_nbr_occurrences >= n && previous_pattern ~= 1
            u = u + 1;
            break;
        elseif max_nbr_occurrences < n && previous_pattern ~= -1
            u = u - 1;
            break;
        end
    end

    % Using this simple loop, we can quickly have an idea of the longest
    % repeated substring. The function find_repeated_str will also give us the
    % "champions" and we will then look more closely to find accurately the
    % lrs. We find the lrs v in 2 steps because the function find_repeated_str
    % is much faster, but it isn't as precised. Indeed, when the substrings are
    % close to 70 bits, Matlab approximates the decimal interpretation of the
    % numbers that the function uses. On the other hand, the function
    % measure_lrs used afterwards can take an array of indexes where known long
    % repeated substrings start. It will therefore figure out which of those 
    % long repeated substring is the longest.
    for i = 50:-10:0
        [found,str_array,N,edges] = find_repeated_str(input_data,i);
        if found == 1
            break;
        end
    end

    % Here, we simply arrange the starting indexes of the substrings into an
    % array to be used in the measure_lrs function.
    maxCol = max(N);
    start_indexes = zeros(sum(N>1),maxCol);
    j = 1;
    nbr_reccurrence_per_seq = zeros(size(start_indexes,1),1);
    for i = 1:length(N)
        if( N(i) > 1 )
            x = find(str_array == edges(i)); 
            nbr_reccurrence_per_seq(j) = length(x);
            start_indexes(j,:) = [x zeros(1,maxCol-nbr_reccurrence_per_seq(j))];
            j = j + 1;
        end
    end
    record = measure_lrs(input_data,start_indexes,nbr_reccurrence_per_seq);
    v = max(record);

    % Generating vectors P and P max
    P = zeros(1,v);
    Pmax = zeros(1,v);
    for W = u:v
        [~,~,N] = find_repeated_str(input_data,W);
        P(W) = N*transpose(N-1)/(2 * nchoosek(L-W+1,2));         % Equivalent of summing all nchoosek(Ci,2)
        Pmax(W) = P(W)^(1/W);
    end

    % Calculating the min-entropy from the previously calculated parameters
    p_hat_max = max(Pmax);
    pu = min(1, p_hat_max + 2.576*sqrt(p_hat_max*(1-p_hat_max)/(L-1)));
    h = -log2(pu);

end
