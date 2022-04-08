function f = folders_within_containing(top_folder, ext)
% Function returns all the folders within the input folder

% Get subfolders that contain files with a given extension
all_files = findfiles(ext, top_folder, 1);
pathnames = fileparts(all_files);
f = unique(pathnames);




