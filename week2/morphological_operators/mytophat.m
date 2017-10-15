function [tophat_x] = mytophat(x, s)

% INPUT: 'x' input image (format: grayscale and double)
%        's' structuring element (size in both dimensions must be odd)
%

% OUTPUT: 'dilated_x' output image after applying top hat
%

tophat_x = x - myopening(x, s);

end 