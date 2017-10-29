function [masks, windows, txf] = compute_masks(img_dir, test_files, params)

seg_type = params.seg_type;
size_filt = params.size_filt;
hole_fill = params.hole_fill;
noise_filt = params.noise_filt;
hist_comp = params.hist_comp;
CCM = params.CCM;

% INPUT: 'img_dir' directory of the files provided for training
%        'mask_dir' directory of the ground-truth mask files
%        'gt_dir' directory of the ground-truth annotation files
%        'train_files' cell array containing the name of all train files
%        'test_files' cell array containing the name of all test files
%        'seg_type' string that can be 'CbCr', 'H' or 'HCbCr', indicating 
%                   which color channels are used in the segmentation
%        'size_filt' if this string is 'Yes' then the connected components
%                    of the mask are filtered depending on their size
%        'hole_fill' if this string is 'Yes' then the holes of the
%                    connected components of the mask are filled
%        'noise_filt' if this string is 'Yes' then an opening morphological
%                     filter is applied.
%        'hist_comp' if this string is 'Yes' then an histogram comparison
%                    between the connected components hist. and the models
%                    hist. is performed.
%        'CCM'     Connected Components Method to discard false positive
%                  using features (form factor, filling ratio, etc)
%

if exist('features.mat')
    load ('features.mat')
else
    analyse_data(img_dir, mask_dir, gt_dir);
    load ('features.mat')
end

masks = cell([1 length(test_files)]); % cell array to store output masks
time = zeros([1 length(test_files)]); % vector to store time per frame

for i=1:length(test_files)
        i
        tic; % Start timer

        % Read current image and convert it to YCbCr and HSV colorspaces
        im = imread(strcat(img_dir,'/',test_files{i}));
        imYCbCr= rgb2ycbcr(im);
        imHSV = rgb2hsv(im);
       
        % Use COLOR SEGMENTATION to create a mask
        final_mask = color_segmentation(imYCbCr, imHSV, seg_type);
        
        % The mask can be refined with POST-PROCESSING
        % (1) Color segmentation is used to detect red and blue, which are
        %     the colors that stand out when it comes to traffic signals.
        %     However, some signals have white/black parts in the middle.
        %     The white/black parts are not detected with color seg. but
        %     these regions of the mask can be filled (with the buit-in 
        %     function 'imfill'). A hole is defined as an area of dark 
        %     pixels (value 0) surrounded by lighter pixels (value 1).
        if strcmp(hole_fill,'Yes')
                final_mask = imfill(final_mask,'holes');
        end
        
        % (2) Morphological operators (erosion and dilation) are used to 
        %     remove noise and non-desired parts of the mask. Those parts
        %     of the mask smaller than the Stucturing Element(SE) will be 
        %     removed when the erosion is applied and the non-removed parts
        %     will return to the original size after the dilation.
        if strcmp(noise_filt,'Yes')
            SE_S = ones(5,5);
            SE_D = strel('disk',20);
            %final_mask = imclose(final_mask, SE); 
            %final_mask = imclose(final_mask, SE);
            final_mask = imopen(final_mask, SE_D);
        end 
      
        % (3) Histogram Comparison between each connected component of each
        % mask and the 6 different model histograms (one for signal type).
        if strcmp(hist_comp,'Yes')
            if i == 1
                close all;
                load('hue_sig.mat');
                load('Cb_sig.mat');
                load('Cr_sig.mat');
            end
            final_mask = histogram_comparision(final_mask,im, Cb_sig, Cr_sig, hue_sig);
        end
        
        % (4) Discard false positives (FP) uisng the propertires of the
        % connected components of the final mask such as form factor, 
        % filling ratio, etc. Two methos are used: Connected Component 
        % Labeling (CCL) and Sliding Window (SLW). 
        switch(CCM)
            case 'CCL'                        
                [final_mask, WindowCandidates] = CCL_filtering(final_mask, features);        
            case 'SLW_basic'
                [final_mask, WindowCandidates] = SLW_filtering_basic(final_mask, features); 
             case 'SLW_integral_image'
                [final_mask, WindowCandidates] = SLW_filtering_integral_image(final_mask, features); 
             case 'SLW_conv'
                [final_mask, WindowCandidates] = SLW_filtering_conv(final_mask, features); 
            otherwise
        end
        
    % stop timer and store required time to create the current mask
    time(i) = toc; 
       
    % store current mask and window candidates
    masks{i} = final_mask; 
    windows{i} = WindowCandidates;
    % save results for visualization
    % save_visualize_results(['Results/Validation_Set/',test_files{i}(1:end-4)], final_mask, im, WindowCandidates);
    
end 
    
         
close all;
txf = mean(time); % return average time per frame       
end
