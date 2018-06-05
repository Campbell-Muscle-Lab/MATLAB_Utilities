function center_image_with_preserved_aspect_ratio(im)

old_axis_units=get(gca,'Units');
axes_pos=get(gca,'Position');
set(gca,'Units','Pixels');
axes_pos=get(gca,'Position');
axes_x=axes_pos(3);
axes_y=axes_pos(4);

im_x=size(im,2);
im_y=size(im,1);

axes_aspect_ratio=axes_x/axes_y;
im_aspect_ratio=im_x/im_y;

% Display the image
imagesc(im);

if (axes_aspect_ratio>im_aspect_ratio)
    % We have to pad the image horizontally so that it has the same
    % aspect ratio as the axes
    
    new_im_x=im_y*axes_aspect_ratio;
    pad_x=(new_im_x-im_x)/2;

    xlim([-pad_x im_x+pad_x]);
    ylim([1 im_y]);
    
else
    % We have to pad the image vertically so that it has the same
    % aspect ratio as the axes

    new_im_y=im_x/axes_aspect_ratio;
    pad_y=(new_im_y-im_y)/2;
    
    xlim([1 im_x]);
    ylim([-pad_y im_y+pad_y]);
end

set(gca,'YDir','Reverse');
set(gca,'Visible','off');

set(gca,'Units',old_axis_units);