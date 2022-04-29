clear variables
close all

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT/scansForResampling/scans_2022.04.28_11.06.11';

scanFolders = dir(fullfile(rootFolder, 'originals', '*__II__*'));

for m = 1:length(scanFolders)
    
    sourceFolder = fullfile(scanFolders(m).folder, scanFolders(m).name);
    destinFolder = strrep(sourceFolder, 'originals','split');
    
    splitSeriesToAcquisitions(sourceFolder, destinFolder);
    
    disp(['Completed ' scanFolders(m).name])
    
end

