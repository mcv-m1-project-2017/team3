function create_hist_backproject(img_dir, mask_dir, gt_dir, hist_type, nbins)

%   Computes and saves the 2D histogram (with 2 channels) for each color 
%   group of signs using the training dataset.

%   INPUT: 'img_dir' directory of the files provided for training
%          'mask_dir' directory of the ground-truth masks
%          'gt_dir' directory of the ground-truth annotation txt files
%          'hist_type' string that can be 'HS'or 'CbCr' indicating 
%                      which color spaces and channels are used to 
%                      construct the 2D histograms
%          'nbins'  number of bins in each dimension of the 2D histogram
%                   total number of bins will be nbins*nbins
%   

%   OUTPUT: 3 files 'BLUE_hist.mat', 'RED_hist.mat', 'RED-BLUE_hist.mat' 
%           containing the normalized histogram value in each bin and the
%           centroids of the bins
%   

% list training files
% 'img_files' cell will contain the filenames of all training files
tmp = ListFiles(img_dir);
img_files = cell([1 length(tmp)]); 
for k=1:length(tmp)
    img_files{k} = tmp(k).name;
end

% init. vectors where the most relevant color components will be stored
H_A = []; H_B = []; H_C = []; H_D = []; H_E = []; H_F = [];
S_A = []; S_B = []; S_C = []; S_D = []; S_E = []; S_F = [];
Cb_A = []; Cb_B = []; Cb_C = []; Cb_D = []; Cb_E = []; Cb_F = [];
Cr_A = []; Cr_B = []; Cr_C = []; Cr_D = []; Cr_E = []; Cr_F = [];

% iterate through all training files
for i=1:size(img_files,2)

    % read the current training image and the associated ground-truth mask
    im = imread(strcat(img_dir ,'/',img_files{i}));
    im_mask = imread(strcat(mask_dir ,'/',['mask.',img_files{i}(1:end-3),'png']));
    im_mask(im_mask~=0)=1; % some masks are not binary !!! 
    
    % filter the current image using the mask
    im_filt(:,:,1) = im(:,:,1).*im_mask;
    im_filt(:,:,2) = im(:,:,2).*im_mask;
    im_filt(:,:,3) = im(:,:,3).*im_mask;
    
    % open and read the associated ground-truth annotation filex_
    fileID = fopen(strcat(gt_dir ,'/',['gt.',img_files{i}(1:end-3),'txt']));
    line = fgetl(fileID);
  
    while line ~= -1
        
        bbox = sscanf(line,'%f'); % get tl and br coord. of the bbox delimiting the signal
        type = line(end);         % get signal type
        
        % extract the signal from the filtered image using the bbox 
        x = im_filt(ceil(bbox(1)):floor(bbox(3)),ceil(bbox(2)):floor(bbox(4)),:);
        % extract the equivalent window from the mask and reshape it into a vector
        mask = im_mask(ceil(bbox(1)):floor(bbox(3)),ceil(bbox(2)):floor(bbox(4)),:);
        mask = reshape(mask, [1,size(mask,1)*size(mask,2)]);
        
        % convert the signal to HSV and YCbCr
        x_HSV = rgb2hsv(x);
        x_YCbCr = rgb2ycbcr(x); 
        im_HSV = rgb2hsv(im);
        
        % extract the Hue and Saturation channels of HSV as vectors 
        % and filter them using the mask
        hue = reshape(x_HSV(:,:,1), [1,size(x_HSV,1)*size(x_HSV,2)]);
        saturation = reshape(x_HSV(:,:,2), [1,size(x_HSV,1)*size(x_HSV,2)]);
        hue_im = reshape(im_HSV(:,:,1), [1,size(im_HSV,1)*size(im_HSV,2)]);
        saturation_im = reshape(im_HSV(:,:,2), [1,size(im_HSV,1)*size(im_HSV,2)]);
        H_filt = hue(mask ~= 0);
        S_filt = saturation(mask ~= 0);
        
        % do the same with the CbCr chrominance channels of YCbCr
        Cb = double(reshape(x_YCbCr(:,:,2), [1,size(x_YCbCr,1)*size(x_YCbCr,2)]));
        Cr = double(reshape(x_YCbCr(:,:,3), [1,size(x_YCbCr,1)*size(x_YCbCr,2)]));
        Cb_filt = Cb(mask ~= 0);
        Cr_filt = Cr(mask ~= 0);

        % concatenate the H, Cb and Cr vectors of all signals 
        % according to the type of signal
        switch(type)
            case 'A'
                H_A = [H_A, H_filt]; S_A = [S_A, S_filt];
                Cb_A = [Cb_A, Cb_filt]; Cr_A = [Cr_A, Cr_filt];
            case 'B'              
                H_B = [H_B, H_filt]; S_B = [S_B, S_filt];
                Cb_B = [Cb_B, Cb_filt]; Cr_B = [Cr_B, Cr_filt];
            case 'C'            
                H_C = [H_C, H_filt]; S_C = [S_C, S_filt];
                Cb_C = [Cb_C, Cb_filt]; Cr_C = [Cr_C, Cr_filt];    
            case 'D'
                H_D = [H_D, H_filt]; S_D = [S_D, S_filt];
                Cb_D = [Cb_D, Cb_filt]; Cr_D = [Cr_D, Cr_filt];
            case 'E'
                H_E = [H_E, H_filt]; S_E = [S_E, S_filt];
                Cb_E = [Cb_E, Cb_filt]; Cr_E = [Cr_E, Cr_filt];
            case 'F'
                H_F = [H_F, H_filt]; S_F = [S_F, S_filt];
                Cb_F = [Cb_F, Cb_filt]; Cr_F = [Cr_F, Cr_filt];
            otherwise

        end
        line = fgetl(fileID);
        
    end
    fclose(fileID);
end

% figure % display 1 channel histograms for RED signals (type A-B-C)
% subplot(1,3,1); histogram([H_A,H_B,H_C]); title('H (red)');
% subplot(1,3,2); histogram([Cb_A,Cb_B,Cb_C]); title('Cb (red)');
% subplot(1,3,3); histogram([Cr_A,Cr_B,Cr_C]); title('Cr (red)');
% figure % display 1 channel histograms for BLUE signals (type D-F)
% subplot(1,3,1); histogram([H_D,H_F]); title('H (blue)');
% subplot(1,3,2); histogram([Cb_D,Cb_F]); title('Cb (blue)');
% subplot(1,3,3); histogram([Cr_D,Cr_F]); title('Cr (blue)');
% figure % display 1 channel histograms for RED-BLUE signals (type E)
% subplot(1,3,1); histogram(H_E); title('H (red-blue)');
% subplot(1,3,2); histogram(Cb_E); title('Cb (red-blue)');
% subplot(1,3,3); histogram(Cr_E); title('Cr (red-blue)');

switch (hist_type)
    case 'HS' % Use HUE and SATURATION
        % full image HS hist
        im_H_S = [hue_im; saturation_im];
        [hist_im,c_R] = hist3(im_H_S', [nbins nbins]);
        [v,locmax] = max(hist_im(:));
        
        % 2D histogram BLUE signals (H and S)
        blue_H = [H_D,H_F]; blue_S = [S_D,S_F];
        blue_H_S = [blue_H; blue_S];
        [hist_BLUE,c_B] = hist3(blue_H_S', [nbins nbins]);
        hist_BLUE(locmax) = 0;
        norm_hist_BLUE = hist_BLUE/(length(blue_H)); % normalize 
        figure; bar3(norm_hist_BLUE), title('Blue (HS)'), xlabel('Saturation'), ylabel('Hue');
        %set(gca,'XTickLabel',c_B{2}), set(gca,'YTickLabel',c_B{1});

        % 2D histogram RED signals (HS)
        red_H = [H_A,H_B,H_C]; red_S = [S_A,S_B,S_C];
        red_H_S = [red_H; red_S];
        [hist_RED,c_R] = hist3(red_H_S', [nbins nbins]);
        hist_RED(locmax)=0;
        norm_hist_RED = hist_RED/(length(red_H)); % normalize 
        figure; bar3(norm_hist_RED), title('Red (HS)'), xlabel('Saturation'), ylabel('Hue'); 
        %set(gca,'XTickLabel',c_R{2}), set(gca,'YTickLabel',c_R{1});
        
        % 2D histogram RED-BLUE signals (HS)
        red_blue_H = H_E; red_blue_S = S_E; 
        red_blue_H_S = [red_blue_H; red_blue_S];
        [hist_RED_BLUE,c_RB] = hist3(red_blue_H_S', [nbins nbins]);
        hist_RED_BLUE(locmax)=0;
        norm_hist_RED_BLUE = hist_RED_BLUE/(length(red_blue_H)); % normalize 
        figure; bar3(norm_hist_RED_BLUE), title('Red-Blue (HS)'), xlabel('Saturation'), ylabel('Hue');
        %set(gca,'XTickLabel',c_RB{2}), set(gca,'YTickLabel',c_RB{1});  
        
        
        % Save histograms
        save('BLUE_hist_HS', 'norm_hist_BLUE', 'c_B');
        save('RED_hist_HS', 'norm_hist_RED', 'c_R');
        save('RED_BLUE_hist_HS', 'norm_hist_RED_BLUE', 'c_RB');
    
    case 'CbCr' % Use Cb and Cr
        % 2D histogram BLUE signals (CbCr)
        blue_Cb = [Cb_D,Cb_F]; blue_Cr = [Cr_D,Cr_F];
        blue_Cb_Cr = [blue_Cb; blue_Cr];
        [hist_BLUE,c_B] = hist3(blue_Cb_Cr', [nbins nbins]);
        norm_hist_BLUE = hist_BLUE/(length(blue_Cr)); % normalize 
        figure; bar3(norm_hist_BLUE), title('Blue (CbCr)'), xlabel('Cr'), ylabel('Cb');
        %set(gca,'XTickLabel',c_B{2}), set(gca,'YTickLabel',c_B{1});

        % 2D histogram RED signals (CbCr)
        red_Cb = [Cb_A,Cb_B,Cb_C]; red_Cr = [Cr_A,Cr_B,Cr_C];
        red_Cb_Cr = [red_Cb; red_Cr];
        [hist_RED,c_R] = hist3(red_Cb_Cr', [nbins nbins]);
        norm_hist_RED = hist_RED/(length(red_Cr)); % normalize 
        figure; bar3(norm_hist_RED), title('Red (CbCr)'), xlabel('Cr'), ylabel('Cb'); 
        %set(gca,'XTickLabel',c_R{2}), set(gca,'YTickLabel',c_R{1});
 
        % 2D histogram RED-BLUE signals (CbCr)
        red_blue_Cb = Cb_E; red_blue_Cr = Cr_E; 
        red_blue_Cb_Cr = [red_blue_Cb; red_blue_Cr];
        [hist_RED_BLUE,c_RB] = hist3(red_blue_Cb_Cr', [nbins nbins]);
        norm_hist_RED_BLUE = hist_RED_BLUE/(length(red_blue_Cr)); % normalize 
        figure; bar3(norm_hist_RED_BLUE), title('Red-Blue (CbCr)'), xlabel('Cr'), ylabel('Cb'); 
        %set(gca,'XTickLabel',c_RB{2}), set(gca,'YTickLabel',c_RB{1});   
        
        % Save histograms
        save('BLUE_hist_CbCr', 'norm_hist_BLUE', 'c_B');
        save('RED_hist_CbCr', 'norm_hist_RED', 'c_R');
        save('RED_BLUE_hist_CbCr', 'norm_hist_RED_BLUE', 'c_RB');
    otherwise
        error('The histogram type is not valid');
end 


    
end