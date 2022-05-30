clear all
close all

% last 35 slices of vol1 overlap with first 35 slices of vol2
% treat vol1 as fixed and vol2 as moving

sourceFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT/scansForResampling/scans_2022.05.29_00.07.38/originals/RMH_RSRC003__II__20161117_135500_LightSpeed/scans';

vol1 = loadSingleDicomVolume(fullfile(sourceFolder, '602-CT_Thick_Axials_2_5mm'));
vol2 = loadSingleDicomVolume(fullfile(sourceFolder, '606-CT_Thick_Axials_2_5mm'));

% vol1 
i11 = find(vol1.imagePosition(3,:) == -370.25);
i12 = find(vol1.imagePosition(3,:) == -455.25);

% vol2
[~,i21] = min(abs(vol2.imagePosition(3,:) - -376.38));
[~,i22] = min(abs(vol2.imagePosition(3,:) - -461.38));

vol1crop = vol1.imageVolume(:,:,i11:i12);
vol2crop = vol2.imageVolume(:,:,i21:i22);


[optimizer, metric] = imregconfig('monomodal');

% ignore pixel spacing, and just put as all 1s
R1crop  = imref3d(size(vol1crop), 1, 1, 1);
R2crop  = imref3d(size(vol2crop), 1, 1, 1);
R2  = imref3d(size(vol2.imageVolume), 1, 1, 1);

%%
% use affine transform, but initialise using rigid as this converges more
% robustly
tformRigid = imregtform(vol2crop, R2crop, vol1crop, R1crop, 'rigid', optimizer, metric);
tform = imregtform(vol2crop, R2crop, vol1crop, R1crop, 'affine', optimizer, metric, 'InitialTransformation', tformRigid);

%%
vol2Reg = imwarp(vol2.imageVolume, tform, 'OutputView', R2);

% default fill the edges
vol2Reg(490:end,:,:) = -1024; vol2Reg(:,1:20,:) = -1024;

%%
% % check results of registration
% figure
% 
% subplot(1,2,1)
% imshowpair(vol1crop(:,:,16), vol2crop(:,:,16));
% 
% % discard first and last slices due to edge effects
% subplot(1,2,2)
% for n = 2:size(vol1crop,3)-1
%     imshowpair(vol1crop(:,:,n), vol2Reg(:,:,n));
%     pause
% end

%%

% merge with linear blend in overlap
% don't use first and last slices of registered overlap
w = reshape(linspace(1,0,size(vol1crop,3)-2),[1 1 size(vol1crop,3)-2]);
volMerged = cat(3, vol1.imageVolume(:,:,1:i11), w.*vol1crop(:,:,2:end-1) + (1-w).*vol2Reg(:,:,2:size(vol1crop,3)-1), vol2Reg(:,:,size(vol1crop,3):end));
%%
% figure
% for n = i11-5:size(volMerged,3)
%     imageQ(volMerged(:,:,n),[-200 200])
%     if n>=i11+1 && (n-i11)<length(w)
%         title(num2str(w(n-i11)))
%     end
%     pause
% end

%%
dz = vol1.imagePosition(3,2) - vol1.imagePosition(3,1);
sliceLocation = [vol1.imagePosition(3,:) vol1.imagePosition(3,end) + dz*(1:(size(volMerged,3) - size(vol1.imageVolume,3)))];

% get template header
dcmFile = dir(fullfile(sourceFolder, '602-CT_Thick_Axials_2_5mm', 'resources', 'DICOM', 'files', '*.dcm'));
info = dicominfo(fullfile(dcmFile(1).folder, dcmFile(1).name));

destinFolder = fullfile(strrep(sourceFolder, 'originals', 'merged'), '602 606 merge CT_Thick_Axials_2_5mm');
mkdir(destinFolder)

info.SeriesInstanceUID = dicomuid;
info.AcquisitionNumber = 1;
info.SeriesDescription = [info.SeriesDescription ' 602 and 606 merged'];
info.SeriesNumber = 602606;
for n = 1:size(volMerged,3)
    info.InstanceNumber = n;
    info.SOPInstanceUID = dicomuid;
    info.ImagePositionPatient(3) = sliceLocation(n);
    dicomwrite(int16(volMerged(:,:,n)-info.RescaleIntercept), fullfile(destinFolder, num2str(n,'%03d.dcm')), info);
end