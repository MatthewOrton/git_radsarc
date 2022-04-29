function writeDicomSegsMatlab(pack, collectionLabel, roiLabel, sopInstMap, rtsFileName, segFolder)

seg = dicominfo('/Users/morton/Dicom Files/TracerX/XNAT_Collaborations_Local/SEG_template.dcm');
source = dicominfo(sopInstMap(pack(1).sopInstance).file);

% sort basic header info by copying or new values
seg.SopInstanceUID =  dicomuid;

dateNow = datestr(date,'yyyymmdd');
timeNow = datestr(datetime,'HHMMss');

seg.StudyDate = source.StudyDate;
seg.SeriesDate = dateNow;
seg.ContentDate = dateNow;
seg.StudyTime = source.StudyTime;
seg.SeriesTime = timeNow;
seg.ContentTime = timeNow;

seg.Manufacturer = source.Manufacturer;
seg.ReferringPhysicianName = '';
seg.SeriesDescription = collectionLabel;
seg.ContentLabel = collectionLabel;
seg.ManufacturerModelName = source.ManufacturerModelName;

% ReferencedSeriesSequence
seg.ReferencedSeriesSequence.Item_1.SeriesInstanceUID = source.SeriesInstanceUID;
for n = 1:length(pack)
    refInsSeq.(['Item_' num2str(n)]) = struct('ReferencedSOPClassUID', source.SOPClassUID, ...
                                              'ReferencedSOPInstanceUID', pack(n).sopInstance);
end
seg.ReferencedSeriesSequence.Item_1.ReferencedInstanceSequence = refInsSeq;

seg.PatientName = source.PatientName;
seg.PatientID = source.PatientID;
seg.PatientBirthDate = source.PatientBirthDate;
if isfield(source, 'PatientSex'), seg.PatientSex = source.PatientSex; end
if isfield(source, 'PatientAge'), seg.PatientAge = source.PatientAge; end

seg.StudyInstanceUID = source.StudyInstanceUID;
seg.SeriesInstanceUID = dicomuid;
if isfield(source, 'StudyID'), seg.StudyID = source.StudyID; end
seg.SeriesNumber = source.SeriesNumber + 42;

seg.FrameOfReferenceUID = source.FrameOfReferenceUID;

% DimensionOrganizationSequence
newDimensionOrganizationUID = dicomuid;
seg.DimensionOrganizationSequence.Item_1.DimensionOrganizationUID = newDimensionOrganizationUID;
% DimensionIndexSequence. Have experimented with this using different size
% source images and number of slices in the mask, and it appears not to
% change (other than the UID part)
seg.DimensionIndexSequence.Item_1.DimensionOrganizationUID = newDimensionOrganizationUID;
seg.DimensionIndexSequence.Item_2.DimensionOrganizationUID = newDimensionOrganizationUID;

seg.NumberOfFrames = length(pack);

% SegmentSequence % Need multiple
seg.SegmentSequence.Item_1.SegmentLabel = roiLabel;
% seg.SegmentSequence.Item_1 = 
% SegmentedPropertyCategoryCodeSequence: [1×1 struct]
%                             SegmentNumber: 1
%                              SegmentLabel: 'seg1'
%                      SegmentAlgorithmType: 'MANUAL'
%             RecommendedDisplayCIELabValue: [3×1 uint16]
%         SegmentedPropertyTypeCodeSequence: [1×1 struct]

% SharedFunctionalGroupsSequence
seg.SharedFunctionalGroupsSequence.Item_1.PlaneOrientationSequence.Item_1.ImageOrientationPatient = source.ImageOrientationPatient;
seg.SharedFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.SliceThickness = source.SliceThickness;
% not sure about this one, but seems to be the case in the template.
seg.SharedFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.SpacingBetweenSlices = source.SliceThickness;
seg.SharedFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.PixelSpacing = source.PixelSpacing;
seg.SharedFunctionalGroupsSequence.Item_1.PixelValueTransformationSequence.Item_1.RescaleIntercept = source.RescaleIntercept;
seg.SharedFunctionalGroupsSequence.Item_1.PixelValueTransformationSequence.Item_1.RescaleSlope = source.RescaleSlope;
if isfield(source,'RescaleType')
    seg.SharedFunctionalGroupsSequence.Item_1.PixelValueTransformationSequence.Item_1.RescaleType = source.RescaleType;
else
    seg.SharedFunctionalGroupsSequence.Item_1.PixelValueTransformationSequence.Item_1.RescaleType = 'US'; % unspecified
end
    

% PerFrameFunctionalGroupsSequence % Need multiple
pffgTemplate = seg.PerFrameFunctionalGroupsSequence.Item_1;
for n = 1:length(pack)
    thisSource = dicominfo(sopInstMap(pack(n).sopInstance).file);
    pffgTemplate.DerivationImageSequence.Item_1.SourceImageSequence.Item_1.ReferencedSOPInstanceUID = thisSource.SOPInstanceUID;
    pffgTemplate.DerivationImageSequence.Item_1.SourceImageSequence.Item_1.ReferencedSOPClassUID = thisSource.SOPClassUID;
    
    % Despite looking it up, I don't quite understand DimensionIndexValues, but I think putting the
    % InstanceNumber of the source image in element 2 will work...
    pffgTemplate.FrameContentSequence.Item_1.DimensionIndexValues = [1; thisSource.InstanceNumber];
    
    pffgTemplate.PlanePositionSequence.Item_1.ImagePositionPatient = thisSource.ImagePositionPatient;
    % pffgTemplate.SegmentIdentificationSequence can stay the same
    pfgs.(['Item_' num2str(n)]) = pffgTemplate;
end
seg.PerFrameFunctionalGroupsSequence = pfgs;

% write into dicomSeg.  NB. this file is not well-formed as the pixel data
% for a dicomSeg should be per bit, but this is as 8-bit integers.  Matlab
% will read this file OK, but nothing else will!
X = cell2mat(reshape(arrayfun(@(x) x.mask, pack, 'UniformOutput', false),[1 1 1 length(pack)]))==1;

segFileName = strrep(rtsFileName,'.dcm',['_' collectionLabel '.dcm']);
segFolder = fullfile(segFolder, collectionLabel);
segFile = fullfile(segFolder, segFileName);
if ~exist(segFolder,'dir')
    mkdir(segFolder)
end

dicomwrite(uint8(X), segFile, seg, 'CreateMode', 'copy');

% convert X to binary representation
X = squeeze(X);
X = permute(X,[2 1 3]);
X = X(:);
nBits = 8;
newLength = nBits*ceil(length(X)/nBits);
X = [X; false(newLength-length(X),1)];
X = reshape(X,nBits,length(X)/nBits)';
X = fliplr(X);
B = bin2dec(num2str(X));

import icr.etherj.dicom.*
import org.dcm4che2.data.*

jDcm = DicomUtils.readDicomFile(java.io.File(segFile));

jDcm.putInt(Tag.Rows, VR.US, size(pack(1).mask,1));
jDcm.putInt(Tag.Columns, VR.US, size(pack(1).mask,2));

jDcm.putInt(Tag.BitsAllocated, VR.US, uint8(1));
jDcm.putInt(Tag.BitsStored, VR.US, uint8(1));
jDcm.putInt(Tag.HighBit, VR.US, uint8(0));
jDcm.putInt(Tag.PixelRepresentation, VR.US, uint8(0));

jDcm.putBytes(Tag.PixelData, VR.OB, uint8(B));

DicomUtils.writeDicomFile(jDcm,java.io.File(segFile));

disp(['written : ' segFile])

