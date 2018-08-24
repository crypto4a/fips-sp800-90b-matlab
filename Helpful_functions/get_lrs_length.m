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
% [LRS_new] = get_lrs_length(L_old, L_new, LRS_old)
%
% This function gives an estimate of the length of the longest repeated
% substring(LRS) within some big dataset based on the LRS of a smaller 
% dataset. We assume the distribution doesn't change. This test is used in 
% the LRS estimate described in NIST SP800-90B (January 2018) in section 
% 6.3.6
%
% L_old:        Length of the old dataset
%
% L_new:        Length of the new dataset
%
% LRS_old:      LRS value from the old dataset
%
% LRS_new:      Probable LRS value with the new dataset
%
function [LRS_new] = get_lrs_length(L_old, L_new, LRS_old)

    % Finding the probability that we get the old LRS with a dataset of length
    % L_old.

    %Results become too unprecise 
    UPPER_LIMIT = 100;

    % P2 is the probability that one particular substring has at least 2
    % occurrences, with any n >= LRS_old. P2 is calculated with a some of P1.
    % P1 is the probability that one particular sequence of length n has at
    % least 2 occurrences. It is calculated with binomial distribution. p is
    % the probability of having the proper sequence if we pick randomly one
    % sequence.
    P2 = 0;
    for n = LRS_old : L_old - 1
        p = 2^(-n);
        P1 = 1-exp((L_old-n)*log(1-p))-exp(log(L_old-n)-n*log(2)+...
            (L_old-n-1)*log(1-p));
        P2 = P2 + P1;
    end

    % P3 is the probability that there's at least one sequence of length at
    % least equal (or superior) to LRS_old that has at least 2 occurrences
    P3 = 1 - exp(2 ^ LRS_old * log(1 - P2));

    % We repeat those steps with different values of k, stopping when the
    % probability P3 is the same than in the previous distribution
    for k = LRS_old:UPPER_LIMIT
        P2_new = 0;
        for n=k:L_new-1
            p = 2^(-n);
            P1_new = 1-exp((L_new-n)*log(1-p))-exp(log(L_new-n)-n*log(2)+...
                     (L_new-n-1)*log(1-p));
            P2_new = P2_new + P1_new;
        end
        P3_new = 1-exp(2^k*log(1-P2_new));
        if P3_new <= P3
            break;
        end
    end

    LRS_new = k;
end
