function [train_files, valid_files] = split_dataset(img_dir, mask_dir, gt_dir, percent_train)

% INPUT: 'img_dir' directory of input training images
%        'mask_dir' directory of masks associated to training images
%        'gt_dir' directory of txt files associated to training images       
%        'percent_train' percentage of files that will be used to train
%        

% OUTPUT: 'train_files' cell containing the names of all the image files
%                       that belong to the training set
%         'valid_files' cell containin the names of all the image
%                       files that belong to the validation set
%   

if exist('signals.mat')
    load ('signals.mat')
else
    analyse_data(img_dir, mask_dir, gt_dir);
    load ('signals.mat')
end
    
% list all files provided for training and get the total amount (n_total)
files = ListFiles(img_dir);
n_total = size(files,1);

% n_train = number of images from n_total that will be used to train
% n_validation = number of images from n_total that will be used to validate 
n_train = round(percent_train * n_total); 
% n_validation = n_total - n_train;

train_files = {}; % this cell will contain the filenames of all the files
                  % that will be used for training

sigA_files = {sA.filename}; % list of images with signals of type A
sigB_files = {sB.filename}; % list of images with signals of type B
sigC_files = {sC.filename}; % list of images with signals of type C
sigD_files = {sD.filename}; % list of images with signals of type D
sigE_files = {sE.filename}; % list of images with signals of type E
sigF_files = {sF.filename}; % list of images with signals of type F


% CREATION OF THE TRAINING SET

% While there are training images left to pick...
while length(train_files) < n_train
    
    % ...we want to pick the amount of 'tmp' images that are left.
    tmp = n_train - length(train_files); 
    
    % The frequency of appearence of signal A can be used to know how  
    % many images out of 'tmp', have to contain signals of type A.
    n_A = ceil(freq(1) * tmp);
    % Signals of type A have to appear n_A times. The images are selected 
    % randomly from the list of images with signals of type A using the
    % built-in function 'randsample'. Also, notice that an image can 
    % contain more than one signal, so we need to make sure that no image 
    % is repeated in the training set by preserving the 'unique' files. 
    train_files = unique([train_files, randsample(sigA_files, n_A)]);
    % Finally, remove the images that have already been picked from the 
    % set of images containing signals of type A
    sigA_files = setdiff(sigA_files, train_files);
    
    % The previous reasoning is applied to the rest of signal types.
    % This way each signal type is present in the training and validation
    % splits in a way that is proportional to its frequency of appearence.
    n_B = ceil(freq(2) * tmp); 
    train_files = unique([train_files, randsample(sigB_files, n_B)]);
    sigB_files = setdiff(sigB_files, train_files);
    
    n_C = ceil(freq(3) * tmp); 
    train_files = unique([train_files, randsample(sigC_files, n_C)]); 
    sigC_files = setdiff(sigC_files, train_files);
    
    n_D = ceil(freq(4) * tmp); 
    train_files = unique([train_files, randsample(sigD_files, n_D)]); 
    sigD_files = setdiff(sigD_files, train_files);
    
    n_E = ceil(freq(5) * tmp); 
    train_files = unique([train_files, randsample(sigE_files, n_E)]);
    sigE_files = setdiff(sigE_files, train_files);
    
    n_F = ceil(freq(6) * tmp);
    train_files = unique([train_files, randsample(sigF_files, n_F)]);
    sigF_files = setdiff(sigF_files, train_files);
end

% CREATION OF THE VALIDATION SET

% The validation set will consist of the remaining files that were 
% not selected for training, which is the difference between the total
% amount of files and the files of the training set.
valid_files = setdiff({files.name}, train_files);

fprintf('    TRAINING SET and VALIDATION SET successfully splitted.\n')
fprintf('        -> Training set: %i%% of the sample images -> %i files\n',percent_train*100,  n_train);
fprintf('        -> Validation set: %i%% of the sample images -> %i files\n',100-(percent_train*100), length(valid_files)); 

end
