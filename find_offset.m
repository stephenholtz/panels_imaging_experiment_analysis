function [disp_x,disp_y] = find_offset(im1, im2, opts)
%FIND_OFFSET Find offset between two images
%   [displ_x, displ_y] = FIND_OFFSET(im1, im2, opts) returns scalar
%   displacements displ_x and displ_y that indicate the displacement
%   of im1 that provides that best match to im2.  Matching is performed
%   by Fourier-based cross-correlation of the two images followed by
%   Gaussian sub-pixel interpolation.
%
%   The optional argument opts provides the following options:
%
%     max_xdisp - Maximum allowed displacement in X direction
%       (defaults to 10).
%
%     max_ydisp - Maximum allowed displacement in Y direction
%       (defaults to 10).
%
%     fft_xsize - Size of fourier transform in X direction
%       (defaults to nearest power of two).
%
%     fft_ysize - Size of fourier transform in Y direction
%       (defaults to nearest power of two).
%
%     interp_xsize - Size of window in X direction around the
%       correlation peak used to perform sub-pixel interpolation
%       (defaults to 5).
%
%     interp_ysize - Size of window in X direction around the
%       correlation peak used to perform sub-pixel interpolation
%       (defaults to 5).
%
%     bump_frac - For numerical stability, correlation values less
%       than bump_frac times the maximum correlation will be rounded
%       up.
%

    % Set default values for options
    opts_v.max_xdisp = 10;
    opts_v.max_ydisp = 10;
    opts_v.fft_xsize = 2^ceil(log2(size(im1,2)));
    opts_v.fft_ysize = 2^ceil(log2(size(im1,1)));
    opts_v.interp_xsize = 5;
    opts_v.interp_ysize = 5;
    opts_v.bump_frac = 0.01;
    
    % Check the opts arguments for validity
    if nargin > 2
        % Check the form of opts argument
        if ~isstruct(opts)
            error 'Argument opts must be a structure';
        end
        
        if length(opts) > 1
            error 'Argument opts must not be an array';
        end
        
        % Check that each field of opts is valid, and overwrite
        % value in defaults with value
        fnames = fieldnames(opts);
        for idx=1:length(fnames)
            if ~isfield(opts_v, fnames{idx})
                error(['Argument opts has invalid field ', fnames{idx}]);
            else
                opts_v.(fnames{idx}) = opts.(fnames{idx});
            end
        end
        
        clear fnames idx opts;
    end

    % Move options into the global namespace
    fnames = fieldnames(opts_v);
    for idx=1:length(fnames)
        eval([fnames{idx}, ' = ', 'opts_v.', fnames{idx}, ';']);
    end
    
    clear fnames idx;
    
    % Check that input arguments are valid 
    if ~ismatrix(im1)
        error 'Argument im1 must be a two dimensional matrix';
    end
    
    if ~isa(im1, 'double')
        error 'Argument im1 must be a double';
    end
    
    if ~ismatrix(im2)
        error 'Argument im2 must be a two dimensional matrix';
    end
    
    if ~isa(im2, 'double')
        error 'Argument im2 must be a double';
    end
    
    if nnz(size(im1)-size(im2)) ~= 0
        error 'Arguments im1 and im2 must have the same size';
    end
    
    if ~isscalar(max_xdisp) || ~isa(max_xdisp, 'double')
        error 'Invalid type for opts.max_xdisp';
    end
    
    if max_xdisp <= 0 || max_xdisp >= size(im1,2)-1
        error 'Invalid value for opts.max_xdisp';
    end
    
    if ~isscalar(max_ydisp) || ~isa(max_ydisp, 'double')
        error 'Invalid type for opts.max_ydisp';
    end
    
    if max_ydisp <= 0 || max_ydisp >= size(im1,1)-1
        error 'Invalid value for opts.max_ydisp';
    end
    
    if ~isscalar(fft_xsize) || ~isa(fft_xsize, 'double')
        error 'Invalid type for opts.fft_xsize';
    end
    
    if fft_xsize < size(im1,2)
        error 'Value of opts.fft_xsize is too small';
    end
    
    if mod(fft_xsize,2) ~= 0
        error 'Value of opts.fft_xsize must be even';
    end
    
    if ~isscalar(fft_ysize) || ~isa(fft_ysize, 'double')
        error 'Invalid type for opts.fft_ysize';
    end
    
    if fft_ysize < size(im1,1)
        error 'Value of opts.fft_ysize is too small';
    end
    
    if mod(fft_ysize,2) ~= 0
        error 'Value of opts.fft_ysize must be even';
    end
    
    if ~isscalar(interp_xsize) || ~isa(interp_xsize, 'double')
        error 'Invalid type for opts.interp_ysize';
    end
    
    if interp_xsize < 1
        error 'Value of opts.interp_xsize is too small';
    end
    
    if mod(interp_xsize, 2) ~= 1
        error 'Value of opts.interp_xsize must be odd';
    end
    
    if interp_xsize > fft_xsize - 2*max_xdisp - 1
        error 'Value of opts.interp_xsize is too large';
    end
    
    if ~isscalar(interp_ysize) || ~isa(interp_ysize, 'double')
        error 'Invalid type for opts.interp_ysize';
    end
    
    if interp_ysize < 1
        error 'Value of opts.interp_ysize is too small';
    end
    
    if mod(interp_ysize, 2) ~= 1
        error 'Value of opts.interp_ysize must be odd';
    end
    
    if interp_ysize > fft_ysize - 2*max_ydisp - 1
        error 'Value of opts.interp_ysize is too large';
    end
    
    if ~isscalar(bump_frac) || ~isa(bump_frac, 'double')
        error 'Invalid type for opts.bump_frac';
    end
    
    if bump_frac <= 0 || bump_frac >= 1
        error 'Value of opts.bump_frac must be between zero and one';
    end
    
    % Detrend the image data
    im1 = detrend_image(im1);
    im2 = detrend_image(im2);
    
    % Zero all of the pixels on edge of im1, so that correlation
    % exposes the same number of pixels regardless of displacement.
    % This is necessary to prevent zero displacement bias.
    im1_wind = zeros(size(im1));
    im1_wind(max_ydisp+1:end-max_ydisp, max_xdisp+1:end-max_xdisp) = ...
        im1(max_ydisp+1:end-max_ydisp, max_xdisp+1:end-max_xdisp);

    % Take the Fourier transform of im1_wind and im2, and use
    % these to calculate the cross-correlation.
    im1_ft = fft2(im1_wind, fft_ysize, fft_xsize);
    im2_ft = fft2(im2, fft_ysize, fft_xsize);
    imX_ft = conj(im1_ft) .* im2_ft;
    imX = ifft2(imX_ft);
    
    % Rearrange the cross-correlation matrix so that rows hold
    % increasing y displacements, and the columns hold increasing
    % x displacements.
    imX = fftshift(imX);
    
    % Zero points outside of the area of interest
    [dispx,dispy] = meshgrid(-fft_xsize/2:1:fft_xsize/2-1, ...
      -fft_ysize/2:1:fft_ysize/2-1);
    imX(abs(dispx) > max_xdisp | abs(dispy) > max_ydisp) = 0.0;
    
    % Identify the largest point in the cross-correlation
    [max_i, max_j] = find(imX == max(imX(:)), 1, 'first');
    
    % Convert the row/column values to a displacement
    intg_disp_x = max_j - (fft_xsize/2+1);
    intg_disp_y = max_i - (fft_ysize/2+1);
    
    % If the displacement exceeds maximum, then return immediately
    if abs(intg_disp_x) > max_xdisp || abs(intg_disp_y) > max_ydisp
        disp_x = min(max(intg_disp_x, -max_xdisp), max_xdisp);
        disp_y = min(max(intg_disp_y, -max_ydisp), max_ydisp);
        return;
    end
    
    % Sample cross-correlation around the center point
    imX_center = ...
        imX(max_i-(interp_ysize-1)/2 : max_i+(interp_ysize-1)/2, ...
        max_j-(interp_xsize-1)/2 : max_j+(interp_xsize-1)/2);
    
    % If a cross-correlation value is exactly zero, then the logarithm
    % used for interpolation is ill-defined.  So we check for any values
    % less than bump_frac times the maximum value, and then reset these
    % to bump_frac times the maximum value.  Provided that bump_frac is
    % much less than one, then this has a negligible effect on the 
    % interpolation but stabilizes the calculation.
    imX_center_max = imX(max_i, max_j);
    imX_center(imX_center < bump_frac * imX_center_max) = ...
        bump_frac * imX_center_max;
    
    % Take the logarithm of the correlation, provided that the 
    % correlation is Gaussian, imX_center_log is paraboloidal.
    imX_center_log = log(imX_center);
    
    % Calculate the coordinates associated with the values in the
    % samples cross-correlation map
    x_coords = linspace(...
        -(interp_xsize-1)/2, (interp_xsize-1)/2, interp_xsize);
    y_coords = linspace(...
        -(interp_ysize-1)/2, (interp_ysize-1)/2, interp_ysize);
    
    [grid_x_coords, grid_y_coords] = meshgrid(x_coords, y_coords);
    
    % Fit the sampled cross-correlation map to a paraboloid using
    % the linear regression routine.
    p = regress(imX_center_log(:), ...
        [ones(numel(imX_center_log), 1), ...
        grid_x_coords(:), grid_y_coords(:), ...
        grid_x_coords(:).^2, grid_y_coords(:).^2, ...
        grid_x_coords(:) .* grid_y_coords(:)]);
    
    % Calculate the center point of the paraboloid
    max_x = (p(3)*p(6) - 2*p(2)*p(5))/(4*p(4)*p(5)-p(6)^2);
    max_y = (p(2)*p(6) - 2*p(3)*p(4))/(4*p(4)*p(5)-p(6)^2);
    
    % Adjust the integral displacement by interpolated value
    disp_x = intg_disp_x + max_x;
    disp_y = intg_disp_y + max_y;
    
    % If the displacement exceeds maximum, then trim it back
    if abs(disp_x) > max_xdisp || abs(disp_y) > max_ydisp
        disp_x = min(max(disp_x, -max_xdisp), max_xdisp);
        disp_y = min(max(disp_y, -max_ydisp), max_ydisp);
        return;
    end
end

function im = detrend_image(im)
    [x,y] = meshgrid(1:size(im,2), 1:size(im,1));
    n = ones(size(im));
    b = regress(im(:), [x(:), y(:), n(:)]);
    im = im - b(1)*x - b(2)*y - b(3)*n;
end