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
% [T] = avg_collision_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in section
% 5.1.7. Converts every non-overlapping 8 bit sequence into a list 
% of integers (input_data_conv) between 0 and 255 corresponding to the 
% decimal equivalent of that sequence. Then, it counts the number of
% successive sample values until a duplicate is found.
%
% input_data:   horizontal vector of bits (binary only)
%
% T:            test result corresponding to the average number of 
%               successive sample until a duplicate is found
%
function[T] = avg_collision_test(input_data)

    % Converting the binary input into integers ranging from 0 to 255
    input_data_conv = convert2(input_data, 8);

    %Declaring some parameters
    L       = length(input_data_conv);
    i       = 1;
    t       = ones(1, 256)* -1; % Will be used as a temporary memory 
    count   = 0;                % Instead of using array C, we will sum the 
    sum     = 0;                % different j's as we go on and count the number 
                                % of elements in C
    
    % Running through the data
    while i < L
        j = 1;
      
      % Finding the first collision
      while (i+j)<(L+1)
          temp = input_data_conv(i+j-1);

          % Checking if we have found a second occurence
          if ismember(temp, t)

              % Same as adding element to C and taking the average
              sum = sum+j;  
              count = count + 1; 
          else
              t(j) = temp; % Adding element to t
              j = j+1;
              continue
          end
          break
      end
      i = i+j;
      t(1, :) = -1;       % Re-initializing the array of elements seen
    end

    % Returning the average of the collisions measured
    T = sum/count;
end
