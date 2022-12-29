clear;
addpath(fullfile('..', '..', 'functions'));
addpath(fullfile('..', '..', 'libraries', 'SHINEtoolbox'));

Vars_CFD;

load('landmarks-cutout.mat');

cutoutImgDir = 'imgs-face-cutout';
datasetDir  = 'imgs-dataset';
datasetDirs = {
	fullfile(datasetDir, 'color')
	fullfile(datasetDir, 'grayscale')
	fullfile(datasetDir, 'lightness-matched')
	fullfile(datasetDir, 'outline-matched')
	};
datasetFile = 'dataset.mat';
datasetXlsx = 'dataset.xlsx';

%%
%  Resize cutout images, save as color & grayscale images, and prepare images
%  for SHINE toolbox histogram matching
%
if ~exist(datasetDir, 'dir')
	mkdir(datasetDir);
end
for i = 1:length(datasetDirs)
	if ~exist(datasetDirs{i}, 'dir')
		mkdir(datasetDirs{i});
	end
end

lmInfo = lmInfo(arrayfun(@(lm) ~isempty(lm.pnts), lmInfo));
shineImgs = { };
shineMask = { };
alphaMaps = [];
fprintf('processing %d cutout images:\n', length(lmInfo));
for i = 1:length(lmInfo)
	imgFile = strcat(lmInfo(i).imgId, '.png');
	[srcImg, ~, alphaMap] = imread(fullfile(cutoutImgDir, imgFile));
	colorImg = imresize(srcImg, [1 1] * CFD.datasetImSize, 'bilinear');
	grayImg  = imresize(rgb2gray(srcImg), [1 1] * CFD.datasetImSize, 'bilinear');
	alphaMap = imresize(alphaMap, [1 1] * CFD.datasetImSize, 'bilinear');
	imwrite(colorImg, fullfile(datasetDirs{1}, imgFile), 'Alpha', alphaMap);
	imwrite(repmat(grayImg, [1 1 3]), fullfile(datasetDirs{2}, imgFile), 'Alpha', alphaMap);

	% build lightness histogram and find median lightness
	alphaMap = im2double(alphaMap);
	lHist = zeros(1, 256);
	for l = 0:255
		lHist(l + 1) = sum(alphaMap(grayImg == l));
	end
	lCDF = cumsum(lHist) / sum(lHist);
	medL = (find(lCDF >= .50, 1) - 1) / 255;
	% normalize image lightness while avoiding saturation
	grayImg = im2double(grayImg);
	orgL = [min(grayImg(:)), medL, max(grayImg(:))];
	newL = (orgL - medL) * CFD.lightness.gainL + CFD.lightness.normL;
	newL = max(0, min(1, newL));
	normImg = spline(orgL, newL, grayImg);
	normImg(alphaMap == 0) = CFD.lightness.normL;
	% prepare images for SHINE toolbox histogram matching
	shineImgs = cat(1, shineImgs, uint8(normImg * 255));
	shineMask = cat(1, shineMask, uint8(alphaMap > 0));
	% alpha map will be used with histogram-matched images
	alphaMaps = cat(3, alphaMaps, alphaMap);

	fprintf('.');
	if mod(i, 50) == 0
		fprintf('\n');
	end
end
if mod(length(lmInfo), 50) ~= 0
	fprintf('\n');
end



%%
%  Lightness histogram mathcing with SHINE toolbox
%
fprintf('running SHINE toolbox...');
normImgs = histMatch(shineImgs, 1, [], shineMask);
for i = 1:length(lmInfo)
	imgFile = strcat(lmInfo(i).imgId, '.png');
	imwrite(normImgs{i}, fullfile(datasetDirs{3}, imgFile), 'Alpha', alphaMaps(:, :, i));
end
fprintf(' done.\n');



%%
%  Find top-N images per category that closely match the average outline
%
alphaDiff = alphaMaps - repmat(mean(alphaMaps, 3), [1 1 size(alphaMaps, 3)]);
matchArea = CFD.outline.upperBound:CFD.outline.lowerBound;
outlineDissim = squeeze(sum(alphaDiff(matchArea, :, :) .^ 2, [1 2]));

outlineMatch = false(length(lmInfo), 1);
imgCategories = unique(arrayfun(@(lm) lm.imgId(1:2), lmInfo, 'UniformOutput', false));
for i = 1:length(imgCategories)
	cidx = find(arrayfun(@(lm) strcmp(lm.imgId(1:2), imgCategories{i}), lmInfo));
	[~, sidx] = sort(outlineDissim(cidx));
	outlineMatch(cidx(sidx(1:CFD.outline.imgsPerCategory))) = true;
	for j = cidx(sidx(1:CFD.outline.imgsPerCategory))'
		imgFile = strcat(lmInfo(j).imgId, '.png');
		copyfile(fullfile(datasetDirs{3}, imgFile), fullfile(datasetDirs{4}, imgFile));
	end
end



%%
%  Save list of images included in the dataset
%
fprintf('saving dataset information...');
imgFiles = dir(datasetDirs{3});
imgFiles = imgFiles(arrayfun(@(f) ~isempty(regexpi(f.name, '^[ABLW][MF][0-9]+\.png$', 'once')), imgFiles));
imgIds = arrayfun(@(f) regexprep(f.name, '\.png$', ''), imgFiles, 'UniformOutput', false);
outlineMatchStr = {''; 'Y'};
imgInfo = table(imgIds, outlineMatchStr(outlineMatch + 1), outlineDissim, ...
	'VariableNames', {'ImgId', 'OutlineMatch', 'OutlineDissim'});
save(datasetFile, 'imgInfo');
writetable(imgInfo, datasetXlsx, 'Sheet', 'ImgInfo');
fprintf(' done.\n');



%%
%  All done, wrapping up
%
fprintf('all done, please check %s%s, %s, and %s\n\n', ...
	datasetDir, filesep, datasetXlsx, datasetFile);
