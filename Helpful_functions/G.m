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
% [x] = G(z,v,d)
%
% This function is used in the compression_estimate that determines the
% min_entropy of a sample that is non-IID.
%
% z:        input value of function G as shown in par 7. of section 6.3.4
%
% v:        parameter from compression_estimate that corresponds to the
%           number of observations used for testing
%
% d:        length of the dictionnary passed from the compression estimate
%
function [x] = G(z, v, d)

    % Initializing some parameters
    x = 0;
    ongoing_sum = 0;

    % Initial Sum. Since we want to increase efficiency, we will not start the
    % second sum (from u = 1 to t) at every loop. We will simply use an
    % ongoing sum to track the changes.
    for u = 1:d-1
        ongoing_sum = ongoing_sum + log2(u).*z.^2.*(1-z).^(u-1);
    end

    % We can now start to increase t and update the ongoing_sum variable. Also,
    % there was an error in NIST's document. The first sum should go from t =
    % d+1 to v+d.
    for t = d+1:v+d
        ongoing_sum = ongoing_sum + log2(t-1).*z.^2.*(1-z).^(t-2); % where t-1 corresponds to u (the newest element     is added to the ongoing sum)
        x = x + ongoing_sum + log2(t).*z.*(1-z).^(t-1);
    end

    x = x./v;
end


        
