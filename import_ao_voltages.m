function voltages = import_ao_voltages(patterns,seq)
%IMPORTFILE Import numeric data and headers from a text file to a struct

filename = [patterns.ao_folder filesep sprintf(patterns.ao_data,seq)];
csv = csvimport(filename);

for h = 1:size(csv,2)
    headers{h} = lower(csv{1,h});
    % replace bad characters with underscores
    headers{h} = regexprep(headers{h},'[() ,.%@#]','_');
    while headers{h}(1) == '_';
        headers{h} = headers{h}(2:end);
    end
    while headers{h}(end) == '_';
        headers{h} = headers{h}(1:end-1);
    end
end

for h = 1:numel(headers)
    voltages.(headers{h}) = [csv{2:end,h}]';
end