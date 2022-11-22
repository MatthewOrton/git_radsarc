clear variables
close all

% This is an experiment to evaluate if simple image thresholding can be used to
% approximate the low/high/calc volume fractions from the semi-automatic
% sub-segmentations

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT';
segFiles = dir(fullfile(rootFolder, 'assessors', 'assessors_SEG_2022.09.02_00.02.25', '*.dcm'));
fatMaskFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT/assessors/assessors_2022.09.01_11.19.46/fatMask';

quickLoadMap = fullfile(rootFolder, 'sopInstanceMap.mat');
if exist(quickLoadMap,'file')
    load(quickLoadMap, 'maps')
else
    maps = sopInstanceMap(fullfile(rootFolder, 'referencedScans'));
    save(quickLoadMap, 'maps')
end

thresholds = -150:250;
percentileThresholds = 50:100;

volumeFraction.low  = zeros(length(segFiles),1);
volumeFraction.high = zeros(length(segFiles),1);
volumeFraction.calc = zeros(length(segFiles),1);

volumeFraction_threshold.low  = zeros(length(segFiles), length(thresholds));
volumeFraction_threshold.high = zeros(length(segFiles), length(thresholds));
volumeFraction_threshold.calc = zeros(length(segFiles), length(thresholds));

volumeFraction_percentileThreshold.low  = zeros(length(segFiles), length(percentileThresholds));

for nSeg =  1:length(segFiles)

    segFile = fullfile(segFiles(nSeg).folder, segFiles(nSeg).name);
    seg = readDicomSeg(segFile, maps);

    patID = strsplitN(segFiles(nSeg).name,'__II__',1);

    % locate and load fat mask
    fatMaskFile = dir(fullfile(fatMaskFolder, [patID '*.mat']));
    load(fullfile(fatMaskFile.folder, fatMaskFile.name))
    % rename for clarity
    fatMask = mask;
    clear mask

    lesionMask = seg.roi('lesion').mask;
    lowMask = seg.roi('low enhancing').mask;
    highMask = seg.roi('high enhancing').mask;
    calcMask = seg.roi('calcification').mask;

    im = seg.roi('lesion').image;

    lesionVolume = nnz(lesionMask);
    lowVolume = nnz(lowMask);
    highVolume = nnz(highMask);
    calcVolume = nnz(calcMask);

    % get low, high and calc volume fractions from actual sub-segmentations
    volumeFraction.low(nSeg,1) = lowVolume/lesionVolume;
    volumeFraction.high(nSeg,1) = highVolume/lesionVolume;
    volumeFraction.calc(nSeg,1) = calcVolume/lesionVolume;

    % for the thresholds specified get the volume fraction obtained by
    % using a basic thresholding on the images
    for m = 1:length(thresholds)
        volumeFraction_threshold.low(nSeg,m) = nnz(im(lesionMask & im<thresholds(m)))/lesionVolume;
        volumeFraction_threshold.high(nSeg,m) = nnz(im(lesionMask & im>thresholds(m)))/lesionVolume;
        volumeFraction_threshold.calc(nSeg,m) = nnz(im(lesionMask & im>thresholds(m)))/lesionVolume;
    end

    for m = 1:length(percentileThresholds)
        fatThreshold = prctile(seg.roi('lesion').image(fatMask), percentileThresholds(m));
        volumeFraction_percentileThreshold.low(nSeg,m) = nnz(im(lesionMask & im<fatThreshold))/lesionVolume;
    end



    for n = 1:length(thresholds)
        score.low(n) = corr(volumeFraction_threshold.low(:,n), volumeFraction.low);
        score.high(n) = corr(volumeFraction_threshold.high(:,n), volumeFraction.high);
        score.calc(n) = corr(volumeFraction_threshold.calc(:,n), volumeFraction.calc);
    end


    subplot(2,2,1)
    plot(thresholds, score.low, 'DisplayName','low fixed')
    hold on
    plot(thresholds, score.high, 'DisplayName','high')
    plot(thresholds, score.calc, 'DisplayName','calc')
    legend
    ylabel('Spearman correlation')
    xlabel('Threshold')
    hold off

    [~,I] = max(score.low);
    subplot(2,2,2)
    plot(volumeFraction_threshold.low(:,I), volumeFraction.low, '.')


    for n = 1:length(percentileThresholds)
        score.lowFat(n) = corr(volumeFraction_percentileThreshold.low(:,n), volumeFraction.low);
    end

    subplot(2,2,3)
    plot(percentileThresholds, score.lowFat, 'DisplayName','low fat')
    legend
    ylabel('Spearman correlation')
    xlabel('percentile threshold')

    [~,I] = max(score.lowFat);
    subplot(2,2,4)
    plot(volumeFraction_percentileThreshold.low(:,I), volumeFraction.low, '.')


    disp(segFiles(nSeg).name)

    drawnow

end

%%

for n = 1:length(thresholds)
    score.low(n) = corr(volumeFraction_threshold.low(:,n), volumeFraction.low, 'Type', 'Spearman');
    score.high(n) = corr(volumeFraction_threshold.high(:,n), volumeFraction.high, 'Type', 'Spearman');
    score.calc(n) = corr(volumeFraction_threshold.calc(:,n), volumeFraction.calc, 'Type', 'Spearman');
end


close
figure('position',[680  691  951  406])

subplot(2,3,1)
plot(thresholds, score.low, 'DisplayName','low fixed')
hold on
plot(thresholds, score.high, 'DisplayName','high')
plot(thresholds, score.calc, 'DisplayName','calc')
legend(location='SouthWest')
ylabel('Spearman correlation')
xlabel('Threshold')
hold off

[~,Ilow] = max(score.low);
[~,Ihigh] = max(score.high);
subplot(2,3,2)
plot(volumeFraction_threshold.low(:,Ilow), volumeFraction.low, '.')
hold on
plot(volumeFraction_threshold.high(:,Ihigh), volumeFraction.high, '.')
plot(volumeFraction_threshold.calc(:,Icalc), volumeFraction.calc, '.')
title({['low threshold = ' num2str(thresholds(Ilow))], ['high threshold = ' num2str(thresholds(Ihigh))]})

[~,Icalc] = max(score.calc);
subplot(2,3,3)
plot(volumeFraction_threshold.calc(:,Icalc), volumeFraction.calc, '.')
title(['calc threshold = ' num2str(thresholds(Icalc))])


for n = 1:length(percentileThresholds)
    score.lowFat(n) = corr(volumeFraction_percentileThreshold.low(:,n), volumeFraction.low, 'Type', 'Spearman');
end

subplot(2,3,4)
plot(percentileThresholds, score.lowFat, 'DisplayName','low fat')
legend
ylabel('Spearman correlation')
xlabel('percentile threshold')

[~,I] = max(score.lowFat);
subplot(2,3,5)
plot(volumeFraction_percentileThreshold.low(:,I), volumeFraction.low, '.')

%%
PatientID = arrayfunQ(@(x) strsplitN(x.name,'__II__',1), segFiles);
volumeFractionLowApprox = volumeFraction_threshold.low(:,Ilow);
volumeFractionHighApprox = volumeFraction_threshold.high(:,Ihigh);
volumeFractionCalcApprox = volumeFraction_threshold.calc(:,Icalc);
tbl = table(PatientID, volumeFractionLowApprox, volumeFractionHighApprox, volumeFractionCalcApprox);

