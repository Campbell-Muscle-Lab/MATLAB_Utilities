function [im_cluster,centroids] = k_means_image_segmentation(im_rgb,n_colors)

% Transform to lab color space
cform = makecform('srgb2lab');
im_lab = applycform(im_rgb,cform);

% Create a n x 2 matrix of [a b] values
a = im_lab(:,:,2);
a = double(a(:));
b = im_lab(:,:,3);
b = double(b(:));
ab = [a b];

% Construct the 2D histogram with appropriate limits
c{1}=[min(ab(:)) : max(ab(:))];
c{2}=c{1};
n = hist3(ab,c);
n1 = n';
n1(size(n,1) + 1, size(n,2) + 1) = 0;

% Perform the segmentation
[id,centroids]=kmeans(ab,n_colors,'replicate',3);

% Reshape array
[r,c] = size(im_rgb(:,:,1));
im_cluster = reshape(id,r,c);


if (0)

% Display
figure(1);
clf;
imagesc(log10(n1));
hold on;
title('2D histogram of pixel values, colored based on log10 of pixel count')
xlabel('a value');
ylabel('b value');



figure(2);
clf;
hold on;
cm = paruly(3);
for i=1:3
    vi = find(id==i);
    plot(ab(vi,1),ab(vi,2),'+','Color',cm(i,:));
    plot(cl(i,1),cl(i,2),'md','MarkerFaceColor','m');
end
xlabel('a value');
ylabel('b value');
set(gca,'YDir','reverse');

figure(3);
imagesc(im_cluster);

end