
% Execute this script to generate the masks of the test split usinig the
% method 3

mkdir('../test_2017/test/method3') 

test_dir = '../test_2017/test'; % list test files
tmp = ListFiles(test_dir);

test_files = cell([1 length(tmp)]); % this cell will contain the filenames of all test files
for k=1:length(tmp)
    test_files{k} = tmp(k).name;
end

% Which color segmentation do you want to use? (HS| CbCr)
seg_type = 'HS';
% Do you want to use size filtering? (Yes | No)
size_filt = 'Yes';
% Do you want to use hole filling? (Yes | No)
hole_fill = 'Yes';
% Do you want to use noise filtering? (Yes | No)
noise_filt = 'Yes';
% Do you want to use histogram comparison? (Yes | No)
hist_comp = 'Yes';


[masks, timexframe] = compute_masks_hist_backproject(test_dir, test_files, seg_type, size_filt, hole_fill, noise_filt, hist_comp);
fprintf('    TASK 4. Masks via histogram back-projection successfully created.\n')
fprintf('               -> Segmentation type: %s\n', seg_type);
fprintf('               -> Size filtering: %s\n', size_filt);
fprintf('               -> Hole filling: %s\n', hole_fill);
fprintf('               -> Noise filtering: %s\n', noise_filt);
fprintf('               -> Histogram comparison: %s\n', hist_comp);
fprintf('               -> Time per frame: %.2f s\n',timexframe);

for i=1:length(test_files)
    imwrite(masks{i},['../test_2017/test/method3/mask.',test_files{i}(1:end-3),'png']);
end