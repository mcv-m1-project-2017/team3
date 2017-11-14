
%execute this script to get the predefined templates for template matching

templates.triangle1 = rgb2gray(im2double(imread('Templates/triangle1.png')));
templates.triangle2 = rgb2gray(im2double(imread('Templates/triangle2.png')));
templates.circle = rgb2gray(im2double(imread('Templates/circle.png')));
templates.square1 = rgb2gray(im2double(imread('Templates/square1.png')));
templates.square2 = rgb2gray(im2double(imread('Templates/square2.png')));
templates.square3 = rgb2gray(im2double(imread('Templates/square3.png')));

templates_edges.triangle1 = edge(templates.triangle1,'Sobel');
templates_edges.triangle2 = edge(templates.triangle2,'Sobel');
templates_edges.circle = edge(templates.circle,'Sobel');
templates_edges.square1 = edge(templates.square1,'Sobel');
templates_edges.square2 = edge(templates.square2,'Sobel');
templates_edges.square3 = edge(templates.square3,'Sobel');

save('Templates/templates_edges', 'templates_edges');
save('Templates/templates', 'templates');