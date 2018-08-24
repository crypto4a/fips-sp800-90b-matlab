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
% [input_data_conv] = convert1(input_data, symbol_size)
%
% This function transforms a vector of bits into a vector of integers
% between 0 and symbol_size of how many '1' there were in every non-
% overlapping symbol_size bit sequences. If the number of bits is not a 
% multiple of symbol_size, zeros are added at the end. If the input 
% presented is a matrix, the function treats it as many independent rows.
% This function is based on the description in NIST SP800-90B (January 
% 2018) in section 5.1. It is used in different IID tests such as those 
% described in sections 5.1.2, 5.1.3, 5.1.4, 5.1.9 and 5.1.10.
%
% input_data:       Array of input bits
%
% symbol_size:      Division of the initial input data
%
% input_data_conv   Array of converted input (integers)
%
function [input_data_conv] = convert1(input_data, symbol_size)

    % Using 8 bits as default
    if nargin < 2
        symbol_size = 8;
    end
    
    % Getting information on array and initializing new array
    [nrows,L] = size(input_data);
    remainder = mod(L,symbol_size);
    input_data_conv = zeros(nrows,ceil(L/symbol_size));

    % Adding zeros to the array to have a length multiple of 8
    if remainder ~=0
        input_data = [input_data zeros(nrows,symbol_size-remainder)];  
        L = L + symbol_size -remainder;
    end

    % Converting the binary list
    for row = 1:nrows
        input_data_conv(row,:) = sum(reshape(input_data(row,:),...
                                 [symbol_size,L/symbol_size]),1);
    end
end
