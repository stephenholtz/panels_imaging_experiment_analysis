% Imaging analysis script
%
% Will take folders/files generated by PView and a folder saved from matlab
% with information about the stimuli, and experimental metadata

%==Set Path / Initialize Variables=========================================

% Initialize variables
pmt_channel = 'Ch2';
% Location of the folder that has all of the experiments
top_folder_loc = '/Users/stephenholtz/local_experiment_copies/';
experiment_name = 'simple_flicker_motion';
exp_subgroup_name = 'pollen_grain_test'; %%%% this will eventually need to be the genotype / iterated over
save_folder_loc = fullfile(top_folder_loc,experiment_name,exp_subgroup_name);

% Add utilities to the path
addpath(genpath('/Users/stephenholtz/matlab-utils'));
% Add the experiment analysis and generation folders to the path
addpath(genpath('/Users/stephenholtz/panels_imaging_experiment_analysis'));
addpath(genpath('/Users/stephenholtz/panels_experiments'));
% Anon funcs
pad_num2str_w_zeros = @(num,num_zeros)([repmat('0',1,num_zeros - numel(num2str(num))) num2str(num)]);
dir_name = @(S)(S(1).name);
ret_inds = @(mat,inds)(mat(inds));

%==Load in data============================================================

% Load metadata file
load([top_folder_loc filesep experiment_name filesep exp_subgroup_name filesep 'matlab' filesep 'metadata.mat']);

% Set the folder that will have all of the images, voltages, xml files etc.
p.tseries_folder = [top_folder_loc filesep experiment_name filesep exp_subgroup_name filesep 'pview'];
% get the base name from the folder: i.e. TSeries-05232013-1550-188, then
% add '_Cycle' and some digits to the end....
base_file_name = cell2mat(regexp(dir_name(dir([p.tseries_folder filesep '*.xml'])),'[^.xml]','match'));
p.tseries_fname_base = [base_file_name '_Cycle%0.5d_'];
% get the next portion of the file name: i.e. 'starting_vals_Ch1_' and add
% some digits to the end and the file extension
p.tseries_fname_suffix = ['starting_vals_' pmt_channel '_%0.6d.tif'];
p.tseries_config = dir_name(dir([p.tseries_folder filesep '*.xml']));

% Currently only using ao, so ai is redundant
p.ai_folder = p.tseries_folder;
p.ai_data   = [base_file_name '_Cycle%0.5d_VoltageRecording_001.csv'];
p.ai_config = dir_name(dir([p.tseries_folder filesep '*VoltageRecording*.xml']));

p.ao_folder = p.tseries_folder;
p.ao_data   = [base_file_name '_Cycle%0.5d_VoltageRecording_001.csv'];
p.ao_config = dir_name(dir([p.tseries_folder filesep '*VoltageRecording*.xml']));

all_files = dir(p.tseries_folder);
sequence_nums = nan(1,numel(all_files),1);
for i = 1:numel(all_files)
    num = str2double(regexp(all_files(i).name,'(?<=Cycle)\d*','match'));
    if ~isempty(num) && isnumeric(num)
        sequence_nums(i) = num;
    else
        sequence_nums(i) = NaN;
    end
end
sequence_nums = unique(sequence_nums);
sequence_nums = sequence_nums(~isnan(sequence_nums));

% All processed/organized data goes to 'condition_data' struct
if ~exist('condition_data','var')
    
    % Pull image data into a structure
    fprintf('\nImporting sequence: %0.8d',sequence_nums(1))
    for seq_ind = 1:numel(sequence_nums)
        sequence(seq_ind).frames = retrieve_images(p,sequence_nums(seq_ind)); %#ok<*SAGROW>
        fprintf('\b\b\b\b\b\b\b\b%0.8d',sequence_nums(seq_ind))
    end
    fprintf('\tDone.\n')
    
    % Retrieve voltage values from .csvs
    fprintf('\nRetrieving voltages for sequence: %0.8d',sequence_nums(1))
    for seq_ind = 1:numel(sequence)
        sequence(seq_ind).ao = import_ao_voltages(p,sequence_nums(seq_ind));
        fprintf('\b\b\b\b\b\b\b\b%0.8d',sequence_nums(seq_ind))
    end
    fprintf('\tDone.\n')
    
    % Register each set of frames
    fprintf('\nRegistering sequence: %0.8d',sequence_nums(1))
    for seq_ind = 1:numel(sequence)
        sequence(seq_ind).frames = remove_motion(sequence(seq_ind).frames,'first');
        fprintf('\b\b\b\b\b\b\b\b%0.8d',sequence_nums(seq_ind))
    end
    fprintf('\tDone.\n')
    
    % Organize the conditions together for analysis
    try metadata.ordered_conditions
    catch ME
        % temporary solution for fake data
        metadata.ordered_conditions = repmat(1:numel(sequence)/4,1,4);
    end
    fprintf('\nOrganizing sequences into condition repetitions')
    r = ones(1,numel(unique(metadata.ordered_conditions)));
    for i = metadata.ordered_conditions
        condition_data(i).rep(r(i)).frames = sequence(seq_ind).frames;
        condition_data(i).rep(r(i)).ao = sequence(seq_ind).ao;
        r(i) = r(i) + 1;
    end
    fprintf('\tDone.\n')

    %==Save Imported Data==================================================
    save_destination = fullfile(save_folder_loc,'condition_data.mat');
    fprintf('\nSaving imported data to %s',save_destination)
    save(save_destination,'condition_data');
    fprintf('\tDone.\n')
    
end
