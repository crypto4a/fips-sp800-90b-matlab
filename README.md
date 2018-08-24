## Readme July 30, 2018.
Copyright Crypto4A Technologies Inc. 2018

###Introduction

This directory contains a set of Matlab functions to help characterize the entropy of a noise source as presented in NIST's SP800-90B (January 2018). Every IID test, including the additional chi-square functions and every min-entropy estimate described in the SP800-90B document have been implemented in Matlab and tested using binary data. In addition, a quick, although less precise, test is provided to determine if a dataset is IID. The reader is referred to NIST's SP800-90B document (https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-90B.pdf) for additional details regarding the statistical tests implemented within this repo. Note that every usage of "section x.y.z" in this document refers to the section of the same name in SP800-90B.

###Pointers on how to use these tools:

- Obtain the "tested with" version of Matlab and toolsets (other versions have not been tested):
	- Matlab 2018a, distrib_computing_toolbox and statistics_toolbox.
	- If you want to use the functions *read_bin_files* and *independance_test_binary*, you also need the Communications System Toolbox to have the bi2de and de2bi functions. However, those functions are fairly easy to write.
- Run the '*setup.m*' file to place everything in the path. Otherwise, Matlab produces an error if you try to run a function.
- To quickly test the IID assumption, run the '*fast_test_IID_assumption.*m' as opposed to the more comprehensive (and time consuming!) '*test_IID_assumption.m*'
- To get a quick idea of how random a file is, run the '*approximation_IID_testing.m*' function.
 - This function uses precalculated averages and standard deviations for every test and establishes bounds of confidence based on these. It then runs the '*fast_IID_test_runner.m*' function to see if the results fit within these bounds of confidence. This function does not provide exactly the same results as the full test, but it requires significantly less time to run. Also, you should avoid using this function when the proportion of '1' in the dataset does not fall within the range of [46%, 54%]. You can also use the functions *autocorr(input_data,100)* or *hist(input_data)*. Alternatively, you can run a few entropy estimates that don't require a lot of time to compute such as: *most_common_value_estimate, collision_estimate, markov_estimate, compression_estimate*. However, these quick methods must not be considered a thorough proof of randomness.
- To get every min-entropy estimates, you should run the function *all_estimates*: *h = all_estimates(input_data)*.
- Be careful running these tests if you think your input_data is not really random as they may take a long time. Specifically, the *lrs_estimate* function tries to look for the longest repeated string. This operation might take an extremely long time (and use a lot of memory) if the size of that string is over 100 bits. Also, the results become less precise after substrings of more than 64 bits. Indeed, the function transforms the strings into decimal value, which Matlab approximates if the value is too big. As a point of reference, results from a good source of entropy are expected to have a longest repeated string of approximately 36 bits.
- The code has been written assuming that the dataset being tested is provided as a binary horizontal vector (or a set of horizontal vectors that are treated independently). Only the "big functions" (*fast_test_IID_assumption.m* and *all_estimates.m*) have mechanisms that can handle vertical vectors and some functions can handle non-binary inputs. You should be careful with how you use these functions.
- If you don't want to use parallel processing, simply change all references to "parfor loops" to be "for loops" (in *all_estimates.m* and *fast_test_IID_assumption.m*). No other changes are required.

### File Functions and Structure
A brief description of the files/directories contained within the RNG_testing directory.

**Estimating_min_entropy**
Contains functions used to measure the min-entropy. If the data set is IID, we use the *most_common_value_estimate* function. If it is non-IID, we take the smallest estimate from all other tests as the estimated min-entropy.

- ***all_estimates.m***: goes through every min-entropy estimates in NIST's document. Will treat every row of the input independently
- ***collision_estimate.m***: section 6.3.2
- ***compression_estimate.m***: section 6.3.4
- ***lag_prediction_estimate.m***: section 6.3.8
- ***lz78y_prediction_estimate.m***: section 6.3.10
- ***markov_estimate.m***: section 6.3.3
- ***most_common_value_estimate.m***: section 6.3.1 (to be used with IID track)
- ***multimcw_estimate.m***: section 6.3.7
- ***multimmc_prediction_estimate.m***: section 6.3.9
- ***t_tuple_estimate.m***: section 6.3.5

**Helpful_functions**
Contains many useful functions used for IID testing and for estimating min entropy.

- ***convert1.m***: converts non-overlapping 'symbol_size'-bit sequences (8 bit sequences) into integers from 0 to 8 corresponding to the number of 1's in that sequence. Based on the description in section 5.1. If given a matrix of values, it will treat each row as  a separate array.
- ***convert2.m***: converts non-overlapping 'symbol_size'-bit sequences (8 bit sequences) into integers from 0 to 255 corresponding to the decimal equivalent of that sequence. Based on the description in section 5.1. If given a matrix of values, it will treat each row as  a separate array.
- ***fast_Q_filling.m***: generates the array Q as described in section 6.3.5. The technique it uses may require a lot of data. Be careful using this function
- ***findfiles.m***: This function is used to recursively get the names of the files that match a certain pattern. It is used to automate data gathering. However, one must be careful with how they name files and which files are present in the directory. to use this function efficiently. It was taken from Matlab's File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/57298-recursively-search-for-files
- ***find_repeated_str.m***: generates an array of the decimal values of every "str_size" sequence (overlapping) in the input. This is the function's prototype: "[found, str_array, N, edges] = find_repeated_str(input_data,str_size,k)". input_data is an horizontal vector of input bits (or integers), str_size is the length of the sequence and k is the base of the input (2 by default for binary, 8 for octal, etc.). Found is a logical 1 if there are least two occurrences of at least one specific sequence, str_array is a vector of all the decimal equivalent of the str_size sequences in order, N is a vector of the numbers of occurrences of every different str_size sequences and eges is a vector of every different str_size sequence present in input_data (given as decimal values).
- ***finding_bounds.m***: takes a vector of averages and a vector of associated standard deviations. It outputs a vector of upper bounds and a vector of lower bounds that define an interval of plus or minus 3.3 std_deviations away from the mean (assuming normal distribution).
- ***G.m***: this function is used in the compression estimate (6.3.4) only.
- ***get_data.m***: This function is used to gather data from multiple files. It returns three arrays: 'input_data' which contains the elements, 'data_id' which contains the names of the files imported and 'data_len' which contains the number of elements in every file. The only input needed is a string pattern. The function will look recursively through the directory for every file that match this pattern. Right now, it can only open .csv and .bin files.
- ***get_lrs_length.m***: gives an estimate of the longest repeated substring that should be found in a large dataset based on the longest repeated substring that was found in a smaller sample of the same dataset.
- ***getkey.m***: function taken from Matlab's file exchange (https://www.mathworks.com/matlabcentral/fileexchange/7465-getkey) that can wait for the user to press a key and use this key to make a decision. Used only in *fast_test_IID_assumption.m* and *all_estimates.m* to make sure that the user is aware that their input is transposed;
- ***lagrange_interpolation.m***: gives the interpolated value y associated to x, given two vectors of coordinates of points to the function. It uses Lagrange's method of interpolation, which creates the smallest polynomial function such that the function passes through every input coordinates.
- ***measure_lrs.m***: can precisely measure the longest repeated substring given an array of starting indexes. It is efficient when we give this function indexes associated to the start of already known long sequences.
- ***read_bin_file.m***: converts a binary file into an horizontal vector of bits.
- ***Shuffle.m***: permutes elements in a vector using the Fisher-Yates algorithm described in section 5.1. If given a matrix, it treats every row as an independent vector.
- ***x_function.m***: used in the multimcw_estimate function and is described in point 6 in section 6.3.7.

**Testing_IID_assumption**
Tests the IID assumption. The Fast_IID_testing_assumption folder contains more efficient functions to determine whether or not a binary dataset is IID. The IID_testing_assumption folder contains every function described in section 5.1 and it contains a function *test_IID_assumption.m* that determines whether or not a binary dataset is IID by running every test. Note that the implementation of this function is less efficient than the one used in the Fast_IID_testing_assumption folder. The Chi_square_tests folder contains additionnal tests that can be run (section 5.2)
- **Chi_square_tests**
  - ***goodness_of_fit_test_binary.m***: section 5.2.4
  - ***independence_test_binary.m***: section 5.2.3
  - ***lrs_test.m*:** section 5.2.5

- **Fast_IID_testing_assumption**
  - ****fast_IID_test_runner.m***: performs every test described in section 5.1, going through the data only three times. If given a matrix, it will treat each row as an independent vector. The output of this function is a matrix (rows x 19) where 'rows' is the number of rows in the input and 19 is the number of statistical tests performed.
  - ***fast_test_IID_assumption.m***: tests the IID assumption by performing each of the 19 tests on the original input and comparing those results with 10000 results generated from a shuffled list. Read section 5.1 for more info.

- **IID_testing_assumption**
  - ***avg_collision_test.m***: section 5.1.7
  - ***compression_test.m***: section 5.1.8
  - ***covariance_test.m***: section 5.1.10
  - ***excursion_test.m***: section 5.1.1
  - ***incdec_test.m***: section 5.1.4
  - ***length_median_test.m***: section 5.1.6
  - ***length_test.m***: section 5.1.3
  - ***max_collision_test.m***: section 5.1.8
  - ***periodicity_test.m***: section 5.1.9
  - ***run_median_test.m***: section 5.1.5
  - ***run_test.m***: section 5.1.2
  - ***test_IID_assumption.m***: section 5.1. This function calls every other test in the subdirectory to validate the IID assumption as described in section 5.1

- **approximation_IID_testing.m**: determines if a dataset is IID or not in a very efficient way. The *fast_test_IID_assumption.m* function was used to calculate the average and the standard deviation from 10,000 iterations of every IID test described in section 5.1. The process is repeated 21 times, using a list of 1 million bits containing {45%, 46%, ..., 55%} 1's, and the results are stored in the 'precalculated_averages.csv' and 'precalculated_std_deviations.csv' files. The function then uses *lagrange_interpolation.m* to find an estimation of the mean and standard deviation for every test according to the percentage of 1's in the dataset. *finding_bounds.m* is used to generate a confidence interval that should correspond to NIST's recommendation. Hence we can run the test a single time instead of the prescribed 10001 times. However, this method is an approximation so it isn't as precise as NIST's full implementation and doesn't always give exactly the same results. In addition, the approximation is only good for datasets of 1 million bits that contain between 460,000 and 540,000 1's as the Lagrange interpolation breaks down beyond that range.

**automated_tests.m**: Can run the full NIST's implementation and return wheter or not the data is IID and what is the min-entropy. The inputs of this function are an array of patterns and an array of folders. These inputs are used to get data from every file that matches the description. Note that those files must be within the global directory.

**precalculated_averages.csv**: array of precalculated averages for every IID test. See *approximation_IID_testing.m*.

**precalculated_std_deviations.csv**: array of precalculated standard deviations for every IID test. See *approximation_IID_testing.m*.

**setup.m**: puts everything into Matlab's path. You should run this file before anything else. Otherwise, You will need to manually run every file to use them. This file was taken from a post on a Matlab forum (https://www.mathworks.com/matlabcentral/answers/247180-how-may-i-add-all-subfolders-in-my-matlab-path)


###Known Issues

- Not able to use a single parfor loop in *all_estimates.m* due to how the variable h is used so multiple parfor loops are used instead, which isn't a very convenient solution.
- *lrs_estimate.m* can run for a very long time and loose precision if the dataset has really long repeated substrings.
- The chi-square functions on non-binary inputs have not been implemented
- Some min-entropy estimates functions are not working for non-binary inputs: *lrs_estimate*, *lz78y*, *multimmc_estimate*, *t_tuple_estimate*
- The tests only work if the input is formatted as a horizontal vector (or set of horizontal vectors). Only *fast_test_IID_assumption.m* and *all_estimates.m* can deal with arrays of vertical vectors (spoiler alert: it transposes them).
- Some functions use a lot of memory: *multi_mmc*, *lrs_estimate*, *t-tuple estimates*. Be careful using them, although Matlab gives warning if you are using too much memory.
- *independance_test_binary.m* uses the bi2de and the de2bi function and *read_bin_file.m* uses the de2bi function. Those functions require the communications system toolbox to be enable. Note that it is fairly easy to implement functions that do the same thing as bi2de and de2bi.