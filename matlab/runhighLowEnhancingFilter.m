clear all
close all force

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT';

quickLoadMap = fullfile(rootFolder, 'sopInstanceMap.mat');
if exist(quickLoadMap,'file')
    load(quickLoadMap)
else
    maps = sopInstanceMap(fullfile(rootFolder, 'referencedScans'));
    save(quickLoadMap, 'maps')
end


% sourceFolder = fullfile('assessors', 'assessors_2022.04.27_20.25.16');
% sourceFolder = fullfile('assessors', 'assessors_2022.06.06_18.06.21', 'lesion');
sourceFolder = fullfile('assessors', 'assessors_2022.06.06_21.56.48', 'lesion');
rtsFiles = dir(fullfile(rootFolder, sourceFolder, '*.dcm'));

thumbFolder = fullfile(rootFolder,'highLowEnhancingAnalysis',['outputs_' datestr(datetime('now'),'yyyymmdd_HHMM')]);
if ~exist(thumbFolder,'dir')
    mkdir(thumbFolder)
    mkdir(fullfile(thumbFolder,'pdf'))
    mkdir(fullfile(thumbFolder,'fig'))
    mkdir(fullfile(thumbFolder,'mat'))
    mkdir(fullfile(thumbFolder,'code'))
    destinFolder = fullfile(thumbFolder,'seg');
    mkdir(destinFolder);

    % copy all code scripts
    copyfile([mfilename('fullpath') '.m'], fullfile(thumbFolder, 'code', [mfilename '.m']))
    otherCode = matlab.codetools.requiredFilesAndProducts([mfilename '.m']);
    for n = 1:length(otherCode)
        [~,thisFile] = fileparts(otherCode{n});
        copyfile(otherCode{n}, fullfile(thumbFolder, 'code', [thisFile '.m']))
    end

end

patDict_numberOfLargestDediff = containers.Map;
patDict_numberOfLargestDediff('RMH_RSRC002') = 1;
patDict_numberOfLargestDediff('RMH_RSRC015') = 1;
patDict_numberOfLargestDediff('RMH_RSRC019') = 1;
patDict_numberOfLargestDediff('RMH_RSRC032') = 1;
patDict_numberOfLargestDediff('RMH_RSRC036') = 1;

patDict_fillDediff = containers.Map;
patDict_fillDediff('RMH_RSRC015') = true;


for nRts = 6 %1:length(rtsFiles)

    try

        patID = strsplit(rtsFiles(nRts).name,'__II__');
        patID = patID{1};

        % find dediff rts file
        dediffRts = dir(fullfile(strrep(rtsFiles(nRts).folder,'lesion','dediff'),[patID '*.dcm']));

        if isempty(dediffRts)
            continue
        end


        prior.mu_mu = [-80; -10; NaN; 200];
        prior.mu_sigma = [1 3 0.01 1].^2;
        prior.sigma_mu = [16 14 NaN 20].^2;
        prior.sigma_cov = [0.01 0.02 0.001 0.02];

        if strcmp(patID,'RMH_RSRC125')
            prior.mu_mu = [-80; -10; NaN; 200];
            prior.mu_sigma = [1 3 0.01 1].^2;
            prior.sigma_mu = [8 8 NaN 20].^2;
            prior.sigma_cov = [0.005 0.005 0.001 0.02];
        end

        postProcess.numberOfLargestDediff = NaN;    % number of largest dediff regions to retain
        postProcess.fillDediff = false;             % fill holes in dediff region
        postProcess.combineMyxoidDediff = false;    % combine myxoid and dediff regions

        if patDict_numberOfLargestDediff.isKey(patID)
            postProcess.numberOfLargestDediff = patDict_numberOfLargestDediff(patID);
        end
        if patDict_fillDediff.isKey(patID)
            postProcess.fillDediff = patDict_fillDediff(patID);
        end

        disp(rtsFiles(nRts).name)

        showProgressBar = true;

        [masks, roi, dediffProbe, prior, gmm] = sarcomaSubsegmentor(rtsFiles(nRts), dediffRts, maps.sopInstMap, prior, showProgressBar);

%%%%%%%%%%%%


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

set(gca,'YTick',[])


flatMask = sum(roi.mask,3)>0;
cols = find(sum(flatMask));
rows = find(sum(flatMask,2));
ax = [cols(1)-15 cols(end)+15 rows(1)-15 rows(end)+15];

mainSlices = setdiff(unique(round(linspace(1, size(roi.im,3), (nRowSP*nColSP-2)))), dediffProbe.sliceIndex);
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

writeDicomSegsMatlab(package, 'lesion_4subseg_v2', maps.sopInstMap, rtsFiles(nRts).name, destinFolder)

matFile = '/Users/morton/Documents/MATLAB/tempSave.mat';
im = roi.im;
save(matFile, 'masks', 'im', 'gmm')



%%%%%%%%%%%%


        %matFile = highLowEnhancingFilter4(rtsFiles(nRts), dediffRts, maps.sopInstMap, destinFolder, prior, postProcess);


        movefile(matFile, fullfile(thumbFolder, 'mat', strrep(rtsFiles(nRts).name,'dcm','mat')))

        sgtitle(strrep(strrep(rtsFiles(nRts).name,'__II__','   '),'.dcm',''),'FontSize',18,'Interpreter','none')

        drawnow
        exportPdf(gcf,fullfile(thumbFolder, 'pdf', strrep(rtsFiles(nRts).name,'dcm','pdf')))
        saveas(gcf,fullfile(thumbFolder, 'fig', strrep(rtsFiles(nRts).name,'dcm','fig')))
        close

    catch exception
        disp(' ')
        disp('_______________')
        disp(rtsFiles(nRts).name)
        disp(getReport(exception))
        disp('_______________')
        disp(' ')
    end
end

function getPrior(patID)

end