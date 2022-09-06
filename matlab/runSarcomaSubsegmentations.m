function runSarcomaSubsegmentations

close all force
diary('/Users/morton/Desktop/matlabDiary.txt')
diary on

showProgressBar = false;

% paths to files
rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT';

tbl = readtable('/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/SubRegionsPresent.xlsx', 'VariableNamingRule', 'preserve');
tbl.Properties.VariableNames = regexprep(tbl.Properties.VariableNames, ' ', '_');

maps = getSopInstMaps(false);

regions = {'lesion', 'repro'}; %

outputFolder = makeOutputFoldersCopyCode(regions);

for r = 1:length(regions)

    % get list of patient IDs
    sourceFolder = fullfile('assessors', 'assessors_2022.09.01_11.19.46', regions{r});
    rtsFiles = dir(fullfile(rootFolder, sourceFolder, '*.dcm'));
    rtsFilesHere = arrayfunQ(@(x) x.name, rtsFiles);
    patIDs = cellfunQ(@(x) strsplitN(x, '__II__', 1), rtsFilesHere);
    patIDs = {'RMH_RSRC072'};
    
    % default prior settings - may be overwridden by patientSpecificSettings()
    defaultPrior.mu_mu = [-80; -10; NaN; 200];
    defaultPrior.mu_sigma = [1 3 0.01 1].^2;
    defaultPrior.sigma_mu = [16 14 NaN 20].^2;
    defaultPrior.sigma_cov = [0.01 0.02 0.001 0.02];
    defaultPrior.alpha = [1 1 1 1];
    defaultPrior.sigmaLimits.high = [25 25 25 25].^2;
    defaultPrior.sigmaLimits.low = [10 10 10 10].^2;
    defaultPrior.dediffThresholdFactor = 1.5;
    defaultPrior.dataPercentileThresholds = [0.5 99.5];
    defaultPrior.calcificationThreshold = 190;
    defaultPrior.apply2Dtidying = false;
    defaultPrior.signalLow = -200;
    defaultPrior.signalHigh = 350;
    defaultPrior.imageSmoothingWidth = false;
    defaultPrior.removeOnlyJustConnectedComponents = true;

    % Load in a whole lot of patient specific settings that are needed to make
    % specific cases sub-segment correctly.  Will also return default
    % values for remaining patients.
    patientSettings = patientSpecificSettings(patIDs, defaultPrior);

    for nRts = 1:length(patIDs)

        disp(patIDs{nRts})
        try

            tblRow = find(cell2mat(cellfunQ(@(x) strcmp(x, patIDs{nRts}), tbl.Patient_ID)));

            if isempty(tbl.("First_round_sub-seg"){tblRow}) && (tbl.("number_of_sub-regions")(tblRow) == 1)
                disp('Only one sub-region')
                disp(' ')
                onlyLoadData = true;
            else
                onlyLoadData = false;
            end

            % find dediff rts file
            dediffRts = dir(fullfile(strrep(rtsFiles(1).folder,regions{r},'dediff'),[patIDs{nRts} '*.dcm']));

            thisLesionRts = dir(fullfile(rtsFiles(1).folder,[patIDs{nRts} '*.dcm']));
            disp(thisLesionRts.folder)
            disp(thisLesionRts.name)

            patientSettingsHere = patientSettings(patIDs{nRts});

            [masks, roi, dediffProbe, prior, gmm] = sarcomaSubsegmentor(thisLesionRts, onlyLoadData, dediffRts, maps.sopInstMap, patientSettingsHere.prior, showProgressBar);
            if onlyLoadData
                masks(:) = false;
                maskInd = [strcmp(tbl.low_enhancing{tblRow},'x') ...
                    strcmp(tbl.mid_enhancing{tblRow},'x') ...
                    strcmp(tbl.high_enhancing{tblRow},'x')];
                if nnz(maskInd)==0
                    disp('No sub-regions indicated for mask!')
                    continue
                end
                if nnz(maskInd)>1
                    disp('More than one sub-region indicated for mask!')
                    continue
                end
                masks(:,:,:,maskInd) = roi.mask;

            else
                masks = applyCorrections(patientSettingsHere, masks);
            end

            % put '.ext' and replace for each output file type
            outputFilename = fullfile(outputFolder, regions{r}, 'ext', strrep(thisLesionRts.name,'.dcm','.ext'));

            % save pdf and fig files
            saveFigFile = true;
            writeThumbnailImage(outputFilename, thisLesionRts, saveFigFile);

            % save matlab variables
            % roi contains java objects that we can't save as a .mat file,
            % so extract the image data, and save the location of the
            % rts file that was used, and we can re-create roi after if we
            % needed to
            im = roi.im;
            rtsFileName = fullfile(thisLesionRts.folder, thisLesionRts.name);
            save(strrep(outputFilename,'ext','mat'), 'rtsFileName', 'masks', 'im', 'gmm', 'prior')

            % save as seg file
            packageAndWriteDicomSeg('lesion_four_subregions', roi, masks, outputFilename, maps);

            disp(' ')


        catch exception
            disp(' ')
            disp('_______________')
            disp(getReport(exception))
            disp('_______________')
            disp(' ')
        end
    end
end
diary off

%%%%%%%%%%%%%%%
    function packageAndWriteDicomSeg(structureSetLabel, roi, masks, outputFilename, maps)

    fprintf('Writing DICOM SEG file ...')

    for m = 1:length(roi.refSopInst)
        packageLesion(m) = struct('image',roi.im(:,:,m), 'mask', roi.mask(:,:,m), 'sopInstance', roi.refSopInst{m});
    end

    packageSubRegions = cell(1,4);
    for mSubRegion = 1:4
        packageSubRegions{mSubRegion} = packageLesion;
        for nSlice = 1:size(masks,3)
            packageSubRegions{mSubRegion}(nSlice).mask = double(masks(:,:,nSlice,mSubRegion) & roi.mask(:,:,nSlice));
        end
    end


    % package up all masks into one cell array/structure
    package{1} = struct('data', packageLesion, 'label', 'lesion');
    package{2} = struct('data', packageSubRegions{1}, 'label', 'low enhancing');
    package{3} = struct('data', packageSubRegions{2}, 'label', 'mid enhancing');
    package{4} = struct('data', packageSubRegions{3}, 'label', 'high enhancing');
    package{5} = struct('data', packageSubRegions{4}, 'label', 'calcification');

    segFileName = strrep(outputFilename, 'ext', 'seg');
    segFileName = strrep(segFileName,'.seg','_SEG_sarcoma.dcm');

    writeDicomSegsMatlab(package, structureSetLabel, maps.sopInstMap, segFileName);
    fprintf(' done\n')
    disp(['Written ' segFileName])

    end
%%%%%%%%%%%%%%%
    function outputFolder = makeOutputFoldersCopyCode(regions)

    outputFolder = fullfile(rootFolder,'subsegmentationAnalysis',['outputs_' datestr(datetime('now'),'yyyymmdd_HHMM')]);
    if ~exist(outputFolder,'dir')
        mkdir(outputFolder)
        mkdir(fullfile(outputFolder,'code'))
        for rr = 1:length(regions)
            mkdir(fullfile(outputFolder, regions{rr},'pdf'))
            mkdir(fullfile(outputFolder, regions{rr},'fig'))
            mkdir(fullfile(outputFolder, regions{rr},'mat'))
            mkdir(fullfile(outputFolder, regions{rr},'seg'));
        end
        % copy all code scripts
        copyfile([mfilename('fullpath') '.m'], fullfile(outputFolder, 'code', [mfilename '.m']))
        otherCode = matlab.codetools.requiredFilesAndProducts([mfilename '.m']);
        for nn = 1:length(otherCode)
            [~,thisFile] = fileparts(otherCode{nn});
            copyfile(otherCode{nn}, fullfile(outputFolder, 'code', [thisFile '.m']))
        end
    end

    end



%%%%%%%%%%%%%%%%
    function maps = getSopInstMaps(refresh)

    quickLoadMap = fullfile(rootFolder, 'sopInstanceMap.mat');
    if exist(quickLoadMap,'file') && ~refresh
        load(quickLoadMap, 'maps')
    else
        maps = sopInstanceMap(fullfile(rootFolder, 'referencedScans'));
        save(quickLoadMap, 'maps')
    end

    end



%%%%%%%%%%%%%%%%
    function writeThumbnailImage(outputFilename, thisLesionRts, saveFigFile)

    disp('Making figure')

    % plotting range for histograms
    x = linspace(-200,200,200);

    figure('position',[1    76  2560  1261], 'Visible','off')

    % get bounding box for whole volume
    flatMask = sum(roi.mask,3)>0;
    cols = find(sum(flatMask));
    rows = find(sum(flatMask,2));
    ax = [cols(1)-15 cols(end)+15 rows(1)-15 rows(end)+15];

    % draw each thumbnail with sub-segmentation mask boundaries
    for nn = 1:size(roi.im,3)

        [~,rr] = subplotQ(size(roi.im,3)+2, nn);

        if nn==1
            % matlab bug causes axes to change size/position when
            % colorbar is called
            pos = get(gca,'position');
            cb = colorbar;
            set(gca,'position',pos)
            cb.Label.String = 'HU    ';
            cb.Label.Rotation = 0;
            cb.Location = 'westoutside';
            cb.FontSize = 12;
        end

        imagesc(roi.im(:,:,nn),[-135 215])
        colormap gray
        axis equal tight off
        hold on

        pos = GetPixellatedROI(imdilate(any(masks(:,:,nn,:),4),strel('disk',1)));
        plot(pos(1,:),pos(2,:), 'w', 'LineWidth', 250/(ax(2)-ax(1))) % 'color', [0 0.65 0],
        set(gca,'ColorOrderIndex',1)
        for mm = 1:4
            % erode mask so the bordering boundary lines don't overlap
            pos = GetPixellatedROI(imerode(masks(:,:,nn,mm),strel('disk',1)));
            plot(pos(1,:),pos(2,:), 'LineWidth', 200/(ax(2)-ax(1)))
        end

        text(0,0,num2str(nn), 'Units','normalized', 'BackgroundColor','w', 'VerticalAlignment','bottom', 'FontSize',12);

        axis(ax)

        % draw probe ROI on appropriate slice
        if ~isempty(dediffProbe)
            dediffProbeIdx = find(dediffProbe.sliceIndex==nn);
            for dd = dediffProbeIdx
                posDediff = GetPixellatedROI(dediffProbe.mask(:,:,dd));
                plot(posDediff(1,:),posDediff(2,:),'c')
            end
            if ~isempty(dediffProbeIdx)
                ax = axis;
                plot([ax(1) ax(2) ax(2) ax(1) ax(1)], [ax(3) ax(3) ax(4) ax(4) ax(3)], 'r', 'LineWidth', 3)
            end
        end

    end

    % move axes to be closer to each other
    allAxes = findobj(gcf,'Type','axes');
    width_x = allAxes(1).Position(3);
    width_y = allAxes(1).Position(4);
    gap_x = mean(diff(unique(cell2mat(arrayfunQ(@(x) x.Position(1), allAxes)))));
    yPosU = unique(cell2mat(arrayfunQ(@(x) x.Position(2), allAxes)));
    if length(yPosU)==1
        gap_y = width_y;
    else
        gap_y = mean(diff(yPosU));
    end
    scale_x = 1.05*width_x/gap_x;
    scale_y = 1.05*width_y/gap_y;
    % scale axes with 0.5,0.5 as a fixed point
    for nn = 1:length(allAxes)
        allAxes(nn).Position(1:2) = 0.5 + (allAxes(nn).Position(1:2) - 0.5).*[scale_x scale_y];
    end

    % Plot histogram and class distributions

    % get this subplot positioned correctly
    xLoc = sort(unique(cell2mat(arrayfunQ(@(x) x.Position(1), allAxes))), 'descend');
    sp = subplot(rr(1), rr(2), rr(1)*rr(2)-[1 0]);
    sp.Position(1) = xLoc(2);
    sp.Position(2) = 0.5 + (sp.Position(2) - 0.5)*scale_y;
    sp.Position(3) = xLoc(1) + width_x - xLoc(2);

    % Histogram of raw pixel values
    pixels = roi.im(roi.mask);
    h = histogram(pixels(pixels>x(1) & pixels<x(end)));
    binEdges = h.BinEdges;
    histogram(pixels, 'BinEdges', [binEdges Inf], 'Normalization','countdensity', 'EdgeColor', 'none');
    hold on
    PreviousColor


    % Kernel smoothed distributions for each class
    BW = 5;
    regionName = {'low enhancing', 'mid enhancing', 'high enhancing','calcification'};
    lineWidth = 1.5;
    for mm = 1:4
        pixelsH = roi.im(masks(:,:,:,mm));
        if length(pixelsH)>1
            fr = ksdensity(pixelsH, x, 'Bandwidth', BW);
            plot(x,fr*nnz(roi.mask & masks(:,:,:,mm)), 'DisplayName', regionName{mm}, 'LineWidth', lineWidth);
        else
            % plot nothing so the ColorOrderIndex increments
            plot(x(1:2), x(1:2), 'DisplayName', regionName{mm}, 'LineWidth', lineWidth);
        end
    end
    set(legend(flipud(findobj(gca,'Type','line')), 'Location', 'best'),'color','none', 'FontSize',8)
    axis tight
    ylim(ylim.*[0 1.5])
    hold off
    xlabel('HU')
    set(gca,'YTick',[])

    set(gcf,'color','w')
    titleStr = strrep(strrep(thisLesionRts.name,'__II__','   '),'.dcm','');

    % don't use sgtitle as it's difficult to move it to account for
    % squeezing the subplots together
    allAxes = findobj(gcf,'Type','axes');
    ann_yPos = max(cell2mat(arrayfunQ(@(x) x.Position(2), allAxes))) + allAxes(1).Position(4);
    annotation('textbox', [0.5, ann_yPos, 0, 0], 'string', titleStr, 'FontSize',18, 'FitBoxToText','on', 'EdgeColor','none', 'Interpreter','none', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

    drawnow

    fprintf('Writing .pdf ...')
    exportPdf(gcf, strrep(outputFilename,'ext','pdf'))
    fprintf(' done\n')

    if saveFigFile
        fprintf('Writing .fig ...')
        saveas(gcf, strrep(outputFilename,'ext','fig'))
        fprintf(' done\n')
    end

    close

    end

%%%%%%%%%%%%%%%%
    function maskHoles = getMaskHolesAgainstBackground(mask, backgroundMask)

    mask(~backgroundMask) = true;
    maskHoles = imfill(mask,'holes') & ~mask;
    maskHoles(~backgroundMask) = false;

    end

%%%%%%%%%%%%%%%%
    function masksHere = applyCorrections(patSet, masksHere)

    % turn myxoid to dediff
    if patSet.convert_myxoid_to_dediff
        maskDeDiff = masksHere(:,:,:,3);
        maskMyxoid = masksHere(:,:,:,2);
        maskDeDiff(maskMyxoid) = true;
        masksHere(:,:,:,3) = maskDeDiff;
        masksHere(:,:,:,2) = false;
    end


    % set dediff to the probe ROI and set any dediff areas from
    % auto-segmentation that don't overlap with the probe to myxoid
    if patSet.exact_probe_dediff
        probeMask = false(size(roi.mask));
        for idx = 1:length(dediffProbe.sliceIndex)
            thisSlice = dediffProbe.sliceIndex(idx);
            probeMask(:,:,thisSlice) = dediffProbe.mask(:,:,idx);
        end
        maskMyxoid = masksHere(:,:,:,2);
        maskMyxoid(masksHere(:,:,:,3) & ~probeMask) = true;
        maskMyxoid(probeMask) = false;
        masksHere(:,:,:,2) = maskMyxoid;
        masksHere(:,:,:,3) = probeMask;
    end


    % merge myxoid and dediff regions into dediff
    if patSet.merge_myxoid_dediff
        masksHere(:,:,:,3) = masksHere(:,:,:,3) | masksHere(:,:,:,2);
        masksHere(:,:,:,2) = false;
    end

    % merge myxoid and dediff regions into dediff
    if patSet.merge_dediff_myxoid
        masksHere(:,:,:,2) = masksHere(:,:,:,2) | masksHere(:,:,:,3);
        masksHere(:,:,:,3) = false;
    end


    % post-process to only keep the probe dediff region and switch any
    % other dediff regions to myxoid
    if patSet.only_probe_dediff
        maskMyx = masksHere(:,:,:,2);
        maskDediff = masksHere(:,:,:,3);
        DD = bwconncomp(maskDediff, 18); % connection excludes 3D corners
        testMask = false(size(maskDediff));
        overlapArea = zeros(1, length(DD.PixelIdxList));
        for k = 1:length(DD.PixelIdxList)
            testMask(:) = false;
            testMask(DD.PixelIdxList{k}) = true;
            thisOverlapArea = 0;
            for ddp = 1:length(dediffProbe.sliceIndex)
                thisOverlapArea = thisOverlapArea + nnz(testMask(:,:,dediffProbe.sliceIndex(ddp)) & dediffProbe.mask(:,:,ddp));
            end
            overlapArea(k) = thisOverlapArea;
        end
        idxOverlap = find(overlapArea>0);
        idxToMyx = setdiff(1:length(DD.PixelIdxList), idxOverlap);
        maskIdxToMyx = cell2mat(DD.PixelIdxList(idxToMyx)');
        maskMyx(maskIdxToMyx) = true;
        maskDediff(maskIdxToMyx) = false;
        masksHere(:,:,:,2) = maskMyx;
        masksHere(:,:,:,3) = maskDediff;
    end


    % post-process to only keep a specified number of the largest dediff regions
    if patSet.number_largest_dediff
        maskMyx = masksHere(:,:,:,2);
        maskDediff = masksHere(:,:,:,3);
        DD = bwconncomp(maskDediff);
        [~, idx] = sort(cellfun(@length, DD.PixelIdxList),'descend');
        idxToMyx = cell2mat(DD.PixelIdxList(idx(patSet.number_largest_dediff+1:end))');
        maskMyx(idxToMyx) = true;
        maskDediff(idxToMyx) = false;
        masksHere(:,:,:,2) = maskMyx;
        masksHere(:,:,:,3) = maskDediff;
    end

    % post-process to only keep a specified number of the largest
    % myxoid regions, set the others to well-diff
    if patSet.number_largest_myxoid
        maskMyx = masksHere(:,:,:,2);
        maskWelldiff = masksHere(:,:,:,1);
        CC = bwconncomp(maskMyx);
        [~, idx] = sort(cellfun(@length, CC.PixelIdxList),'descend');
        idxToWellDiff = cell2mat(CC.PixelIdxList(idx(patSet.number_largest_myxoid+1:end))');
        maskWelldiff(idxToWellDiff) = true;
        maskMyx(idxToWellDiff) = false;
        masksHere(:,:,:,2) = maskMyx;
        masksHere(:,:,:,1) = maskWelldiff;
    end

    % post-process to fill in all holes in dediff mask (other than calcifications) and remove them from
    % whichever other mask they were in
    if patSet.fill_dediff
        dediffMaskHole = false(size(masksHere));
        % do this with a loop because imfill either has a bug when
        % doing in 3D, or I'm misunderstanding it.
        for k = 1:size(masksHere,3)
            dediffMaskHole(:,:,k) = imfill(masksHere(:,:,k,3),'holes') & ~masksHere(:,:,k,3) & ~masksHere(:,:,k,4);
        end
        for mm = 1:3 % leave calcification mask alone
            maskH = masksHere(:,:,:,mm);
            maskH(dediffMaskHole) = (mm==3);
            masksHere(:,:,:,mm) = maskH;
        end
        % make sure dediff hasn't stolen any calcifications
        masksDediff = masksHere(:,:,:,3);
        masksCalc = masksHere(:,:,:,4);
        masksDediff(masksCalc) = false;
        masksHere(:,:,:,3) = masksDediff;

    end

    % post-process to make whole mask dediff
    if patSet.all_dediff
        maskDediff = any(masksHere,4);
        masksHere(:) = false;
        masksHere(:,:,:,3) = maskDediff;
    end

    % turn well diff to myxoid
    if patSet.convert_welldiff_to_myxoid
        maskWellDiff = masksHere(:,:,:,1);
        maskMyxoid = masksHere(:,:,:,2);
        maskMyxoid(maskWellDiff) = true;
        masksHere(:,:,:,2) = maskMyxoid;
        masksHere(:,:,:,1) = false;
    end

    % switch small dediff regions to myxoid
    if patSet.minPixelCount_dediff_to_myxoid_per_slice

        for mm = 1:size(masksHere,3)
            maskDeDiff = masksHere(:,:,mm,3);
            maskMyxoid = masksHere(:,:,mm,2);
            CC = bwconncomp(maskDeDiff);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_dediff_to_myxoid_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskDeDiff(pixelIdx) = false;
            maskMyxoid(pixelIdx) = true;
            masksHere(:,:,mm,3) = maskDeDiff;
            masksHere(:,:,mm,2) = maskMyxoid;
        end

    end


    % keep biggest dediff region and biggest myxoid region and swap the
    % smaller regions between the two
    if patSet.number_largest_dediff_and_myxoid
        maskMyx = masksHere(:,:,:,2);
        maskDediff = masksHere(:,:,:,3);
        CCmyx = bwconncomp(maskMyx);
        CCdd  = bwconncomp(maskDediff);

        [~, idxDd] = sort(cellfun(@length, CCdd.PixelIdxList));
        for mm = 1:length(idxDd) - patSet.number_largest_dediff_and_myxoid(1)
            jdx = CCdd.PixelIdxList{idxDd(mm)};
            maskDediff(jdx) = false;
            maskMyx(jdx) = true;
        end

        [~, idxMyx] = sort(cellfun(@length, CCmyx.PixelIdxList));
        for mm = 1:length(idxMyx) - patSet.number_largest_dediff_and_myxoid(2)
            jdx = CCmyx.PixelIdxList{idxMyx(mm)};
            maskMyx(jdx) = false;
            maskDediff(jdx) = true;
        end

        masksHere(:,:,:,2) = maskMyx;
        masksHere(:,:,:,3) = maskDediff;
    end

    % turn myxoid to well diff
    if patSet.convert_myxoid_to_welldiff
        maskWellDiff = masksHere(:,:,:,1);
        maskMyxoid = masksHere(:,:,:,2);
        maskWellDiff(maskMyxoid) = true;
        masksHere(:,:,:,1) = maskWellDiff;
        masksHere(:,:,:,2) = false;
    end

    % switch small well-diff regions to myxoid
    if patSet.minPixelCount_welldiff_to_myxoid_per_slice

        for mm = 1:size(masksHere,3)
            maskWellDiff = masksHere(:,:,mm,1);
            maskMyxoid = masksHere(:,:,mm,2);
            CC = bwconncomp(maskWellDiff);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_welldiff_to_myxoid_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskWellDiff(pixelIdx) = false;
            maskMyxoid(pixelIdx) = true;
            masksHere(:,:,mm,1) = maskWellDiff;
            masksHere(:,:,mm,2) = maskMyxoid;
        end

    end


    % switch small myxoid regions to well-diff
    if patSet.minPixelCount_myxoid_to_welldiff_per_slice

        for mm = 1:size(masksHere,3)
            maskMyxoid = masksHere(:,:,mm,2);
            maskWellDiff = masksHere(:,:,mm,1);
            CC = bwconncomp(maskMyxoid);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_myxoid_to_welldiff_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskMyxoid(pixelIdx) = false;
            maskWellDiff(pixelIdx) = true;
            masksHere(:,:,mm,1) = maskWellDiff;
            masksHere(:,:,mm,2) = maskMyxoid;
        end

    end

    if patSet.lowThresholdMyxoidToWellDiff

        threshold = patSet.lowThresholdMyxoidToWellDiff;
        maskMyxoid = masksHere(:,:,:,2);
        CC = bwconncomp(maskMyxoid, 8);
        CCmean = cell2mat(cellfunQ(@(x) mean(roi.im(x)), CC.PixelIdxList));
        maskMyxoid(cell2mat(CC.PixelIdxList(CCmean < threshold)')) = false;
        maskWellDiff = masksHere(:,:,:,1);
        maskWellDiff(cell2mat(CC.PixelIdxList(CCmean < threshold)')) = true;
        masksHere(:,:,:,1) = maskWellDiff;
        masksHere(:,:,:,2) = maskMyxoid;

    end

    if patSet.lowThresholdCalcToDediff

        threshold = patSet.lowThresholdCalcToDediff;
        maskCalc = masksHere(:,:,:,4);
        CC = bwconncomp(maskCalc, 8);
        CCmean = cell2mat(cellfunQ(@(x) mean(roi.im(x)), CC.PixelIdxList));
        maskCalc(cell2mat(CC.PixelIdxList(CCmean < threshold)')) = false;
        maskDeDiff = masksHere(:,:,:,3);
        maskDeDiff(cell2mat(CC.PixelIdxList(CCmean < threshold)')) = true;
        masksHere(:,:,:,3) = maskDeDiff;
        masksHere(:,:,:,4) = maskCalc;

    end


    if patSet.highThresholdMyxoidToDeDiff_per_slice

        threshold = patSet.highThresholdMyxoidToDeDiff_per_slice;
        for mm = 1:size(masksHere,3)
            maskMyxoid = masksHere(:,:,mm,2);
            CC = bwconncomp(maskMyxoid, 8);
            imHere = roi.im(:,:,mm);
            CC10prct = cell2mat(cellfunQ(@(x) prctile(imHere(x),10), CC.PixelIdxList));
            maskMyxoid(cell2mat(CC.PixelIdxList(CC10prct > threshold)')) = false;
            maskDeDiff = masksHere(:,:,mm,3);
            maskDeDiff(cell2mat(CC.PixelIdxList(CC10prct > threshold)')) = true;
            masksHere(:,:,mm,3) = maskDeDiff;
            masksHere(:,:,mm,2) = maskMyxoid;
        end

    end

    if patSet.highThresholdWellDiffToMyxoid_per_slice

        threshold = patSet.highThresholdWellDiffToMyxoid_per_slice;
        for mm = 1:size(masksHere,3)
            maskWellDiff = masksHere(:,:,mm,1);
            CC = bwconncomp(maskWellDiff, 8);
            imHere = roi.im(:,:,mm);
            CC10prct = cell2mat(cellfunQ(@(x) prctile(imHere(x),10), CC.PixelIdxList));
            maskWellDiff(cell2mat(CC.PixelIdxList(CC10prct > threshold)')) = false;
            maskMyxoid = masksHere(:,:,mm,2);
            maskMyxoid(cell2mat(CC.PixelIdxList(CC10prct > threshold)')) = true;
            masksHere(:,:,mm,2) = maskMyxoid;
            masksHere(:,:,mm,1) = maskWellDiff;
        end

    end

    % fill small holes in welldiff
    if patSet.minPixelCount_welldiff_hole_fill_per_slice_including_calcif

        for mm = 1:size(masksHere,3)
            maskWellDiff = masksHere(:,:,mm,1);
            % make sure small regions that are on the edge of the
            % welldiff mask are counted as holes
            maskWellDiffHoles = getMaskHolesAgainstBackground(maskWellDiff, roi.mask(:,:,mm));
            maskWellDiffHoles = maskWellDiffHoles | getMaskHolesAgainstBackground(maskWellDiff, masksHere(:,:,mm,2));
            maskWellDiffHoles = maskWellDiffHoles | getMaskHolesAgainstBackground(maskWellDiff, masksHere(:,:,mm,3));
            CC = bwconncomp(maskWellDiffHoles);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_welldiff_hole_fill_per_slice_including_calcif, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskWellDiff(pixelIdx) = true;
            masksHere(:,:,mm,1) = maskWellDiff;
            for kk = 2:4
                thisMask = masksHere(:,:,mm,kk);
                thisMask(pixelIdx) = false;
                masksHere(:,:,mm,kk) = thisMask;
            end
        end

    end

    % fill small holes in myxoid
    if patSet.minPixelCount_myxoid_hole_fill_per_slice_including_calcif

        for mm = 1:size(masksHere,3)
            maskMyxoid = masksHere(:,:,mm,2);
            maskMyxoidHoles = getMaskHolesAgainstBackground(maskMyxoid, roi.mask(:,:,mm));
            maskMyxoidHoles = maskMyxoidHoles | getMaskHolesAgainstBackground(maskMyxoid, masksHere(:,:,mm,1));
            maskMyxoidHoles = maskMyxoidHoles | getMaskHolesAgainstBackground(maskMyxoid, masksHere(:,:,mm,3));
            CC = bwconncomp(maskMyxoidHoles);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_myxoid_hole_fill_per_slice_including_calcif, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskMyxoid(pixelIdx) = true;
            masksHere(:,:,mm,2) = maskMyxoid;
            for kk = [1 3 4]
                thisMask = masksHere(:,:,mm,kk);
                thisMask(pixelIdx) = false;
                masksHere(:,:,mm,kk) = thisMask;
            end
        end

    end

    % fill small holes in welldiff
    if patSet.minPixelCount_welldiff_hole_fill_per_slice

        for mm = 1:size(masksHere,3)
            maskWellDiff = masksHere(:,:,mm,1);
            % make sure small regions that are on the edge of the
            % welldiff mask are counted as holes
            maskWellDiffHoles = getMaskHolesAgainstBackground(maskWellDiff, roi.mask(:,:,mm));
            maskWellDiffHoles = maskWellDiffHoles | getMaskHolesAgainstBackground(maskWellDiff, masksHere(:,:,mm,2));
            maskWellDiffHoles = maskWellDiffHoles | getMaskHolesAgainstBackground(maskWellDiff, masksHere(:,:,mm,3));
            CC = bwconncomp(maskWellDiffHoles);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_welldiff_hole_fill_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskWellDiff(pixelIdx) = true;
            % keep any calcifications
            maskWellDiff(masksHere(:,:,mm,4)) = false;
            masksHere(:,:,mm,1) = maskWellDiff;
            for kk = 2:3
                thisMask = masksHere(:,:,mm,kk);
                thisMask(pixelIdx) = false;
                masksHere(:,:,mm,kk) = thisMask;
            end
        end

    end

    % fill small holes in dediff
    if patSet.minPixelCount_dediff_hole_fill_per_slice

        for mm = 1:size(masksHere,3)
            maskDeDiff = masksHere(:,:,mm,3);
            maskDeDiffHoles = getMaskHolesAgainstBackground(maskDeDiff, roi.mask(:,:,mm));
            maskDeDiffHoles = maskDeDiffHoles | getMaskHolesAgainstBackground(maskDeDiff, masksHere(:,:,mm,1));
            maskDeDiffHoles = maskDeDiffHoles | getMaskHolesAgainstBackground(maskDeDiff, masksHere(:,:,mm,2));
            CC = bwconncomp(maskDeDiffHoles);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_dediff_hole_fill_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskDeDiff(pixelIdx) = true;
            % keep any calcifications
            maskDeDiff(masksHere(:,:,mm,4)) = false;
            masksHere(:,:,mm,3) = maskDeDiff;
            for kk = 1:2
                thisMask = masksHere(:,:,mm,kk);
                thisMask(pixelIdx) = false;
                masksHere(:,:,mm,kk) = thisMask;
            end
        end

    end

    % fill small holes in myxoid
    if patSet.minPixelCount_myxoid_hole_fill_per_slice

        for mm = 1:size(masksHere,3)
            maskMyxoid = masksHere(:,:,mm,2);
            maskMyxoidHoles = getMaskHolesAgainstBackground(maskMyxoid, roi.mask(:,:,mm));
            maskMyxoidHoles = maskMyxoidHoles | getMaskHolesAgainstBackground(maskMyxoid, masksHere(:,:,mm,1));
            maskMyxoidHoles = maskMyxoidHoles | getMaskHolesAgainstBackground(maskMyxoid, masksHere(:,:,mm,3));
            CC = bwconncomp(maskMyxoidHoles);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_myxoid_hole_fill_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskMyxoid(pixelIdx) = true;
            % keep any calcifications
            maskMyxoid(masksHere(:,:,mm,4)) = false;
            masksHere(:,:,mm,2) = maskMyxoid;
            for kk = [1 3]
                thisMask = masksHere(:,:,mm,kk);
                thisMask(pixelIdx) = false;
                masksHere(:,:,mm,kk) = thisMask;
            end
        end

    end

    if patSet.maxImageValue_welldiff
        maskWellDiff = masksHere(:,:,:,1);
        maskMyxoid = masksHere(:,:,:,2);
        CC = bwconncomp(maskWellDiff);
        idx = cell2mat(cellfunQ(@(x) median(roi.im(x)), CC.PixelIdxList)) >= patSet.maxImageValue_welldiff;
        pixelIdx = cell2mat(CC.PixelIdxList(idx)');
        maskWellDiff(pixelIdx) = false;
        maskMyxoid(pixelIdx) = true;
        masksHere(:,:,:,1) = maskWellDiff;
        masksHere(:,:,:,2) = maskMyxoid;
    end

    if patSet.exact_probe_dediff_no_well_diff
        masksHere = false(size(masksHere));
        masksHere(:,:,:,2) = roi.mask;
        for idx = 1:length(dediffProbe.sliceIndex)
            thisSlice = dediffProbe.sliceIndex(idx);
            masksHere(:,:,thisSlice,3) = dediffProbe.mask(:,:,idx);
            maskMyxoid = masksHere(:,:,thisSlice,2);
            maskMyxoid(dediffProbe.mask(:,:,idx)) = false;
            masksHere(:,:,thisSlice,2) = maskMyxoid;
        end
    end

    if patSet.exact_probe_dediff_no_myxoid
        masksHere = false(size(masksHere));
        masksHere(:,:,:,1) = roi.mask;
        for idx = 1:length(dediffProbe.sliceIndex)
            thisSlice = dediffProbe.sliceIndex(idx);
            masksHere(:,:,thisSlice,3) = dediffProbe.mask(:,:,idx);
            maskWellDiff = masksHere(:,:,thisSlice,1);
            maskWellDiff(dediffProbe.mask(:,:,idx)) = false;
            masksHere(:,:,thisSlice,1) = maskWellDiff;
        end
    end

    if patSet.minPixelCount_myxoid_to_dediff_per_slice

        for mm = 1:size(masksHere,3)
            maskMyxoid = masksHere(:,:,mm,2);
            maskDeDiff = masksHere(:,:,mm,3);
            CC = bwconncomp(maskMyxoid);
            idx = cell2mat(cellfunQ(@(x) length(x)<patSet.minPixelCount_myxoid_to_welldiff_per_slice, CC.PixelIdxList));
            pixelIdx = cell2mat(CC.PixelIdxList(idx)');
            maskMyxoid(pixelIdx) = false;
            maskDeDiff(pixelIdx) = true;
            masksHere(:,:,mm,3) = maskDeDiff;
            masksHere(:,:,mm,2) = maskMyxoid;
        end

    end



    end

end