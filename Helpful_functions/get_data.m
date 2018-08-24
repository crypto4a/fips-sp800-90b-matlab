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
% [input_data,data_id,data_len] = get_data(pattern, folder)
%
% This function searches through the files present in the RNG_testing
% directory and returns an array containing the bits of every dataset and
% an array containing the names of every file. It uses a function to
% recursively find the names with a certain pattern. This function has been
% taken from https://www.mathworks.com/matlabcentral/fileexchange/57298-...
% recursively-search-for-files. Note that input_data will be adjusted to
% the size of the maximum set of data. To avoid errors in Matlab, the rest
% of the array will be filled with zeros if necessary.
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
% input_data:   array of the datasets contained in the files. Every
%               horizontal vector represents the data from the same file
%               and every row contains data from different files
%
% data_id:      vertical vector containing the names of the files imported.
%               The rows of this vector corresponds to the rows of
%               input_data.
%
% data_len:     vertical vector containing the length of the dataset in
%               every file. 
%
function [input_data,data_id,data_len] = get_data(pattern, folder)

    % This function will avoid processing files above this size. Note the
    % Matlab will produce an error when opening a file too large, so there is
    % no need to check the number of bytes prior to opening the file.
    MAX_LENGTH = 2e6;
    data_id = [];

    %% Getting the file names and the number of files
    
    % This if statement is for when the folder is not specified.
    if nargin == 1
        
        % If 'pattern' is an array of strings, we go through the array and
        % get the names of files each time.
        if isstring(pattern)
            for i = 1:length(pattern)
                temp = string(findfiles(['*' char(pattern(i)) '*']));
                data_id = [data_id; temp(isfile(temp),:)];
            end
            
        % If 'pattern' is an array of char, we simply call the function
        % 'findfiles'
        else
            temp = string(findfiles(['*' pattern '*']));
            data_id = [data_id; temp(isfile(temp),:)];
        end
    
    % This if statement is for when the folder is specified. Note that if
    % the folder is specified, both the folder and the pattern must be
    % either strings or char. If they are strings, pattern and folder must
    % have the same number of rows.
    elseif nargin == 2
        
        % If both pattern and folder are strings, we check if they have the
        % same number of rows and we go in a loop to get the files that
        % contain the pattern 'pattern(i)' in the folders that contain the
        % pattern 'folder(i)'.
        if ( isstring(pattern) && isstring(folder) )
            
            if length(pattern) ~= length(folder)
                error('pattern and folder must have the same number of elements');
            end
            for i = 1:length(pattern)
                
                % We check for the folders that contain 'folder(i)'
                folder_path = findfiles(['*' char(folder(i)) '*']);
                
                % Since there might be more than one folder with a match,
                % we do another loop
                for j = 1:size(folder_path,1)
                    if isfolder(folder_path(j,:))
                        temp = string(findfiles(['*' char(pattern(i)) '*'],...
                                                    char(folder_path(j,:))));
                        data_id = [data_id; temp(isfile(temp),:)];
                    end
                end
            end
        
        % If both pattern and folder are chars, we first find every folder
        % that contain 'folder'. We then go in a loop to get the files that
        % contain the pattern 'pattern' in the folders that contain the
        % pattern 'folder'.
        elseif ( ischar(pattern) && ischar(folder) )
            
            % We check for the folders that contain 'folder(i)'
            folder_path = findfiles(['*' folder '*']);
            
            % Since there might be more than one folder with a match,
            % we do another loop
            for j = 1:size(folder_path,1)
                if isfolder(folder_path(j,:))
                    temp = string(findfiles(['*' pattern '*'],...
                                        char(folder_path(j,:))));
                    data_id = [data_id; temp(isfile(temp),:)];
                end
            end
        
        % If 'folder' is a string and 'pattern' is a char or vice-versa, we
        % produce an error.
        else
            error('pattern and folder must both be either char or string arrays');
        end
    
    else
        error('Wrong number of inputs');
    end
    
    nbr_files = length(data_id);
    data_len = zeros(nbr_files,1);
    input_data = zeros(nbr_files,MAX_LENGTH);       % Again, Matlab will produce an error if requesting too much memory

    if nbr_files == 0 
        warning('No files were found using the pattern: "%s"', pattern);
    end

    %% Getting data from files
    for i = 1:nbr_files
        
        % Getting the data from the file depending on the file extension
        if contains(data_id(i),'.csv', 'IgnoreCase', true)
            temp = csvread(data_id(i));
        elseif contains(data_id(i),'.bin', 'IgnoreCase', true)
            temp = read_bin_file(data_id(i));
        else
            error('Wrong file extension');
        end

        % Avoiding getting data in the form of arrays (only vectors) and making
        % sure they are horizontal
        if iscolumn(temp)
            temp = temp';
        elseif ~isrow(temp)
            error('Input from file must be a vector');
        end

        % Making sure the input doesn't go beyond MAX_LENGTH elements
        data_len(i) = length(temp);
        if data_len(i) > MAX_LENGTH
            data_len(i) = MAX_LENGTH;
            warning('Input file has been truncated');
        end

        % Adding the file's data
        input_data(i,1:data_len(i)) = temp(1:data_len(i)); 
    end

    % Reducing the output array to the maximum needed length
    input_data = input_data(:,1:max(data_len));
end

