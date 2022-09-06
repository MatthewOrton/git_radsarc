function [masks, prob] = getMasksFromGMM(gmm, imHere, maskHere, dediffProbe)

% get class weights from dilated mask so we avoid edge effects when we smooth the wIm arrays later
lesionDilate = imdilate(maskHere,strel('sphere',3));
[~,~,w] = cluster(gmm, imHere(lesionDilate));

if size(maskHere,3)==1
    prob = zeros([size(maskHere) 1 4]);
else
    prob = zeros([size(maskHere) 4]);
end
prob(repmat(lesionDilate,[1 1 1 4])) = w(:);

% hard threshold on the dediff portion at this stage in the analysis
if ~isempty(dediffProbe)
    probDediff = prob(:,:,:,3);
    probDediff(imHere < prctile(dediffProbe.pixels,1)) = 0;
    prob(:,:,:,3) = probDediff;
end

% apply a bit of smoothing, but more to dediff and none to calcifications
for nn = [1 2]
    prob(:,:,:,nn) = imgaussfilt(prob(:,:,:,nn), 2);
end
% more smoothing for dediff region to encourge it to find simple blobs
prob(:,:,:,3) = imgaussfilt(prob(:,:,:,3), 5);
prob(prob<0) = 0;
prob = prob./sum(prob,4);
prob(~repmat(maskHere,[1 1 1 4])) = 0;

% get mask for each class
masks = false(size(prob));
wImMax = max(prob,[],4);
for nn = 1:4
    masks(:,:,:,nn) = prob(:,:,:,nn) == wImMax;
end
masks = masks & maskHere;

