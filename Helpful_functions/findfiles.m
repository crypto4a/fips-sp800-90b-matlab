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
%
% Note: This code was taken from Matt Tearle's post on Matlab's forum in
% this link: https://www.mathworks.com/matlabcentral/fileexchange/57298-recursively-search-for-files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% flist = findfiles(pattern,basedir)
%
% Recursively finds all instances of files and folders with a naming pattern
%
% FLIST = FINDFILES(PATTERN) returns a cell array of all files and folders
% matching the naming PATTERN in the current folder and all folders below
% it in the directory structure. The PATTERN is specified as a string, and
% can include standard file-matching wildcards.
%
% FLIST = FINDFILES(PATTERN,BASEDIR) finds the files starting at the
% BASEDIR folder instead of the current folder.
%
% Examples:
% Find all MATLAB code files in and below the current folder:
%   >> files = findfiles('*.m');
% Find all files and folders starting with "matlab"
%   >> files = findfiles('matlab*');
% Find all MAT-files in and below the folder C:\myfolder
%   >> files = findfiles('*.mat','C:\myfolder');
%
% Copyright 2016 The MathWorks, Inc.
%
function flist = findfiles(pattern,basedir)

% Maybe need to add extra bulletproofing for stupid things like
% findfiles('.*')

% Input check
if nargin < 2
    basedir = pwd;
end
if ~ischar(pattern) || ~ischar(basedir)
    error('File name pattern and base folder must be specified as strings')
end
if ~isfolder(basedir)
    error(['Invalid folder "',basedir,'"'])
end

% Get full-file specification of search pattern
fullpatt = [basedir,filesep,pattern];

% Get list of all folders in BASEDIR
d = cellstr(ls(basedir));
d(1:2) = [];
d(~cellfun(@isdir,strcat(basedir,filesep,d))) = [];

% Check for a direct match in BASEDIR
% (Covers the possibility of a folder with the name of PATTERN in BASEDIR)
if any(strcmp(d,pattern))
    % If so, that's our match
    flist = {fullpatt};
else
    % If not, do a directory listing
    f = ls(fullpatt);
    if isempty(f)
        flist = {};
    else
        flist = strcat(basedir,filesep,cellstr(f));
    end
end

% Recursively go through folders in BASEDIR
for k = 1:length(d)
    flist = [flist;findfiles(pattern,[basedir,filesep,d{k}])]; %#ok<AGROW>
end
end       
