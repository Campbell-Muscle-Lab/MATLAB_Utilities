function fit_Nyquist_plot(varargin);

% Handle inputs
p = inputParser;
parse(p,varargin{:});
p = p.Results;

% Raw data
excel_file_string = 'C:\ken_sync\kscamp3guk\Collaborations\Tanner\Projects\Frequency_analysis\raw_data\human_data.xlsx');
d = readtable(excel_file_string);
expt_data.freq = d.freq;
expt_data.elastic_mod = d.em;
expt_data.viscous_mod = d.vm;

% Make figure
figure(1);
clf;
plot(expt_data.elastic_mod,expt_data.viscous_mod,'ko');
