function [bothat_x] = mybothat(x, s)

% INPUT: 'x' input image (format: grayscale and double)
%        's' structuring element (size in both dimensions must be odd)
%

% OUTPUT: 'bothat_x' output image after applying bottom hat
%

bothat_x = myclosing(x,s) - x;

end 