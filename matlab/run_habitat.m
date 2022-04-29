clear all
close all

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT';

rtsFiles = dir(fullfile(rootFolder, 'assessors/assessors_2022.04.27_20.25.16/*.dcm'));

saveOutputs = true;

if saveOutputs
    % make new folder for results
    destinFolder = [rootFolder, '/habitatAnalysis/' datestr(now,'yyyymmddHHMMss') '_habitatAnalysis'];
    mkdir(destinFolder)
    mkdir(fullfile(destinFolder, 'mat'))
    mkdir(fullfile(destinFolder, 'fig'))
    mkdir(fullfile(destinFolder, 'pdf'))
    mkdir(fullfile(destinFolder, 'code'))
    
    % copy all code scripts
    copyfile([mfilename('fullpath') '.m'], fullfile(destinFolder, 'code', [mfilename '.m']))
    otherCode = matlab.codetools.requiredFilesAndProducts([mfilename '.m']);
    for n = 1:length(otherCode)
        [~,thisFile] = fileparts(otherCode{n});
        copyfile(otherCode{n}, fullfile(destinFolder, 'code', [thisFile '.m']))
    end
    segFolder = fullfile(destinFolder, 'seg');
    mkdir(segFolder)
end


% loop over subjects
for nEval = 2 %1:length(rtsFiles)
    try
        rng(0)
        
        subjectID = strsplit(rtsFiles(nEval).name,'__II__');
        subjectID = subjectID{1};
        
        disp(['Processing ' subjectID])
        
        % find and load images and masks
        subjectScanFolder = dir(fullfile(rootFolder, 'referencedScans', [subjectID '*']));
        subjectScanFolder = subjectScanFolder(cell2mat(arrayfunQ(@(x) x.isdir, subjectScanFolder)));
        if length(subjectScanFolder) ~=1
            disp('More than one eligible scan folder found!')
            continue
        end
        
        map = sopInstanceMap(fullfile(subjectScanFolder(1).folder, subjectScanFolder(1).name));
        rts = readDicomRT(fullfile(rtsFiles(nEval).folder, rtsFiles(nEval).name), map.sopInstMap);
        
        % get lesion ROI
        keys = rts.roi.keys;
        lesionInd = cell2mat(cellfunQ(@(x) ~contains(x,'hole'), keys));
        if nnz(lesionInd)>1
            disp('More than one eligible lesion ROI')
            continue
        end
        lesionROI = rts.roi(keys{lesionInd});
        lesionSOPInstanceList = arrayfunQ(@(x) x.ReferencedSOPInstanceUID{1}, lesionROI.contour);
        % loop over hole ROIs and remove from mask slice, based on
        % matching SOPInstanceUID
        for n = find(~lesionInd)
            holeROI = rts.roi(keys{n});
            for m = 1:length(holeROI.contour)
                sliceIdx = find(strcmp(lesionSOPInstanceList, holeROI.contour(m).ReferencedSOPInstanceUID{1}));
                lesionROI.contour(sliceIdx).mask(holeROI.contour(m).mask) = false;
            end
        end
        % compose mask and image slices into volumes
        z = cell2mat(arrayfunQ(@(x) x.z(1), lesionROI.contour));
        zU = unique(z);
        mask = false([size(lesionROI.contour(1).mask) length(zU)]);
        im = zeros([size(lesionROI.contour(1).image) length(zU)]);
        for n = 1:length(zU)
            iSlices = find(z==zU(n));
            im(:,:,n) = lesionROI.contour(iSlices(1)).image;
            for m = 1:length(iSlices)
                mask(:,:,n) = mask(:,:,n) | lesionROI.contour(iSlices(m)).mask;
            end
            packSeg(n) = struct('sopInstance', lesionROI.contour(iSlices(1)).ReferencedSOPInstanceUID{1}, 'mask', mask(:,:,n));
        end

        
        
        param = struct('maxHU', 1000, ...%200, ...
            'minHU', -1000, ... %-150, ...
            'minHUdisp', -200, ...
            'maxHUdisp', 200, ...
            'maxHUstd', 30, ...
            'binWidth', 15, ...
            'meshsize', 1, ...
            'windowrad', 1, ...
            'alpha', 5e-2, ...
            'nIterations', 10, ...
            'nSamples', 5, ...
            'lambda', 1, ...
            'edgeMethod', 'standard');
        
%         skip = 1;
%         im = im(1:skip:end,1:skip:end,1:6:end); %1:skip:end);
%         mask = mask(1:skip:end,1:skip:end,1:6:end); %1:skip:end);
        
%         if saveOutputs
%             writeDicomSegsMatlab(packSeg, 'Lesion', 'Lesion', map.sopInstMap, rtsFiles(nEval).name, segFolder)
%         end
        
        if saveOutputs
            writeDicomSegsMatlab(packSeg, 'Solid', 'Solid', map.sopInstMap, rtsFiles(nEval).name, segFolder)
            return
        end
        
        showFigures = true;
        visibleFigures = true;
        [meanIm, labelIm, stdIm, numLargeRegions] = habitatSegmentation(im, mask, param, showFigures, [], visibleFigures);


        
        if showFigures
            if saveOutputs
                saveas(gcf,fullfile(destinFolder, 'fig', [subjectID '.fig']))
            end
            set(gcf,'Units','Inches');
            pos = get(gcf,'Position');
            set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
            if saveOutputs
                print(gcf,fullfile(destinFolder, 'pdf', [subjectID '.pdf']),'-dpdf','-r0')
                close
            end
        end
        
        % re-order so the slice is in the first dimension
        meanIm = shiftdim(meanIm,2);
        labelIm = shiftdim(labelIm,2);
        stdIm = shiftdim(stdIm,2);
        if saveOutputs
            save(fullfile(destinFolder, 'mat', [subjectID '.mat']),'meanIm', 'labelIm', 'numLargeRegions', 'stdIm')
        end
        
        disp(['Completed ' subjectID])
    catch ME
        disp(getReport(ME,'extended'))
    end
    disp(' ')
end