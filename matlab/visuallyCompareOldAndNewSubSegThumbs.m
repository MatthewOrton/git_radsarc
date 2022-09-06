clear all
close all

currentFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/outputs_20220816_2321/pdf';

currentFiles = dir(fullfile(currentFolder, '*.pdf'));
currentPatNames = arrayfunQ(@(x) strsplitN(x.name,'__II__',1), currentFiles);

testFolder1 = '/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/outputs_20220607_2146_visualQA_onTeams/pdf';
testFolder2 = '/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/outputs_20220621_0108_withCorrections/pdf';

for n = 1:length(currentPatNames)
    currentPdf = dir(fullfile(currentFolder, [currentPatNames{n},'*']));
    open(fullfile(currentPdf.folder, currentPdf.name))

    testFolder1Pdf = dir(fullfile(testFolder1, [currentPatNames{n},'*']));
    for m = 1:length(testFolder1Pdf)
        open(fullfile(testFolder1Pdf(m).folder, testFolder1Pdf(m).name))
    end

    testFolder2Pdf = dir(fullfile(testFolder2, [currentPatNames{n},'*']));
    for m = 1:length(testFolder2Pdf)
        open(fullfile(testFolder2Pdf(m).folder, testFolder2Pdf(m).name))
    end

    pause
end 