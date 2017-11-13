function [mask] = template_matching_DT (mask, templates)

% get connected components
labels = bwlabel(mask);
CC = regionprops(labels,'BoundingBox');

for i = 1:size(CC,1)
    
    bbox = CC(i).BoundingBox;
    candidate = mask(ceil(bbox(2)):floor(bbox(2)+bbox(4)),ceil(bbox(1)):floor(bbox(1)+bbox(3)));

    % compute edges with sobel
    B_triangle1 = edge(imresize(padarray(candidate,[1 1],0,'both'),size(templates.triangle1)),'Sobel');
    B_triangle2 = edge(imresize(padarray(candidate,[1 1],0,'both'),size(templates.triangle2)),'Sobel');
    B_circle= edge(imresize(padarray(candidate,[1 1],0,'both'),size(templates.circle)),'Sobel');
    B_square1 = edge(imresize(padarray(candidate,[1 1],0,'both'),size(templates.square1)),'Sobel');
    B_square2 = edge(imresize(padarray(candidate,[1 1],0,'both'),size(templates.square2)),'Sobel');
    B_square3 = edge(imresize(padarray(candidate,[1 1],0,'both'),size(templates.square3)),'Sobel');
    
    % distance transform
    D_triangle1 = bwdist(B_triangle1);
    D_triangle2 = bwdist(B_triangle2);
    D_circle = bwdist(B_circle);
    D_square1 = bwdist(B_square1);
    D_square2 = bwdist(B_square2);
    D_square3 = bwdist(B_square3);
    
    % chamfer distance
    coef_triangle1 = sum(sum(D_triangle1.*templates.triangle1));
    coef_triangle2 = sum(sum(D_triangle2.*templates.triangle2));
    coef_circle = sum(sum(D_circle.*templates.circle));
    coef_square1 = sum(sum(D_square1.*templates.square1));
    coef_square2 = sum(sum(D_square2.*templates.square2));
    coef_square3 = sum(sum(D_square3.*templates.square3));
    
    % Filter
    v = [coef_triangle1*0.8,coef_triangle2*0.8,coef_circle*1.4,coef_square1,coef_square2,coef_square3];
    if min(v) > 1000
        labels(labels==i) = 0;
        mask = labels>0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for display
    
%     figure(2);
%     
%     subplot(3,6,1); imshow(B_triangle1);
%     subplot(3,6,2); imshow(B_triangle2);
%     subplot(3,6,3); imshow(B_circle);
%     subplot(3,6,4); imshow(B_square1);
%     subplot(3,6,5); imshow(B_square2);
%     subplot(3,6,6); imshow(B_square3);
% 
%     subplot(3,6,7); imagesc(D_triangle1);
%     subplot(3,6,8); imagesc(D_triangle2);
%     subplot(3,6,9); imagesc(D_circle);
%     subplot(3,6,10); imagesc(D_square1);
%     subplot(3,6,11); imagesc(D_square2);
%     subplot(3,6,12); imagesc(D_square3);
% 
%     subplot(3,6,13); imshow(templates.triangle1); title(coef_triangle1*0.8);
%     subplot(3,6,14); imshow(templates.triangle2); title(coef_triangle2*0.8);
%     subplot(3,6,15); imshow(templates.circle); title(coef_circle*1.4);
%     subplot(3,6,16); imshow(templates.square1); title(coef_square1);
%     subplot(3,6,17); imshow(templates.square2); title(coef_square2);
%     subplot(3,6,18); imshow(templates.square3); title(coef_square3);
% 
%     close(figure(2));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

end