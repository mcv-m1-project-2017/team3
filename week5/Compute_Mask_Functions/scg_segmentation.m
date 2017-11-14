function [final_mask] = mcg_segmentation(im, features, seg_method)

final_mask = zeros(size(im,1),size(im,2)); % init. final mask

[candidates_mcg, ucm2_mcg] = im2mcg(im,'fast'); % segment image

% we decide that only those 'objects' with score higher than 0.3 are relevant
[candidates_mcg.scores,idx] = sort(candidates_mcg.scores,'descend');
candidates_mcg.scores = candidates_mcg.scores(candidates_mcg.scores > 0.25);

% load model histograms for histogram comparison
load('hue_sig.mat');

for i = 1:size(candidates_mcg.scores,1) 
    
    discard = 0; % set to 1 if this component is to be discarded
    
    mask = ismember(candidates_mcg.superpixels, candidates_mcg.labels{idx(i)});
    bbox = candidates_mcg.bboxes(idx(i),:);
    roi_mask = mask(bbox(1):bbox(3),bbox(2):bbox(4));
    roi_im = im(bbox(1):bbox(3),bbox(2):bbox(4),:);
    roi_mask = imfill(roi_mask,'holes');
    
    % extract features of current candidate
    width = bbox(4)-bbox(2);
    height = bbox(3)-bbox(1);
    bbox_area = width*height;
    form_factor = width/height;
    signal_size = sum(sum(roi_mask));
    %imshow(roi_mask);
    
    % filter according to form_factor, size and bbox area
    if ~(    ( form_factor>= 0.5 && form_factor<= 1.2 )  ...
          && ( signal_size >= min(features.size.min) && signal_size <= max(features.size.max)) ...
          && ( bbox_area >= 900 && bbox_area <= 56000 ) )
                discard = 1;
    end
    
    % filter according to histogram comparison (Hue channel)
    edges = linspace(0,1,101);
    if (discard == 0)
        candidate_HSV = rgb2hsv(roi_im);
        candidate_H = candidate_HSV(:,:,1);
        hist_candidate = histcounts(candidate_H(roi_mask~=0),edges)/numel(candidate_H);
        match_values_H = zeros([1 6]);
        for h=1:6
            match_values_H(h) = sum(min(hist_candidate, hue_sig{h}));
        end
        %imshow(roi_im.*uint8(roi_mask));
        %match_values_H
        if match_values_H < 0.4
            discard = 1;
        else
            [maxim, index] = max(match_values_H);
            if (index == 1 || index == 2 || index == 3) ... 
               && abs(maxim-match_values_H(4)) < 0.2 ...
               && abs(maxim-match_values_H(6)) < 0.2
                discard = 1;
            elseif (index == 4 || index == 6 ) && maxim < 0.5
                discard = 1;
            end
        end
    end
    
    % the component is kept if it has not been discarded at this point
    if discard == 0
        final_mask(bbox(1):bbox(3),bbox(2):bbox(4)) = roi_mask;
    end
    
end

%final_mask = imclose(final_mask, strel('disk',9));
final_mask = imfill(final_mask);

%subplot(2,2,1), imshow(im), subplot(2,2,2), imshow(final_mask);
%subplot(2,2,3), imshow(imdilate(ucm2_mcg,strel(ones(3))));

switch(seg_method)
    case 'SCG_TM'
        % run template matching (distance transform) as implemented in week 4
        if exist('Templates/templates_edges.mat')
            load ('Templates/templates_edges.mat')
        else
            get_templates_predefined;
            load ('Templates/templates_edges.mat')
        end
        final_mask = template_matching_DT(final_mask, templates_edges);
    case 'SCG_Hough'  
        %Hough transform goes here
        labels = bwlabel(final_mask);
        CC = regionprops(labels,'BoundingBox');
        for i = 1:size(CC,1)
            discard = 0;
            
            bbox = CC(i).BoundingBox;
            candidate = final_mask(ceil(bbox(2)):floor(bbox(2)+bbox(4)),ceil(bbox(1)):floor(bbox(1)+bbox(3)));
            
            bbox_area = bbox(3)*bbox(4);
            form_factor = bbox(3)/bbox(4);
            signal_size = sum(sum(candidate));
            
            if ~(    ( form_factor>= 0.5 && form_factor<= 1.2 )  ...
                && ( signal_size >= min(features.size.min) && signal_size <= max(features.size.max)) ...
                && ( bbox_area >= 900 && bbox_area <= 56000 ) )
                    discard = 1;
            end
            
            % filter using hough transform
            if discard 
                final_mask(labels==i) = 0;
            else
                remove = hough_filter(candidate);
                if ~remove
                    final_mask(labels==i) = 0;
                end
            end
        end    
    otherwise
        
end
%subplot(2,2,4), imshow(final_mask);

final_mask = imclose(final_mask, strel('disk',9));

end