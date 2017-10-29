function [features, signals, freq] = analyse_data(img_dir, mask_dir, gt_dir)

img_files = ListFiles(img_dir);   % list image files
mask_files = ListFiles(mask_dir); % list ground-truth mask files
gt_files = ListFiles_txt(gt_dir); % list ground-truth annotation files

% init. variables to store the data of the signals 
sA = struct([]); sB = struct([]); sC = struct([]); 
sD = struct([]); sE = struct([]); sF = struct([]);  
% init. counter of signal type
contA = 0; contB = 0; contC = 0; contD = 0; contE = 0; contF = 0;

for i=1:size(gt_files,1)

    % read ground-truth mask of the current image
    mask = imread(strcat(mask_dir ,'/',mask_files(i).name));
    mask(mask~=0)=1; % some masks are not binary !!! 
    
    % read the txt annotation file of the current image
    fileID = fopen(strcat(gt_dir ,'/',gt_files(i).name));
    line = fgetl(fileID);
    
    % line = -1 when all lines of the txt file have been read
    while line ~= -1
         
        gt_bbox = sscanf(line,'%f');   % get numbers of the current line
        tl = [gt_bbox(2), gt_bbox(1)]; % bbox top left corner coord.
        br = [gt_bbox(4), gt_bbox(3)]; % bbox bottom right corner coord.
        
        gt_sig = line(end); % get letter of the current line (signal type)
        
        w = abs(br(1) - tl(1));  % bbox width 
        h = abs(br(2) - tl(2));  % bbox height 
        
        % form factor = bbox width / bbox height
        form_factor = w/h; 
        
        % signal size = pixels in the mask within the bbox with value 1
        mask_bbox = mask(ceil(gt_bbox(1)):floor(gt_bbox(3)),ceil(gt_bbox(2)):floor(gt_bbox(4)),:);
        signal_size = sum(sum(mask_bbox)); 
        
        % filling ratio = signal size / bbox area
        filling_ratio = signal_size/numel(mask_bbox); 
        
        % compute convex ratio
        CC = regionprops(bwlabel(mask_bbox),'BoundingBox','ConvexArea');
        convex_ratio = CC.ConvexArea/(CC.BoundingBox(3)*CC.BoundingBox(4));
        
        % the next switch classifies signals according to their type
        % for each signal we want to store:
        % --> name of the image file where it appears
        % --> features: size, form factor, filling ratio, width, height
        % (*) the counter for each type of signal is also updated
        switch(gt_sig)
            case 'A'
                contA = contA + 1;
                sA(contA).filename = img_files(i).name; 
                sA(contA).fill = filling_ratio;
                sA(contA).size = signal_size;
                sA(contA).form = form_factor;
                sA(contA).w = w;
                sA(contA).h = h;
                sA(contA).convex = convex_ratio;
            case 'B'
                contB = contB + 1;
                sB(contB).filename = img_files(i).name;
                sB(contB).fill = filling_ratio;
                sB(contB).size = signal_size;
                sB(contB).form = form_factor;
                sB(contB).w = w;
                sB(contB).h = h;
                sB(contB).convex = convex_ratio;
            case 'C'
                contC = contC + 1;
                sC(contC).filename = img_files(i).name;
                sC(contC).fill = filling_ratio;
                sC(contC).size = signal_size;
                sC(contC).form = form_factor;
                sC(contC).w = w;
                sC(contC).h = h;
                sC(contC).convex = convex_ratio;
            case 'D'
                contD = contD + 1;
                sD(contD).filename = img_files(i).name;
                sD(contD).fill = filling_ratio;
                sD(contD).size = signal_size;
                sD(contD).form = form_factor;
                sD(contD).w = w;
                sD(contD).h = h;
                sD(contD).convex = convex_ratio;
            case 'E'
                contE = contE + 1;
                sE(contE).filename = img_files(i).name;
                sE(contE).fill = filling_ratio;
                sE(contE).size = signal_size;
                sE(contE).form = form_factor;
                sE(contE).w = w;
                sE(contE).h = h;
                sE(contE).convex = convex_ratio;
            case 'F'
                contF = contF + 1;
                sF(contF).filename = img_files(i).name;
                sF(contF).fill = filling_ratio;
                sF(contF).size = signal_size;
                sF(contF).form = form_factor;
                sF(contF).w = w;
                sF(contF).h = h;
                sF(contF).convex = convex_ratio;
            otherwise
        end

        line = fgetl(fileID); % jump to the next line of the txt
    end
    
    fclose(fileID); % close the txt annotation file of the current image
end

% compute frequencies of appearence of each signal type
total_signals = contA + contB + contC + contD + contE + contF;
freq = [contA, contB, contC, contD, contE, contF]/total_signals;

% summarize data by feature in matrix form:
%                 min value  |  max value  |  mean value |  std value
%         A                  |             |             |
%         B                  |             |             |
%         C                  |             |             |
%         D                  |             |             |
%         E                  |             |             |
%         F                  |             |             |

feat_size_tmp = [min([sA.size]), max([sA.size]), mean([sA.size]), std([sA.size]);
                 min([sB.size]), max([sB.size]), mean([sB.size]), std([sB.size]);
                 min([sC.size]), max([sC.size]), mean([sC.size]), std([sC.size]);
                 min([sD.size]), max([sD.size]), mean([sD.size]), std([sD.size]);
                 min([sE.size]), max([sE.size]), mean([sE.size]), std([sE.size]);
                 min([sF.size]), max([sF.size]), mean([sF.size]), std([sF.size])];
         
feat_size = struct('min',feat_size_tmp(1:end,1), ...
                   'max',feat_size_tmp(1:end,2), ...
                   'mean',feat_size_tmp(1:end,3), ...
                   'std',feat_size_tmp(1:end,4));
        
feat_form_tmp = [min([sA.form]), max([sA.form]), mean([sA.form]), std([sA.form]);
                 min([sB.form]), max([sB.form]), mean([sB.form]), std([sB.form]);
                 min([sC.form]), max([sC.form]), mean([sC.form]), std([sC.form]);
                 min([sD.form]), max([sD.form]), mean([sD.form]), std([sD.form]);
                 min([sE.form]), max([sE.form]), mean([sE.form]), std([sE.form]);
                 min([sF.form]), max([sF.form]), mean([sF.form]), std([sF.form])]; 
         
feat_form = struct('min',feat_form_tmp(1:end,1), ...
                   'max',feat_form_tmp(1:end,2), ...
                   'mean',feat_form_tmp(1:end,3), ...
                   'std',feat_form_tmp(1:end,4));

feat_fill_tmp = [min([sA.fill]), max([sA.fill]), mean([sA.fill]), std([sA.fill]);
                 min([sB.fill]), max([sB.fill]), mean([sB.fill]), std([sB.fill]);
                 min([sC.fill]), max([sC.fill]), mean([sC.fill]), std([sC.fill]);
                 min([sD.fill]), max([sD.fill]), mean([sD.fill]), std([sD.fill]);
                 min([sE.fill]), max([sE.fill]), mean([sE.fill]), std([sE.fill]);
                 min([sF.fill]), max([sF.fill]), mean([sF.fill]), std([sF.fill])];  

feat_fill = struct('min',feat_fill_tmp(1:end,1), ...
                   'max',feat_fill_tmp(1:end,2), ...
                   'mean',feat_fill_tmp(1:end,3), ...
                   'std',feat_fill_tmp(1:end,4));
         
feat_w_tmp = [min([sA.w]), max([sA.w]), mean([sA.w]), std([sA.w]);
              min([sB.w]), max([sB.w]), mean([sB.w]), std([sB.w]);
              min([sC.w]), max([sC.w]), mean([sC.w]), std([sC.w]);
              min([sD.w]), max([sD.w]), mean([sD.w]), std([sD.w]);
              min([sE.w]), max([sE.w]), mean([sE.w]), std([sE.w]);
              min([sF.w]), max([sF.w]), mean([sF.w]), std([sF.w])];

feat_w = struct('min',feat_w_tmp(1:end,1), ...
                'max',feat_w_tmp(1:end,2), ...
                'mean',feat_w_tmp(1:end,3), ...
                'std',feat_w_tmp(1:end,4));

feat_h_tmp = [min([sA.h]), max([sA.h]), mean([sA.h]), std([sA.h]);
              min([sB.h]), max([sB.h]), mean([sB.h]), std([sB.h]);
              min([sC.h]), max([sC.h]), mean([sC.h]), std([sC.h]);
              min([sD.h]), max([sD.h]), mean([sD.h]), std([sD.h]);
              min([sE.h]), max([sE.h]), mean([sE.h]), std([sE.h]);
              min([sF.h]), max([sF.h]), mean([sF.h]), std([sF.h])];
          
feat_h = struct('min',feat_h_tmp(1:end,1), ...
                'max',feat_h_tmp(1:end,2), ...
                'mean',feat_h_tmp(1:end,3), ...
                'std',feat_h_tmp(1:end,4));

feat_convex_tmp = [min([sA.convex]), max([sA.convex]), mean([sA.convex]), std([sA.convex]);
                   min([sB.convex]), max([sB.convex]), mean([sB.convex]), std([sB.convex]);
                   min([sC.convex]), max([sC.convex]), mean([sC.convex]), std([sC.convex]);
                   min([sD.convex]), max([sD.convex]), mean([sD.convex]), std([sD.convex]);
                   min([sE.convex]), max([sE.convex]), mean([sE.convex]), std([sE.convex]);
                   min([sF.convex]), max([sF.convex]), mean([sF.convex]), std([sF.convex])];
          
feat_convex = struct('min',feat_convex_tmp(1:end,1), ...
                'max',feat_convex_tmp(1:end,2), ...
                'mean',feat_convex_tmp(1:end,3), ...
                'std',feat_convex_tmp(1:end,4));
            
fprintf('    DATA ANALYSIS successfully completed.\n')
verbose = 1;
if(verbose)
    fprintf('\n');
    fprintf('        -> Freq. of appearance: A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n\n', ... 
    freq(1), freq(2), freq(3), freq(4), freq(5), freq(6));

    fprintf('        -> Size (min): A = %i,     B = %i,    C = %i,    D = %i,     E = %i,    F = %i\n', ... 
    feat_size_tmp(1,1), feat_size_tmp(2,1), feat_size_tmp(3,1), feat_size_tmp(4,1), feat_size_tmp(5,1), feat_size_tmp(6,1));
    fprintf('        -> Size (max): A = %i,   B = %i,    C = %i,   D = %i,   E = %i,   F = %i\n', ... 
    feat_size_tmp(1,2), feat_size_tmp(2,2), feat_size_tmp(3,2), feat_size_tmp(4,2), feat_size_tmp(5,2), feat_size_tmp(6,2));
    fprintf('        -> Size (avg): A = %.2f, B = %.2f, C = %.2f, D = %.2f, E = %.2f, F = %.2f\n', ... 
    feat_size_tmp(1,3), feat_size_tmp(2,3), feat_size_tmp(3,3), feat_size_tmp(4,3), feat_size_tmp(5,3), feat_size_tmp(6,3));
    fprintf('        -> Size (std): A = %.2f, B = %.2f, C = %.2f, D = %.2f, E = %.2f, F = %.2f\n\n', ... 
    feat_size_tmp(1,4), feat_size_tmp(2,4), feat_size_tmp(3,4), feat_size_tmp(4,4), feat_size_tmp(5,4), feat_size_tmp(6,4));

    fprintf('        -> Form factor (min): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
    feat_form_tmp(1,1), feat_form_tmp(2,1), feat_form_tmp(3,1), feat_form_tmp(4,1), feat_form_tmp(5,1), feat_form_tmp(6,1));
    fprintf('        -> Form factor (max): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
    feat_form_tmp(1,2), feat_form_tmp(2,2), feat_form_tmp(3,2), feat_form_tmp(4,2), feat_form_tmp(5,2), feat_form_tmp(6,2));
    fprintf('        -> Form factor (avg): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
    feat_form_tmp(1,3), feat_form_tmp(2,3), feat_form_tmp(3,3), feat_form_tmp(4,3), feat_form_tmp(5,3), feat_form_tmp(6,3));
    fprintf('        -> Form factor (std): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n\n', ... 
    feat_form_tmp(1,4), feat_form_tmp(2,4), feat_form_tmp(3,4), feat_form_tmp(4,4), feat_form_tmp(5,4), feat_form_tmp(6,4));

    fprintf('        -> Fill. ratio (min): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
    feat_fill_tmp(1,1), feat_fill_tmp(2,1), feat_fill_tmp(3,1), feat_fill_tmp(4,1), feat_fill_tmp(5,1), feat_fill_tmp(6,1));
    fprintf('        -> Fill. ratio (max): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
    feat_fill_tmp(1,2), feat_fill_tmp(2,2), feat_fill_tmp(3,2), feat_fill_tmp(4,2), feat_fill_tmp(5,2), feat_fill_tmp(6,2));
    fprintf('        -> Fill. fatio (avg): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n', ... 
    feat_fill_tmp(1,3), feat_fill_tmp(2,3), feat_fill_tmp(3,3), feat_fill_tmp(4,3), feat_fill_tmp(5,3), feat_fill_tmp(6,3));
    fprintf('        -> Fill. ratio (std): A = %.3f, B = %.3f, C = %.3f, D = %.3f, E = %.3f, F = %.3f\n\n', ... 
    feat_fill_tmp(1,4), feat_fill_tmp(2,4), feat_fill_tmp(3,4), feat_fill_tmp(4,4), feat_fill_tmp(5,4), feat_fill_tmp(6,4));
end

features.filling_ratio = feat_fill;
features.form_factor = feat_form;
features.size = feat_size;
features.height = feat_h;
features.width = feat_w;
features.convex_ratio = feat_convex;

signals.A = sA;
signals.B = sB;
signals.C = sC;
signals.D = sD;
signals.E = sE;
signals.F = sF;

save('features', 'features');
save('signals', 'sA','sB','sC','sD','sE','sF','freq');
end