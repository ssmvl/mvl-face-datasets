clear;
addpath(fullfile('..', '..', 'functions'));

Vars_CFD;

load('landmarks.mat');

datasetDir  = 'imgs-dataset';
datasetFile = 'dataset.mat';
datasetXlsx = 'dataset.xlsx';

%%
%  Generate masked face images
%
if ~exist(datasetDir, 'dir')
	mkdir(datasetDir);
end

lmInfo = lmInfo(arrayfun(@(lm) ~isempty(lm.pnts), lmInfo));
fprintf('building dataset with %d images:\n', length(lmInfo));
for i = 1:length(lmInfo)
	if any(strcmp(lmInfo(i).imgId, CFD.mask.rejectedImgIds))
		fprintf('!');
	elseif ~maskPrereq(lmInfo(i), CFD.mask.reqMargin)
		fprintf('!');
	else
		[maskX, maskY] = maskOutline(lmInfo(i), CFD.mask.padding);
		img = imread(lmInfo(i).file);

		hfig = figure('Color', [1 1 1]);
		imshow(img, 'Border', 'tight', 'Interpolation', 'bilinear');
		imgClean = getframe(hfig.Children(1)).cdata;
		cx = mean(lmInfo(i).pnts([28 29], 1)) / size(img, 2) * size(imgClean, 2);
		xidx = round((1:size(imgClean, 1)) - (1 + size(imgClean, 1)) / 2 + cx);
		imwrite(imgClean(:, xidx, :), fullfile(datasetDir, strcat(lmInfo(i).imgId, '-clean.png')));

		patch(maskX, maskY, CFD.mask.color, 'LineWidth', CFD.mask.lineWidth, 'EdgeColor', CFD.mask.lineColor);
		imgMasked = getframe(hfig.Children(1)).cdata;
		imwrite(imgMasked(:, xidx, :), fullfile(datasetDir, strcat(lmInfo(i).imgId, '-masked.png')));
		close(hfig);
		fprintf('.');
	end
	if mod(i, 50) == 0
		fprintf('\n');
	end
end
if mod(length(lmInfo), 50) ~= 0
	fprintf('\n');
end



%%
%  Save list of images included in the dataset
%
fprintf('saving dataset information...');
imgFiles = dir(datasetDir);
imgFiles = imgFiles(arrayfun(@(f) ~isempty(regexpi(f.name, '^[ABLW][MF][0-9]+-masked\.png$', 'once')), imgFiles));
imgIds = arrayfun(@(f) regexprep(f.name, '-masked\.png$', ''), imgFiles, 'UniformOutput', false);
imgInfo = table(imgIds, 'VariableNames', {'ImgId'});
save(datasetFile, 'imgInfo');
writetable(imgInfo, datasetXlsx, 'Sheet', 'ImgInfo');
fprintf(' done.\n');



%%
%  All done, wrapping up
%
fprintf('all done, please check %s%s, %s, and %s\n\n', ...
	datasetDir, filesep, datasetXlsx, datasetFile);
