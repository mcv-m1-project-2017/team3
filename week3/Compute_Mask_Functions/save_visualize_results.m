function save_visualize_results(filename, mask, picture, input_window_coordinates)

window_coordinates = zeros(length(input_window_coordinates),4);
for i = 1:length(input_window_coordinates)
    current_window = input_window_coordinates(i);
    window_coordinates(i,1) = current_window.x;
    window_coordinates(i,2) = current_window.y;
    window_coordinates(i,3) = current_window.x + current_window.w;
    window_coordinates(i,4) = current_window.y + current_window.h;
end

% Save mask
imshow(mask), hold on;
im = frame2im(getframe(gca));
imwrite(im,[filename, '_mask.tif']); 

% Save mask + windows
if(~isempty(window_coordinates))
    for n=1:size(window_coordinates,1)
        x1 = window_coordinates(n,1); y1 = window_coordinates(n,2);
        x2 = window_coordinates(n,3); y2 = window_coordinates(n,4);
        plot([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'y'); hold on;
    end
end
im = frame2im(getframe(gca));
imwrite(im,[filename, '_mask_windows.tif']);

% Save original image
imshow(picture), hold on;
im = frame2im(getframe(gca));
imwrite(im,[filename, '_original.tif']); 

% Save original image + windows
if(~isempty(window_coordinates))
    for n=1:size(window_coordinates,1)
        x1 = window_coordinates(n,1); y1 = window_coordinates(n,2);
        x2 = window_coordinates(n,3); y2 = window_coordinates(n,4);
        plot([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'y'); hold on;
    end
end
im = frame2im(getframe(gca));
imwrite(im,[filename, '_original_windows.tif']);

end