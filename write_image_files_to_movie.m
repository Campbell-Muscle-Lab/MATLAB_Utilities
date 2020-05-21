function write_image_files_to_movie(image_file_strings,output_file_string,varargin)

p=inputParser;
addOptional(p,'frame_rate',10);
addOptional(p,'brand_string','http://www.campbellmusclelab.org');
addOptional(p,'font_size',14);
addOptional(p,'font_color',[0 0 1]);
addOptional(p,'font_background',[1 1 1]);
addOptional(p,'font_edge',[0 0 1]);
parse(p,varargin{:});
p=p.Results;

% Create a movie
out = VideoWriter(output_file_string);
out.FrameRate = p.frame_rate;
open(out);

% Add in frames
progress_bar(0);
for i=1:numel(image_file_strings)

    progress_bar(i/numel(image_file_strings), ...
        sprintf('Adding image %.0f of %.0f to video', ...
            i,numel(image_file_strings)));
    
    im = imread(image_file_strings{i});

    if (~isempty(p.brand_string))
        figure(1);
        clf
        image(im);
        text(1,1,p.brand_string, ...
            'FontSize',p.font_size, ...
            'Color',p.font_color, ...
            'BackgroundColor',p.font_background, ...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','top', ...
            'EdgeColor',p.font_edge);
        set(gca,'Visible','off');
        f=getframe();
        im=frame2im(f);
    end
    
    writeVideo(out,im);
end

% Close the video
close(out);




