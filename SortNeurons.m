%% Sort Neurons

%load "import" which contains spike times as a ppDataCell, stim data, EMG as an
%xtDataCell, force as an xtDataCell, and the indices for forelimb and
%hindlimb trials

%Find Neurons whose firing patterns vary from Gaussian using Kmeans
GoodNeuronCandidates %note that you may need to edit the channels for neurons vs SMU based on metadata
GoodNeuronSpikes

%Categorize Neurons: fire in both, forelimb only, or hindlimb only
DistinctNeurons

%Filter Neurons by number of spikes over selected trials and generate SDOs
%sdo_comparisions_forelimb_hindlimb

%ICA of EMG
%xtdc.setWeightMatrix('ica');
