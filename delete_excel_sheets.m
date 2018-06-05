function delete_excel_sheets(varargin)
% Code does as it says
% Modified from Technical Solution ID 1-21EPB4 at
% http://www.mathworks.com/support/solutions/en/data/1-21EPB4/index.html?solution=1-21EPB4

params.filename='';
params.delete_sheets={'Sheet1','Sheet2','Sheet3'};

% Update
params=parse_pv_pairs(params,varargin);

% Try to correct filename for relative path
temp_string = params.filename;
if (temp_string(2)~=':')
    % It's not likely to be a full path
    params.filename = fullfile(cd,params.filename);
end

% Check file exists
check_f=fopen(params.filename,'r');
if (check_f<0)
    disp(sprintf('%s could not be opened by delete_Excel_sheets()'));
    return
end
fclose(check_f);

% Open Excel as a COM Automation server
Excel = actxserver('Excel.Application');
% Make it invisible
set(Excel,'Visible',0);
% Turn off alerts
set(Excel,'DisplayAlerts',0);
% Get a handle to Excel's Workbooks
Workbooks=Excel.Workbooks;
% Open an Excel Workbook and activate it
Workbook=Workbooks.Open(params.filename);

% Get the sheets
Sheets=Excel.ActiveWorkBook.Sheets;
index_adjust=0;

[temp,sheet_names]=xlsfinfo(params.filename);

% Cycle through the sheets
for i=1:length(params.delete_sheets)
    matches=(strcmp(sheet_names,params.delete_sheets{i}));
    if (any(matches))
        current_sheet=get(Sheets,'Item',(i-index_adjust));
        invoke(current_sheet,'Delete');
        index_adjust=index_adjust+1;
    end
end

% Save the workbook
Workbook.Save;
% Close the Workbook
Workbooks.Close;
% Quite Excel
invoke(Excel,'Quit');
% Delete the handle to the ActiveX object
delete(Excel);
  




