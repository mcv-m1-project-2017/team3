function [gt_windows] = get_gt_windows(input_gt_file)

% all ground truth windows in the current image will be stored in this vector
gt_windows = [];

% read the txt annotation file of the current image
fileID = fopen(input_gt_file);
line = fgetl(fileID);

% line = -1 when all lines of the txt file have been read
while line ~= -1

    gt_bbox = sscanf(line,'%f');   % get numbers of the current line
    tl = [gt_bbox(1), gt_bbox(2)]; % (Ymax,Xmin)bbox top left corner coord.
    br = [gt_bbox(3), gt_bbox(4)]; % (Ymin,Xmax) bbox bottom right corner coord.

    w = abs(br(2) - tl(2));  % bbox width
    h = abs(tl(1) - br(1));  % bbox height 

    bbox_signal = struct('x',gt_bbox(2),'y',gt_bbox(1),'w',w,'h',h);
    gt_windows = [gt_windows, bbox_signal];

    line = fgetl(fileID); % jump to the next line of the txt
end
fclose(fileID); % close the txt annotation file of the current image
    
end