function [final_mask] = size_filtering(mask, min_size, max_size)

% INPUT: 'mask' input mask to be filtered
%        'min_size' minimum size in pixels of the resulting connected components
%        'max_size' maximum size in pixels of the resulting connected components
%
% OUTPUT:'final_mask' resulting mask after size filtering 

labels = bwlabel(mask); % label connected components
for j=1:max(max(labels)) % iterate through all components
    % if the area of the component is smaller than the
    % minimum expected size or bigger than the maximum
    % expected size, then this component is most probably
    % not a signal and can be erased from the mask
    if sum(sum(labels==j))<min_size || sum(sum(labels==j))>max_size
        labels(labels==j)=0;
    end
end
final_mask = labels>0;




end