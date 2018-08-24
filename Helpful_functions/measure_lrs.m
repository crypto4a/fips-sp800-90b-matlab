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
% record = measure_lrs(input_data,start_indexes, nbr_reccurrence_per_seq)
%
% This function can precisely measure the longest repeated substring (lrs) 
% in a dataset given an array of values that correspond to the indexes 
% where some long known sequences are found. For instance, if input_data = 
% [1 0 0 1 1 0 1 1 0 1 0 1] and we have previously found strings that are at 
% least 3 bits long, start_indexes will be given as follows: [3 6 0;4 7 0; 
% 5 8 10]. nbr_reccurrence_per_seq will be [2;2;3]. This function will find
% the length of the lrs for all three sequences of at least 3 bits long.
% So, record will be: [5;4;3].
%
% input_data:               horizontal binary vector to analyse    
%
% start_indexes:            matrix containing the indexes where every
%                           known sequence starts. Every row contains the
%                           indexes related to a different known sequence
%                           and every column contains different indexes
%                           where the same known sequences were found
%
% nbr_reccurrence_per_seq:  column vector that indicates how many columns
%                           of the matrix start_indexes must be considered
%                           per row
%
% record:                   vertical vector of the lrs associated to every
%                           known sequence
%
function record = measure_lrs(input_data,start_indexes, nbr_reccurrence_per_seq)

    % Initialize some parameters
    nbr_sequences = size(start_indexes,1);
    record = zeros(nbr_sequences,1);

    for sequence = 1:nbr_sequences
        % Re-initialization of some parameters. nbr_elements is the number of
        % known sequences in input_data. precise_sequence is an horizontal
        % vector that gives a different label for different sequences: we stop
        % looking for the lrs when every sequence has its own label, which
        % means they are now all different. counter of course counts the number
        % of bits in the sequence. different_runs is a variable that indicates
        % how many different sequences have been found yet.
        nbr_elements = nbr_reccurrence_per_seq(sequence);
        precise_sequence = ones(1,nbr_elements);
        counter = 0;
        different_runs = 1;
        while (different_runs < nbr_elements)
            % If we reach the end of input_data, we add -1, to avoid having
            % indexing errors and to ensure we are aware that we finished the
            % data.
            if max(start_indexes(sequence,1:nbr_reccurrence_per_seq(sequence))) + counter > length(input_data)
                input_data = [input_data -1];
            end
            % This vector takes the new bits to analyse
            new_bits_vector = input_data(start_indexes(sequence,1:nbr_elements) + counter);
            % We increment our counter
            counter = counter + 1;
            for i = 1:different_runs
                % This vector takes only the new bits from the same sequence.
                % If they are not the same, we create a new sequence and
                % increment different_runs. precise_sequence is updated by
                % assuming input_data can only be ones and zeros, so if the
                % sequences diverge, the ones with a '1' will have a new label
                % and the ones with a '0' will keep their label. At the same
                % time, we check if one sequence has reached the end of
                % input_data and we give it a new label. We break out of this
                % loop as soon as every sequence is now different
                comparaison_vector = new_bits_vector(precise_sequence == i);
                if (any(comparaison_vector == 1) && any(comparaison_vector == 0))
                    different_runs = different_runs + 1;
                    precise_sequence = (precise_sequence == i) .* (different_runs-i) .* new_bits_vector + precise_sequence;       
                end
                if ( any(comparaison_vector == -1) ) && ( length(comparaison_vector) > 1 )
                    different_runs = different_runs + 1;
                    precise_sequence = (precise_sequence == i) .* (different_runs-i) .* (new_bits_vector == -1) + precise_sequence;       
                end
                if different_runs == nbr_elements
                    break;
                end
            end
        end
        % Since every sequence diverged in the last iteration, we subtract one
        % from counter
       record(sequence) = counter - 1;  
    end
    
end
