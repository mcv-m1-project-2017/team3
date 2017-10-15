%% TASK 1: IMPLEMENT MORPHOLOGICAL OPERATORS
% Implement morphological operators Erosion/Dilation. Compose new
% operators from Dilation/Erosion: Opening, Closing, Top hat, Top hat dual

% Our morphological operators implementations are the functions: 
%               
%         EROSION: myerode.m 
%         DILATION: mydilate.m                                                     
%         CLOSING: myclosing.m                                                  
%         OPENING: myopening.m                                                     
%	      TOP HAT: mytophat.m													
%         BOTTOM HAT: mybothat.m                                                    
%

%% TASK 2: MEASURE THE COMPUTATIONAL EFFICIENCY OF YOUR OPERATORS

addpath('morphological_operators');

% Vectors to store computation time of the matlab functions
er_matlab_time = zeros(1,5); dil_matlab_time = zeros(1,5);
% Vectors to store computation time of our functions
er_our_time = zeros(1,5); dil_our_time = zeros(1,5);

% Compute erosion and dilation of a set of 5 images (folder /images_task2)
for i=1:5
    
    % Conversion of input image to grayscale and double
    x = im2double(rgb2gray(imread(['images_task2/',num2str(i),'.jpg'])));
    
    % Compute erosion 
    tic
    x_imerode = im2uint8(imerode(x, ones(11))); % matlab function
    er_matlab_time(i) = toc;
    tic
    x_myerode = im2uint8(myerode(x, ones(11))); % our function
    er_our_time(i) = toc;

    % Compute dilation 
    tic
    x_imdilate = im2uint8(imdilate(x, ones(11))); % matlab function
    dil_matlab_time(i) = toc;
    tic
    x_mydilate = im2uint8(mydilate(x, ones(11))); % our function
    dil_our_time(i) = toc;
end

% Print computation times and efficiency for each operator
fprintf('\n-------EROSION-------\n');
fprintf('Matlab time = %.3f seconds\n', mean(er_matlab_time));
fprintf('Our time = %.3f seconds\n', mean(er_our_time));
fprintf('The efficiency is %.2f%% \n\n', 100*mean(er_our_time)/mean(er_matlab_time));

fprintf('-------DILATION-------\n');
fprintf('Matlab time = %.3f seconds\n', mean(dil_matlab_time));
fprintf('Our time = %.3f seconds \n', mean(dil_our_time));
fprintf('The efficiency is %.2f%%\n', 100*mean(dil_our_time)/mean(dil_matlab_time));

% Show resulting images + difference image
figure
subplot(1,4,1), imshow(x), title('original image'); 
subplot(1,4,2), imshow(x_imerode), title('imerode'); 
subplot(1,4,3), imshow(x_myerode), title('myerode'); 
subplot(1,4,4), imshow(x_imerode - x_myerode), title('difference'); 
figure
subplot(1,4,1), imshow(x), title('original image'); 
subplot(1,4,2), imshow(x_imdilate), title('imdilate'); 
subplot(1,4,3), imshow(x_mydilate), title('mydilate'); 
subplot(1,4,4), imshow(x_imdilate - x_mydilate), title('difference'); 
