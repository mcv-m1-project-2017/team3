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


%% 1: ANALYSE THE DATA
% Determine the characteristics of the signals in the training set: 
% max and min size, form factor, filling ratio of each type of signal, 
% frequency of appearance (using text annotations and ground-truth masks). 
% Group the signals according to their shape and color.

img_dir = '../train_2017/train'; % list image files
img_files = ListFiles(img_dir);

mask_dir = '../train_2017/train/mask'; % list ground-truth mask files
mask_files = ListFiles(mask_dir);
    
gt_dir = '../train_2017/train/gt'; % list ground-truth annotation files
gt_files = ListFiles_txt(gt_dir);

% init. variables to store the data of the signals 
sA = struct([]); sB = struct([]); sC = struct([]); 
sD = struct([]); sE = struct([]); sF = struct([]);  
% init. counter of signal type
contA = 0; contB = 0; contC = 0; contD = 0; contE = 0; contF = 0;

for i=1:size(gt_files,1)

    % read ground-truth mask of the current image
    mask = imread(strcat(mask_dir ,'/',mask_files(i).name));
    mask(mask~=0)=1; % some masks are not binary !!! 
    
    % read the txt annotation file of the current image
    fileID = fopen(strcat(gt_dir ,'/',gt_files(i).name));
    line = fgetl(fileID);
    
    % line = -1 when all lines of the txt file have been read
    while line ~= -1
         
        gt_bbox = sscanf(line,'%f');   % get numbers of the current line
        tl = [gt_bbox(2), gt_bbox(1)]; % bbox top left corner coord.
        br = [gt_bbox(4), gt_bbox(3)]; % bbox bottom right corner coord.
        
        gt_sig = line(end); % get letter of the current line (signal type)
        
        w = abs(br(1) - tl(1));  % bbox width 
        h = abs(br(2) - tl(2));  % bbox height 
        bbox_area = w * h; % bbox area = bbox width * bbox height
        
        % form factor = bbox width / bbox height
        form_factor = w/h; 
        
        % signal size = pixels in the mask within the bbox with value 1
        mask_bbox = mask(ceil(gt_bbox(1)):floor(gt_bbox(3)),ceil(gt_bbox(2)):floor(gt_bbox(4)),:);
        signal_size = sum(sum(mask_bbox)); 
        
        % filling ratio = signal size / bbox area
        filling_ratio = signal_size/numel(mask_bbox); 

        % the next switch classifies signals according to their type
        % for each signal we want to store:
        % --> name of the image file where it appears
        % --> characteristics: size, form factor, filling ratio
        % (*) a counter for each type of signal is also updated
        switch(gt_sig)
            case 'A'
                contA = contA + 1;
                sA(contA).filename = img_files(i).name; 
                sA(contA).fill_ratio = filling_ratio;
                sA(contA).size = signal_size;
                sA(contA).form_factor = form_factor;
            case 'B'
                contB = contB + 1;
                sB(contB).filename = img_files(i).name;
                sB(contB).fill_ratio = filling_ratio;
                sB(contB).size = signal_size;
                sB(contB).form_factor = form_factor;
            case 'C'
                contC = contC + 1;
                sC(contC).filename = img_files(i).name;
                sC(contC).fill_ratio = filling_ratio;
                sC(contC).size = signal_size;
                sC(contC).form_factor = form_factor;
            case 'D'
                contD = contD + 1;
                sD(contD).filename = img_files(i).name;
                sD(contD).fill_ratio = filling_ratio;
                sD(contD).size = signal_size;
                sD(contD).form_factor = form_factor;
            case 'E'
                contE = contE + 1;
                sE(contE).filename = img_files(i).name;
                sE(contE).fill_ratio = filling_ratio;
                sE(contE).size = signal_size;
                sE(contE).form_factor = form_factor;
            case 'F'
                contF = contF + 1;
                sF(contF).filename = img_files(i).name;
                sF(contF).fill_ratio = filling_ratio;
                sF(contF).size = signal_size;
                sF(contF).form_factor = form_factor;
            otherwise
        end

        line = fgetl(fileID); % jump to the next line of the txt
    end
    
    fclose(fileID); % close the txt annotation file of the current image
end

% compute frequencies of appearence of each signal type
total_signals = contA + contB + contC + contD + contE + contF;
freqA = contA/total_signals;
freqB = contB/total_signals;
freqC = contC/total_signals;
freqD = contD/total_signals;
freqE = contE/total_signals;
freqF = contF/total_signals;
freqs = [freqA, freqB, freqC, freqD, freqE, freqF];

% summarize data per each signal
% summaryX = [min size, max size, average form factor, average filling ratio, freq. of appearence] 
summaryA = [min([sA.size]), max([sA.size]), mean([sA.form_factor]), mean([sA.fill_ratio]), freqA];
summaryB = [min([sB.size]), max([sB.size]), mean([sB.form_factor]), mean([sB.fill_ratio]), freqB];
summaryC = [min([sC.size]), max([sC.size]), mean([sC.form_factor]), mean([sC.fill_ratio]), freqC];
summaryD = [min([sD.size]), max([sD.size]), mean([sD.form_factor]), mean([sD.fill_ratio]), freqD];
summaryE = [min([sE.size]), max([sE.size]), mean([sE.form_factor]), mean([sE.fill_ratio]), freqE];
summaryF = [min([sF.size]), max([sF.size]), mean([sF.form_factor]), mean([sF.fill_ratio]), freqF];

% group signals by shape
sTriangle = [sA, sB];   % --> Triangles: signals of type A and B
sCircle = [sC, sD, sE]; % --> Circles; signals of type C, D and E
sRectangle = sF;        % --> Rectangles: signals of type F

% group signals by color
sRed = [sA, sB, sC]; % --> Red: signals of type A, B and C
sBlue = [sD, sF];    % --> Blue: signals of type D and F
sRedBlue = sE;       % --> Red and blue: signals of type E
                        
fprintf('    TASK 1. Data analysis successfully completed.\n')
fprintf('               -> Max size: A = %i, B = %i, C = %i, D = %i, E = %i, F = %i\n', ... 
                         summaryA(2), summaryB(2), summaryC(2), summaryD(2), summaryE(2), summaryF(2));
fprintf('               -> Min size: A = %i, B = %i, C = %i, D = %i, E = %i, F = %i\n', ... 
                         summaryA(1), summaryB(1), summaryC(1), summaryD(1), summaryE(1), summaryF(1));
fprintf('               -> Form factor: A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
                         summaryA(3), summaryB(3), summaryC(3), summaryD(3), summaryE(3), summaryF(3));
fprintf('               -> Filling ratio: A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
                         summaryA(4), summaryB(4), summaryC(4), summaryD(4), summaryE(4), summaryF(4));
fprintf('               -> Frequency of appearance: A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
                         summaryA(5), summaryB(5), summaryC(5), summaryD(5), summaryE(5), summaryF(5));


%% 2. CREATE TRAINING AND VALIDATION DATASETS
% Create train/validation split using provided training images.
% The split has to be well balanced in terms of numbers of elements of 
% each class in train/validation splits.
% Use the information of class frequencies computed in Task 1.

train = 0.7; % percentage of files used to train (value between 0 and 1)
[train_files, valid_files] = split_dataset(img_dir, train, freqs, ...
                                           sA, sB, sC, sD, sE, sF);

fprintf('    2. Training set and validation set successfully splitted.\n')
fprintf('               -> Training set: %i%% of the sample images\n',train*100);
fprintf('               -> Validation set: %i%% of the sample images\n',100-(train*100));  
         
%% 3. COLOR SEGEMENTATION TO CREATE MASKS
% Color segmentation to generate a mask.
% Thresholds can be hand-picked by looking to images in the train split.
% An appropriate color space should be selected.


% 3.1. Study the color properties of the signals in the
%       training set to stablish reasonable thresholds
%visualize_histograms(img_dir, mask_dir, gt_dir, train_files, 'color')
visualize_histograms(img_dir, mask_dir, gt_dir, train_files, 'type');
% 3.2 Compute masks

% Which color segmentation do you want to use? (CbCr | H | HCbCr)
seg_type = 'HCbCr';
% Do you want to use size filtering? (Yes | No)
size_filt = 'Yes';
% Do you want to use hole filling? (Yes | No)
hole_fill = 'Yes';
% Do you want to use noise filtering? (Yes | No)
noise_filt = 'Yes';
% Do you want to use histogram comparison? (Yes | No)
hist_comp = 'Yes';

[masks, timexframe] = compute_masks(img_dir, valid_files, seg_type, size_filt, hole_fill, noise_filt, hist_comp);
fprintf('    TASK 3. Masks via color segmentation successfully created.\n')
fprintf('               -> Segmentation type: %s\n', seg_type);
fprintf('               -> Size filtering: %s\n', size_filt);
fprintf('               -> Hole filling: %s\n', hole_fill);
fprintf('               -> Noise filtering: %s\n', noise_filt);
fprintf('               -> Histogram comparison: %s\n', hist_comp);
fprintf('               -> Time per frame: %.2f s\n',timexframe);

% 3.3 Show masks
% image_num = 16; % select a sample of the validation set
% show_mask(img_dir, valid_files, masks, image_num);

%% TASK 4. SEGMENTATION USING HISTOGRAM BACK-PROJECTION

% Color segmentation to generate a mask.
% Thresholds can be hand-picked by looking to images in the train split.
% An appropriate color space should be selected.

% 4.1. Study the color properties of the signals in the
%       training set to extract the 2D histograms  

% Which color segmentation do you want to use? (HS| CbCr)
seg_type = 'HS';
% Specify number of bins
nbins = 10;
create_hist_backproject(img_dir, mask_dir, gt_dir, seg_type, nbins)
fprintf('    1. 2D histograms are succesfully created and saved.\n')

% 4.2 Compute masks
% Do you want to use size filtering? (Yes | No)
size_filt = 'Yes';
% Do you want to use hole filling? (Yes | No)
hole_fill = 'Yes';
% Do you want to use noise filtering? (Yes | No)
noise_filt = 'Yes';
% Do you want to use histogram comparison? (Yes | No)
hist_comp = 'Yes';


[masks, timexframe] = compute_masks_hist_backproject(img_dir, valid_files, seg_type, size_filt, hole_fill, noise_filt, hist_comp);
fprintf('    TASK 4. Masks via histogram back-projection successfully created.\n')
fprintf('               -> Segmentation type: %s\n', seg_type);
fprintf('               -> Size filtering: %s\n', size_filt);
fprintf('               -> Hole filling: %s\n', hole_fill);
fprintf('               -> Noise filtering: %s\n', noise_filt);
fprintf('               -> Histogram comparison: %s\n', hist_comp);
fprintf('               -> Time per frame: %.2f s\n',timexframe);
% 
% % 3.3 Show masks
% image_num = 16; % select a sample of the validation set
% show_mask(img_dir, valid_files, masks, image_num);


%% SYSTEM EVALUATION
% Evaluate the segmentation using ground truth

N = length(valid_files);
pPr = zeros([1 N]); pAc = zeros([1 N]); pF1 = zeros([1 N]); pRe = zeros([1 N]); 
pTN = zeros([1 N]); pFN = zeros([1 N]); pTP = zeros([1 N]); pFP = zeros([1 N]);

for i=1:size(valid_files,2)

    % read current ground-truth mask
    gt_mask = imread(strcat(mask_dir ,'/',['mask.',valid_files{i}(1:end-3),'png']));
    gt_mask(gt_mask~=0)=1; % some masks are not binary !!! 
    
    % read current color segmentation mask
    mask = masks{i};
    
    % evaluate performance of the color segementation mask with respect to the ground truth 
    [pPr(i),pAc(i),pF1(i),pRe(i),pTN(i),pFN(i),pTP(i),pFP(i)] = evaluate_mask(mask, gt_mask);
end 

% calculate mean values of the performance measures
pPr(isnan(pPr))=0;
mean_pPrecision = mean(pPr);
mean_pAccuracy = mean(pAc);
mean_pRecall = mean(pRe);
mean_pF1 = mean(pF1);
mean_pTP = mean(pTP);
mean_pTN = mean(pTN);
mean_pFP = mean(pFP);
mean_pFN = mean(pFN);

fprintf('      4. Pixel-based evaluation successfully completed.\n')
fprintf('           -> F1-measure: %.3f \n',mean_pF1);
fprintf('           -> Precision: %.3f \n',mean_pPrecision);
fprintf('           -> Accuracy: %.3f \n',mean_pAccuracy); 
fprintf('           -> Recall: %.3f \n',mean_pRecall); 
fprintf('           -> TP (average): %.2f pixels \n',mean_pTP);
fprintf('           -> FP (average): %.2f pixels \n',mean_pFP);
fprintf('           -> FN (average): %.2f pixels \n',mean_pFN);