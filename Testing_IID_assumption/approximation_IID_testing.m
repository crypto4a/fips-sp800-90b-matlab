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
% [IID_binary, IID_analog] = approximation_IID_testing( input_data )
%
% This function gives a good estimate of the IID test and is very fast, but 
% it doesn't generate exactly the same results as the full IID test. We
% suggest to run this test when trying to test multiple datasets to get
% an idea of how IID those datasets are. However, we also recommend running
% the real version of the test (fast_test_IID_assumption.m) to obtain
% proper results. 
%
% We have tested (using fast_test_IID_assumption.m) datasets of one million
% bits containing 450,000 x '1', 455,000 x '1', 460,000 x '1' ... 550,000 x
% '1' and calculated the average and variance that was generated for every
% test. This function uses those values to interpolate (using Lagrange's
% interpolation) the average and the variance associated to the number of
% '1' contained in the dataset under test (dut). Then, we find upper bounds 
% and lower bounds of confidence for every IID test. We finally compare the
% test results ran on the dut with the bounds obtain from previously
% calculated (and interpolated) test results. If the test results are
% within those bounds, we keep the IID assumption, otherwise, we don't.
% 
% [IID_binary, IID_analog] = approximation_IID_testing( input_data )
%
% input_data:       array of input data. Every row is considered as a
%                   different dataset.
%
% IID_binary:       array of binary values. The rows match the rows in
%                   input_data and the every columns represent a same IID
%                   test. A '1' is for a pass and a '0' is for a fail.
%
% IID_analog:       array of real numbers. Very similar to IID_binary in
%                   its construction. However, the values contained in this
%                   array are the difference between the interpolated
%                   average and the test results in standard deviations.
%                   For instance, if the interpolated average was 1, the
%                   interpolated standard deviation was 2 and the test
%                   result was 3, then IID_analog(i,j) would be 1.
%
function [IID_binary, IID_analog] = approximation_IID_testing( input_data )

    NBR_TESTS  = 19;                % Number of IID test
    [nrows, L] = size(input_data);

    % Automatically transposing the array if the size don't seem to match
    if ( nrows > L )
        input_data = transpose(input_data);
    end

    % Resizing the data to get 1 million bits
    input_data = input_data(:, 1:1e6);

    % Arrays that will be generated. IID_binary is an array 
    % of ones and zeros. Every row is associated to the same
    % row as the input_data and every column is associated to one
    % of the IID tests. A one is to indicate a test passed (is
    % IID) and a zeros is for a fail. IID_analog is a very similar
    % array, but instead of being binary values, each element contains
    % the difference between the test result and the average of test 
    % results in terms of standard deviations. This can be useful to see how 
    % far off we are from the actual values.
    IID_binary     = zeros(nrows, NBR_TESTS);
    IID_analog     = zeros(nrows, NBR_TESTS);


    % x_m is a vector of different quantities of '1' used
    % to perform the tests. averages is an array containing the
    % tests results' averages. Every row contains the values associated
    % to a different x and every column contains the values 
    % associated to a different test. std_deviations is an array
    % containing the tests results' averages. Every row contains the 
    % values associated to a different x and every column contains the 
    % values associated to a different test.
    x_m            = 450e3 : 5e3 : 550e3;
    averages       = csvread('precalculated_averages.csv');
    std_deviations = csvread('precalculated_std_deviations.csv');

    % Interpolated averages and std_deviations for every test and for
    % every dataset. Each row contains the values associated to a same
    % dataset, while the columns contains the values associated to a 
    % same IID test.
    interpolated_averages       = zeros(nrows, NBR_TESTS);
    interpolated_std_deviations = zeros(nrows, NBR_TESTS);

    for i = 1 : nrows
    
        % Counting the proportion of '1' to find an interpolated approximation
        % of the average and the variance for every test result
        pop_count = sum(input_data(i, :));
        for j = 1 : NBR_TESTS
            interpolated_averages(i, j) = lagrange_interpolation(x_m, averages(:, j)', pop_count);
            interpolated_std_deviations(i, j) = lagrange_interpolation(x_m, std_deviations(:, j)', pop_count);
        end

        % Generating bounds of confidence and the dut's test results
        [lower_bounds, upper_bounds] = finding_bounds(interpolated_averages(i, :), interpolated_std_deviations(i, :));
        T = fast_IID_test_runner(input_data(i, :));      % Don't forget to uncomment the compression_test
    
        % Checking if the dut's test results are within the bounds
        for j = 1 : NBR_TESTS

            % Filling IID_binary -> 1 is for a pass, 0 for a fail
            if ( T(j) >= lower_bounds(j) ) && ( T(j) <= upper_bounds(j) )
                IID_binary(i, j) = 1;
            end
        
            % Filling IID_analog
            IID_analog(i, j) = ( T(j) - interpolated_averages(i, j) ) / interpolated_std_deviations(i, j);
        end
    end

    if nrows > 1
    
         % Generating graphs
         figure(1);
         surf(1:NBR_TESTS, 1:nrows, IID_binary);
         title('Array of IID tests results (1 for pass, 0 for failure)');
         xlabel('Number of the test');
         ylabel('Dataset');
         zlabel('IID or not');

         figure(2);
         surf(1:NBR_TESTS, 1:nrows, IID_analog);
         title('IID map with relation to variance');
         xlabel('Number of the test');
         ylabel('Dataset');
         zlabel('Difference between test result and expected result');
    end
    
    % Controlling the number of outputs
    if nargout > 2
        error('Too many inputs');
    end
end
