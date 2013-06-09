% Make space-time diagrams

% Add a few things to the path.
addpath(genpath('/Users/stephenholtz/matlab-utils')) % add matlab utilities
addpath(genpath('~/panels_experiments'));

% Load in conditions from the experimental protocol
C = simple_flicker_motion;
C = C.experiment;

save_path = '/Users/stephenholtz/temp_space_time/simple_flicker_motion';

if ~exist(save_path,'dir')
    mkdir(save_path)
end

make_stds = 1;
make_vids = 0;
make_gifs = 1;

for i = 1:numel(C)
 
    stim_name = ['cond_' num2str(i) '_' C(i).PatternName];

    save_file = fullfile(save_path,stim_name);

    stimulus = panels_arena_simulation('large',C(i));

    if make_stds
        std_handle = stimulus.MakeSimpleSpaceTimeDiagram('green');
        params_handle = stimulus.MakeParametersPage;
        panels_arena_simulation.SaveSpaceTimeDiagram(save_file,std_handle,params_handle);
    end

    if make_vids
        mov_handle = stimulus.MakeMovie('green',save_file);
        disp(save_file)
    end

    if make_gifs
        stimulus.MakeSaveAnimatedGif(save_file);
        disp(save_file)
    end

    close all
end