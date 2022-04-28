clear variables
close all

studyFolder = '/Users/morton/Dicom Files/octapus';

folders = {'/Users/morton/Dicom Files/octapus/OCTAPUS_CHLW', ...
           '/Users/morton/Dicom Files/octapus/OCTAPUS_BARTS', ...
           '/Users/morton/Dicom Files/octapus/OCTAPUS_GSTTAB', ...
           '/Users/morton/Dicom Files/octapus/OCTAPUS_5293AB' ...
           '/Users/morton/Dicom Files/octapus/OCTAPUS_NCCID'};

for nf = 5 %1:length(folders)
    thisStudy = folders{nf};
    
    % destinStudy = fullfile(thisStudy,'experiments_Resampled');
    destinStudy = fullfile(thisStudy,'nonCompressed_Resampled');
    mkdir(destinStudy);
    
    Logger = log4m.getLogger(fullfile(thisStudy, 'resampling_logfile.txt'));
    
    % scanFolders = dir(fullfile(thisStudy, 'experiments','*__II__*'));
    scanFolders = dir(fullfile(thisStudy, 'nonCompressed','Covid*'));
    
    for m = 1:length(scanFolders)
        
        targetVoxelSize = [1 1 1];
        if nf<4 || nf==5
            patientCommentEditFunc = @(x) strrep(x, folders{nf}, [strrep(strrep(folders{nf}, 'OCTAPUS', 'OCTA'),'GSST','GST') '_1mm']);
        elseif nf==4
            %Project: OCTA_BARTS_1mm; Subject: OCTA_IO_SB_001; Session: OCTA_IO_SB_001; AA:true
            ss = strsplit(scanFolders(m).name,'__II__');
            patientCommentEditFunc = @(x) ['Project: OCTA5293AB_1mm; Subject: ' ss{1} '; Session: ' ss{2} '; AA:true'];
        end
        
        sourceFolder = fullfile(scanFolders(m).folder, scanFolders(m).name);
        destinFolder = fullfile(destinStudy, scanFolders(m).name);
        
        % direct the biggest data set to external HDD
        if nf==4
            destinFolder = strrep(destinFolder ,'/Users/morton/Dicom Files/octapus/OCTAPUS_5293AB', '/Volumes/BigBackup/OCTAPUS_5293AB');
        end
        
        Logger.info('resampleStudyAB', ['Resampling ' scanFolders(m).name])
        %try
            outputInfo = resizectseries(sourceFolder, destinFolder, targetVoxelSize, patientCommentEditFunc);
        %catch
        %    disp(['FAILED : ' scanFolders(m).name])
        %end
        
    end
end

