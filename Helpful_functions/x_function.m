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
% [x] = x_function(P_local,r)
%
% This iterating function is used to solve for P_local in the Multi Most 
% Common in Window prediction estimate (section 6.3.7), in the lag 
% prediction estimate (section 6.3.8), in the MultiMMC prediction estimate 
% (section 6.3.9) and in the LZ78Y prediction estimate (section 6.3.10) in 
% NIST SP800-90B (January 2018).
%
% P_local:      Input parameter we need to solve for. Can be a vector
%
% r:            Input parameter of the longest run
%
% x:            Answer after nbr_iter iterations. x can be a vector.
%
function x = x_function(P_local,r)
    %Initializing some parameters
    q = 1 - P_local;
    nbr_iter = 10;
    x_old = ones(1,length(P_local));

    %Doing the iterations
    for i=1:nbr_iter
        x_new = 1 + q .* P_local.^r .* x_old.^(r+1);
        x_old = x_new;
    end

    x = x_new;
end
    
