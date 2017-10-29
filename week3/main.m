%%
% MASTER IN COMPUTER VISION 2017
% M1 PROJECT: TRAFFIC SIGN DETECTION/RECOGNITION
% Authors: Joan Sintes, Àlex Palomo, Àlex Vicente, Roger Marí
%
%
clear all
clc 
close all
fprintf('TRAFFIC SIGN DETECTION/RECOGNITION PROJECT\n\n')

img_dir = '../train_2017/train'; % training images directory
mask_dir = '../train_2017/train/mask'; % ground-truth masks directory
gt_dir = '../train_2017/train/gt'; % annotation files directory

%% ANALYSE THE DATA
% Determine the characteristics of the signals in the training set: 
% max and min size, form factor, filling ratio of each type of signal, 
% frequency of appearance (using text annotations and ground-truth masks). 
% Group the signals according to their shape and color.

[features, signals, freq] = analyse_data(img_dir, mask_dir, gt_dir);


%% CREATE TRAINING AND VALIDATION DATASETS
% Create train/validation split using provided training images.
% The split has to be well balanced in terms of numbers of elements of 
% each class in train/validation splits.
% Use the information of class frequencies computed in Task 1.

train = 0.7; % percentage of files used to train (value between 0 and 1)
[train_files, valid_files] = split_dataset(img_dir, mask_dir, gt_dir, train); 
     

%% COLOR SEGEMENTATION TO CREATE MASKS
% Color segmentation to generate a mask.
% Thresholds can be hand-picked by looking to images in the train split.
% An appropriate color space should be selected.

addpath Compute_Mask_Functions

% 3.1. Study the color properties of the signals in the
%       training set to stablish reasonable thresholds
%visualize_histograms(img_dir, mask_dir, gt_dir, train_files, 'color')
%visualize_histograms(img_dir, mask_dir, gt_dir, train_files, 'type');

% 3.2 Compute masks
% Which color segmentation do you want to use? (CbCr | H | HCbCr)
params.seg_type = 'HS';
% Do you want to use size filtering? (Yes | No)
params.size_filt = 'Yes';
% Do you want to use hole filling? (Yes | No)
params.hole_fill = 'Yes';
% Do you want to use noise filtering? (Yes | No)
params.noise_filt = 'Yes';
% Do you want to use histogram comparison? (Yes | No)
params.hist_comp = 'No';
% Which Connected Components Method do yo want to use ? (CCL | SLW_basic | SLW_integral_image | SLW_conv)
params.CCM = 'SLW_conv';

[masks, windows, timexframe] = compute_masks(img_dir, valid_files, params);
fprintf('    MASKS VIA COLOR SEGMENTATION successfully created.\n')
fprintf('               -> Segmentation type: %s\n', params.seg_type);
fprintf('               -> Size filtering: %s\n', params.size_filt);
fprintf('               -> Hole filling: %s\n', params.hole_fill);
fprintf('               -> Noise filtering: %s\n', params.noise_filt);
fprintf('               -> Histogram comparison: %s\n', params.hist_comp);
fprintf('               -> Time per frame: %.2f s\n', timexframe);

% 3.3 Show masks
% image_num = 16; % select a sample of the validation set
% show_mask(img_dir, valid_files, masks, image_num);

%% SYSTEM EVALUATION (PIXEL BASED)
% Evaluate the segmentation using ground truth

addpath Evaluation

N = length(valid_files);
pTN = zeros([1 N]); pFN = zeros([1 N]); pTP = zeros([1 N]); pFP = zeros([1 N]);
for i=1:N
    % read current ground-truth mask
    gt_mask = imread(strcat(mask_dir ,'/',['mask.',valid_files{i}(1:end-3),'png']));
    % evaluate candidate mask with respect to ground-truth mask
    [pTP(i), pFP(i), pFN(i), pTN(i)] = PerformanceAccumulationPixel(masks{i}, gt_mask);
end 
% calculate performance measures
[pPrecision, pAccuracy, pRecall, pF1] = PerformanceEvaluationPixel(sum(pTP), sum(pFP), sum(pFN), sum(pTN));

fprintf('    PIXEL-BASED EVALUATION successfully completed.\n');
fprintf('        -> F1-measure: %.3f \n',pF1);
fprintf('        -> Recall: %.3f \n',pRecall); 
fprintf('        -> Precision: %.3f \n',pPrecision);
fprintf('        -> Accuracy: %.3f \n',pAccuracy); 
fprintf('        -> TP (average): %.2f pixels \n',mean(pTP));
fprintf('        -> FP (average): %.2f pixels \n',mean(pFP));
fprintf('        -> FN (average): %.2f pixels \n',mean(pFN));


%% SYSTEM EVALUATION (REGION BASED)
% Perform region based evaluation in addition to the pixel based evaluation

N = length(valid_files);
wFN = zeros([1 N]); wTP = zeros([1 N]); wFP = zeros([1 N]);

for i=1:size(valid_files,2)
    % read current ground-truth mask windows
    gt_windows = get_gt_windows(strcat(gt_dir ,'/gt.',valid_files{i}(1:end-3),'txt'));
    % evaluate candidate mask with respect to ground-truth mask
    [wTP(i),wFN(i),wFP(i)] = PerformanceAccumulationWindow(windows{i},gt_windows); 
end

[wPrecision, wAccuracy, wRecall, wF1] = PerformanceEvaluationWindow(sum(wTP),sum(wFN),sum(wFP));

fprintf('    REGION-BASED EVALUATION successfully completed.\n');
fprintf('        -> F1-measure: %.3f \n',wF1);
fprintf('        -> Recall: %.3f \n',wRecall); 
fprintf('        -> Precision: %.3f \n',wPrecision);
fprintf('        -> Accuracy: %.3f \n',wAccuracy); 
fprintf('        -> TP : %.2f signals \n',mean(wTP));
fprintf('        -> FP : %.2f signals \n',mean(wFP));
fprintf('        -> FN : %.2f signals \n',mean(wFN));