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
% [lower_bounds, upper_bounds] = finding_bounds( averages, std_deviations )
%
% This function finds the lower and upper bounds of a random variable, such
% that the probability of observing an event greater than the upper bound
% is the same as observing an event lower than the lower bound and is equal
% to 5/10000. Therefore, the results of the IID tests on the sampled data
% should be within those bounds in order to pass the test.
%
% averages: 		vector of averages of the different IID test results
%			for a given distribution
%
% std_deviation: 	vector of standard deviation associated to the different
%			IID test results for a given distribution
%
% lower_bounds:		vector of the lower bounds of the 'good' region (where the
%			test passes)
%
% upper_bounds:		vector of the upper bounds of the 'good' region (where the
%			test passes)
%
function [lower_bounds, upper_bounds] = finding_bounds( averages, std_deviations )

    % Simply checking inputs to avoid some errors
    if size(averages, 1) > size(averages, 2)
        averages = transpose(averages);
    end

    if size(std_deviations, 1) > size(std_deviations, 2)
        std_deviations = transpose(std_deviations);
    end

    % Making sure that there are as many values of x_m as std_deviations
    if size(averages, 2) ~= size(std_deviations, 2)
        error('averages and std_deviations must have the same dimension');
    end

    % Using a normalized gaussian function, we figure what are the bounds we need to
    % avoid. Those values were obtained using the inverse Q-function of 5/10000
    z_upper =  3.29052673;
    z_lower = -3.29052673;

    % We de-normalize the value to fit our parameters 
    upper_bounds = ones(1,length(averages)) .* z_upper .* std_deviations + averages;
    lower_bounds = ones(1,length(averages)) .* z_lower .* std_deviations + averages;
end
