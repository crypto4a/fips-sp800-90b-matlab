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
% [h] = markov_estimate(input_data)
%
% This function determines the min entropy of a non-IID sample as described
% in NIST SP-800-90B (January 2018) section 6.3.3. 
%
% input_data:   vector of input elements (only binary). Can handle both 
%               horizontal and vertical vectors
%
% h:            min-entropy estimate
%
function [h] = markov_estimate(input_data)

    % Adjusting size of the input_data to have an odd number of elements
    L = length(input_data);
    L = L - (1 - mod(L, 2));
    input_data = input_data(1:L);

    % Estimating initial probabilities for each output value
    p1 = sum(input_data)/L;
    p0 = 1 - p1;

    % Counting the number of two bits occurences by transforming every two bit
    % sequence into an integer from 0 to 3. We create an array with two rows.
    % The first row contains every two bit sequence starting with the first
    % bit, while the second row starts with the second bit, giving every other
    % overlap.
    two_bits_list = zeros(2, floor(L/2));
    reshaped_data_1 = reshape(input_data(1:L-1), [2, floor(L/2)]);
    reshaped_data_2 = reshape(input_data(2:L), [2, floor(L/2)]);                 
    two_bits_list(1, :) = [2 1] * reshaped_data_1;
    two_bits_list(2, :) = [2 1] * reshaped_data_2;
    nbr_occurrences = histcounts(two_bits_list, 4);      % gives number of occurrences
    nbr_00 = nbr_occurrences(1);
    nbr_01 = nbr_occurrences(2);
    nbr_10 = nbr_occurrences(3);
    nbr_11 = nbr_occurrences(4);

    % Creating the matrix T
    p00 = nbr_00/(nbr_00+nbr_01);
    p01 = nbr_01/(nbr_00+nbr_01);
    p10 = nbr_10/(nbr_10+nbr_11);
    p11 = nbr_11/(nbr_10+nbr_11);
    T = [p00 p01 ; p10 p11];

    % Calculating the most likely sequence of outputs for some sequence
    prob_seq = [p0*p00^127; p0*p01^64*p10^63; p0*p01*p11^126; ...
                p1*p10*p00^126; p1*p10^64*p01^63;p1*p11^127];
    pmax = max(prob_seq);
    h = min(-log2(pmax)/128, 1);
end
