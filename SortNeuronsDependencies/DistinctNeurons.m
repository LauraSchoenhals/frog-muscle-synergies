%% Plot distinct neurons
%find neurons that fire in one time but not in the other
%Designed to follow GoodNeuronSpikes

%neurons that fire ever in arm condition
ppdc_arm = ppdc.subsample(arm_trials, 1:nchannels);
li_forelimb_fire = false(nchannels, 1);
for channel = 1:nchannels
    li_forelimb_fire(channel) = sum(ppdc_arm.nTrialEvents(channel)) > 0;
end

%neurons that fire ever in leg condition
ppdc_leg = ppdc.subsample(leg_trials, 1:nchannels);
li_hindlimb_fire = false(nchannels, 1);
for channel = 1:nchannels
    li_hindlimb_fire(channel) = sum(ppdc_leg.nTrialEvents(channel)) > 0;
end

%neurons that fire in both
li_both_fire = li_forelimb_fire & li_hindlimb_fire;
both_ch_idx = find(li_both_fire);

%neurons that *only* fire in arm condition
li_forelimb_only_ch = li_forelimb_fire & ~li_hindlimb_fire;
forelimb_only_ch = find(li_forelimb_only_ch);

%neurons that *only* fire in leg condition
li_hindlimb_only_ch = li_hindlimb_fire & ~li_forelimb_fire;
hindlimb_only_ch = find(li_hindlimb_only_ch);