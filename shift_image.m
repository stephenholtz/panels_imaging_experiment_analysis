function shifted_im = shift_image(im, max_disp, shift_disp)
%SHIFT_IMAGE Shift the image by a fixed displacement
%   shifted_im = SHIFT_IMAGE(im, max_disp, shift_disp) shifts the
%   input image using linear interpolation by the displacement given
%   in shift_disp, where the first element stores the x displacement
%   and the second element stores the y displacement.  This displacement
%   must be less than max_disp and produces an image that is
%   [size(im,1)-max_disp(2), size(im,2)-max_disp(1)] in size.

    % Check input arguments
    if ~isa(im, 'double') || ~ismatrix(im)
        error 'Argument im has invalid type';
    end
    
    if ~isa(max_disp, 'double') || ~ismatrix(max_disp)
        error 'Argument max_disp has invalid type';
    end
    
    if nnz(size(max_disp) - [2, 1]) ~= 0
        error 'Argument max_disp has invalid size';
    end
    
    if ~isa(shift_disp, 'double') || ~ismatrix(shift_disp)
        error 'Argument shift_disp has invalid type';
    end
    
    if nnz(size(shift_disp) - [2, 1]) ~= 0
        error 'Argument shift_disp has invalid size';
    end
    
    if nnz(abs(shift_disp) > max_disp) ~= 0
        error 'Shift displacement is greater than max_disp';
    end
    
    % Create interpolation function
    [row_coord, col_coord] = ndgrid(1:size(im,1), 1:size(im,2));
    interp_f = griddedInterpolant(row_coord, col_coord, im, 'cubic');

    % Calculate grid coordinates
    [row_wind, col_wind] = ndgrid(max_disp(2)+1:size(im,1)-max_disp(2),...
        max_disp(1)+1:size(im,2)-max_disp(1));

    % Produce interpolated image
    shifted_im = interp_f([row_wind(:) + shift_disp(2), ...
        col_wind(:) + shift_disp(1)]);
    shifted_im = reshape(shifted_im, size(im,1) - 2*max_disp(2), ...
        size(im,2) - 2*max_disp(1));   
end