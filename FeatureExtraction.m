% Import an eye image and calculate its height and width
I = imread('eye.jpg');
imshow(I);
title('Original Image');
[w h] = size(I);
s = [w h];
maxvalue = max(s);
maxR = maxvalue/2;
minR = maxvalue*.10;
rRange = [minR minR*3];

% Sobel Filtering is used to identify the edges of an image
figure
subplot(2,2,1)
imshow(I);
title('Original Image')
subplot(2,2,2)
BW1 = edge(I,'sobel');
BW2 = BW1;
BW3 = BW1;
imshow(BW1)
title('Sobel Filter');

% Locating and detecting the outer and inner boundaries of an iris
subplot(2,2,3)
[centers, radii, metric] = imfindcircles(BW3,rRange);
imshow(BW1)
viscircles(centers, radii, 'EdgeColor', 'b');
subplot(2,2,4)
imshow(BW2)
rRangeSmall = [ceil(minR/3) minR];
[centers2, radii2, metric] = imfindcircles(BW2, rRangeSmall);
viscircles(centers2, radii2, 'EdgeColor', 'g');

% Insert the circles on the location of inner and outer boundaries of iris.
subplot(2,2,3)
RGB_I = insertShape(double(BW1), 'Circle', [centers(1) centers(2) radii], 'LineWidth', 5);
imshow(RGB_I);
title('Outer Boundary of Iris');
subplot(2,2,4)
RGB_I2 = insertShape(double(BW2), 'Circle', [centers2(1) centers2(2) radii2], 'LineWidth', 5);
imshow(RGB_I2);
title('Inner Boundary of Iris');

% Subtraction of the new images from the sobel filtering image to isolate the boundaries of the iris
figure
subplot(2,3,2)
I_circle = RGB_I - double(BW2);
imshow(I_circle)

subplot(2,3,3)
I2_circle = RGB_I2 - double(BW2);
imshow(I2_circle)

% Segmentation of the iris is performed by implementing masks on the original image
subplot(2,3,4)
imshow(I);
title('Original Image')
subplot(2,3,1)
mask = zeros(size(I));
mask(20:end-20, 20:end-20) = 1;
imshow(mask)
title('Initial Contour Location')
subplot(2,3,2)
bw1 = activecontour(I_circle, mask, 300);
imshow(bw1)
title('Outer Segmented Image')
subplot(2,3,3)
bw2 = activecontour(I2_circle, mask, 300);
imshow(bw2)
title('Inner Segmented Image')
subplot(2,3,5)
out_seg = immultiply(I, bw1);
imshow(out_seg)
title('Segmentation of Eye')
subplot(2,3,6)
in_seg = immultiply(out_seg,~bw2);
imshow(in_seg)
title('Segmentation of Iris')

%To minimize the high-frequency outliers in the image.
J = wiener2(in_seg,[3 3]);
figure
subplot(1,3,2)
imshow(J)
title('High Frequency Removal')

%The zero value pixels in the image are converted into 255.
I3 = J;
I2 = find(J == 0);
I3(I2)= 255;
subplot(1,3,2)
Image_orig = I3;
subplot(1,3,1)
imshow(in_seg)
title('Original Image')

% PST function implementation to extract the feautures of the iris
Image_orig = double(Image_orig);
handles.LPF = 0.21;
handles.Phase_strength = 0.48;
handles.Warp_strength = 12.14;
handles.Thresh_min = -1;
handles.Thresh_max = 0.0019;
Morph_flag = 0;
[Edge PST_Kernel] = PST(Image_orig, handles, Morph_flag);

if Morph_flag == 0
	subplot(1,3,3)
	imshow(Edge/max(max(Edge))*3)
	title('Detected Features Using PST')
else
	subplot(1,3,3)
	imshow(Edge)
	title('Detected Features Using PST')
	overlay = double(imoverlay(Image_orig, Edge/1000000, [1 0 0]));
	figure
	imshow(overlay/max(max(max(overlay))));
	title('Detected Features Using PST overlaid with original image')
end

figure
[D_PST_Kernel_x D_PST_Kernel_y] = gradient(PST_Kernel);
mesh(sqrt(D_PST_Kernel_x.^2 + D_PST_Kernel_y.^2))
title('PST Kernel Phase Gradient')




