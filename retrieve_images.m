function frame_data = retrieve_images(patterns, seq, max_speed_flag)
%RETRIEVE_IMAGES Gather images into a structure.
%
%  patterns - A structure containing the fields:
%    tseries_folder - Folder containing time-series images
%    tseries_fname_base - Base name for time-series images
%    tseries_fname_suffix - Suffix for time-series images
%    tseries_config - Filename for time-series configuration
%    ai_folder - Folder containing analog input data
%    ai_data - Filename of analog input data
%    ai_config - Filename of analog input configuration
%    ao_folder - Folder containing analog input data
%    ao_data - Filename of analog input data
%    ao_config - Filename of analog input configuration
%
%  seq - Sequence to examine
%
%  The filenames are constructed using the passed patterns and
%  the passed sequence number.  The tseries image file for a given
%  frame is given by the expression:
%     [sprintf(tseries_fname_folder, seq),  ...
%     filesep,  ...
%     sprintf(tseries_fname_base, seq), ...
%     sprintf(tseries_fname_suffix, frame)]
%
%  The analog input data file is given by the expression:
%     [sprintf(ai_folder, seq),  ...
%     filesep,  ...
%     sprintf(ai_data, seq)]
%
%  The analog configuration file is given by the expression:
%     [sprintf(ai_folder, seq), ...
%     filesep,  ...
%     sprintf(ai_config, seq)]
%
%  Added:
%  If the max_speed_flag is true, the xml parsing function will check if
%  the "Max Speed" option was checked, and only look for the first 10
%  frames' timestamps, and apply the same difference between them to the
%  rest of the frames.
    
    % Check arguments
    if ~isa(seq, 'double') || ~isscalar(seq)
        error 'Argument seq has invalid type';
    end
    if ~exist('max_speed_flag','var')
        max_speed_flag = 0;
    end
    
    % Assemble the t-series frame pattern
    tseries_folder = sprintf(patterns.tseries_folder, seq);
    tseries_fname_base = sprintf(patterns.tseries_fname_base, seq);
    
    tseries_pattern = [tseries_folder, filesep, tseries_fname_base];
    tseries_pattern = [tseries_pattern, patterns.tseries_fname_suffix];
    
    tseries_config = sprintf(patterns.tseries_config, seq);
    tseries_config = [tseries_folder, filesep, tseries_config];
    
    clear tseries_folder tseries_fname_base;
    
    % Locate each of the frames
    frames = find_valid_frames(tseries_pattern);
    
    % Ignore the last frame, since it is corrupt with aborted series
    frames = frames(1:end-1);
    
    % Get timestamps for each frame
    if ~max_speed_flag
        frames_time = read_tseries_stamps(tseries_config);
        frames_time = frames_time(frames);
    end
    
    % Create data structure
    frame_data = [];
    frame_data.time = [];
    frame_data.image = [];
    frame_data(length(frames)).time = [];
    
    % Retrieve each image
    for idx=1:length(frames)
        % Open the frame
        fname = sprintf(tseries_pattern, frames(idx));
        im = double(imread(fname));
        
        if max_speed_flag
            'apple'
        else
            frame_data(idx).time = frames_time(idx);
        end
        frame_data(idx).image = im;
    end
end