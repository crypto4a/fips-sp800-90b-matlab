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
% T = compression_test(input_data)
%
% This function is specified in NIST SP-800-90B (January 2018) in 
% section 5.1.11. It writes every bit as a byte to create a string.
% It then compresses this binary file using the bzip2 algorithm. We then 
% measure the size of this file. If inputs are "truly" random, there
% shouldn't be a lot of compression
%
% input_data:   array of input bits. Can be of any size
%
% t:            Number of bytes in the compressed input_data
%
function T = compression_test(input_data)

    % Creating a temporary bin file and writing the integers as bytes. 
    fid = fopen('tmp.bin','w');
    fwrite(fid,input_data);
    fclose(fid);
    
    % Compressing the input_data through a shell command
    system('bzip2 tmp.bin');

    % Getting the number of bytes
    s = dir('tmp.bin.bz2');
    T = s.bytes;

    % Removing the temporary files
    delete tmp.bin.bz2;
end
