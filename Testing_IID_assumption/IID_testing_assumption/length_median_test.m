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
% [T] = length_median_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in section
% 5.1.6. This test calculates the longest run of numbers either above or
% below the median. 
%
% input_data:   vector of input bits (binary only). Can handle both 
%               horizontal and vertical vectors.
%
% T:            Result of the test, which corresponds to the longest run of
%               numbers either above or below the median
%
function[T] = length_median_test(input_data)

    % Defining some parameters
    L       = length(input_data);
    s_prime = zeros(1,L);
    X       = 0.5;          % median used for binary data
    record  = 0;
    count   = 1;            % initial value of the length of the first run

    % Calculating the length of the biggest run
    for i=1:L

        %Creating the vector s_prime
       if input_data(i) >= X
           s_prime(i) = 1;
       else
           s_prime(i) = -1;    
       end

       % Adding an element to the length
       if i>1
           if s_prime(i) == s_prime(i-1)
               count = count+1;
           else
               if count>record
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
