clear all
close all

folders = dir('/Users/morton/Dicom Files/RADSARC_R/XNAT/RMH_EORTC/experiments/RAD*');

global dicomwrite_KeepSOPInstanceUID 
dicomwrite_KeepSOPInstanceUID = true;

for n = 16:length(folders)
    files = dir(fullfile(folders(n).folder, folders(n).name, '**','*'));
    newFolder = strrep(fullfile(folders(n).folder,folders(n).name),'experiments','renamed');
    mkdir(newFolder)
    for m = 1:length(files)
        thisItem = fullfile(files(m).folder, files(m).name);
        if files(m).name(1)=='.' || isfolder(thisItem)
            continue
        end
        warning off
        info = dicominfo(thisItem);
        warning on
        data = dicomread(thisItem);

        % make PatientName and PatientID using folder name - I've already
        % checked that these are consistent with existing metadata
        oldStr = 'RADSARC-R-';
        newStr = 'EORTCRSRC_';
        info.PatientID = strrep(info.PatientID, oldStr, newStr);
        info.PatientName.FamilyName = strrep(info.PatientName.FamilyName, oldStr, newStr);

        info.PatientComments = strrep(info.PatientComments, oldStr, newStr);
        idx1 = strfind(info.PatientComments, 'Session: ');
        idx2 = strfind(info.PatientComments, '; AA:True');
        sessionStr = strsplit(info.PatientComments(idx1:idx2),' ');
        % modify Session ID to avoid clashing with existing
        info.PatientComments = [info.PatientComments(1:idx1-1) sessionStr{1} ' ' sessionStr{2} '_PR; ' info.PatientComments(idx2+1:end)];

        dicomwrite(data, fullfile(newFolder,files(m).name), info, 'VR', 'explicit');
    end
    disp(folders(n).name)
end