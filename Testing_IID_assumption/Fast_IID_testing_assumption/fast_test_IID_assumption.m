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
% [C0, C1, success] = fast_test_IID_assumption(input_data, data_len)
%				%
% This function tests the IID assumption as described in NIST SP800-90B
% (January 2018) section 5.1. It runs a battery of statistical tests on the
% sampled data. Then, it shuffles the same data 10000 times, performing
% each test everytime and comparing the results with the original sampled
% data. If the comparators (C0 and C1) remain within defined limits, we
% presume the data to be IID.
%
% input_data:   array of input bits. If input_data has multiple rows,
%               the test will treat each row as a separate vector of bits
%
% C0:           array that contains the amount of times the statistical 
%               tests' results were greater with the sampled bits than 
%               with the shuffled bits. This value should be less than 9995 
%               to avoid rejecting the IID assumption. If there are
%               multiple rows in the input_data, each row of C0 will
%               present the test result of the values associated to this
%               row in input_data.
%
% C1:           array that contains the amount of times the statistical 
%               tests gave equal results. C1(i) + C0(i) should not be less 
%               than 5 to avoid rejecting the IID assumption. If there are
%               multiple rows in the input_data, each row of C1 will
%               present the test result of the values associated to this
%               row in input_data.
%
% success:      returns a 1 if the IID assumption is maintained and a zero
%               otherwise
%
function [C0, C1, success] = fast_test_IID_assumption(input_data, data_len)
%% Defining some parameters

    % Some constants
    NBR_TEST            = 19; 
    NBR_SHUFFLE         = 10000;
    TEST_LIMIT_LOWER    = 5;
    TEST_LIMIT_UPPER    = 9995;

    % Some parameters
    [nrows, L]      = size(input_data);
    C0              = zeros(nrows, NBR_TEST);
    C1              = zeros(nrows, NBR_TEST);  
    success         = zeros(nrows, 1);
    
    % In case we don't use data_len
    if nargin < 2
        data_len = ones(min(nrows, L), 1) * max(nrows, L);
    end    
    
    % This is to avoid confusion when using matrices
    if nrows > L   
        warning('Be aware that you may want to transpose your array.');
        disp('Type <a> if you want to exit this function');
        disp('Type <b> if you want to transpose the input and keep going with the function');
        disp('Type <c> if you want to continue with this function');

        key = char(getkey());
        if(strcmp (key , 'a'))
            return
        elseif (strcmp (key, 'b'))
            input_data = transpose(input_data);
            temp = nrows;
            nrows = L;
            L = temp;
        elseif ~(strcmp (key, 'c'))
            error("The key you pressed wasn't an option");
        end
    end

    %% Performing the test
    for row = 1:nrows
        % Getting test values from original sequence
        T = fast_IID_test_runner(input_data(row, 1:data_len(row)));
    
        % Matlab doesn't handle well different arrays in a parfor. we will
        % therefore use temporary arrays containing the necessary information
        C0_temp         = zeros(1, NBR_TEST);                                   
        C1_temp         = zeros(1, NBR_TEST);  
        tmp_input_data  = input_data(row, 1:data_len(row));
    
        % Getting test values from shuffled sequence and comparing with
        % original sequence    
        parfor j = 1:NBR_SHUFFLE
            shuffled_data   = Shuffle(tmp_input_data);
            T_prime         = fast_IID_test_runner(shuffled_data);
            C0_temp         = C0_temp  + double(T > T_prime);
            C1_temp         = C1_temp  + double(T == T_prime);
        end
    
        % We assign the values to C0
        C0(row, :) = C0_temp;
        C1(row, :) = C1_temp;
    
        % Showing results
        if (any(C0(row, :) >= TEST_LIMIT_UPPER) || any(C0(row, :) + C1(row, :)...
                                                   <= TEST_LIMIT_LOWER))
            disp('The IID assumption must be rejected. The following matrix');
            disp('will have a logical 1 when the test has failed');
            disp(C0(row, :) >= TEST_LIMIT_UPPER | C0(row, :) + C1(row, :)...
                                                  <= TEST_LIMIT_LOWER);
            success(row) = 0;
        else
            disp('We assume that the noise source outputs are IID');
            success(row) = 1;
        end
    
        % Display current status
        fprintf('Finished simulation %d out of %d\n', row, nrows);
    end
end
