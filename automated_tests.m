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
% [C0, C1, success, h, data_id] = automated_tests(pattern, folder)
%
% This function runs a succession of IID permutation tests as described in
% NIST SP800-90B (January 2018) in section 5.1 and min-entropy estimates as 
% described in the same publication in section 6.3. 
%
% pattern:      common string to every file that are wanted. Wildcards 
%               can be used. Pattern can be either a string array or a char
%               array. If it's a string array, this function will get files
%               matching every pattern
%
% folder:       this input is offered as an option to select only files
%               contained within a certain directory. Note that this
%               directory must be within the same directory as the file
%               'setup.m' and it is possible to use wildcards and patterns
%               for the folder. So it is not necessary to specify the whole
%               directory. Also, it can be either a string or an array and,
%               like 'pattern', if it's a string array, this funtion will
%               get files matching every folder. Finally, the number of
%               strings must be the same in 'folder' and in 'pattern'
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
% h:            consists in the min-entropy measured according to NIST's
%               SP800-90B (January 2018)
%
% data_id:      vertical vector containing the names of the files imported.
%               The rows of the other output vectors corresponds to the
%               rows of this vector.
%
function [C0, C1, success, h, data_id] = automated_tests(pattern, folder)

    % We gather the data we want using this function.
    if nargin == 1
        [input_data, data_id, data_len] = get_data(pattern);
    elseif nargin == 2
        [input_data, data_id, data_len] = get_data(pattern, folder);
    else
        error('Too many inputs')
    end

    % We perform IID test for each of the datasets
    [C0,C1, success] = fast_test_IID_assumption(input_data,data_len);

    % We measure the min-entropy depending on the track (IID or non-IID)
    h = zeros(length(data_id), 1);
    for i = 1:length(data_id)
        if success(i) == 1
            h = most_common_value_estimate(input_data(i,1:data_len));
        else
            h = min(all_estimates(input_data(i,1:data_len),data_len));
        end
    end
end