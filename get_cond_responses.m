function cond_response = get_cond_responses(roi_data,cond_num,roi_num)
% Returns false padded response
    if ~exist('roi_num','var')
        roi_num = 1;
    end
    
    temp_cell = [];
    cond_response = [];
    for rep_num = 1:numel(roi_data.cond(cond_num).rep)
        temp_cell{rep_num} = roi_data.cond(cond_num).rep(rep_num).roi(roi_num).stim;
    end
    long_ts = max(cellfun(@numel,temp_cell));
    for rep_num = 1:numel(roi_data.cond(cond_num).rep)
        cond_response(rep_num,:) = [temp_cell{rep_num} nan(long_ts-numel(temp_cell{rep_num}),1,1)];
    end

end