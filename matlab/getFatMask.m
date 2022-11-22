clear variables
close all force

% This is an experiment to evaluate if simple image thresholding can be used to
% approximate the low/high/calc volume fractions from the semi-automatic
% sub-segmentations

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT';
rtsFiles = dir(fullfile(rootFolder, 'assessors', 'assessors_2022.09.01_11.19.46', 'lesion', '*.dcm'));

quickLoadMap = fullfile(rootFolder, 'sopInstanceMap.mat');
if exist(quickLoadMap,'file')
    load(quickLoadMap, 'maps')
else
    maps = sopInstanceMap(fullfile(rootFolder, 'referencedScans'));
    save(quickLoadMap, 'maps')
end

for nRts =  1:length(rtsFiles)

    disp([num2str(nRts) ' : ' rtsFiles(nRts).name])

    thisFile = fullfile(rtsFiles(nRts).folder, rtsFiles(nRts).name);
    rts = readDicomRT(thisFile, maps.sopInstMap);

    key = rts.roi.keys;
    key = key(cell2mat(cellfunQ(@(x) ~contains(x,'hole'), key)));

    mask = rts.roi(key{1}).mask;
    im = rts.roi(key{1}).im;
    
    newFile = strrep(strrep(thisFile,'.dcm','.mat'),'lesion','fatMask');
    H  = makeSimpleROI(im, [-150 100], newFile);
    uiwait(H)
    close(H)
end
