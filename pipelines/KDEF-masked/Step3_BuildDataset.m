clear;
addpath(fullfile('..', '..', 'functions'));

Vars_KDEF;

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
	if any(strcmp(lmInfo(i).imgId, KDEF.mask.rejectedImgIds))
		fprintf('!');
	elseif ~maskPrereq(lmInfo(i), KDEF.mask.reqMargin)
		fprintf('!');
	else
		if ~isempty(regexp(lmInfo(i).imgId, 'S$', 'once'))
			maskPadding = KDEF.mask.padding{1};
		else
			maskPadding = KDEF.mask.padding{2};
		end
		[maskX, maskY] = maskOutline(lmInfo(i), maskPadding);

		hfig = figure('Color', [1 1 1] * KDEF.bgPatch.normL);
		imshow(imread(lmInfo(i).file), 'Border', 'tight', 'Interpolation', 'bilinear');
		imgClean = getframe(hfig.Children(1)).cdata;
		imwrite(getframe(hfig.Children(1)).cdata, ...
			fullfile(datasetDir, strcat(lmInfo(i).imgId, '-clean.png')));

		patch(maskX, maskY, KDEF.mask.color, 'LineWidth', KDEF.mask.lineWidth, 'EdgeColor', KDEF.mask.lineColor);
		imwrite(getframe(hfig.Children(1)).cdata, ...
			fullfile(datasetDir, strcat(lmInfo(i).imgId, '-masked.png')));
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
%  Save map of images included in the dataset
%
fprintf('saving dataset information...');
imgIdMap = repmat({ char([]) }, [length(KDEF.models), length(KDEF.exprs), length(KDEF.angles)]);
for i = 1:length(KDEF.models)
	for j = 1:length(KDEF.exprs)
		for k = 1:length(KDEF.angles)
			imgId = strcat(KDEF.models{i}, KDEF.exprs{j}, KDEF.angles{k});
			imgFile = fullfile(datasetDir, strcat(imgId, '-masked.png'));
			if exist(imgFile, 'file')
				imgIdMap{i, j, k} = imgId;
			end
		end
	end
end
models = KDEF.models;
exprs  = KDEF.exprs;
angles = cell(1, 1, length(KDEF.angles));
angles(:) = KDEF.angles;
save(datasetFile, 'imgIdMap', 'models', 'exprs', 'angles');
for i = 1:length(angles)
	tblData = arrayfun(@(c) imgIdMap(:, c, i), 1:size(imgIdMap, 2), 'UniformOutput', false);
	tbl = table(models, tblData{:}, 'VariableNames', cat(2, {'Model'}, exprs));
	writetable(tbl, datasetXlsx, 'Sheet', sprintf('Angle %s', angles{i}));
end
fprintf(' done.\n');



%%
%  All done, wrapping up
%
fprintf('all done, please check %s%s, %s, and %s\n\n', ...
	datasetDir, filesep, datasetXlsx, datasetFile);
