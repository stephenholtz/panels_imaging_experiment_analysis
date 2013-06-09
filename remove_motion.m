function frame_data = remove_motion(frame_data, ref)
%REMOVE_MOTION Remove motion artifact from the video
%
%  frame_data - Structure containing movie as output by pool_images
%
%  ref - Method used to calculate reference.  Should be 'first',
%    'prev', 'mean', or 'std'

    max_xdisp = 10; % maximum x displacement in pixels
    max_ydisp = 10; % maximum y displacement in pixels
    disp_boxcar_order = 1; % order of displacement boxcar filter
   
    % Check arguments
    if ~isa(ref, 'char') || ~ismatrix(ref) || ~size(ref,1) == 1
        error 'Argument ref must be a string'
    end

    % Calculate the best-fit displacements for time series
    offset_opts.max_xdisp = max_xdisp;
    offset_opts.max_ydisp = max_ydisp;
        
    ref_disp = find_offset_seq(frame_data, ref, offset_opts); 
    movement = sqrt(ref_disp(1,:).^2 + ref_disp(2,:).^2);
            
    % Use boxcar filter to clean up displacement from first frame
    filt_ref_disp(1,:) = filter_boxcar(ref_disp(1,:), disp_boxcar_order);
    filt_ref_disp(2,:) = filter_boxcar(ref_disp(2,:), disp_boxcar_order);

    % Retrieve each image
    for idx=1:length(frame_data)
        % Open the frame
        im = frame_data(idx).image;
        
        % Shift it to align with the reference frame
        im = shift_image(im, ceil([max(abs(filt_ref_disp(1,:))); ...
            max(abs(filt_ref_disp(2,:)))]), filt_ref_disp(:, idx));

        frame_data(idx).image = im;
        frame_data(idx).movement = movement(:,idx);
    end    
end