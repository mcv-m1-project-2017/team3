function [eroded_x] = myerode(x, s)

% INPUT: 'x' input image (format: grayscale and double)
%        's' structuring element (size in both dimensions must be odd)
%

% OUTPUT: 'eroded_x' output image after applying erosion
%

% Pad the input image with INF values so that it can be treated as a whole
% and the neighbour values of the borders do not affect the result
hs1 = floor(size(s,1)/2); % amount of padding in 1st dimension
hs2 = floor(size(s,2)/2); % amount of padding in 2nd dimension
x = padarray(x,[hs1 hs2],Inf,'both'); 

% Set the 0's of the SE to INF values so that they do not affect the 
% local result in each pixel of the output image
s(s==0) = Inf;

% Get size of the image and initialize output image
[N, M] = size(x);
eroded_x = x;

% Iterate pixel by pixel
for j = hs2+1:M-hs2
    for i = hs1+1:N-hs1
        % Compute erosion at the current block centered at pixel (i,j)
        patch = x(i-hs1:i+hs1,j-hs2:j+hs2) .* s;
        eroded_x(i,j) = min(patch(:));
    end
end

% Remove padding and return the output image
eroded_x = eroded_x(hs1+1:N-hs1,hs2+1:M-hs2);

end