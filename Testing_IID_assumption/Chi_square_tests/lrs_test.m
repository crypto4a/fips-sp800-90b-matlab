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
% [P, record, indice, step] = lrs_test(input_data, max_size)
%
% This test calculates the longest overlapping substring that is repeated
% through a binary dataset.
%
% input_data:   input vector (binary or integers). Can handle both 
%               horizontal and vertical vectors.
%
% max_size:     maximum size to be considered
%
% P:            probability that X is greater than or equal to 1, where X 
%               is a binomial distributed random variable as described in 
%               par. 5. of section 5.2.5
%
% record:       the length of the streak that is repeated
%
% indice:       position of the first digit of the first time the streak is
%               seen
% step:         indice+step = the first digit of the second time the streak 
%               is seen
%
function [P, record, indice, step] = lrs_test(input_data, max_size)

    % Setting a value by default
    if nargin == 1
        max_size = length(input_data);
    end

    % Limiting the size of the input_data as it takes a lot of time to compute
    if length(input_data) > max_size
        L = max_size;
        input_data = input_data(1:max_size);
    else
        L = length(input_data);
    end

    % Counting the sum of the probability of each different instance squared
    tab1 = tabulate(input_data);
    pcol = sumsqr(tab1(:, 2)/L);

    % Finding the longest repeated substring
    % Setting some parameters
    k = 1;
    record = 2;
    count = 0;

    % We go through the list 
    while k < (L+1-record)
        i = 1;
        temp = k;                      % we don't want to change the value of k
    
        % For every element in the list, we try to see how long the longest
        % substring being repeated is.
        while (i+temp) < (L+1)
        
            % If the two substring still match, we carry on
            if input_data(temp) == input_data(i+temp)
                count = count + 1;
                temp = temp + 1;

            % If the two substring diverge but we have a new record
            elseif ( input_data(temp) ~= input_data(i+temp) )&& ( count > record )
                record = count;
                indice = k;
                count = 0;
                step = i;
                i = i + 1;
                temp = k;

            % If the two substring diverge but we do not have a new record
            else
                i = i + 1;
                count = 0;
                temp = k;
            end
        end
        k = k + 1;
    end

    % Determining
    N = nchoosek(L-record+1, 2);
    P = 1-(1-pcol^record)^N;

    % Displaying results
    if P < 0.001
        disp('Test failed. P should have been above 0.001');
        disp('But it was:');
        disp(P);
    else
        disp('Test passed. P needed to be above 0.001');
        disp('And it was:');
        disp(P); 
    end
end
