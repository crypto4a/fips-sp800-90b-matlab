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
% [T] = length_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in section
% 5.1.3. This test first converts every non-overlapping 8 bit sequence into
% a list of integers (input_data_conv) between 0 and 8 corresponding to the 
% quantity of '1' in that sequence. Then, it calculates the longest run of
% values that are either increasing or decreasing.
%
% input_data:   vector of input bits (binary only). Can handle only 
%               horizontal vectors.
%
% T:            Result of the test, which corresponds to the length of the
%               longest run of values either increasing or decreasing
function[T] = length_test(input_data)

    % Converting a binary list into integers from 0 to 8
    input_data_conv = convert1(input_data, 8);

    % Defining some parameters
    L       = length(input_data_conv);
    s_prime = zeros(1, L-1);
    record  = 0;
    count   = 1;                  % counts the length of a run
    
    % Calculating the length of runs
    for i = 1:L-1
        
       % Creating the vector s_prime
       if input_data_conv(i)> input_data_conv(i+1)
           s_prime(i) = -1;
       else
           s_prime(i) = 1;    
       end
       
       % Adding an element to the length 
       if i > 1
           if s_prime(i) == s_prime(i-1)
               count = count+1;
           else
               if count > record
                   record = count;
               end
               count = 1;
           end
       end
       
       % If the record is found at the end of the sequence
       if i == L && count > record
          record = count;
       end
    end
    
    % Returning the record length
    T = record;
end
