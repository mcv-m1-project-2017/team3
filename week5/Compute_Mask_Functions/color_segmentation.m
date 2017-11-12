function [final_mask] = color_segmentation(imYCbCr, imHSV, seg_type)

% INPUT: 'imYCbCr' input image in the YCbCr color space
%        'imHSV' input image in the HSV color spaces
%        'seg_type' segmentation type to compute the mask directory of the ground-truth annotation files
%
% OUTPUT:'final_mask' resulting mask computed with the color segmentation 

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
        mask_RED = or(mask_Cr,mask_RH);
        % Blue
        mask_Cb = imYCbCr(:,:,2) > 135 & imYCbCr(:,:,2) < 175 & imYCbCr(:,:,1) < 175;
        mask_BH = imHSV(:,:,1)>0.55 & imHSV(:,:,1)<0.7;
        mask_BLUE = or(mask_Cb,mask_BH);
        % Final
        final_mask = or(mask_BLUE,mask_RED);
     case 'HS'
        % Red
        
        mask_RED = (imHSV(:,:,1) > 0.9 | imHSV(:,:,1) < 0.07) & imHSV(:,:,2)>0.4 & imHSV(:,:,3)>0;
        % Blue 1
        mask_BLUE1 = imHSV(:,:,1) > 0.5 & imHSV(:,:,1) < 0.7 & imHSV(:,:,2)>0.4 & imHSV(:,:,3)>0;
        % Blue 2
        mask_BLUE2 = imHSV(:,:,1) > 0.58 & imHSV(:,:,1) < 0.83 & imHSV(:,:,2) > 0.15 & imHSV(:,:,2) < 0.4 & imHSV(:,:,3) < 0.3; 
        % Final
        final_mask = mask_BLUE1 | mask_RED | mask_BLUE2;
    otherwise
        error('The segmentation type is not valid');
end

end