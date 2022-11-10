function [masks, roi, dediffProbe, prior, gmm, vesselMask] = sarcomaSubsegmentor(rtsFile, onlyLoadData, dediffRts, sopInstMap, prior, showProgressBar)

% load image and mask and dediff probe
[roi, dediffProbe, vesselMask] = loadData;

if onlyLoadData
    masks = repmat(roi.mask,[1 1 1 4]);
    prior = [];
    gmm = [];
    return
end

skip = 1 + 0*ceil(size(roi.im,3)/14); roi.im = roi.im(:,:,1:skip:end); roi.mask = roi.mask(:,:,1:skip:end); smoothedThreshold(roi.im, [-200 200], roi.mask); return

% % %dediffProbe.mask = dediffProbe.mask(:,:,2);
% dediffProbe.sliceIndex = 20;

% smooth image a little to avoid too many spurious regions when making masks
if prior.imageSmoothingWidth
    imForFitting = imgaussfilt(roi.im, prior.imageSmoothingWidth);
else
    imForFitting = roi.im;
end

% fit Bayesian Gaussian mixture model using prior to soft-constrain the class statistics
[gmm, prior] = fitBayesianGMM(prior, imForFitting, roi.mask, dediffProbe);
% disp(' ')
% disp(gmm.mu(:)')
% disp(sqrt(gmm.Sigma(:))')
% disp(gmm.ComponentProportion)
% disp(' ')

% get initial version of sub-region masks from gmm fit
[masks,prob] = getMasksFromGMM(gmm, imForFitting, roi.mask, dediffProbe);
% masks1 = masks(:,:,:,1);
% masks2 = masks(:,:,:,2);
% masks3 = masks(:,:,:,3);
% masks4 = masks(:,:,:,4);
% volumeViewer
n = 1;
m = 1;
k=0;

% figure('position',[130   407  2258   697])
% k = 0;
% for m = 1:4
%     for n = 1:4
%         k = k + 1;
%         subplot(4,4,k)
%         imageQ(masks(:,:,n,m))
%     end
% end
% pause
% close
% % 
% figure('position',[130   407  2258   697])
% subplot(1,3,1)
% x = linspace(-200,400,1000);
% for m = 1:4
%     plot(x, normpdf(x, gmm.mu(m), sqrt(gmm.Sigma(m))))
%     hold on
% end
% subplot(1,3,2)
% imageQ(any(masks(:,:,:,3),3))
% subplot(1,3,3)
% imageQ(any(masks(:,:,:,4),3))
% pause
% close

% Sometimes regions in the dediff mask have HU that are too low and should
% really be counted as myxoid or well diff

if ~isempty(dediffProbe)
    % Use probe to define lower bound for dediff regions
    dediffThreshold = mean(dediffProbe.pixels) - prior.dediffThresholdFactor*std(dediffProbe.pixels);
    
    % Remove connected dediff regions whose mean HU is below this threshold
    masks(:,:,:,3) = removeConnectedComponentsBelowThreshold(masks(:,:,:,3), dediffThreshold, @mean, 8);

    % Some low HU dediff areas are connected to OK HU areas so they survive the
    % previous step, but they are only just connected.
    % Erode dediff mask, remove components that are below threshold, then
    % dilate mask back to original size.
    if prior.removeOnlyJustConnectedComponents
        SE = strel('disk', 4);
        masks(:,:,:,3) = imerode(masks(:,:,:,3), SE);
        masks(:,:,:,3) = removeConnectedComponentsBelowThreshold(masks(:,:,:,3), dediffThreshold, @mean, 8);
        masks(:,:,:,3) = imdilate(masks(:,:,:,3), SE) & roi.mask;
    end

end

% Switch connected regions of calcification mask that are below
% calcificationThreshold to dediff
[masks(:,:,:,4), calcifRemoved] = removeConnectedComponentsBelowThreshold(masks(:,:,:,4), prior.calcificationThreshold, prior.calcificationThresholdStatistic, 4);
% just these three lines might be controversial...
maskDediff = masks(:,:,:,3);
maskDediff(calcifRemoved) = true;
masks(:,:,:,3) = maskDediff;

% dilate the calcifications masks a bit
maskCalcif = masks(:,:,:,4);
maskCalcif = imdilate(maskCalcif, strel('disk', 2)) & roi.mask;
maskCalcifExtra = maskCalcif & ~masks(:,:,:,4);
for m = 1:3
    thisMask = masks(:,:,:,m);
    thisMask(maskCalcifExtra) = false;
    masks(:,:,:,m) = thisMask;
end

% Apply 2D tidying operations to all slices of all masks except the
% calcification mask.
if prior.apply2Dtidying
    masks = apply2Dtidying(masks);
end

% At this stage because of all the tidying operations there will be some
% regions that are not associated with any of the three classes, and there may also
% be some pixels that are allocated to more than one class.

% Fill in missing pixels with most frequent neighbour class, but only fill
% using well-diff, myxoid or calcification labels
missing = ~any(masks,4) & roi.mask;
leaveDediff = true;
masks = fillWithMostFrequentNeighbour(masks, missing, leaveDediff);

% Fill in pixels allocated to more than one class with most frequent
% neighbour class, including ded-diff regions
duplicated = sum(masks,4)>1 & roi.mask;
masks(repmat(duplicated,[1 1 1 4])) = false;
leaveDediff = false;
masks = fillWithMostFrequentNeighbour(masks, duplicated, leaveDediff);

% ensure that all masks are confined to the original mask
for m = 1:4
    masks(:,:,:,m) = masks(:,:,:,m) & roi.mask;
end

if all(squash(roi.mask == (sum(masks,4)==1)))
    disp('Mask check OK')
else
    cprintf([1,0.5,0], 'Warning: Mask check not OK!\n')
end

    function masks = apply2Dtidying(masks)


       if showProgressBar
           progressBar = waitbar(0,'','Name','Progress: 2D tidying', 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); 
           setappdata(progressBar,'canceling',0);
       end
    
        % the mask for m = 4 is for calcification, which tend to be small
        for nn = 1:size(roi.im,3)
            for mm = 1:3
                removeSkinnyRegions = mm==3;
                masks(:,:,nn,mm) = tidyMask2d(masks(:,:,nn,mm), roi.mask(:,:,nn), removeSkinnyRegions);
        
                if showProgressBar
                    if getappdata(progressBar,'canceling')
                        return
                    elseif mod(nn,10)==0
                        waitbar(nn/size(roi.im,3),progressBar,[num2str(nn) '/' num2str(size(roi.im,3))])
                    end
                end

            end
        end

       if showProgressBar
           delete(progressBar)
       end

    end

    function W = tidyMask2d(W, lesionMask, removeSkinnyRegionsH)

        % remove any blobs/holes less than nBlob
        nBlob = 15;
        W = bwareaopen(W, nBlob);
        W = ~bwareaopen(~W, nBlob);

        % get list of connected regions
        CC = bwconncomp(W);
        largestRegionArea = max(cellfun(@length, CC.PixelIdxList));
        lesionEdge = lesionMask & ~imerode(lesionMask,strel('disk',1,0));
        testMask = zeros(size(lesionMask));
        for r = 1:length(CC.PixelIdxList)

            if removeSkinnyRegionsH
                testMask(:) = 0;
                testMask(CC.PixelIdxList{r}) = 1;
                [rIdx, cIdx] = find(testMask);
                sv = sqrt(eig(cov([rIdx cIdx])));
                if sv(1)/sv(2)<0.1
                    W(CC.PixelIdxList{r}) = 0;
                end
            end

            % remove region if likely to be an edge smear, i.e. more than 45%
            % of pixels are on the edge of the lesion mask
            if (sum(lesionEdge(CC.PixelIdxList{r}))/length(CC.PixelIdxList{r}))>0.45
                W(CC.PixelIdxList{r}) = 0;
            end

            % remove region if area is less than smallPct of the largest
            % region, or less than smallSize
            smallPct = 0.05;
            smallSize = 100;
            if (length(CC.PixelIdxList{r}) < (smallPct*largestRegionArea)) && (length(CC.PixelIdxList{r}) < smallSize)
                W(CC.PixelIdxList{r}) = 0;
            end
        end

        % final morphological operation to tidy the edges up
        W = imerode(imdilate(W,strel('disk',2,0)),strel('disk',2,0));
        W = W & lesionMask;
    end


    function masks = fillWithMostFrequentNeighbour(masks, missing, leaveDediff)

        missingCC = bwconncomp(missing);    

       if showProgressBar
           progressBar = waitbar(0,'','Name','Progress: in-filling', 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); 
           setappdata(progressBar,'canceling',0);
       end


        steps = length(missingCC.PixelIdxList);
        for rr = 1:steps
            thisBlob = false(size(missing(:,:,:,1)));
            thisBlob(missingCC.PixelIdxList{rr}) = true;
            thisBlobSurface = imdilate(thisBlob,strel('sphere',1))==1 & ~thisBlob;
            for mm = 1:4
                edgeClassCount(mm) = nnz(masks(:,:,:,mm) & thisBlobSurface);
            end
            % next line means we leave the dediff mask alone unless the blob is
            % inside a dediff region, i.e. only edgeClassCount(3)>0
            if leaveDediff && any(edgeClassCount([1 2 4])>0)
                edgeClassCount(3) = 0;
            end
            [~,idx] = max(edgeClassCount);
            maskH = masks(:,:,:,idx);
            maskH(thisBlob) = true;
            masks(:,:,:,idx) = maskH;
    
            if showProgressBar
                if getappdata(progressBar,'canceling')
                    return
                elseif mod(rr,10)==0
                    waitbar(rr/steps,progressBar,[num2str(rr) '/' num2str(steps)])
                end
            end

        end

        if showProgressBar
           delete(progressBar)
       end

    end

    % Main data loading function
    function [roi, dediffProbe, vesselMask] = loadData()

        % open main rts file
        rts = readDicomRT(fullfile(rtsFile.folder, rtsFile.name), sopInstMap);
    
        % find any ROIs with 'hole' in the label
        roiKeys = rts.roi.keys;
        holes = cell2mat(cellfunQ(@(x) contains(x,'hole'), roiKeys));
        vessels = cell2mat(cellfunQ(@(x) contains(x,'vessels'), roiKeys));
        notHole = find(~holes & ~vessels);
        holes = find(holes);
    
        % remove any holes from mask
        for mm = 1:length(holes)
            thisRoi = rts.roi(roiKeys{holes(mm)});
            lesionRoi = rts.roi(roiKeys{notHole});
            for nn = 1:length(thisRoi.refSopInst)
                sliceIdx = find(cell2mat(cellfunQ(@(x) strcmp(x, thisRoi.refSopInst{nn}), lesionRoi.refSopInst)));
                holeMask = thisRoi.mask(:,:,nn);
                holeMask = imdilate(holeMask, strel('disk',2));
                lesionRoi.mask(:,:,sliceIdx) = lesionRoi.mask(:,:,sliceIdx) & ~holeMask;
            end
            rts.roi(roiKeys{notHole}) = lesionRoi;
        end
        roi = rts.roi(roiKeys{notHole});
        roi.mask = logical(roi.mask);

        % find any ROIs called 'vessels'
        vesselMask = false(size(roi.mask));
        if rts.roi.isKey('vessels')
            thisRoi = rts.roi('vessels');
            lesionRoi = rts.roi(roiKeys{notHole});
            for nn = 1:length(thisRoi.refSopInst)
                sliceIdx = find(cell2mat(cellfunQ(@(x) strcmp(x, thisRoi.refSopInst{nn}), lesionRoi.refSopInst)));
                vesselMask(:,:,sliceIdx) = thisRoi.mask(:,:,nn);
            end
        end


        if ~isempty(dediffRts)
            % open file with dediff probe mask
            rtsDediff = readDicomRT(fullfile(dediffRts.folder, dediffRts.name), sopInstMap);
    
            % get mask and stats
            dediffProbe.pixels = rtsDediff.roi('dediff').im(logical(rtsDediff.roi('dediff').mask));
    
            dediffProbe.mask = rtsDediff.roi('dediff').mask;
            for mm = 1:size(rtsDediff.roi('dediff').mask,3)
                dediffProbe.sliceIndex(mm) = find(cell2mat(cellfunQ(@(x) strcmp(x, rtsDediff.roi('dediff').refSopInst{mm}), roi.refSopInst)));
                % trim the dediff mask so it is totally within the lesion mask
                dediffProbe.mask(:,:,mm) = dediffProbe.mask(:,:,mm) & roi.mask(:,:,dediffProbe.sliceIndex(mm));
            end

        else
            dediffProbe = [];
        end


    end


    function [thisMask, partsRemoved] = removeConnectedComponentsBelowThreshold(thisMask, threshold, averageFun, connectivity)

        CC = bwconncomp(thisMask, connectivity);
        CCmean = cell2mat(cellfunQ(@(x) averageFun(imForFitting(x)), CC.PixelIdxList));
        partsRemoved = false(size(thisMask));
        thisMask(cell2mat(CC.PixelIdxList(CCmean < threshold)')) = false;
        partsRemoved(cell2mat(CC.PixelIdxList(CCmean < threshold)')) = true;
        
    end

end