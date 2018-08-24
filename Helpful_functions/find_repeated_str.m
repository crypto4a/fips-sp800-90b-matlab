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
% [found, str_array, N] = find_repeated_str(input_data, str_size, k)
%
% This function returns an array containing all str_size strings within the
% set as decimal numbers (instead of strings)
%
% input_data:   horizontal vector of input bits (only bits and only
%               horizontal)
%
% str_size:     size of the strings 
%
% k:            base of the input. 2 for binary, 8 for octal, etc.
%
% found:        logical value that is 1 if there are at least two
%               occurrences of a string of size str_size
%
% str_array:    array of size (input_data-str_size) that contains all
%               str_size overlapping sequence in the form of decimal
%               numbers
%
% N:            vector containing the number of occurrences of every
%               str_size tuple
%
% edges:        vector containing the values of the decimal interpretations
%               of every sequence found in numerical order.
%
function [found, str_array, N, edges] = find_repeated_str(input_data, str_size, k)

    % Default parameter is for binary inputs
    if nargin == 2
        k = 2;
    end
    
    % Getting information on array and initializing new array
    [nrows, L] = size(input_data);
    str_array = zeros(1, L-str_size+1);
    
    % If the input is not an horizontal vector
    if nrows > 1
        error('Input_data can only be an horizontal vector');
    end

    % Converting every possible str_size-bit overlapping sequence into a
    % decimal value. This generates an array of the decimal equivalent of
    % str_size overlapping sequences of bits. Every row contains
    % non-overlapping sequence that starts with a different offset
    % (therefore covering overlaps).
    powerkvec = k.^(0:str_size-1);
    for i = 1:str_size
          end_bit = L - mod(L - i + 1, str_size);
          nbr_col = (end_bit - i + 1)/str_size;
          reshaped_data = reshape(input_data(i:end_bit), [str_size,...
                          nbr_col]);
          str_array(1, i:str_size:end_bit) = powerkvec * reshaped_data;
    end
    
    % Getting a single occurence of every element in str_array
    dictionnary = unique(str_array);
    
    % Counting the number of occurrence of every element in str_array. We
    % need to duplicate the last value to avoid Matlab grouping the last
    % two values together
    [N, edges] = histcounts(str_array, [dictionnary dictionnary(end)]);   
    
    % Few calls to this function need the edges
    if nargout <= 3
        edges = [];
    end
    
    if any(N >= 2)
        found = true;
    else
        found = false;
    end   
end
    

