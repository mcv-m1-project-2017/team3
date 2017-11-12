function mask = template_matching_corr(mask, templates)

% get connected components
labels = bwlabel(mask);
CC_info = regionprops(labels,'BoundingBox');

for i = 1:length(CC_info)

    % pick connected component
    bbox = CC_info(i).BoundingBox;
    CC = mask(ceil(bbox(2)):floor(bbox(2)+bbox(4)),ceil(bbox(1)):floor(bbox(1)+bbox(3)));

    % resize to templates size
    CC_triangle1 = imresize(CC,size(templates.triangle1));
    CC_triangle2 = imresize(CC,size(templates.triangle2));
    CC_circle = imresize(CC,size(templates.circle));
    CC_square1 = imresize(CC,size(templates.square1));
    CC_square2 = imresize(CC,size(templates.square2));
    CC_square3 = imresize(CC,size(templates.square3));

    % compute correlation between CC and templates
    correlation(1) = corr2(CC_triangle1, templates.triangle1);
    correlation(2) = corr2(CC_triangle2, templates.triangle2);
    correlation(3) = corr2(CC_circle, templates.circle);
    correlation(4) = corr2(CC_square1, templates.square1);
    correlation(5) = corr2(CC_square2, templates.square2);
    correlation(6) = corr2(CC_square3, templates.square3);
    
    %sort the correlations vector to select first and second max.
    [v, idx] = sort(correlation,'descend'); 
    if ((v(1) > 0.6))
        switch idx(1)
            case 1:3
                if ~(v(1)-v(2)>0.3)
                    labels(labels==i) = 0;
                    mask = labels>0;
                end 
             otherwise
        end
    else
        labels(labels==i) = 0;
        mask = labels>0;
    end
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for display
    
%     figure(2);
% 
%     subplot(2,6,1);imshow(templates.triangle1); title(correlation(1));
%     subplot(2,6,2);imshow(templates.triangle2); title(correlation(2));
%     subplot(2,6,3);imshow(templates.circle); title(correlation(3));
%     subplot(2,6,4);imshow(templates.square1); title(correlation(4));
%     subplot(2,6,5);imshow(templates.square2); title(correlation(5));
%     subplot(2,6,6);imshow(templates.square3); title(correlation(6));
%     subplot(2,6,7);imshow(CC_triangle1); 
%     subplot(2,6,8);imshow(CC_triangle2); 
%     subplot(2,6,9);imshow(CC_circle); 
%     subplot(2,6,10);imshow(CC_square1); 
%     subplot(2,6,11);imshow(CC_square2); 
%     subplot(2,6,12);imshow(CC_square3); 
%     
%     close(figure(2));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

end