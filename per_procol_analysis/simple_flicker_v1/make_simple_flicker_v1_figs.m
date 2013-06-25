% Make a figure for the simple flicker motion stimulus
%
% A timeseries of the Deltaf/f (with different ROIs)
%

%==Set Path / Initialize Variables=========================================
% Add utilities to the path
addpath(genpath('/Users/stephenholtz/matlab-utils'));
% Add the experiment analysis and generation folders to the path
addpath(genpath('/Users/stephenholtz/panels_imaging_experiment_analysis'));

% Location of the folder that has all of the experiments
top_folder_loc = '/Users/stephenholtz/local_experiment_copies';
experiment_name = 'simple_flicker_v1';

genotype = 1;
switch genotype
    case 1
        top_folder = 'c2_gcamp_6m_vk5/';
    case 2
        top_folder = 'c3_gcamp_6m_vk5/';
    case 3
        top_folder = 'lai_gcamp_6m_vk5/';
end

exp_folders = (dir([fullfile(top_folder_loc,experiment_name,top_folder) '*T*']));
exp_folders = {exp_folders.name};

exp_num = 1; % iterate later...
save_folder_loc = fullfile(top_folder_loc,experiment_name,top_folder,exp_folders{exp_num});

%==Load in data files======================================================
if ~exist('experiment','var')
    load(fullfile(save_folder_loc,'experiment'));
end

if ~exist('roi_data','var')
    if exist(fullfile(save_folder_loc,'roi_data.mat'),'file')
        load(fullfile(save_folder_loc,'roi_data')); 
    else
        save_destination=fullfile(save_folder_loc,'roi_data.mat');
        roi_data = get_roi_data(experiment);
        save(save_destination,'roi_data');
    end
end

%==Find/Organize Average Responses=========================================
for cond_num = 1:8
    roi_num = 1;
    cond_resp = get_cond_responses(roi_data(roi_num),cond_num);
    graph.line = nanmean(cond_resp);
    graph.shade = nanstd(cond_resp);
    graph.color = [.05 .8 .1];
    %graph.color = [.9 .3 .3];
    figure('Name',['Cond ' num2str(cond_num)],'NumberTitle','off','Color',[1 1 1],'Position',[50 50 650 300],'PaperOrientation','portrait');
    makeErrorShadedTimeseries(graph);
    box off;
end

% Break up the timeseries according to the stimulus and make an average
% over each periodic part of the stimulus....
