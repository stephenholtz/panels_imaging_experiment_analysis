function [disp] = find_offset_seq(frame_data, method, offset_opts)
%FIND_OFFSET_SEQ Find image offset for an image sequence
%  [first_disp] = FIND_OFFSET_SEQ(frame_data, method, offset_opts)
%  calculates the best-fit displacement between every member of the image
%  sequence and a reference frame.
%  
%  The argument method determines the reference frame that is used.
%  Can be 'first', 'mean', or 'std'.
%
%  The argument offset_opts stores parameters that control how the offset
%  is calculated.  See find_offset() for more information on the form of
%  this structure.

    % Check arguments    
    if ~isa(method, 'char') || ~ismatrix(method) || size(method,1) ~= 1
        error 'Invalid type for method';
    end
    
    % Do not check offset_opts, this will be done by find_offset
    
    
    % Create empty displacement vectors
    disp = zeros(2, length(frame_data));
    
    % Construct the reference image
    switch method
        case {'first', 'prev'}
            im_ref = frame_data(1).image;
        case 'mean'
            im_ref = [];
            
            for idx=1:length(frame_data)
                % Open idx member of the sequence
                im = frame_data(idx).image;
        
                % Calculate the displacement from reference member
                if isempty(im_ref)
                    im_ref = im;
                else
                    if nnz(size(im)-size(im_ref)) ~= 0
                        error 'Image sizes do not match';
                    end
                        
                    im_ref = im_ref + im;
                end
            end
            
            im_ref = im_ref ./ length(frame_data);
        case 'std'
            im_mean = [];
            
            % Find the mean
            for idx=1:length(frame_data)
                % Open idx member of the sequence
                im = frame_data(idx).image;
        
                % Calculate the displacement from reference member
                if isempty(im_mean)
                    im_mean = im;
                else
                    if nnz(size(im)-size(im_mean)) ~= 0
                        error 'Image sizes do not match';
                    end
                        
                    im_mean = im_mean + im;
                end
            end
            
            im_mean = im_mean ./ length(frame_data);            
            im_std = [];
            
            % Find the std deviation
            for idx=1:length(frame_data)
                % Open idx member of the sequence
                im = frame_data(idx).image;
        
                % Calculate the displacement from reference member
                if isempty(im_std)
                    im_std = (im - im_mean).^2;
                else
                    if nnz(size(im)-size(im_std)) ~= 0
                        error 'Image sizes do not match';
                    end
                        
                    im_std = im_std + (im - im_mean).^2;
                end
            end
            
            im_ref = sqrt(im_std) ./ (length(frame_data) - 1);
        otherwise
            error 'Unrecognized referencing method';
    end
    
    % Find the offset for each image from reference
    for idx=1:length(frame_data)
        % Open idx member of the sequence
        im = frame_data(idx).image;
        
        % Calculate the displacement from reference member
        if nargin > 2
            [disp(1,idx),disp(2,idx)] = ...
                find_offset(im_ref, im, offset_opts);
        else
            [disp(1,idx),disp(2,idx)] = ...
                find_offset(im_ref, im);
        end
        
        if strcmp(method, 'prev')
            im_ref = im;
        end
    end
    
    if strcmp(method, 'prev')
        disp = cumsum(disp,2);
    end
end