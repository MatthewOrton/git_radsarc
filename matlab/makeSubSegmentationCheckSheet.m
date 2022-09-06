clear all
close all

firstBatch = dir('/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/outputs_20220621_0108_withCorrections/pdf/*.pdf');
secondBatch = dir('/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/outputs_20220816_2321/pdf/*.pdf');

firstBatchFiles = arrayfunQ(@(x) x.name, firstBatch);
secondBatchFiles = arrayfunQ(@(x) x.name, secondBatch);

alreadyChecked = intersect(firstBatchFiles, secondBatchFiles);
notChecked = setdiff(secondBatchFiles, alreadyChecked);

% stack checked flag and file names in the same way so we can sort both
% together
batch1 = [repmat('x', length(alreadyChecked), 1); repmat(' ', length(notChecked),1)];

segmentation = [alreadyChecked; notChecked];

[~,idx] = sort(segmentation);
segmentation = segmentation(idx);
batch1 = batch1(idx);

tbl = table(segmentation, batch1);