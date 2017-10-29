% Execute this script to generate the masks of the test split
clear all;
mkdir('../test_2017/test/mask') 
addpath Compute_Mask_Functions

test_dir = '../test_2017/test'; % list test files
tmp = ListFiles(test_dir);

load ('features.mat')

test_files = cell([1 length(tmp)]); % this cell will contain the filenames of all test files
for k=1:length(tmp)
    test_files{k} = tmp(k).name;
end

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
params.CCM = 'CCL';

[masks, windowCandidates, timexframe] = compute_masks(test_dir, test_files, params);
fprintf('    TASK 3. Masks via color segmentation successfully created.\n')
fprintf('               -> Segmentation type: %s\n', params.seg_type);
fprintf('               -> Size filtering: %s\n', params.size_filt);
fprintf('               -> Hole filling: %s\n', params.hole_fill);
fprintf('               -> Noise filtering: %s\n', params.noise_filt);
fprintf('               -> Histogram comparison: %s\n', params.hist_comp);
fprintf('               -> Time per frame: %.2f s\n', timexframe);

for i=1:length(test_files)
    imwrite(masks{i},['../test_2017/test/mask/mask.',test_files{i}(1:end-3),'png']);
    windows = windowCandidates{i};
	save(['../test_2017/test/mask/mask.',test_files{i}(1:end-3),'mat'],'windows');
end
