function tempSave = highLowEnhancingFilter4(rtsFile, dediffRts, sopInstMap, destinFolder, prior, postProcess)

f = waitbar(0,'1','Name','', 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); setappdata(f,'canceling',0);

% load image and mask and dediff probe
[roi, dediffProbe] = loadData;

% smooth image a little to avoid too many spurious regions
imSmoothed = imgaussfilt(roi.im, 1);

% fit Bayesian Gaussian mixture model using prior to soft-constrain the class statistics
[gmm, prior] = fitBayesianGMM(prior);

% get initial version of sub-region masks from gmm fit
masks = getMasksFromGMM(gmm);

% remove 2D connected components of dediff mask whose mean value is below dediffThreshold
maskDediff = masks(:,:,:,3);
dediffCC = bwconncomp(maskDediff ,8);
dediffCCmean = cell2mat(cellfunQ(@(x) mean(imSmoothed(x)), dediffCC.PixelIdxList));
dediffThreshold = mean(dediffProbe.pixels) - 1.5*std(dediffProbe.pixels);
maskDediff(cell2mat(dediffCC.PixelIdxList(dediffCCmean < dediffThreshold)')) = 0;
masks(:,:,:,3) = maskDediff;


% Erode the mask and then...
% remove 2D connected components of dediff mask whose mean value is below dediffThreshold
% ... and then dilate mask to get back where you started (roughly).
% This operation will trim off bits that are only just connected where th
% HU is too low
SE = strel('disk', 4);
maskDediff = imerode(masks(:,:,:,3), SE);
dediffCC = bwconncomp(maskDediff ,8);
dediffCCmean = cell2mat(cellfunQ(@(x) mean(imSmoothed(x)), dediffCC.PixelIdxList));
dediffThreshold = mean(dediffProbe.pixels) - 1.5*std(dediffProbe.pixels);
maskDediff(cell2mat(dediffCC.PixelIdxList(dediffCCmean < dediffThreshold)')) = 0;
masks(:,:,:,3) = imdilate(maskDediff, SE);

% remove 2D connected components of calcification mask whose mean value is below calcificationThreshold
maskCalcif = masks(:,:,:,4);
calcifCC = bwconncomp(maskCalcif ,8);
calcifCCmean = cell2mat(cellfunQ(@(x) mean(imSmoothed(x)), calcifCC.PixelIdxList));
calcificationThreshold = 190;
maskCalcif(cell2mat(calcifCC.PixelIdxList(calcifCCmean < calcificationThreshold)')) = 0;
masks(:,:,:,4) = maskCalcif;



% the mask for m = 4 is for calcification, which tend to be small
if exist('f','var'), set(f,'Name','Progress: 2D tidying'); end
for n = 1:size(imSmoothed,3)
    for m = 1:3
        removeSkinnyRegions = m==3;
        masks(:,:,n,m) = tidyMask(masks(:,:,n,m), roi.mask(:,:,n), removeSkinnyRegions);
        if exist('f','var') && getappdata(f,'canceling')
            return
        end
        if exist('f','var') && mod(n,10)==0
            waitbar(n/size(imSmoothed,3),f,[num2str(n) '/' num2str(size(imSmoothed,3))])
        end
    end
end

% at this stage because of all the tidying operations there will be some
% regions that are not associated with any of the three classes, and there may also
% be some pixels that are allocated to more than one class.
% Fill these cases using surrounding mask and image info
%
% The dediff class needs special attention because this step often
% re-instates regions to the dediff mask that were deleted in the
% tidyMask() step.  So we leave the dediff mask alone, and only fill in the
% other three classes.
%
missing = ~any(masks,4);
missing(~roi.mask) = false;
leaveDediff = true;
masks = fillWithMostFrequentNeighbour(masks, missing, leaveDediff);

missing = sum(masks,4)>1;
missing(~roi.mask) = false;
masks(repmat(missing,[1 1 1 4])) = 0;
leaveDediff = false;
masks = fillWithMostFrequentNeighbour(masks, missing, leaveDediff);




if exist('f','var'), delete(f); end

% post-process to only keep a specified number of the largest dediff regions
if isfinite(postProcess.numberOfLargestDediff)
    maskMyx = masks(:,:,:,2);
    maskDediff = masks(:,:,:,3);
    DD = bwconncomp(maskDediff);
    [~, idx] = sort(cellfun(@length, DD.PixelIdxList),'descend');
    idxToMyx = cell2mat(DD.PixelIdxList(idx(postProcess.numberOfLargestDediff+1:end))');
    maskMyx(idxToMyx) = 1;
    maskDediff(idxToMyx) = 0;
    masks(:,:,:,2) = maskMyx;
    masks(:,:,:,3) = maskDediff;
end

% post-process to fill in all holes in dediff mask and remove them from
% whichever other mask they were in
if postProcess.fillDediff
    dediffMaskHole = imfill(masks(:,:,:,3),'holes') & ~masks(:,:,:,3);
    for m = 1:4
        maskH = masks(:,:,:,m);
        maskH(dediffMaskHole) = (m==3);
        masks(:,:,:,m) = maskH;
    end
end

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

% % special mask to identify the largest de-diff region
% packageSubRegions{mSubRegion+1} = packageLesion;
% DD = bwconncomp(masks(:,:,:,3));
% [~, idx] = max(cellfun(@length, DD.PixelIdxList));
% largestDeDiffmask = zeros(size(masks(:,:,:,1)));
% largestDeDiffmask(DD.PixelIdxList{idx}) = 1;
% for nSlice = 1:size(masks,3)
%     packageSubRegions{mSubRegion+1}(nSlice).mask = double(largestDeDiffmask(:,:,nSlice) & roi.mask(:,:,nSlice));
% end


lesionPixelsOriginal = roi.im(roi.mask);

x = linspace(-200,200,200);
BW = 5;
fLesion = ksdensity(lesionPixelsOriginal, x, 'Bandwidth', BW);

for m = 1:4
    pixelsH = roi.im(masks(:,:,:,m) & roi.mask);
    if length(pixelsH)>1
        fr(m,:) = ksdensity(pixelsH, x, 'Bandwidth', BW);
    else
        fr(m,:)  = NaN(size(x));
    end
end

figure('position',[1    76  2560  1261],'Visible','off')

nRowSP = 6;
nColSP = 14;
subplot(nRowSP,nColSP,[1 2])

% do initial plot to get the BinEdges suitable for the range shown
h = histogram(lesionPixelsOriginal(lesionPixelsOriginal>-200 & lesionPixelsOriginal<200));
binEdges = h.BinEdges;
histogram(lesionPixelsOriginal, 'BinEdges', [binEdges Inf], 'Normalization','countdensity', 'EdgeColor', 'none');
hold on

PreviousColor
for m = 1:4
    HL{m} = plot(x,fr(m,:)*nnz(roi.mask & masks(:,:,:,m)));
end

axis tight
ylim(ylim.*[0 1.5])
hold off
xlabel('HU')
% xlabel({ '       mean_1    std_1    mean_2   std_2      f_1',  ...
%         ['gmm  : ' num2str([gmm.mu(1) sqrt(gmm.Sigma(1)) gmm.mu(2) sqrt(gmm.Sigma(2)) gmm.ComponentProportion(1)],3)], ...
%         ['mask : ' num2str(out,3)]},...
%         'Interpreter','none',...
%         'FontSize',9)

set(gca,'YTick',[])

% subplot(5,10,[6 7 8])

% interior = roi.mask & circshift(roi.mask,[1 0 0]) & circshift(roi.mask,[-1 0 0]) & ...
%     circshift(roi.mask,[0 1 0]) & circshift(roi.mask,[0 -1 0]) & ...
%     circshift(roi.mask,[0 0 1]) & circshift(roi.mask,[0 0 -1]);
% 
% surface = roi.mask & ~interior;
% surfaceNecrosis = surface & necrosis;
% 
% median values used for thresholding


flatMask = sum(roi.mask,3)>0;
cols = find(sum(flatMask));
rows = find(sum(flatMask,2));
ax = [cols(1)-15 cols(end)+15 rows(1)-15 rows(end)+15];

mainSlices = setdiff(unique(round(linspace(1, size(imSmoothed,3), (nRowSP*nColSP-2)))), dediffProbe.sliceIndex);
sliceDisplay = unique([mainSlices(1:min([nRowSP*nColSP-3 length(mainSlices)])) dediffProbe.sliceIndex]);

for n = 1:length(sliceDisplay)
    posL = GetPixellatedROI(roi.mask(:,:,sliceDisplay(n)));
    for m = 1:4
        posS{m} = GetPixellatedROI(imerode(masks(:,:,sliceDisplay(n),m),strel('disk',1)));
    end
    
    subplot(nRowSP,nColSP,n+2)
    imageQ(roi.im(:,:,sliceDisplay(n)),[-135 215])
    hold on
    %plot(posL(1,:),posL(2,:),'c')
    for m = 1:4
        plot(posS{m}(1,:),posS{m}(2,:)) %,'LineWidth',1)
    end
    if sliceDisplay(n)==dediffProbe.sliceIndex
        posDediff = GetPixellatedROI(dediffProbe.mask);
        plot(posDediff(1,:),posDediff(2,:),'c--')
    end
    axis(ax)
    title(num2str(sliceDisplay(n)))
    hold off
end

pos = get(gca,'position');
cb = colorbar;
set(gca,'position',pos)
cb.Label.String = '    HU';
cb.Label.Rotation = 0;
cb.Location = 'eastoutside';
%cb.Ticks = -200:50:200;


set(gcf,'color','w')

drawnow


% package up all masks into one cell array/structure
package{1} = struct('data', packageLesion, 'label', 'lesion');
package{2} = struct('data', packageSubRegions{1}, 'label', 'Well differentiated');
package{3} = struct('data', packageSubRegions{2}, 'label', 'Myxoid');
package{4} = struct('data', packageSubRegions{3}, 'label', 'De-differentiated');
package{5} = struct('data', packageSubRegions{4}, 'label', 'Calcification');
%package{6} = struct('data', packageSubRegions{5}, 'label', 'Largest De-differentiated 3D region');

writeDicomSegsMatlab(package, 'lesion_4subseg_v2', sopInstMap, rtsFile.name, destinFolder)

tempSave = '/Users/morton/Documents/MATLAB/tempSave.mat';
save(tempSave, 'masks', 'imSmoothed', 'gmm')

    function W = tidyMask(W, lesionMask, removeSkinnyRegionsH)

        % remove any blobs/holes less than nBlob
        nBlob = 15; % 9
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
            % remove region if area is less than smallPct of the largest region
            smallPct = 0.05; % 0.02
            smallSize = 100;
            if (length(CC.PixelIdxList{r}) < (smallPct*largestRegionArea)) && (length(CC.PixelIdxList{r}) < smallSize)
                W(CC.PixelIdxList{r}) = 0;
            end
        end

        % final morphological operation to tidy the edges up
        W = imerode(imdilate(W,strel('disk',2,0)),strel('disk',2,0));
        W = double(W & lesionMask);
    end


    function masks = fillWithMostFrequentNeighbour(masks, missing, leaveDediff)

        missingCC = bwconncomp(missing);    

        steps = length(missingCC.PixelIdxList);
        if exist('f','var'), set(f,'Name','Progress: in-filling'); end
        for rr = 1:steps
            thisBlob = false(size(missing(:,:,:,1)));
            thisBlob(missingCC.PixelIdxList{rr}) = true;
            thisBlobSurface = imdilate(thisBlob,strel('sphere',1))==1 & ~thisBlob;
            for m = 1:4
                edgeClassCount(m) = nnz(masks(:,:,:,m) & thisBlobSurface);
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
    
            if exist('f','var') && getappdata(f,'canceling')
                return
            end
            if exist('f','var') && mod(rr,20)==0
                waitbar(rr/steps,f,[num2str(rr) '/' num2str(steps)])
            end
        end
    end

    % Main data loading function
    function [roi, dediffProbe] = loadData

        % open main rts file
        rts = readDicomRT(fullfile(rtsFile.folder, rtsFile.name), sopInstMap);
    
        % find any ROIs with 'hole' in the label
        roiKeys = rts.roi.keys;
        holes = cell2mat(cellfunQ(@(x) contains(x,'hole'), roiKeys));
        notHole = find(~holes);
        holes = find(holes);
    
        % remove any holes from mask
        for mm = 1:length(holes)
            thisRoi = rts.roi(roiKeys{holes(mm)});
            lesionRoi = rts.roi(roiKeys{notHole});
            for nn = 1:length(thisRoi.refSopInst)
                sliceIdx = find(cell2mat(cellfunQ(@(x) strcmp(x, thisRoi.refSopInst{nn}), lesionRoi.refSopInst)));
                holeMask = thisRoi.mask(:,:,nn);
                holeMask = imdilate(holeMask, strel('disk',2));
                lesionRoi.mask(:,:,sliceIdx) = lesionRoi.mask(:,:,sliceIdx) - holeMask;
            end
            rts.roi(roiKeys{notHole}) = lesionRoi;
        end
        roi = rts.roi(roiKeys{notHole});
        roi.mask = logical(roi.mask);

        % open file with dediff probe mask
        rtsDediff = readDicomRT(fullfile(dediffRts.folder, dediffRts.name), sopInstMap);

        % get mask and stats
        dediffProbe.mask = logical(rtsDediff.roi('dediff').mask);
        dediffProbe.pixels = rtsDediff.roi('dediff').im(dediffProbe.mask);

        % find slice index in main image volume that contains the dediff probe
        [~, zSortIdx] = sort(cell2mat(arrayfunQ(@(x) x.z(1), rts.roi(roiKeys{notHole}).contour)));
        refSopInst = arrayfunQ(@(x) x.ReferencedSOPInstanceUID{1}, rts.roi(roiKeys{notHole}).contour);
        refSopInst = refSopInst(zSortIdx);
        refSopInstDediff = rtsDediff.roi('dediff').contour(1).ReferencedSOPInstanceUID{1};
        dediffProbe.sliceIndex = find(cell2mat(cellfunQ(@(x) strcmp(x, refSopInstDediff), refSopInst)));

    end

    % Bayesian EM fitting function, with special data preparation and prior
    % adjustments (if indicated)
    function [gmm, prior] = fitBayesianGMM(prior)

        data = imSmoothed(roi.mask);

        % crop pixels to hard limits to avoid influence of outliers
        signalLow = -200;
        signalHigh = 350; %250;
        data = data(data>signalLow);
        data = data(data<signalHigh);
        pct = prctile(data,[0.5 99.5]);
        data = data(data>pct(1) & data<pct(2));

        % Use no more than 20000 pixels for the GMM fitting.  This is so that the
        % power of the prior is similar for large and small ROIs
        data = data(1:ceil(length(data)/20000):end);

        % NaNs in the prior stats indicate these values should be set using
        % the dediff prob statistics
        if isnan(prior.mu_mu(2))
            prior.mu_mu(2) = 0.5*(prior.mu_mu(1) + mean(dediffProbe.pixels));
        end
        if isnan(prior.mu_mu(3))
            prior.mu_mu(3) = mean(dediffProbe.pixels);
        end
        if isnan(prior.sigma_mu(3))
            prior.sigma_mu(3) = var(dediffProbe.pixels);
        end

        % fit Bayesian EMM
        gmm = kSeparatePriorsEMfunc(data, prior.mu_mu, prior.mu_sigma, prior.sigma_mu, prior.sigma_cov);

    end

    function masks = getMasksFromGMM(gmm)

        % get class weights from dilated mask so we avoid edge effects when we smooth the wIm arrays later
        lesionDilate = imdilate(roi.mask,strel('sphere',3));
        [~,~,w] = cluster(gmm, imSmoothed(lesionDilate));
        
        % apply a bit of smoothing
        prob = zeros([size(roi.mask) 4]);
        prob(repmat(lesionDilate,[1 1 1 4])) = w(:);
        
        % hard threshold on the dediff portion at this stage in the analysis
        probDediff = prob(:,:,:,3);
        probDediff(imSmoothed < prctile(dediffProbe.pixels,1)) = 0;
        prob(:,:,:,3) = probDediff;
        
        for nn = [1 2 4]
            prob(:,:,:,nn) = imgaussfilt(prob(:,:,:,nn), 2);
        end
        % more smoothing for dediff region to encourge it to find simple blobs
        prob(:,:,:,3) = imgaussfilt(prob(:,:,:,3), 5);
        prob(prob<0) = 0;
        prob = prob./sum(prob,4);
        prob(~repmat(roi.mask,[1 1 1 4])) = 0;
        
        % get mask for each class
        masks = false(size(prob));
        wImMax = max(prob,[],4);
        for nn = 1:4
            masks(:,:,:,nn) = prob(:,:,:,nn) == wImMax;
        end
        masks = masks & roi.mask;

    end

end