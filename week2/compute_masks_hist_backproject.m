function [masks, txf] = compute_masks_hist_backproject(img_dir, test_files, hist_type, size_filt, hole_fill, noise_filt, hist_comp)

% INPUT: 'img_dir' directory of the files provided for training
%        'mask_dir' directory of the ground-truth mask files
%        'gt_dir' directory of the ground-truth annotation files
%        'train_files' cell array containing the name of all train files
%        'test_files' cell array containing the name of all test files
%        'hist_type' string that can be 'HS' or 'CbCr', indicating 
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
%

% OUTPUT: 'masks' cell array containing the output masks
%         'txf' average value of computation time per frame
%

if strcmp(hist_type,'CbCr')
    load('RED_hist_CbCr.mat');
    load('BLUE_hist_CbCr.mat');
    load('RED_BLUE_hist_CbCr.mat');
end 

if strcmp(hist_type,'HS')
    load('RED_hist_HS.mat');
    load('BLUE_hist_HS.mat');
    load('RED_BLUE_hist_HS.mat');
end 

masks = cell([1 length(test_files)]); % cell array to store output masks
time = zeros([1 length(test_files)]); % vector to store time per frame


CbCr_threshold_B = 0.1;
CbCr_threshold_R = 0.1;
CbCr_threshold_RB = 0.1;
CbCr_threshold_B_up = 0.3;
CbCr_threshold_R_up = 0.18;
CbCr_threshold_RB_up = 1;

HS_threshold_B = 0.02;
HS_threshold_R = 0.04;
HS_threshold_RB = 0.02;

for i=1:length(test_files)
        
        i
        tic; % start timer

        % read current image and convert it to YCbCr and HSV colorspaces
        im = imread(strcat(img_dir,'/',test_files{i}));
        imYCbCr= rgb2ycbcr(im);
        imHSV = rgb2hsv(im);
       
        % arrays of probabilities for each group of color
        p_BLUE = zeros(size(im,1),size(im,2));
        p_RED = zeros(size(im,1),size(im,2));
        p_RED_BLUE = zeros(size(im,1),size(im,2));
  
        switch(hist_type)
            
            case 'HS' 
                % iterate for all pixels in the image
                for j = 1:size(im,1)
                    for k = 1:size(im,2)            
                        % find the nearest bin centroid to current
                        % pixel (j,k) Hue and Saturation values
                        [~,loc_B_H] = min(abs(c_B{1}-imHSV(j,k,1)));
                        [~,loc_B_S] = min(abs(c_B{2}-imHSV(j,k,2)));
                        [~,loc_R_H] = min(abs(c_R{1}-imHSV(j,k,1)));
                        [~,loc_R_S] = min(abs(c_R{2}-imHSV(j,k,2)));                 
                        [~,loc_RB_H] = min(abs(c_RB{1}-imHSV(j,k,1)));
                        [~,loc_RB_S] = min(abs(c_RB{2}-imHSV(j,k,2)));
                        
                        % the probability of pixel (j,k) being part of
                        % each signal group is the value in the previous bin
                        p_BLUE(j,k) = norm_hist_BLUE(loc_B_H,loc_B_S);
                        p_RED(j,k) = norm_hist_RED(loc_R_H,loc_R_S);
                        p_RED_BLUE(j,k) = norm_hist_RED_BLUE(loc_RB_H,loc_RB_S);
                    end
                end
                % only those pixels with probability higher than the
                % threshold will be part of each color group mask
                mask_BLUE = p_BLUE > HS_threshold_B;
                mask_BLUE = mask_BLUE*0;
                mask_RED = p_RED > HS_threshold_R;
                mask_RED = mask_RED*0;
                mask_RED_BLUE = p_RED_BLUE > HS_threshold_RB;
                    
            case 'CbCr'
                % iterate for all pixels in the image
                 for j = 1:size(im,1)
                    for k = 1:size(im,2)
                        % find the nearest bin centroid to current
                        % pixel (j,k) Cb and Cr values
                        [~,loc_B_Cb] = min(abs(c_B{1}-double(imYCbCr(j,k,2))));
                        [~,loc_B_Cr] = min(abs(c_B{2}-double(imYCbCr(j,k,3))));
                        [~,loc_R_Cb] = min(abs(c_R{1}-double(imYCbCr(j,k,2))));
                        [~,loc_R_Cr] = min(abs(c_R{2}-double(imYCbCr(j,k,3))));
                        [~,loc_RB_Cb] = min(abs(c_RB{1}-double(imYCbCr(j,k,2))));
                        [~,loc_RB_Cr] = min(abs(c_RB{2}-double(imYCbCr(j,k,3))));

                        % the probability of pixel (j,k) being part of
                        % each signal group is the value in the previous bin
                        p_BLUE(j,k) = norm_hist_BLUE(loc_B_Cb,loc_B_Cr);
                        p_RED(j,k) = norm_hist_RED(loc_R_Cb,loc_R_Cr);
                        p_RED_BLUE(j,k) = norm_hist_RED_BLUE(loc_RB_Cb,loc_RB_Cr);
                    end
                 end
                % only those pixels with probability higher than the
                % threshold will be part of each color group mask
                mask_BLUE = (p_BLUE > CbCr_threshold_B) & (p_BLUE < CbCr_threshold_B_up);
                mask_RED = (p_RED > CbCr_threshold_R) & (p_RED < CbCr_threshold_R_up);
                mask_RED_BLUE = (p_RED_BLUE > CbCr_threshold_RB)&(p_RED_BLUE < CbCr_threshold_RB_up);
           
            otherwise
                error('The histogram type is not valid');
        end
        
        % build the final mask
        final_mask = or(or(mask_BLUE,mask_RED),mask_RED_BLUE);
%         figure; subplot(1,2,1); imshow(im), title('Original image'); 
%         subplot(1,2,2); imshow(final_mask), title('Color segmentation mask');
        
        % (1) Color segmentation is used to detect red and blue, which are
        %     the colors that stand out when it comes to traffic signals.
        %     However, some signals have white/black parts in the middle.
        %     The white/black parts may not be detected with color seg.
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
        final_mask = imopen(final_mask, ones(5,5)); 
        if strcmp(noise_filt,'Yes')
            SE = ones(5,5);
            final_mask = imopen(final_mask, SE); 
        end
        
        % (3) The minimum and maximum size of each type of signal is known,
        %     so a min. and a max. amount of pixels that a reasonable 
        %     signal would accupy can be stablished to filter all the
        %     connected components in the mask outside of this range
        if strcmp(size_filt,'Yes')
                labels = bwlabel(final_mask); % label connected components
                for j=1:max(max(labels)) % iterate through all components
                    % if the area of the component is smaller than the 
                    % minimum expected size or bigger than the maximum
                    % expected size, then this component is most probably
                    % not a signal and can be erased from the mask
                    if sum(sum(labels==j))<200 || sum(sum(labels==j))>60000
                        labels(labels==j)=0;
                    end
                end
                final_mask = labels>0;
        end
                
        % (4) Histogram Comparison between each connected component of each
        % mask and the six different model histograms (one for each siganl
        % type).
        if strcmp(hist_comp,'Yes')
            if i == 1
                close all;
                load('hue_sig.mat');
                load('Cb_sig.mat');
                load('Cr_sig.mat');
            end
            labels = bwlabel(final_mask);
            for s=1:max(max(labels))
                labels_tmp = labels;
                labels_tmp(labels~=s)=0;
                labels_tmp(labels_tmp==s)=1;
                sig_detected = uint8(labels_tmp).*im;
                sig_detected_HSV = rgb2hsv(sig_detected);
    %             sig_detected_YCbCr = rgb2ycbcr(sig_detected);
                H_sig_detected = sig_detected_HSV(:,:,1);
    %             Cb_sig_detected = sig_detected_YCbCr(:,:,2);
    %             Cr_sig_detected = sig_detected_YCbCr(:,:,3);
                %figure(); imshow(sig_detected);
                %subplot(1,3,1);
                if max(any(H_sig_detected))
                    figure();
                    hist_target_hue = histogram(H_sig_detected(H_sig_detected~=0),100);
                    hist_target_hue.BinCounts = hist_target_hue.BinCounts/length(hist_target_hue.Data);
        %             subplot(1,3,2); hist_target_Cb = histogram(Cb_sig_detected(Cb_sig_detected~=0),100);
        %             hist_target_Cb.BinCounts = hist_target_Cb.BinCounts/length(hist_target_Cb.Data);
        %             subplot(1,3,3); hist_target_Cr = histogram(Cr_sig_detected(Cr_sig_detected~=0),100);
        %             hist_target_Cr.BinCounts = hist_target_Cr.BinCounts/length(hist_target_Cr.Data);
                    for h=1:6
                        match_values_H(h) = compare_histograms(hist_target_hue, hue_sig{h});
        %                 match_values_Cb(h) = compare_histograms(hist_target_Cb, Cb_sig{h});
        %                 match_values_Cr(h) = compare_histograms(hist_target_Cr, Cr_sig{h});
                    end
                    close(figure(7));
                    if match_values_H(:)<0.5
                        if match_values_H(4)<0.24 & match_values_H(6)<0.18
                            labels(labels==s)=0;
                        end
                    end
                end
            end
            labels(labels~=0)=1;
    %         figure();
    %         subplot(1,2,1); imshow(final_mask);
            final_mask = labels;
    %         subplot(1,2,2); imshow(final_mask);
        end
        masks{i} = final_mask; % store current mask
        
        % stop timer and store required time to create the current mask
        time(i) = toc; 
end

txf = mean(time); % return average time per frame
end