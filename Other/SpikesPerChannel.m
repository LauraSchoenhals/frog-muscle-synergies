
%% Spike Count Visualization To Find Threshold
%{
Spikes_per_channel = sum(ppdc.nTrialEvents, 2);
sorted_spikes_per_channel = sort(Spikes_per_channel);


%figure; 
%plot(sorted_spikes_per_channel)
%figure;
%plot(diff(sorted_spikes_per_channel))
%}

%% ISI Visualization to find Threshold
input_data = ppDataCell;
input_data = ppdc;
idx = idx; %select trials

log_normal = true;
EMG = 1:88; %% Must specify
Neural = 89:285; %%Must specify



%input_data = input_data.subsample(idx, Neural);
input_data = input_data.subsample(idx, []);

ntrials = input_data.nTrials; 
nchannels = size(input_data.sensor, 2); 
isi_array = cell(nchannels, ntrials);

for trial = 1:ntrials
    for channel = 1:nchannels
        spike_times = input_data.data{1, trial}(channel).times;
        isi_temp = diff(spike_times);
        if log_normal
            isi_temp = log(isi_temp);
        end
        isi_array{trial, channel} = isi_temp;
    end
end
isi_array = isi_array(1:ntrials, 1:nchannels)';
isi_across_trials = cellhcat(isi_array);


%% KS test for normal distribution
kstest_isi = false(nchannels, 1);

for channel = 1:nchannels
    if isempty (isi_across_trials{channel})
        continue
    end
    kstest_isi(channel) = kstest(zscore(isi_across_trials{channel}), 'Alpha', 0.05);
end

li_kstest = [kstest_isi] > 0;

%% Graphing

tmax = 1; %maximum size of ISI
nbins = 100;

%Filter by number of spikes
threshold = ntrials/20 * 500; % Avg spikes across trials per trial > 25
li_spike_count_threshold = [sum(input_data.nTrialEvents, 2)] > threshold;

filtered_isi = isi_across_trials(li_kstest & li_spike_count_threshold);

channel_idx = find(li_spike_count_threshold & li_kstest);

%input_data.plot(1:ntrials, channel_idx)

%{
figure;
for channel = 1:size(filtered_isi, 1)
    subplot(11, 6, channel)
    data = (filtered_isi{channel, 1});
    histogram(data(data < tmax), nbins); 
end
%}
 nchannelsfilt = size(filtered_isi, 1);

%% Coefficient of Correlation

input_data_filtered = input_data.subsample(1:ntrials, channel_idx);
coherence_array = CollapseRedundantSpikeTrains(input_data_filtered, 0.01);

%figure;
%imagesc(max(coherence_array, [], 3))

%% PCA based K-means clustering
%based on ISI 


histct_filtered_isi = zeros(nchannelsfilt, nbins);
t0 = log(0.001);
t1 = log(tmax);
bin_edges = [t0: (t1-t0)/(nbins) : t1];

for x = 1:size(filtered_isi, 1);
    histct_filtered_isi(x,:) = histcounts(filtered_isi{x}, bin_edges, 'Normalization', 'probability'); %normalize the counts to be a probability distribution
end

Cos_Sim_filtered_isi = cosSimCov(histct_filtered_isi');
%figure; imagesc(Cos_Sim_filtered_isi);

eval = evalclusters(Cos_Sim_filtered_isi, 'kmeans', 'silhouette', 'KList',1:6);
eval.OptimalY;
max_clust = eval.OptimalK;

%% Linkage Tree Plotting
%{
linkage_tree = linkage(histct_filtered_isi);
max_linkage_tree = cluster(linkage_tree, 'maxclust', max_clust);

try
    cutoff = median([linkage_tree(end-(max_clust-1),3) linkage_tree(end-(max_clust-2),3)]); %cutoff is halfway between third from last and second from last linkages to see the 3 clusters
    figure; dendrogram(linkage_tree, 'ColorThreshold', cutoff);    
catch
    disp('Optimal clusters are less than or equal to one. Graph will not generate.');
end
%}

%% STIRPD spike triggered impulse response probability distribution (STA p(x)/t)

smm = sdoMultiMat;

%Import force or Emg data and select trials
xtdc = xtDataCell; 
xtdc.import(emgCell);   %input xtdc: force or emg
xtdc_subsample = xtdc.subsample(idx); %subsample select trials

%Import spike times
ppdc_st = ppDataCell;
ppdc_st.import(spikeTimeCell);
ppdc_st_subsample = ppdc_st.subsample(idx); %subsample select trials

%Select xt channels, pp channels, and trials
xt_channels = 1:11;
pp_channels = 1:15;
trials = 1:ntrials;


%smm.compute(xtdc_subsample, ppdc_st_subsample, xt_channels, pp_channels, trials);
%smm.findSigSdos;

%% plot sig SDOs

%{
nSigLI = [smm.sigMat.nSigValues] >1;
nSpikesLI = [smm.sigMat.nSpikes] >1;
miniSig = smm.sigMat(nSigLI&nSpikesLI); 

try
for r = 1:size(miniSig, 1)
    smm.plot(miniSig(r).xtChannelNo, miniSig(r).ppChannelNo); 
end
catch
    disp('no significant data');
end
%}
%% 

%{
graphed_channels = 0;
start = 1;


for nwindow = ceil(nchannels/100)
    while (graphed_channels < nchannels-100)
        for channel = start:start + 100

end
%}

%{
figure;
nbins = 100;
tmax = 1;


%plot first 100 channels
for channel = 1:100
    subplot(10, 10, channel)
    data = (isi_across_trials{channel, 1});
    histogram(data(data < tmax), nbins); 
end

%plot channels 101-200
figure;
for channel = 1:100
    subplot(10, 10, channel);
    data = (isi_across_trials{channel + 100, 1});
    histogram(data(data < tmax), nbins); 
end


figure;
%plot channels 201-end
for channel = 1:85
    subplot(10, 10, channel);
    data = (isi_across_trials{channel + 200, 1});
    histogram(data(data < tmax), nbins); 
end

%}

%% PSTH
%{
binned_idx = input_data_filtered.getRasterIndices;
binned_timestamps = cellfun(@times, binned_idx, repelem({1/ppdc.fs}, 61,19), 'UniformOutput', false);

CalculatePSTH(binned_timestamps);
%}







