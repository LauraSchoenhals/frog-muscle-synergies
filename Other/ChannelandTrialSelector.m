%% Channel and Trial Selector


function [out, idx] = ChannelandTrialSelector(ppdc, trial_idx, ppdc_idx, nspikes, log_normal)
arguments
    ppdc ppDataCell
    trial_idx
    ppdc_idx
    nspikes {mustBeNumeric} = 500;
    log_normal {mustBeNumericOrLogical} = 1;
end
    ppdc = ppdc.subsample(trial_idx, ppdc_idx);
    ntrials = ppdc.nTrials;
    nchannels = size(ppdc.sensor, 2);

    %isi across trials
    isi_array = cell(nchannels, ntrials);

    for trial = 1: ntrials
        for channel = 1:nchannels
            spike_times = ppdc.data{1, trial}(channel).times;
            isi_temp = diff(spike_times);
            if log_normal
                isi_temp = log(isi_temp);
            end
            isi_array{trial, channel} = isi_temp;
        end
    end
    isi_array = isi_array(1:ntrials, 1:nchannels)';
    isi_across_trials = cellhcat(isi_array);

    if nchannels == 1
        isi_across_trials = {isi_across_trials}; 
    end

    %KS test for normal distribution
    kstest_isi = false(nchannels, 1);

    for channel = 1:nchannels
        if isempty (isi_across_trials{channel})
            continue
        end
        kstest_isi(channel) = kstest(zscore(isi_across_trials{channel}), 'Alpha', 0.05);
    end

    li_kstest = [kstest_isi] > 0;

    %number of spikes filter
    li_spike_count_threshold = [sum(ppdc.nTrialEvents, 2)] > nspikes;

    %idx for spikes that pass number and kmean significance
    li_selected_channels = li_kstest & li_spike_count_threshold;

    %filter obj by selected channels
    obj_filt = ppdc.subsample(1:ntrials, li_selected_channels);

    out = obj_filt;
    idx = li_selected_channels;

end
