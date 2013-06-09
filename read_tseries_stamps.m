function stamps = read_tseries_stamps(fname)
%READ_TSERIES_PARAM Reads the timestamps from a time series configuration
%    stamps = READ_TSERIES_STAMPS(fname) returns an array of timestamps,
%    one for each frame of the relevant time series.

    % Check input parameters
    if ~isa(fname, 'char') || ~ismatrix(fname) || ~size(fname,1) == 1
        error 'Argument fname must be filename string'
    end
    
    % Read in the XML file
    try
        root = xmlread(fname);
    catch
        error 'Unable to parse XML file';
    end
    
    % Search for the PVScan element
    root = scan_to(root, 'PVScan');
    
    % Search for the Sequence element
    root = scan_to(root, 'Sequence');
   
    % Get nodes of the sequence element
    if ~root.hasChildNodes
        error 'Invalid XML file format';
    end
    
    children = root.getChildNodes;
    
    % Preallocate time-stamps array (it is too large
    % but we will trim it at the end)
    stamps_data = zeros(1, children.getLength);
    stamps_num = 0;
    
    % Traverse list of children
    for idx = 1:children.getLength
        if strcmp(children.item(idx-1).getNodeName, 'Frame')
            node = children.item(idx-1);
            attrib_list = node.getAttributes;
            
            t_val = [];
            i_val = [];
            
            for idx2 = 1:attrib_list.getLength
                attrib = attrib_list.item(idx2-1);
                if strcmp(attrib.getName, 'relativeTime')
                    t_str = char(attrib.getValue);
                    t_val = str2double(t_str);
                    if isempty(t_val)
                        error 'Invalid XML file format';
                    end
                    
                    clear t_str;
                elseif strcmp(attrib.getName, 'index')
                    i_str = char(attrib.getValue);
                    i_val = str2double(i_str);
                    if isempty(i_val)
                        error 'Invalid XML file format';
                    end
                    
                    clear i_str;
                end
            end
            
            if isempty(t_val) || isempty(i_val)
                error 'Invalid XML file format';
            end
 
            if stamps_num + 1 ~= i_val
                error 'Invalid XML file format';
            end
            
            stamps_num = stamps_num + 1;
            stamps_data(stamps_num) = t_val;
        end
    end
    
    stamps = stamps_data(1:stamps_num);
end

function out = scan_to(root, name)
%SCAN_TO Scan to the first element of the element with the given name

    if ~root.hasChildNodes
        error 'Invalid XML file format';
    end

    children = root.getChildNodes;
    for idx = 1:children.getLength
        if strcmp(children.item(idx-1).getNodeName, name)
            out = children.item(idx-1);
            return;
        end
    end
    
    error 'Invalid XML file format';
end