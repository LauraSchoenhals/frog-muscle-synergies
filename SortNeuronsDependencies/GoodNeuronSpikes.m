%% Sorts Neural Channels by Spike Count
%Continues from GoodNeuronCandidates
%This should be altered to use the desired xtdc (force or emg) and the
%desired trials (forelimb/hindlimb, from metadata). 

xtdc = xtDataCell();
xtdc.import(emgCell);

all_good_pp_ch = [find(li_good_pp_ch)];

arm_trials = arm_idx; %?
leg_trials= leg_idx; %?

both_trials = [leg_trials, arm_trials]; 
%% Filter by spike count across selected trials only

threshold = 500; %can specify this
spkCount = ppdc.nTrialEvents(all_good_pp_ch,[leg_trials arm_trials]); 
totalCount = sum(spkCount,2); 
LI2 = totalCount > threshold; 

all_good_pp_ch2 = all_good_pp_ch(LI2); %this is the one that is filtered by relevant spike count