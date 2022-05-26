function out = highLowEnhancingFilter(rtsFile, sopInstMap, sourceFolder, destinFolder)

% open rts file
rts = readDicomRT(fullfile(rtsFile.folder, rtsFile.name), sopInstMap);

% find any ROIs with 'hole' in the label
roiKeys = rts.roi.keys;
holes = cell2mat(cellfunQ(@(x) contains(x,'hole'), roiKeys));
notHole = find(~holes);
holes = find(holes);

% remove any holes from mask
for m = 1:length(holes)
    thisRoi = rts.roi(roiKeys{holes(m)});
    lesionRoi = rts.roi(roiKeys{notHole});
    for n = 1:length(thisRoi.refSopInst)
        sliceIdx = find(cell2mat(cellfunQ(@(x) strcmp(x, thisRoi.refSopInst{n}), lesionRoi.refSopInst)));
        holeMask = thisRoi.mask(:,:,n);
        holeMask = imdilate(holeMask, strel('disk',2));
        lesionRoi.mask(:,:,sliceIdx) = lesionRoi.mask(:,:,sliceIdx) - holeMask;
    end
    rts.roi(roiKeys{notHole}) = lesionRoi;
end
roi = rts.roi(roiKeys{notHole});
roiKeys = roiKeys(notHole);

for m = 1:length(roi.refSopInst)
    packageLesion(m) = struct('image',roi.im(:,:,m), 'mask', roi.mask(:,:,m), 'sopInstance', roi.refSopInst{m});
end

% get image and lesion mask
im = roi.im;
lesion = roi.mask==1;
lesionPixels = im(lesion);


% Use no more than 20000 pixels for the GMM fitting.  This is so that the
% power of the prior is similar for large and small ROIs
data = lesionPixels;
% crop pixels to hard limits
signalLow = -200;
signalHigh = 150; %200;
data = data(data>signalLow);
data = data(data<signalHigh);
pct = prctile(data,[0.5 99.5]);
data = data(data>pct(1) & data<pct(2));
data = data(1:ceil(length(data)/20000):end);

% initialise and fit gmm
mu_mu = [-83; -8.5; 42]; %[-100; -25; 30];
mu_sigma = [3 3 3].^2;
sigma_mu = [14 14 16].^2;
sigma_cov = [0.02 0.02 0.02];
gmm = kSeparatePriorsEMfunc(data, mu_mu, mu_sigma, sigma_mu, sigma_cov);
% init.mu = [-100; -25; 30];
% init.Sigma = 20^2*reshape([1 1 1],[1 1 3]);
% init.ComponentProportion = [0.4 0.3 0.3];
% gmm = fitgmdist(data, 3, 'Start', init);

necrosisProb = zeros(size(lesion));
viableProb = zeros(size(lesion));

% GMM class probabilities
[~,~,w] = cluster(gmm, im(lesion));
necrosisProb(lesion) = w(:,1);
viableProb(lesion) = w(:,3);

% Gaussian smoothing and threshold.  Threshold of 0.6 sucks the
% boundary in a bit to offset the Gaussian smoothing.
necrosis = imgaussfilt(necrosisProb,0.5)>0.6;
viable = imgaussfilt(viableProb,0.5)>0.6;

% after smoothing there may be voxels that are classified as both necrosis
% and viable, so set these to whichever class has higher probability (in
% non-smoothed maps)
clash = necrosis & viable;
necrosis(clash & (necrosisProb>viableProb)) = true;
viable(clash & (necrosisProb<viableProb)) = true;

for n = 1:size(im,3)
    necrosis(:,:,n) = tidyMask(necrosis(:,:,n), lesion(:,:,n));
    viable(:,:,n) = tidyMask(viable(:,:,n), lesion(:,:,n));
end

% remove small volumes (we also do this per slice based on area)
viableCC = bwconncomp(viable);
viableLargestRegionVol = max(cellfun(@length, viableCC.PixelIdxList));
for rr = 1:length(viableCC.PixelIdxList)
    % remove region if volume is less than smPct of the largest region
    smPct = 0.10; % 0.02
    if length(viableCC.PixelIdxList{rr}) < (smPct*viableLargestRegionVol)
        viable(viableCC.PixelIdxList{rr}) = 0;
    end
end
necrosisCC = bwconncomp(necrosis);
necrosisLargestRegionVol = max(cellfun(@length, necrosisCC.PixelIdxList));
for rr = 1:length(necrosisCC.PixelIdxList)
    % remove region if volume is less than smPct of the largest region
    smPct = 0.10; % 0.02
    if length(necrosisCC.PixelIdxList{rr}) < (smPct*necrosisLargestRegionVol)
        necrosis(necrosisCC.PixelIdxList{rr}) = 0;
    end
end

% make mask for voxels with middle HU
middle = lesion & (~necrosis & ~viable);

% remove small regions from middle mask. 
% Do this per slice and then on the whole volume
% Per slice:
for n = 1:size(middle,3)
    % remove small volumes - extra work needed to decide what label to give
    % them since these are "middle" brightness regions
    thisMask = middle(:,:,n);
    middleCC = bwconncomp(thisMask);
    middleLargestRegionArea = max(cellfun(@length, middleCC.PixelIdxList));
    for rr = 1:length(middleCC.PixelIdxList)
        % remove region if area is less than smPct of the largest region
        smPct = 0.05; % 0.02
        if length(middleCC.PixelIdxList{rr}) < (smPct*middleLargestRegionArea)
            thisMask(middleCC.PixelIdxList{rr}) = 0;
        end
    end
    middle(:,:,n) = thisMask;
end
% Per volume
middleCC = bwconncomp(middle);
middleLargestRegionArea = max(cellfun(@length, middleCC.PixelIdxList));
for rr = 1:length(middleCC.PixelIdxList)
    % remove region if area is less than smPct of the largest region
    smPct = 0.10; % 0.02
    if length(middleCC.PixelIdxList{rr}) < (smPct*middleLargestRegionArea)
        middle(middleCC.PixelIdxList{rr}) = 0;
    end
end

% at this stage because of all the tidying operations there will be some
% regions that are not associated with any of the three classes, so fill
% these in with the majority class of the surrounding voxels
missing = lesion & (~viable & ~middle & ~necrosis);
missingCC = bwconncomp(missing);
for rr = 1:length(missingCC.PixelIdxList)
    thisBlob = false(size(missing));
    thisBlob(missingCC.PixelIdxList{rr}) = true;
    thisBlobSurface = imdilate(thisBlob,strel('sphere',1))==1 & ~thisBlob;
    necrosisCount = nnz(necrosis & thisBlobSurface);
    middleCount = nnz(middle & thisBlobSurface);
    viableCount = nnz(viable & thisBlobSurface);
    if necrosisCount>=middleCount && necrosisCount>viableCount
        necrosis(thisBlob) = true;
    end
    if middleCount>necrosisCount && middleCount>viableCount
        middle(thisBlob) = true;
    end
    if viableCount>=necrosisCount && viableCount>=middleCount
        viable(thisBlob) = true;
    end
end


packageLowEnhance = packageLesion;
packageMidEnhance = packageLesion;
packageHighEnhance = packageLesion;
for n = 1:size(necrosis,3)
    packageLowEnhance(n).mask = necrosis(:,:,n);
end
for n = 1:size(middle,3)
    packageMidEnhance(n).mask = middle(:,:,n);
end
for n = 1:size(viable,3)
    packageHighEnhance(n).mask = viable(:,:,n);
end


x = linspace(-200,200,200);
BW = 5;
fLesion = ksdensity(lesionPixels, x, 'Bandwidth', BW);

necrosisPixels = im(necrosis);
middlePixels = im(middle);
viablePixels = im(viable);
if length(necrosisPixels)>1
    fNecrosis = ksdensity(necrosisPixels, x, 'Bandwidth', BW);
else
    fNecrosis  = NaN(size(x));
end
if length(middlePixels)>1
    fMiddle = ksdensity(middlePixels, x, 'Bandwidth', BW);
else
    fMiddle  = NaN(size(x));
end
if length(viablePixels)>1
    fViable = ksdensity(viablePixels, x, 'Bandwidth', BW);
else
    fViable = NaN(size(x));
end
% remainingPixels =im(lesion & ~necrosis & (im>signalLow) & (im<signalHigh));
% fRemainder = ksdensity(remainingPixels, x, 'Bandwidth', BW);

out(1) = mean(necrosisPixels);
out(2) = std(necrosisPixels);
% out(3) = mean(remainingPixels);
% out(4) = std(remainingPixels);
% out(5) =  length(necrosisPixels)/length(lesionPixels);
%disp(num2str(out))

%return

figure('position',[1    72  2560  1265])

subplot(5,10,[3 4 5])

% do initial plot to get the BinEdges suitable for the range shown
h = histogram(lesionPixels(lesionPixels>-200 & lesionPixels<200));
binEdges = h.BinEdges;
histogram(lesionPixels, 'BinEdges', [binEdges Inf], 'Normalization','countdensity', 'EdgeColor', 'none');
hold on

% y = normpdf(x, gmm.mu(1), sqrt(gmm.Sigma(1)))*gmm.ComponentProportion(1)*length(lesionPixels);
% patchline(x,y,zeros(size(x)), 'edgecolor','k','edgealpha',0.25);
% y = normpdf(x, gmm.mu(2), sqrt(gmm.Sigma(2)))*gmm.ComponentProportion(2)*length(lesionPixels);
% patchline(x,y,zeros(size(x)), 'edgecolor','k','edgealpha',0.25);

% set(gca,'ColorOrderIndex',1)
% plot(x,fLesion*length(lesionPixels),'LineWidth',1.75)
H1 = plot(x,fNecrosis*length(necrosisPixels),'b','LineWidth',1.75);
H2 = plot(x,fMiddle*length(middlePixels),'r','LineWidth',1.75);
H3 = plot(x,fViable*length(viablePixels),'g','LineWidth',1.75);
%H2 = plot(x,fRemainder*length(remainingPixels),'r','LineWidth',1.75);
legend([H1 H2 H3],'Low enhancement', 'Mid enhancement', 'High enhancement','Location','NorthEast')
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

subplot(5,10,[6 7 8])

interior = lesion & circshift(lesion,[1 0 0]) & circshift(lesion,[-1 0 0]) & ...
    circshift(lesion,[0 1 0]) & circshift(lesion,[0 -1 0]) & ...
    circshift(lesion,[0 0 1]) & circshift(lesion,[0 0 -1]);

surface = lesion & ~interior;
surfaceNecrosis = surface & necrosis;

% median values used for thresholding


flatMask = sum(lesion,3)>0;
cols = find(sum(flatMask));
rows = find(sum(flatMask,2));
ax = [cols(1)-15 cols(end)+15 rows(1)-15 rows(end)+15];

sliceDisplay = unique(round(linspace(1, size(im,3), 30)));

for n = 1:length(sliceDisplay)
    posL = GetPixellatedROI(lesion(:,:,sliceDisplay(n)));
    posN = GetPixellatedROI(imerode(necrosis(:,:,sliceDisplay(n)),strel('disk',1)));
    posM = GetPixellatedROI(imerode(middle(:,:,sliceDisplay(n)),strel('disk',1)));
    posV = GetPixellatedROI(imerode(viable(:,:,sliceDisplay(n)),strel('disk',1)));
    
    subplot(5,10,n+10)
    imageQ(im(:,:,sliceDisplay(n)),[-200 200])
    hold on
    plot(posL(1,:),posL(2,:),'c')
    plot(posN(1,:),posN(2,:),'b')
    plot(posM(1,:),posM(2,:),'r')
    plot(posV(1,:),posV(2,:),'g')
    axis(ax)
    hold off
end

%subplot(5,10,11)
pos = get(gca,'position');
cb = colorbar;
set(gca,'position',pos)
cb.Label.String = '    HU';
cb.Label.Rotation = 0;
cb.Location='eastoutside';
cb.Ticks = -200:50:200;


subplot(5,10,50)
plot(0,0)
set(gca,'XColor',0.99*[1 1 1],'YColor',0.99*[1 1 1],'XTick',[],'YTick',[])

set(gcf,'color','w')

drawnow

% package up all masks into one cell array/structure
package{1} = struct('data', packageLesion, 'label', 'lesion');
package{2} = struct('data', packageLowEnhance, 'label', 'lowEnhancing');
package{3} = struct('data', packageMidEnhance, 'label', 'midEnhancing');
package{4} = struct('data', packageHighEnhance, 'label', 'highEnhancing');
segFolder = strrep(rtsFile.folder, sourceFolder, destinFolder);
writeDicomSegsMatlab(package, 'lesion', sopInstMap, rtsFile.name, segFolder)

out = struct('gmm', gmm, 'lesion', lesion, 'necrosis', necrosis, 'middle', middle, 'viable', viable, 'im', im);

    function W = tidyMask(W, lesionMask)

        % remove any blobs/holes less than nBlob
        nBlob = 15; % 9
        W = bwareaopen(W, nBlob);
        W = ~bwareaopen(~W, nBlob);

        % get list of connected regions
        CC = bwconncomp(W);
        largestRegionArea = max(cellfun(@length, CC.PixelIdxList));
        lesionEdge = lesionMask & ~imerode(lesionMask,strel('disk',1,0));
        for r = 1:length(CC.PixelIdxList)
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
    end

end