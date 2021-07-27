function enrollment_table(varargin)
% Generates data for an NIH enrollment data

p = inputParser;
addOptional(p, 'clin_data_folder', ...
    'c:/ken/lab/irb/clinical_data/most_recent');
addOptional(p, 'start_date', '1/1/1900');
addOptional(p, 'stop_date', '8/1/2019');
addOptional(p, 'category_fields', {'demo_race', 'demo_ethnicity', 'demo_sex'});
addOptional(p, 'out_file_string', 'c:/temp/enrollment_data.xlsx');
parse(p, varargin{:});
p = p.Results;

% Read in data
clin_file = findfiles('xlsx', p.clin_data_folder);
t = readtable(clin_file{1});

fn = t.Properties.VariableNames'

% Restrict to dates
vi = find(...
    (t.collection_date >= datetime(p.start_date, 'InputFormat', 'MM/dd/uuuu')) & ...
    (t.collection_date <= datetime(p.stop_date, 'InputFormat', 'MM/dd/uuuu')));
t = t(vi,:);

% Replace 'No data' with 'Unknown or not reported'

for i = 1 : numel(p.category_fields)
    vi = find(strcmp(t.(p.category_fields{i}), 'No data'));
    t.(p.category_fields{i})(vi) = {'Unknown or not reported'};
end

% Find groups
unique_race = unique(t.demo_race)
unique_ethnicity = unique(t.demo_ethnicity)
unique_sex = unique(t.demo_sex)

% Develop table
c = 0;
for r = 1 : numel(unique_race)
    for e = 1 : numel(unique_ethnicity)
        for s = 1 : numel(unique_sex)
            vi = find( ...
                    strcmp(t.demo_race, unique_race{r}) & ...
                    strcmp(t.demo_ethnicity, unique_ethnicity{e}) & ...
                    strcmp(t.demo_sex, unique_sex{s}));
            % Store data
            c = c + 1;
            out.race{c} = unique_race{r};
            out.ethnicity{c} = unique_ethnicity{e};
            out.sex{c} = unique_sex{s};
            out.count(c) = numel(vi);
        end
    end
end
out = struct2table(columnize_structure(out))

writetable(out, p.out_file_string)

% Generate full list
out = []
for i = 1 : size(t,1)
    out.Race{i} = t.demo_race{i};
    out.Ethnicity{i} = t.demo_ethnicity{i};
    out.Gender{i} = t.demo_sex{i};
    if (isnan(t.demo_age(i)))
        out.Age{i} = 'Unknown';
    else
        out.Age{i} = sprintf('%.0f', t.demo_age(i));
    end
    out.Age_Unit{i} = 'Years';
end
out = out
out = struct2table(columnize_structure(out))
out = renamevars(out, 'Age_Unit', 'Age Unit')
    
    

