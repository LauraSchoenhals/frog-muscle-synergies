
% assuming that ppdc and xtdc are in memory; 

% run multiple itterations of sdoMultiMat, save, delete, move on

MAX_PP_CH = 25; 

N_PP_CH = ppdc.nChannels; 


use_path = pwd; %assuming we're already in the folder we want; 


%pp_rng = 1:MAX_PP_CH; 
pp_rng = 276:299; 

%b = 1; 
while max(pp_rng) <= N_PP_CH
    minippdc = ppdc.subsample(1:ppdc.nTrials, pp_rng); 
    smm = sdoMultiMat(); 
    
    %minixtdc = xtdc.subsample(1:xtdc.nTrials, 1); 
    % declare the mini first, then pass; 
    smm.compute(xtdc, minippdc); 
    %smm.compute(minixtdc, minippdc); 
    %
    nm = strcat('sdo_', num2str(b), '.mat');
    ff = fullfile(use_path, nm); 
    smm.findSigSdos; 
    %
    save(ff, "smm", '-v7.3'); %uncompressed; 
    clear smm; %release memory; 
    b = b+1; 
    pp_rng = pp_rng+MAX_PP_CH; 
end

%for b = 1