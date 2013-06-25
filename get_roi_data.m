function roi_data = get_roi_data(experiment)
%==Get Df/f wrt ROIs=======================================================
% pass the experiment struct and hope the fields haven't been changed

n_rois = 1;

% Set the ROI and use it for the entire experiment
[r,c]=size(experiment(1).frames(1).image);
roi_frame_inds = 1:1000;
roi_frames = zeros(r,c,numel(roi_frame_inds));
for i = 1:numel(roi_frame_inds)
    roi_frames(:,:,i) = experiment(1).frames(roi_frame_inds).image;
end
max_int = (max(roi_frames,[],3));

figure;
imagesc(max_int);

for i = 1:n_rois
    fprintf('Draw ROI %d for Masking ',i);
    roi_data.mask(i).name = ['Mask ' num2str(i)];
    fh_h = imfreehand(gca);
    roi_positions = fh_h.getPosition;
    roi_data.mask(i).x = roi_positions(:,1);
    roi_data.mask(i).y = roi_positions(:,2);
    roi_data.mask(i).binary = fh_h.createMask;
    fprintf('\tDone\n')
end

% Iterate over all of the conditions and repetitions
for cond_num = 1:numel(experiment(1).condition_data)
    for rep_num = 1:numel(experiment(1).condition_data(cond_num).rep)

        % Frame inds that correspond to the daq timeseries
        %daq_pre_inds  = experiment(1).condition_data(cond_num).rep(rep_num).daq.pre_stim_inds;
        %daq_stim_inds = experiment(1).condition_data(cond_num).rep(rep_num).daq.post_stim_inds;
        %daq_post_inds = experiment(1).condition_data(cond_num).rep(rep_num).daq.stim_inds;

        % Frame inds that correspond to the frames
        frame_pre_inds = experiment(1).condition_data(cond_num).rep(rep_num).frames.pre_stim_inds;
        frame_stim_inds = experiment(1).condition_data(cond_num).rep(rep_num).frames.stim_inds;
        frame_post_inds = experiment(1).condition_data(cond_num).rep(rep_num).frames.post_stim_inds;

        % Calculate the Df/f using the non ROI as the baseline
        for i = 1:n_rois
            for f = [frame_pre_inds frame_stim_inds frame_post_inds]
                curr_frame = experiment(1).frames(f).image;
                roi_data.dfof(f) =(sum(curr_frame.*roi_data.mask(i).binary)/sum(curr_frame));
            end
            
            roi_data.cond(cond_num).rep(rep_num).roi(i).full = roi_data.dfof([frame_pre_inds frame_stim_inds frame_post_inds]);
            roi_data.cond(cond_num).rep(rep_num).roi(i).pre  = roi_data.dfof(frame_pre_inds);
            roi_data.cond(cond_num).rep(rep_num).roi(i).stim = roi_data.dfof(frame_stim_inds);
            roi_data.cond(cond_num).rep(rep_num).roi(i).post = roi_data.dfof(frame_post_inds);
        end
    end
end
clear roi dfof force
