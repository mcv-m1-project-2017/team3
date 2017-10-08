% Execute this script to generate the masks of the test split

mkdir('../test_2017/test/mask') 

test_dir = '../test_2017/test'; % list test files
tmp = ListFiles(test_dir);

test_files = cell([1 length(tmp)]); % this cell will contain the filenames of all test files
for k=1:length(tmp)
    test_files{k} = tmp(k).name;
end

% Which color segmentation do you want to use? (CbCr | H | HCbCr)
seg_type = 'HCbCr';
% Do you want to use size filtering? (Yes | No)
size_filt = 'Yes';
% Do you want to use hole filling? (Yes | No)
hole_fill = 'Yes';

% Compute masks via color segmentation
[masks, timexframe] = compute_masks(test_dir, test_files, seg_type, size_filt, hole_fill);
fprintf('    Masks via color segmentation successfully created.\n')
fprintf('               -> Segmentation type: %s\n', seg_type);
fprintf('               -> Size filtering: %s\n', size_filt);
fprintf('               -> Hole filling: %s\n', hole_fill);
fprintf('               -> Time per frame: %.2f s\n',timexframe);

for i=1:length(test_files)
    imwrite(masks{i},['../test_2017/test/mask/mask.',test_files{i}(1:end-3),'png']);
end

