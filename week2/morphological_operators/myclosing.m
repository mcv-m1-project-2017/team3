function [closed_x] = myclosing(x, s)

% INPUT: 'x' input image (format: grayscale and double)
%        's' structuring element (size in both dimensions must be odd)
%

% OUTPUT: 'dilated_x' output image after applying closing
%

closed_x = myerode(mydilate(x, s), s);

end 