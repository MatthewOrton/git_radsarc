clear all
close all

global dicomwrite_KeepSOPInstanceUID 
dicomwrite_KeepSOPInstanceUID = true;

global dicomread_IgnoreOverlays
dicomread_IgnoreOverlays = true;

rootFolder = '/Volumes/Windows/radsarc/DICOM';
newRootFolder = '/Volumes/Windows/radsarc/DICOM_forUpload';

patFolders = dir(rootFolder);
patFolders = patFolders(~startsWith({patFolders.name}, '.'));
for nPat = 5 %1:length(patFolders)
    visitFolders = dir(fullfileQ(patFolders(nPat), '*Visit*'));    
    for nVisit = 1:length(visitFolders)

        scanFolders = dir(fullfileQ(visitFolders(nVisit)));
        scanFolders = scanFolders(~startsWith({scanFolders.name}, '.'));
        for nScan = 1:length(scanFolders)

            files = dir(fullfileQ(scanFolders(nScan), '*.dcm'));
            files = files(~startsWith({files.name}, '.'));

            newFolder = strrep(fullfileQ(scanFolders(nScan)), 'DICOM', 'DICOM_forUpload');
            mkdir(newFolder);

            for nFile = 1:length(files)
                info = dicominfo(fullfileQ(files(nFile)), 'UseDictionaryVR', true);
                if strcmp(info.SOPClassUID, '1.2.840.10008.5.1.4.1.1.2')
                    data = dicomread(fullfileQ(files(nFile)));
                    patID = ['EORTCRSRC_' num2str(str2double(info.PatientID), '%03d')];

                    info.PatientID = patID;
                    info.PatientName = patID;
                    
                    patientComments = ['Project: RADSARC-R; Subject: ' info.PatientID '; Session: ' visitFolders(nVisit).name ' ' info.StudyDate '; AA:True'];
                    info.PatientComments = patientComments;

                    tags = fieldnames(info);
                    privateTags = tags(startsWith(tags, 'Private'));
                    overlayTags = tags(startsWith(tags, 'Overlay'));
                    info = rmfield(info, privateTags);
                    info = rmfield(info, overlayTags);
                                        
                    dicomwrite(data, fullfile(newFolder, files(nFile).name), info, 'VR', 'explicit');

                end
            end
            disp(fullfileQ(scanFolders(nScan)))
        end
    end
end
