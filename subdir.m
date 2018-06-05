function sub_folders = subdir(folder_name)
% Returns the sub_folders

if (nargin==1)
    listing = dir(folder_name);
else
    folder_name = cd;
    listing = dir;
end

listing = listing(~ismember({listing.name},{'.','..'}));
sub_folders = [];
i=1;
counter=0;
while (i<=numel(listing))
    check_name = fullfile(folder_name,listing(i).name);
    if (isdir(check_name))
        counter=counter+1;
        sub_folders{counter} = check_name;
    end
    i=i+1;
end


    