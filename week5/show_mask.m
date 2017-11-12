function show_mask(img_dir, valid_files, masks, image_num)
if(image_num > size(valid_files,2))
    error('There are only %i images\n', size(valid_files,2));
else
    figure();
    subplot(1,2,1); imshow(imread(strcat(img_dir,'/',valid_files{image_num}))); title('Image');
    subplot(1,2,2); imshow(masks{image_num});  title('Mask');
end