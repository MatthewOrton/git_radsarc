clear all
close all

lesionFiles = dir('/Users/morton/Dicom Files/RADSARC_R/XNAT/assessors/assessors_2022.08.09_22.27.30/lesion/*.dcm');
dediffFiles = dir('/Users/morton/Dicom Files/RADSARC_R/XNAT/assessors/assessors_2022.08.09_22.27.30/dediff/*.dcm');

patientID = arrayfunQ(@(x) strsplitN(x.name,'__II__',1), lesionFiles);
dediffPat = arrayfunQ(@(x) strsplitN(x.name,'__II__',1), dediffFiles);


for n = 1:length(patientID)
    if any(cell2mat(cellfunQ(@(x) strcmp(x, patientID{n}), dediffPat)))
        dediff{n,1} = 'x';
    else
        dediff{n,1} = 'NA';
    end
end

tbl = table(patientID, dediff);

writetable(tbl, '/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/SubRegionsPresent.xlsx')