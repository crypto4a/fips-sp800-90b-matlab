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
% independance_test_binary(input_data)
%
% This function checks for independance using a chi-square test as
% prescribed in NIST SP-800-90B (January 2018). 
%
% input_data: vector of binary elements (binary only). Can handle both
%             horizontal and vertical vectors
%
function independance_test_binary(input_data)

    % Setting some parameters 
    T = 0;
    L = length(input_data);
    p1 = sum(input_data)/L;         % proportion of ones in the set
    p0 = 1-p1;                      % proportion of zeros in the set

    % Transposing the data
    if size(input_data,1) > size(input_data,2)
        input_data = transpose(input_data);
    end

    % Calculating the value of m
    possible_m = 1:11;
    expression = min(p0,p1).^possible_m.*floor(L./possible_m);
    m = find(expression >= 5,1,'last');
    if isempty(m)
        m = 11;
    end

    % Calculating the number of occurance "o" of every m-bit tuples in the 
    % input_data (with overlap)
    o = zeros(1, 2^m);
    for i = 1:floor(L/m)
        index = 1+bi2de(input_data((i-1)*m+1:i*m),'left-msb');
        o(index) = o(index) + 1;
    end
    
    % Calculating the number of one's in every m-bit tuples 
    w = zeros(1, 2^m);
    for i=0:2^m-1
        w(1+i) = sum(de2bi(i,m));
    end

    % Calculating the value of e and T for every m-bit tuple
    e = zeros(1, 2^m);
    for i = 1:2^m
        e(i) = (p1^w(i)*p0^(m-w(i)))*floor(L/m);
        T = T + (o(i)-e(i))^2/e(i);
    end

    % Calculating the chi square critical value with 2^m-2 degrees of liberty
    % and a probability of 0.999
    chi2_value = chi2inv(0.999,2^m-2);

    % Displaying results
    if chi2_value<T
        disp('Test failed. The critical value was:');
        disp(chi2_value);
        disp('And the value from the test was:');
        disp(T);
    else
        disp('Test passed. The critical value was:');
        disp(chi2_value);
        disp('And the value from the test was:');
        disp(T);   
    end
end
