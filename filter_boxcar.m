function out = filter_boxcar(input, num)
%FILTER_BOXCAR Filter data using boxcar filter
%   out = FILTER_BOXCAR(input, num) filters the input column vector
%   input using a zero-phase shift num-length boxcar filter.

    % Check input arguments
    if ~isa(input, 'double') || ~ismatrix(input)
        error 'Argument input has invalid type';
    end
    
    if size(input, 1) ~= 1
        error 'Argument input has invalid dimensions';
    end
    
    if ~isa(input, 'double') || ~isscalar(num)
        error 'Argument num has invalid type';
    end

    if abs(num - round(num)) > eps
        error 'Argument num must be an integer';
    end
    
    if num <= 0 || 3*num > size(input,2)
        error 'Argument num has invalid value';
    end
    
    % Execute the filter
    a = 1;
    b = ones(1, num) ./ num;
    out = filtfilt(b, a, input);
end