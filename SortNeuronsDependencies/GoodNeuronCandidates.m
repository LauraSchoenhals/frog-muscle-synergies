%% Good Neurons Candidates
input_data = ppdc;

% Num spikes/channel threshold filter
%threshold = 500;
%li_spike_count_threshold = [sum(input_data.nTrialEvents, 2)] > threshold;

% ISI visualization
%input_data = ppDataCell;
%input_data = ppdc;

log_normal = true;
EMG = 1:88; %% Must specify
Neural = 89:285; %%Must specify
%% 
nchannels = size(input_data.sensor, 2); 
ntrials = input_data.nTrials; 

isi_array = cell(nchannels, ntrials);

for trial = 1:ntrials
    for channel = 1:nchannels
        spike_times = input_data.data{1, trial}(channel).times;
        isi_temp = diff(spike_times);
        if log_normal
            isi_temp = log(isi_temp);
        end
        isi_array{channel, trial} = isi_temp;
    end
end
%% 

isi_across_trials = cellhcat(isi_array);
if nchannels == 1
        isi_across_trials = {isi_across_trials}; 
end

%ks test for variance from normal distribution 
kstest_isi = false(nchannels, 1);

for channel = 1:nchannels
    if isempty (isi_across_trials{channel})
        continue
    end
    kstest_isi(channel) = kstest(zscore(isi_across_trials{channel}), 'Alpha', 0.05);
end

li_kstest = [kstest_isi] > 0;

smu = false(88, 1);
neural = true(211, 1);
li_neural = [smu; neural];


%% filter by ks test and by threshold

li_good_pp_ch = (li_kstest & li_neural);


