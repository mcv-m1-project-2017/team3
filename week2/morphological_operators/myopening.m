function [opened_x] = myopening(x, s)

% INPUT: 'x' input image (format: grayscale and double)
%        's' structuring element (size in both dimensions must be odd)
%

% OUTPUT: 'opened_x' output image after applying opening
%

opened_x = mydilate(myerode(x, s), s);

end 