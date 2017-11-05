function [WindowCandidates] = get_WindowCandidates(final_mask)

labels = bwlabel(final_mask);
CC = regionprops(labels,'Area','BoundingBox','FilledArea','Perimeter','ConvexArea','Perimeter');

% extract properties of each connected component
WindowCandidates = [];
for j = 1:length(CC)
    
    bbox = CC(j).BoundingBox;    %expressed [x , y , width , height]
    bbox_signal = struct('x',bbox(1),'y',bbox(2),'w',bbox(3),'h',bbox(4));
    WindowCandidates = [WindowCandidates, bbox_signal];
end

end