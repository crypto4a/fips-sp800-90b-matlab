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
% [input_data] = Shuffle(input_data)
%
% This function shuffles the element of a vector using the Fisher-Yates
% algorithm. Basically, it goes through every element of a vector and swaps
% the current element with another one, determined randomly. This function 
% is based on the description in NIST SP800-90B (January 2018) in section 
% 5.1. It can be used for binary inputs or integers strictly positive. It
% will treat every row independently.
%
% input_data:               Array of input bits (or integers strictly
%                           positive)
%
% shuffled_input_data:      Array of shuffled elements
%
function [input_data] = Shuffle(input_data)
    
    % Creating a vector of uniformly distributed random integers;
    [nrows, L] = size(input_data);
    j = ceil(rand([1 L]).*L);
    
    % Shuffling the data
    for row = 1:nrows
        for i = 1:L
            tmp = input_data(row,i);
            input_data(row,i) = input_data(row,j(i));
            input_data(row,j(i)) = tmp;
        end
    end
end
