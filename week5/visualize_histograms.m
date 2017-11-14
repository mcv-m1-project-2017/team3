function [hue_sig, Cb_sig, Cr_sig]=visualize_histograms(img_dir, mask_dir, gt_dir, train_files, group_by)

% INPUT: 'img_dir' directory of the files provided for training
%        'mask_dir' directory of the ground-truth masks
%        'gt_dir' directory of the ground-truth annotation txt files
%        'train_files' cell array containing the name of all train files
%        'group_by' string that can be 'type' or 'color', indicating if 
%                   you want to see a histogram for each type of signal 
%                   or each color group of signals (red, blue, red-blue) 
%        

% init. vectors where the most relevant color components will be stored
H_A = []; H_B = []; H_C = []; H_D = []; H_E = []; H_F = [];
Cb_A = []; Cb_B = []; Cb_C = []; Cb_D = []; Cb_E = []; Cb_F = [];
Cr_A = []; Cr_B = []; Cr_C = []; Cr_D = []; Cr_E = []; Cr_F = [];

% iterate through all training files
for i=1:size(train_files,2)

    % read the current training image and the associated ground-truth mask
    im = imread(strcat(img_dir ,'/',train_files{i}));
    im_mask = imread(strcat(mask_dir ,'/',['mask.',train_files{i}(1:end-3),'png']));
    im_mask(im_mask~=0)=1; % some masks are not binary !!! 
    
    % filter the current image using the mask
    im_filt(:,:,1) = im(:,:,1).*im_mask;
    im_filt(:,:,2) = im(:,:,2).*im_mask;
    im_filt(:,:,3) = im(:,:,3).*im_mask;
    
    % open and read the associated ground-truth annotation file
    fileID = fopen(strcat(gt_dir ,'/',['gt.',train_files{i}(1:end-3),'txt']));
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
        
        % extract the Hue channel of HSV as a vector and filter it using the mask
        H = reshape(x_HSV(:,:,1), [1,size(x_HSV,1)*size(x_HSV,2)]);
        H_filt = H(mask ~= 0);
        
        % do the same with the CbCr chrominance channels of YCbCr
        Cb = reshape(x_YCbCr(:,:,2), [1,size(x_YCbCr,1)*size(x_YCbCr,2)]);
        Cr = reshape(x_YCbCr(:,:,3), [1,size(x_YCbCr,1)*size(x_YCbCr,2)]);
        Cb_filt = Cb(mask ~= 0);
        Cr_filt = Cr(mask ~= 0);
        
        % concatenate the H, Cb and Cr vectors of all signals 
        % according to the type of signal
        switch(type)
            case 'A'
                H_A = [H_A, H_filt]; 
                Cb_A = [Cb_A, Cb_filt]; Cr_A = [Cr_A, Cr_filt];
            case 'B'              
                H_B = [H_B, H_filt];
                Cb_B = [Cb_B, Cb_filt]; Cr_B = [Cr_B, Cr_filt];
            case 'C'            
                H_C = [H_C, H_filt];
                Cb_C = [Cb_C, Cb_filt]; Cr_C = [Cr_C, Cr_filt];    
            case 'D'
                H_D = [H_D, H_filt];
                Cb_D = [Cb_D, Cb_filt]; Cr_D = [Cr_D, Cr_filt];
            case 'E'
                H_E = [H_E, H_filt];
                Cb_E = [Cb_E, Cb_filt]; Cr_E = [Cr_E, Cr_filt];
            case 'F'
                H_F = [H_F, H_filt];
                Cb_F = [Cb_F, Cb_filt];
                Cr_F = [Cr_F, Cr_filt];
            otherwise

        end
        line = fgetl(fileID);
        
    end
    fclose(fileID);
end

%Initialize variables containing the model histograms for Hue, Cb and Cr channels
hue_sig = cell(1,6);
Cb_sig = cell(1,6);
Cr_sig = cell(1,6);


edges = linspace(0,1,101);
% plot histograms according to signal type or signal color
switch(group_by)
    case 'type'
        figure % display histograms for signals of type A
        subplot(1,3,1); hue_sig{1}=histogram(H_A,edges); title('H (signal A)');
        subplot(1,3,2); Cb_sig{1}=histogram(Cb_A); title('Cb (signal A)');
        subplot(1,3,3); Cr_sig{1}=histogram(Cr_A); title('Cr (signal A)');
        figure % display histograms for signals of type B
        subplot(1,3,1); hue_sig{2}=histogram(H_B,edges); title('H (signal B)');
        subplot(1,3,2); Cb_sig{2}=histogram(Cb_B); title('Cb (signal B)');
        subplot(1,3,3); Cr_sig{2}=histogram(Cr_B); title('Cr (signal B)');
        figure % display histograms for signals of type C
        subplot(1,3,1); hue_sig{3}=histogram(H_C,edges); title('H (signal C)');
        subplot(1,3,2); Cb_sig{3}=histogram(Cb_C); title('Cb (signal C)');
        subplot(1,3,3); Cr_sig{3}=histogram(Cr_C); title('Cr (signal C)');
        figure % display histograms for signals of type D
        subplot(1,3,1); hue_sig{4}=histogram(H_D,edges); title('H (signal D)');
        subplot(1,3,2); Cb_sig{4}=histogram(Cb_D); title('Cb (signal D)');
        subplot(1,3,3); Cr_sig{4}=histogram(Cr_D); title('Cr (signal D)');
        figure % display histograms for signals of type E
        subplot(1,3,1); hue_sig{5}=histogram(H_E,edges); title('H (signal E)');
        subplot(1,3,2); Cb_sig{5}=histogram(Cb_E); title('Cb (signal E)');
        subplot(1,3,3); Cr_sig{5}=histogram(Cr_E); title('Cr (signal E)');
        figure % display histograms for signals of type F
        subplot(1,3,1); hue_sig{6}=histogram(H_F,edges); title('H (signal F)');
        subplot(1,3,2); Cb_sig{6}=histogram(Cb_F); title('Cb (signal F)');
        subplot(1,3,3); Cr_sig{6}=histogram(Cr_F); title('Cr (signal F)');
        
        %Histogram normalization
        for h=1:6
            hue_sig{h}.BinCounts = hue_sig{h}.BinCounts/length(hue_sig{h}.Data);
        end
        
    case 'color'
        figure % display histograms for RED signals (type A-B-C)
        subplot(1,3,1); histogram([H_A,H_B,H_C]); title('H (red)');
        subplot(1,3,2); histogram([Cb_A,Cb_B,Cb_C]); title('Cb (red)');
        subplot(1,3,3); histogram([Cr_A,Cr_B,Cr_C]); title('Cr (red)');
        figure % display histograms for BLUE signals (type D-F)
        subplot(1,3,1); histogram([H_D,H_F]); title('H (blue)');
        subplot(1,3,2); histogram([Cb_D,Cb_F]); title('Cb (blue)');
        subplot(1,3,3); histogram([Cr_D,Cr_F]); title('Cr (blue)');
        figure % display histograms for RED-BLUE signals (type E)
        subplot(1,3,1); histogram(H_E); title('H (red-blue)');
        subplot(1,3,2); histogram(Cb_E); title('Cb (red-blue)');
        subplot(1,3,3); histogram(Cr_E); title('Cr (red-blue)');
    otherwise
        error('You need to group by type or color');
end


for i = 1:6
    hue_sig{i} = hue_sig{i}.BinCounts;
    Cb_sig{i} = Cb_sig{i}.BinCounts;
    Cr_sig{i} = Cr_sig{i}.BinCounts;
    
end

save('Compute_Mask_Functions/hue_sig','hue_sig');

% extract measures
%
% H_A_mean = mean(H_A); H_A_std = std(H_A);
% H_B_mean = mean(H_B); H_B_std = std(H_B);
% H_C_mean = mean(H_C); H_C_std = std(H_C);
% H_D_mean = mean(H_D); H_D_std = std(H_D);
% H_E_mean = mean(H_E); H_E_std = std(H_E);
% H_F_mean = mean(H_F); H_F_std = std(H_F);
% 
% Cb_A_mean = mean(Cb_A); Cb_A_std = std(double(Cb_A));
% Cb_B_mean = mean(Cb_B); Cb_B_std = std(double(Cb_B));
% Cb_C_mean = mean(Cb_C); Cb_C_std = std(double(Cb_C));
% Cb_D_mean = mean(Cb_D); Cb_D_std = std(double(Cb_D));
% Cb_E_mean = mean(Cb_E); Cb_E_std = std(double(Cb_E));
% Cb_F_mean = mean(Cb_F); Cb_F_std = std(double(Cb_F));
% 
% Cr_A_mean = mean(Cr_A); Cr_A_std = std(double(Cr_A));
% Cr_B_mean = mean(Cr_B); Cr_B_std = std(double(Cr_B));
% Cr_C_mean = mean(Cr_C); Cr_C_std = std(double(Cr_C));
% Cr_D_mean = mean(Cr_D); Cr_D_std = std(double(Cr_D));
% Cr_E_mean = mean(Cr_E); Cr_E_std = std(double(Cr_E));
% Cr_F_mean = mean(Cr_F); Cr_F_std = std(double(Cr_F));

end