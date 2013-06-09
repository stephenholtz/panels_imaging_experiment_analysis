function frames = find_valid_frames(pattern)
%FIND_VALID_FRAMES Locate filenames that have the given pattern

    % Check arguments
    if ~isa(pattern, 'char') || ~ismatrix(pattern) || size(pattern,1) ~= 1
        error 'Argument pattern must be a string';
    end

    lo_limit = 1;
    hi_limit = 1;
    
    % Use exponentially increasing numbers to search for
    % the last frame
    while true
        fname = sprintf(pattern, hi_limit);
        fid = fopen(fname, 'r');
        if fid == -1
            break;
        end
        
        fclose(fid);            
        hi_limit = 2 * hi_limit;
    end
    
    % Check that got something
    if lo_limit == hi_limit
        disp(fname)
        error 'Unable to open first frame';
    end
    
    % At this point lo_limit is the last known valid element,
    % and hi_limit is the first known bad element.  We do a
    % binary search to locate the actual last bad element.
    while hi_limit - lo_limit > 1
        % The mid_point must be greater than the lo_limit
        % for this test to be useful, so we use ceil
        mid_point = ceil(0.5*(lo_limit + hi_limit));
        
        fname = sprintf(pattern, mid_point);
        fid = fopen(fname, 'r');
        if fid == -1
            hi_limit = mid_point;
        else
            fclose(fid);
            lo_limit = mid_point;
        end        
    end
    
    % At this point lo_limit is the last valid element.
    frames = [1:lo_limit];
end

