function correct_fonts(file_string)

fs=[file_string '.eps'];
% Read in the file
fid = fopen(fs,'r');
of=fopen(sprintf('%s2.eps',file_string),'w');

% Scan it line by line for oldfont
while ~feof(fid)
    ls=fgetl(fid);
    if (~isempty(regexp(ls,'+Helvetica')))
        ii=regexp(ls,'+Helvetica');
        end_bit=ls(ii+10:end);
        ls(ii-6:ii+9)=[];
        ls=[ls(1:ii-7) 'Arial' end_bit];
        
    end
    fprintf(of,'%s\n',ls);
end

fclose(fid);
fclose(of);

% Swop the files
fs1=sprintf('%s.eps',file_string);
fs2=sprintf('%s2.eps',file_string);

[status,message,id] = copyfile(fs2,fs1,'f');
delete(fs2);

% Now correct projecting lines
fid=fopen(fs1);
ff=char(fread(fid))';
fclose(fid);
% Nwo correct italics
ff=strrep(ff,'Oblique','Italic');

% Adds projecting caps to lines
ff=strrep(ff,'0 cap','2 cap');

% open the file up and overwrite it
fid = fopen(fs1,'w');
fprintf(fid,'%s',ff);
fclose(fid);







