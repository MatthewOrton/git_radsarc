clear variables
close all

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT/scansForResampling/scans_2022.10.20_08.16.55';

Logger = log4m.getLogger(fullfile(rootFolder, 'resampling_logfile.txt'));

scanFolders = dir(fullfile(rootFolder, 'originals', '*__II__*'));

for m = 1:length(scanFolders)
    
    targetVoxelSize = [1 1 5];
    patientCommentEditFunc = @(x) x;
    
    sourceFolder = fullfile(scanFolders(m).folder, scanFolders(m).name);
    destinFolder = strrep(sourceFolder, 'originals','resampled');
    
    Logger.info('resampleStudy', ['Resampling ' scanFolders(m).name])
    outputInfo = resizectseries(sourceFolder, destinFolder, targetVoxelSize, patientCommentEditFunc);
    
end

