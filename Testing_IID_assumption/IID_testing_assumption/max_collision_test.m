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
% [T] = max_collision_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in section
% 5.1.8. This test first converts every non-overlapping 8 bit sequence into
% a list of integers (input_data_conv) between 0 and 255 corresponding to 
% the decimal equivalent of those bits. Then, it measures the maximum 
% number of values before a dupplicate is found.
%
% input_data:   vector of input bits (binary only). Can handle only 
%               horizontal vectors.
%
% T:            Result of the test, which corresponds to the length of the
%               longest run of values either increasing or decreasing
function[T] = max_collision_test(input_data)

    % Converting the input_data into integers from 0 to 255.
    input_data_conv = convert2(input_data, 8);

    % Declaring some parameters
    L       = length(input_data_conv);
    i       = 1;
    t       = ones(1, 256)*-1;  % Will be used as a temporary memory 
    
    record  = 0;                % Instead of using array C, we will keep 
                                % track of the record run

    % Running through the data
    while i < L
        j = 1;
        
      % Finding the first collision
      while (i+j) < (L+1)
          temp = input_data_conv(i+j-1);

          % Checking if we have found a second occurence
          if ismember(temp, t)
              if j>record
                  record = j;  % Setting new record run
              end
          else
              t(j) = temp;     % Adding element to t
              j = j+1;
              continue
          end
          break
      end
      i = i+j;
      t(1, :) = -1;           % Re-initializing the array of elements seen
    end

    % Returning the maximum collision
    T = record;
end
