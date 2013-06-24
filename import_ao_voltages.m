function voltages = import_ao_voltages(patterns,seq)
%IMPORTFILE Import numeric data and headers from a text file to a struct

cfg_filename = [patterns.ao_folder filesep patterns.ao_config];
dat_filename = [patterns.ao_folder filesep sprintf(patterns.ao_data,seq)];

% retrieve channel names from cfg file
% i.e. the line in the prm file Ch 0 Name=panel_ctrl_ao3 will become 
% header{1} = panel_ctrl_ao3

fid = fopen(cfg_filename,'r');
h = 1;
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    end
    if regexp(tline,'Ch\s\d\sName=','once')
        chan_name = lower(regexp(tline,'(?<=Name=).*','match'));
        if ~strcmpi(chan_name,'""');
            headers{h} = chan_name{1};

            % replace bad characters with underscores
            headers{h} = regexprep(headers{h},'[() ,.%@#]','_');
            while headers{h}(1) == '_';
                headers{h} = headers{h}(2:end);
            end
            while headers{h}(end) == '_';
                headers{h} = headers{h}(1:end-1);
            end
            
            h = h + 1;
        end
    end
end
fclose(fid);

% import data from dat file
fid = fopen(dat_filename,'r');
dat=fscanf(fid,'%f');
fclose(fid);
dat=dat(2:end);
for h = 1:numel(headers)
    voltages.(headers{h}) = dat(h:numel(headers):end);
end