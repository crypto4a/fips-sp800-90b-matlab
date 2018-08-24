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
% [T] = fast_IID_test_runner(input_data)
%
% This function is based on section 5.1 in NIST SP-800-90B (January 2018).
% Since running the different tests can be quite exhaustive, the intent of
% this function is to minimize the amount of times we go through the data  
% to accelerate the process. Since there are many parameters and NIST's 
% documentation tends to use the same variable names multiple times, the 
% variable names will be given followed by the section number(s) in which 
% they are used (according to NIST's document). For example, 's_prime' will
% become 's_prime_234' or 's_prime56' because these sequences are used in 
% the second, third and fourth test; the fifth and sixth test described 
% in sections 5.1.2, 5.1.3 and 5.1.4; 5.1.5 and 5.1.6 respectively. For 
% some common parameters like the median, the name will be given followed 
% by a quick description. For example, 'X' will become "X_median". If the 
% input presented is a matrix, the function treats it as many independent 
% rows.
%
% input_data:   Array of input bits 
%
% T:            Array of test results. The results are stored following
%               this table:
%
%               TEST NAME                             INDEX
%
%               Excursion Test Statistic                1
%               Number of Directional Runs              2
%               Length of Directional Runs              3
%               Number of Increases and Decreases       4
%               Number of Runs Based on the Median      5
%               Length of Runs Based on the Median      6
%               Average Collision Test Statistic        7
%               Maximum Collision Test Statistic        8
%               Periodicity Test Statistic (p = 1)      9
%               Periodicity Test Statistic (p = 2)      10
%               Periodicity Test Statistic (p = 8)      11
%               Periodicity Test Statistic (p = 16)     12
%               Periodicity Test Statistic (p = 32)     13
%               Covariance Test Statistic (p = 1)       14
%               Covariance Test Statistic (p = 2)       15
%               Covariance Test Statistic (p = 8)       16
%               Covariance Test Statistic (p = 16)      17
%               Covariance Test Statistic (p = 32)      18
%               Compression Test Statistic              19
%
function [T] = fast_IID_test_runner(input_data)
    %% Defining some parameters

    % GLOBAL PARAMETERS
    % T index
    ExcursionTestStatistic          = 1;
    NumberofDirectionalRuns         = 2;
    LengthofDirectionalRuns         = 3;
    NumberofIncreasesandDecreases   = 4;
    NumberofRunsBasedontheMedian    = 5;
    LengthofRunsBasedontheMedian    = 6;
    AverageCollisionTestStatistic   = 7;
    MaximumCollisionTestStatistic   = 8;
    PeriodicityTestStatistic1       = 9;
    PeriodicityTestStatistic2       = 10;
    PeriodicityTestStatistic8       = 11;
    PeriodicityTestStatistic16      = 12;
    PeriodicityTestStatistic32      = 13;
    CovarianceTestStatistic1        = 14;
    CovarianceTestStatistic2        = 15;
    CovarianceTestStatistic8        = 16;
    CovarianceTestStatistic16       = 17;
    CovarianceTestStatistic32       = 18;
    CompressionTestStatistic        = 19;

    % Some constants
    BINARY_MEDIAN   = 0.5;                     % Median used for binary input
    NBR_TEST        = 19;                      % Number of tests applied
    NULL            = -1;                      % -1 will be considered as Null
    PER_COV_LAG     = [1 2 8 16 32];           % Lag values used for periodicity and covariance tests
    SYMBOL_SIZE     = 8;                       % Number of bits considered when applying conversions
    
    % Creating converted lists used for some of the tests
    input_data_conv1 = convert1(input_data,SYMBOL_SIZE);
    input_data_conv2 = convert2(input_data,SYMBOL_SIZE);

    % Common parameters
    L_conv_length               = size(input_data_conv1,2);                % Same as input_data_conv2
    [nbr_rows, L_full_length]   = size(input_data);
    nbr_lag910                  = length(PER_COV_LAG);
    p910                        = PER_COV_LAG;                             % Number of lag values used
    s_prime234                  = zeros(nbr_rows,L_conv_length-1);
    s_prime56                   = zeros(nbr_rows,L_full_length);
    temp78                      = ones(1,2^SYMBOL_SIZE)*NULL;
    T                           = zeros(nbr_rows,NBR_TEST);
    X_mean                      = mean(input_data,2);
    X_median                    = BINARY_MEDIAN;  
      
    % FUNCTION SPECIFIC PARAMETERS
    % Excursion Test Statistic
    diff1           = zeros(nbr_rows,L_full_length);
    running_sum1    = zeros(nbr_rows,1);
    % X_mean -> specified in Common parameters

    % Number of Directional Runs
    runs2           = ones(nbr_rows,1);                                % initial value for the first run
    % s_prime234 -> specified in Common parameters
        
    % Length of Directional Runs
    record3         = zeros(nbr_rows,1);
    count3          = ones(nbr_rows,1);
    % s_prime234 -> specified in Common parameters

    % Number of Increases and Decreases
    increases4      = zeros(nbr_rows,1);
    decreases4      = zeros(nbr_rows,1);
    % s_prime234 -> specified in Common parameters        

    % Number of Runs Based on the Median
    runs5           = ones(nbr_rows,1);
    % s_prime56 -> specified in Common parameters
    % X_median  -> specified in Common parameters
    
    % Length of Runs Based on Median
    record6         = zeros(nbr_rows,1);
    count6          = ones(nbr_rows,1);
    % s_prime56 -> specified in Common parameters
    % X_median  -> specified in Common parameters
        
    % Average Collision Test Statistic
    count7          = zeros(nbr_rows,1);
    sum7            = zeros(nbr_rows,1);
    % temp78 -> specified in Common parameters
        
    % Maximum Collision Test Statistic
    record8         = zeros(nbr_rows,1);
    % temp78 -> specified in Common parameters
    
    % Periodicity Test Statistic
    result9         = zeros(nbr_rows,nbr_lag910);
    % lag910 -> specified in Common parameters
    % nbrlag910 -> specified in Common parameters

    % Covariance Test Statistic
    result10        = zeros(nbr_rows,nbr_lag910);
    % lag910 -> specified in Common parameters
    % nbrlag910 -> specified in Common parameters
        
    % Compression Test Statistic
    basename        = 'tmp';
    nbr_byte11      = zeros(nbr_rows,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Going through the input data

    %We treat every row independantly
    for row = 1:nbr_rows
    
        % TESTS WITHOUT CONVERSION
        % Three tests are performed without any conversion. Those tests are
        % described in sections 5.1.1, 5.1.5 and 5.1.6. Note that although the
        % compression test from section 5.1.11 doesn't need any conversion, we 
        % perform this test later on in this file.
    
        for i = 1:L_full_length

            % EXCURSION TEST STATISTIC
            running_sum1(row,1) = running_sum1(row,1) + input_data(row,i);
            diff1(row,i) = abs(running_sum1(row,1) - i * X_mean(row,1));

            % NUMBER OF RUNS BASED ON THE MEDIAN
            % Creating the vector s_prime56
            if input_data(row,i) < X_median
                s_prime56(row,i) = -1;
            else
                s_prime56(row,i) = 1;    
            end
        
            % Adding a run if the value s_prime56(i) differs from the previous 
            % value
            if i > 1
                if s_prime56(row,i) ~= s_prime56(row,i-1)
                    runs5(row,1) = runs5(row,1) + 1;
                end
            end
    
            % LENGTH OF RUNS BASED ON THE MEDIAN
            % The sequence s_prime56 has been created in the the "number of
            % runs based on the median" section   
       
            % Adding an element to the length
            if i > 1
                if s_prime56(row,i) == s_prime56(row,i-1)
                    count6(row,1) = count6(row,1) + 1;
                else
                    if count6(row,1) > record6(row,1)
                        record6(row,1) = count6(row,1);
                    end
                    count6(row,1) = 1;
                end
            end

            % If the record is found at the end of the sequence
            if i == L_full_length && count6(row,1) > record6(row,1)
                record6(row,1) = count6(row,1);
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
       
        % TESTS WITH CONVERSION
        % We will require a first loop to complete the tests described in
        % sections 5.1.2, 5.1.3, 5.1.9 and 5.1.10. A second loop will be 
        % required to complete the tests described in section 5.1.7 and 5.1.8 
        % Finally, the test described in sections 5.1.4 and 5.1.11 will be 
        % computed after the loops.
    
        % First Loop
        for i = 1:L_conv_length - 1          % No test actually requires to go through the whole length
        
            % NUMBER OF DIRECIONAL RUNS
            % Creating the vector s_prime234
            if input_data_conv1(row,i) > input_data_conv1(row,i+1)
                s_prime234(row,i) = -1;
            else
                s_prime234(row,i) = 1;    
            end

            % Adding a run if the value s_prime234(i) differs from the previous 
            % value
            if i > 1
                if s_prime234(row,i) ~= s_prime234(row,i-1)
                    runs2(row,1) = runs2(row,1) + 1;
                end
            end

            % LENGTH OF DIRECTIONAL RUNS
            % The sequence s_prime234 has been created in the the "number of
            % directional runs" section

            % Adding an element to the length 
            if i > 1
                if s_prime234(row,i) == s_prime234(row,i-1)
                    count3(row,1) = count3(row,1) + 1;
                else
                    if count3(row,1) > record3(row,1)
                        record3(row,1) = count3(row,1);
                    end
                    count3(row,1) = 1;
		end
            end

            % If the record is found at the end of the sequence
            if i == L_conv_length && count3(row,1) > record3(row,1)
                record3(row,1) = count3(row,1);
            end

            % PERIODICITY TEST STATISTIC && COVARIANCE TEST STATISTIC
            % Doing the test with every value in p9
            for k = 1:nbr_lag910
                if i <= L_conv_length - p910(k)                                % Avoiding errors due to too big index
                    if input_data_conv1(row,i) == input_data_conv1(row,...
                                                  i+p910(k))                   % (Periodicity test)
                        result9(row,k) = result9(row,k) + 1;
                    end
                    result10(row,k) = result10(row,k) + input_data_conv1...    % (Covariance test)
                                      (row,i)*input_data_conv1(row,i+p910(k));
                end
            end
	end
	
        % ----------------------------------------------------------------------- %
        % Second loop
        i = 1;                                                                 % Resetting the index i to 1
        while i < L_conv_length
        
            % AVERAGE COLLISION TEST STATISTIC && MAXIMUM COLLISION TEST STATISTIC
            % Reinitializing the lag value
            j = 1;
      
            % Finding the first collision
            while (i+j) < (L_conv_length+1)
                current_loop_value = input_data_conv2(row,i+j-1);

                % Checking if we have found a second occurence
                if ismember(current_loop_value,temp78)
                
                    % Same as adding element to C and taking the average
                    sum7(row,1) = sum7(row,1) + j;                             % (Average collision)
                    count7(row,1) = count7(row,1) + 1; 
                    if j > record8(row,1)
                        record8(row,1) = j;                                    % Setting new record run (Max collision)
                    end
                else
                    temp78(1,j) = current_loop_value;                          % Adding element to t
                    j = j + 1;
                    continue
                end
                break
            end
            i = i + j;
            temp78(1,:) = -1;                                                  % Re-initializing the array of elements seen
        end         

        % ----------------------------------------------------------------------- %

        % NUMBER OF INCREASES AND DECREASES
        % The sequence s_prime234 has been created in the the "number of
        % directional runs" section
        increases4(row,1) = sum(s_prime234(row,:) == 1);
        decreases4(row,1) = sum(s_prime234(row,:) == -1);
       
        % COMPRESSION TEST STATISTIC
        % Creating a temporary bin file and writing the integers as bytes. 
        % Since it might be running in parallel, we create different files
        % for different core ID to avoid confusion

        % It's important to get the taskID to avoid having parallel cores
        % using the same file name
        task = getCurrentTask();
        taskID = get(task,'ID');
        
        % Getting the names of the compressed and uncompressed files
        fullname = [basename '_' num2str(taskID) '.bin'];
        compressed_fullname = [fullname '.bz2'];

        % Creating a file
        if exist(fullname, 'file')
            delete(fullname);
        end
        fid = fopen(fullname,'w');
        while fid == -1
            delete(fullname);
            fid = fopen(fullname,'w');
        end
        
        % Writing to the file
        fwrite(fid,input_data_conv2(row,:));

        % Removing the temporary files
        while(fclose(fid));end

        % Compressing the input_data through a shell command
        if exist(compressed_fullname,'file')
            delete(compressed_fullname);
        end
        [status, ~] = system(['bzip2 ' fullname]);
        while( status ~= 0 ) 
            delete(compressed_fullname);
            [status, ~] = system(['bzip2 ' fullname]);
        end
        
        % Getting the number of bytes
        s = dir(compressed_fullname);
        nbr_byte11(row,1) = s.bytes;

        % Removing the compressed file to avoid having too many files
        delete(compressed_fullname);
                
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Returning test results
    T(:,ExcursionTestStatistic)        = max(diff1,[],2);
    T(:,NumberofDirectionalRuns)       = runs2(:,1);
    T(:,LengthofDirectionalRuns)       = record3(:,1);
    T(:,NumberofIncreasesandDecreases) = max([increases4 decreases4], [], 2);
    T(:,NumberofRunsBasedontheMedian)  = runs5(:,1);
    T(:,LengthofRunsBasedontheMedian)  = record6(:,1);
    T(:,AverageCollisionTestStatistic) = sum7(:,1)./count7(:,1);
    T(:,MaximumCollisionTestStatistic) = record8(:,1);
    T(:,PeriodicityTestStatistic1)     = result9(:,1);
    T(:,PeriodicityTestStatistic2)     = result9(:,2);
    T(:,PeriodicityTestStatistic8)     = result9(:,3);
    T(:,PeriodicityTestStatistic16)    = result9(:,4);
    T(:,PeriodicityTestStatistic32)    = result9(:,5);
    T(:,CovarianceTestStatistic1)      = result10(:,1);
    T(:,CovarianceTestStatistic2)      = result10(:,2);
    T(:,CovarianceTestStatistic8)      = result10(:,3);
    T(:,CovarianceTestStatistic16)     = result10(:,4);
    T(:,CovarianceTestStatistic32)     = result10(:,5);
    T(:,CompressionTestStatistic)      = nbr_byte11(:,1);
end
