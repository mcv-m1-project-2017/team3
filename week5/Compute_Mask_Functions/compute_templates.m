function [templates] = compute_templates(mask_dir, gt_dir, signals)

s_circle = [signals.C signals.D signals.E];
h_circle = ceil(mean([s_circle.h])); w_circle = ceil(mean([s_circle.w]));
circles = zeros([h_circle, w_circle, length(s_circle)]);

s_square = signals.F;
h_square = ceil(mean([s_square.h])); w_square = ceil(mean([s_square.w]));
squares = zeros([h_square, w_square, length(s_square)]);

s_triangle1 = signals.A;
h_triangle1 = ceil(mean([s_triangle1.h])); w_triangle1 = ceil(mean([s_triangle1.w]));
triangles1 = zeros([h_triangle1, w_triangle1, length(s_triangle1)]);

s_triangle2 = signals.B;
h_triangle2 = ceil(mean([s_triangle2.h])); w_triangle2 = ceil(mean([s_triangle2.w]));
triangles2 = zeros([h_triangle2, w_triangle2, length(s_triangle2)]);

mask_files = ListFiles(mask_dir); % list ground-truth mask files
gt_files = ListFiles_txt(gt_dir); % list ground-truth annotation files

contT1 = 0; contT2 = 0; contC = 0; contS = 0;
for i=1:size(gt_files,1)

    % read ground-truth mask of the current image
    mask = imread(strcat(mask_dir ,'/',mask_files(i).name));
    mask(mask~=0)=1; % some masks are not binary !!! 
    
    % read the txt annotation file of the current image
    fileID = fopen(strcat(gt_dir ,'/',gt_files(i).name));
    line = fgetl(fileID);
    
    % line = -1 when all lines of the txt file have been read
    while line ~= -1
         
        bbox = sscanf(line,'%f');   % get numbers of the current line
        tl = [bbox(2), bbox(1)]; % bbox top left corner coord.
        br = [bbox(4), bbox(3)]; % bbox bottom right corner coord.
        
        gt_sig = line(end); % get letter of the current line (signal type)
        
        x = mask(ceil(bbox(1)):floor(bbox(3)),ceil(bbox(2)):floor(bbox(4)),:);
        
        switch(gt_sig)
            case 'A'
                contT1 = contT1 + 1;
                triangles1(:,:,contT1) = imresize(x,[h_triangle1,w_triangle1]);
            case 'B' 
                contT2 = contT2 + 1;
                triangles2(:,:,contT2) = imresize(x,[h_triangle2,w_triangle2]);  
            case 'C'
                contC = contC + 1;
                circles(:,:,contC) = imresize(x,[h_circle,w_circle]);   
            case 'D'
                contC = contC + 1;
                circles(:,:,contC) = imresize(x,[h_circle,w_circle]);  
            case 'E'
                contC = contC + 1;
                circles(:,:,contC) = imresize(x,[h_circle,w_circle]);  
            case 'F'
                contS = contS + 1;
                squares(:,:,contS) = imresize(x,[h_square,w_square]);  
            otherwise
        end

        line = fgetl(fileID); % jump to the next line of the txt
    end
    
    fclose(fileID); % close the txt annotation file of the current image
end

templates.triangle1 = padarray(mean(triangles1,3),[1 1],0,'both');
templates.triangle2 = padarray(mean(triangles2,3),[1 1],0,'both');
templates.circle = padarray(mean(circles,3),[1 1],0,'both');
templates.square = padarray(mean(squares,3),[1 1],0,'both');

end