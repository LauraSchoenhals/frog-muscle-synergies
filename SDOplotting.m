

SDO_instance = sdoMultiMat;
idx = idx; %idx is the channels you want to use
neurons = [19, 88]; 

chosen_ones = ppdc_subset.subsample(1:19, neurons);
xtdc_subset = xtDataCell;
xtdc_subset.import(emgCell);
xtdc_subset = xtdc_subset.subsample(idx);  
xtdc_subset.plot

SDO_instance.compute(xtdc_subset, chosen_ones);

SDO_instance.findSigSdos;
SigSDOs = SDO_instance.findSigSdos;

SDO_extracted = SDO_instance.extract(11, 1);
SDO_extracted.plot

SDO_extracted = SDO_instance.extract(11, 2);
SDO_extracted.plot

xtdc_subset.plot(1:19, 1:11);