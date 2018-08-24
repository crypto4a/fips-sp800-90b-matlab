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
% [C0, C1] = test_IID_assumption(input_data)
%
% This function tests the IID assumption as described in NIST SP800-90B
% (January 2018) section 5.1. It runs a battery of statistical tests on the
% sampled data. Then, it shuffles the same data 10000 times, performing
% each test everytime and comparing the results with the original sampled
% data. If the comparators (C0 and C1) remain within defined limits, we
% presume the data to be IID.
%
% input_data:   vector of input bits (binary only). Can handle both 
%               horizontal and vertical vectors.
%
% C0:           vector that contains the amount of times the statistical 
%               tests's results were greater with the sampled bits than 
%               with the shuffled bits. This value should be less than 9995 
%               to avoid rejecting the IID assumption
%
% C1:           vector that contains the amount of times the statistical 
%               tests gave equal results. C1(i) + C0(i) should not be less 
%               than 5 to avoid rejecting the IID assumption
%
function[C0, C1] = test_IID_assumption(input_data)

    % This test will not work if the input has multiple rows
    [nrows, ncols] = size(input_data);
    if nrows > 1 && ncols == 1
        input_data = transpose(input_data);
    elseif nrows > 1 && ncols > 1
        error('This function can only be performed on a vector');
    end

    % This performs the tests on a single list of the values. 
    t     = zeros(1, 20);
    t(1)  = excursion_test(input_data);
    t(2)  = run_test(input_data);
    t(3)  = length_test(input_data);
    t(4)  = incdec_test(input_data);
    t(5)  = run_median_test(input_data);
    t(6)  = length_median_test(input_data);
    t(7)  = avg_collision_test(input_data);
    t(8)  = max_collision_test(input_data);
    t(9)  = periodicity_test(input_data, 1);
    t(10) = periodicity_test(input_data, 2);
    t(11) = periodicity_test(input_data, 8);
    t(12) = periodicity_test(input_data, 16);
    t(13) = periodicity_test(input_data, 32);
    t(14) = covariance_test(input_data, 1);
    t(15) = covariance_test(input_data, 2);
    t(16) = covariance_test(input_data, 8);
    t(17) = covariance_test(input_data, 16);
    t(18) = covariance_test(input_data, 32);
    t(19) = compression_test(input_data);


    % We perform every test with a sample that is shuffled (with the
    % Fisher-Yates algorithm) and we do this 10,000 times while 
    % comparing with the original sample every time.
    t_prime = zeros(1,19);
    for j = 1:10000
        shuffled_data = Shuffle(input_data);
        t_prime(1)    = excursion_test(shuffled_data);
        t_prime(2)    = run_test(shuffled_data);
        t_prime(3)    = length_test(shuffled_data);
        t_prime(4)    = incdec_test(shuffled_data);
        t_prime(5)    = run_median_test(shuffled_data);
        t_prime(6)    = length_median_test(shuffled_data);
        t_prime(7)    = avg_collision_test(shuffled_data);
        t_prime(8)    = max_collision_test(shuffled_data);
        t_prime(9)    = periodicity_test(shuffled_data, 1);
        t_prime(10)   = periodicity_test(shuffled_data, 2);
        t_prime(11)   = periodicity_test(shuffled_data, 8);
        t_prime(12)   = periodicity_test(shuffled_data, 16);
        t_prime(13)   = periodicity_test(shuffled_data, 32);
        t_prime(14)   = covariance_test(shuffled_data, 1);
        t_prime(15)   = covariance_test(shuffled_data, 2);
        t_prime(16)   = covariance_test(shuffled_data, 8);
        t_prime(17)   = covariance_test(shuffled_data, 16);
        t_prime(18)   = covariance_test(shuffled_data, 32);
        t_prime(19)   = compression_test(shuffled_data);
        
        %Comparing results
        C0 = C0 + double(t > t_prime);
        C1 = C1 + double(t == t_prime);
    end
    
    % Showing results
    if any(C0 >= TEST_LIMIT_UPPER) || any(C0+C1 <= TEST_LIMIT_LOWER)
        disp('The IID assumption must be rejected. Here is matrix that');
        disp('will be a logical 1 when the test has failed');
        disp(C0 >= TEST_LIMIT_UPPER || C0+C1 <= TEST_LIMIT_LOWER);
    else
        disp('We assume that the noise source outputs are IID');
    end
end
    
