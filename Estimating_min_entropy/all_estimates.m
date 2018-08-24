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
% [h] = all_estimates(input_data, data_len)
%
% This gives a list of all min-entropy estimates according to NIST 
% SP-800-90B section 6.3.x (January 2018). 
%
% input_data: array of input bits. Every row is dealt with independently.
%             If the number of rows is greater than the number of columns,
%             the program will prompt the user with three different 
%             choices: exit function, transpose and keep going, or just run
%             the function 'as is'.
%
% data_len:   vertical vector containing the number of bits to be
%             considered in each row of input_data
%
% h:          consists of an array of all estimates of the min-entropy. The
%             table below shows the index of the column associated with 
%             every estimate (follows NIST's document)
%
%             Most_common_value_estimate -> 1
%             Collision_estimate         -> 2
%             Markov_estimate            -> 3
%             Compression_estimate       -> 4
%             t-Tuple_estimate           -> 5
%             lrs_estimate               -> 6
%             Multimcw_estimate          -> 7
%             lag_prediction_estimate    -> 8
%             multimmc_estimate          -> 9
%             lz78y_prediction_estimate  -> 10
%
function [h] = all_estimates(input_data, data_len)

    % Setting up input parameters
    [nrows,L] = size(input_data);
    h         = zeros(nrows, 10);

    if nargin == 1
        data_len = ones(nrows, 1) * L;
    end

    % This is to avoid confusion when using matrices
    if nrows > L   
        warning('Be aware that you may want to transpose your array.');
        disp('Type <a> if you want to exit this function');
        disp('Type <b> if you want to transpose the input and keep going with the function');
        disp('Type <c> if you want to continue with this function');
    
        key = char(getkey());
        if(strcmp (key , 'a'))
            return
        elseif (strcmp (key, 'b'))
            input_data = transpose(input_data);
            temp = nrows;
            nrows = L;
            L = temp;
            data_len = ones(nrows, 1) * L;
        elseif ~(strcmp (key, 'c'))
            error('The key you pressed was not a valid option');
        end
    end   


    % Optimized calculation of min-entropy estimates if there are multiple rows
    % of data. 100 is a totally arbitrary number
    if nrows > 100

        parfor row = 1:nrows
            h(row, 1) = most_common_value_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished most_common_value_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 2) = collision_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished collision_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 3) = markov_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished markov_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 4) = compression_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished compression_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 5) = t_tuple_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished t_tuple_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 6) = lrs_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished lrs_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 7) = multimcw_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished multimcw_estiamte %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 8) = lag_prediction_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished lag_prediction_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 9) = multimmc_prediction_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished multimmc_prediction_estimate %d out of %d\n', row, nrows);
        end

        parfor row = 1:nrows
            h(row, 10) = lz78y_prediction_estimate(input_data(row, 1:data_len(row)));
            fprintf('Finished lz78y_prediction_estimate %d out of %d\n', row, nrows);
        end
    else
        % Simple for loop to run the tests
        for row = 1 : nrows
            h(row, 1)  = most_common_value_estimate(input_data(row, 1:data_len(row)));
            h(row, 2)  = collision_estimate(input_data(row, 1:data_len(row)));
            h(row, 3)  = markov_estimate(input_data(row, 1:data_len(row)));
            h(row, 4)  = compression_estimate(input_data(row, 1:data_len(row)));
            h(row, 5)  = t_tuple_estimate(input_data(row, 1:data_len(row)));
            h(row, 6)  = lrs_estimate(input_data(row, 1:data_len(row)));
            h(row, 7)  = multimcw_estimate(input_data(row, 1:data_len(row)));
            h(row, 8)  = lag_prediction_estimate(input_data(row, 1:data_len(row)));
            h(row, 9)  = multimmc_prediction_estimate(input_data(row, 1:data_len(row)));
            h(row, 10) = lz78y_prediction_estimate(input_data(row, 1:data_len(row)));

            fprintf('Finished simulation %d out of %d\n',row,nrows);
        end
    end
end
