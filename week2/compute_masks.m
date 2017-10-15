function [masks, txf] = compute_masks(img_dir, test_files, seg_type, size_filt, hole_fill, noise_filt, hist_comp)

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
%

masks = cell([1 length(test_files)]); % cell array to store output masks
time = zeros([1 length(test_files)]); % vector to store time per frame

for i=1:length(test_files)
        
        tic; % Start timer

        % Read current image and convert it to YCbCr and HSV colorspaces
        im = imread(strcat(img_dir,'/',test_files{i}));
        imYCbCr= rgb2ycbcr(im);
        imHSV = rgb2hsv(im);
       
        % Use COLOR SEGMENTATION to create a mask
        switch(seg_type)
            case 'CbCr'
                % Detection of red signals --> mask 1
                mask_Cr = imYCbCr(:,:,3) > 135 & imYCbCr(:,:,3) < 175;
                % Detection of blue signals --> mask 2
                mask_Cb = imYCbCr(:,:,2) > 135 & imYCbCr(:,:,2) < 175 & imYCbCr(:,:,1) < 175;
                % Join mask 1 and mask 2 to obtain the final mask
                final_mask = or(mask_Cr,mask_Cb);
            case 'H'
                % Red
                mask_RH = imHSV(:,:,1)>0.9 | imHSV(:,:,1)<0.03;
                % Blue
                mask_BH = imHSV(:,:,1)>0.55 & imHSV(:,:,1)<0.7;
                % Final
                final_mask = or(mask_RH,mask_BH);
            case 'HCbCr'
                % Red
                mask_Cr = imYCbCr(:,:,3) > 135 & imYCbCr(:,:,3) < 175;
                mask_RH = imHSV(:,:,1)>0.9 | imHSV(:,:,1)<0.03;
                mask_RED = and(mask_Cr,mask_RH);
                % Blue
                mask_Cb = imYCbCr(:,:,2) > 135 & imYCbCr(:,:,2) < 175 & imYCbCr(:,:,1) < 175;             
                mask_BH = imHSV(:,:,1)>0.55 & imHSV(:,:,1)<0.7;
                mask_BLUE = and(mask_Cb,mask_BH);   
                % Final
                final_mask = or(mask_BLUE,mask_RED);
            otherwise
                error('The segmentation type is not valid');
        end
        
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
close all;
txf = mean(time); % return average time per frame
end