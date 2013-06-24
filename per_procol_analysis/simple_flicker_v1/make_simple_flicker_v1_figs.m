% Make a figure for the simple flicker motion stimulus
%
% A timeseries of the Deltaf/f (with different ROIs)
%

%==Set Path / Initialize Variables=========================================

% Add the experiment analysis and generation folders to the path
addpath(genpath('/Users/stephenholtz/panels_imaging_experiment_analysis'));

% Initialize variables / load in data
top_folder_loc = '/Users/stephenholtz/local_experiment_copies/';
experiment_name = 'simple_flicker_motion';
exp_subgroup_name = 'pollen_grain_test'; %%%% this will eventually need to be the genotype / iterated over
save_folder_loc = fullfile(top_folder_loc,experiment_name,exp_subgroup_name);

if ~exist('condition_data','var')
    load(fullfile(save_folder_loc,'condition_data'));
end


%==Get Df/f wrt ROIs=======================================================

% Condition to test
cond_num = 1;
rep_num = 1;

pre_inds = condition_data(cond_num).rep(rep_num).pre_stim_frame_inds;
stim_inds = condition_data(cond_num).rep(rep_num).stim_frame_inds;
post_inds = condition_data(cond_num).rep(rep_num).post_stim_frame_inds;

% Set the ROI and use it as the default for the experiment
first_stim_frame = condition_data(cond_num).rep(rep_num).frames(stim_inds(1)).image;
BW = roipoly(first_stim_frame);


% Calculate the Df/f using the non ROI as the baseline

% Save each ROI as a timesieres of Df/f per repetition of the condition

% Save the roi data in a summary file

% Break up the timeseries according to the stimulus and make an average
% over each periodic part of the stimulus





