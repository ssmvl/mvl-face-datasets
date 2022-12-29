clear;

Vars_KDEF;

lightnessFig = 'img-lightness.fig';
srcInfoFile  = 'img-src-info.mat';
srcImgDir    = 'imgs-source';
normImgDir   = 'imgs-normalized';

%%
%  Check KDEF imageset directory
%
probeModel = strcat(KDEF.setIds{1}, KDEF.models{1});
probeFile = strcat(probeModel, KDEF.exprs{1}, KDEF.angles{1}, '.JPG');
if ~exist(fullfile(KDEF.imgDir, probeModel, probeFile), 'file')
	curDir = strcat(fileparts(mfilename('fullpath')), filesep);
	warning(['Please download the KDEF imagest from https://www.kdef.se/, ' ...
		'unpack the zip file, and place the KDEF%s directory under %s'], filesep, curDir);
	return;
end



%%
%  Check lightness values of all images
%    Lightness cutoff values (KDEF.bgPatch.cutoffL) were determined based on
%    the distribution of the background patch lightness values (M ± ~2.5 SD)
%    and defined in Vars_KDEF.m file.
%
if ~exist(lightnessFig, 'file')
	fprintf('checking image lightness...');
	modelDirs = dir(KDEF.imgDir);
	modelDirs = modelDirs(arrayfun(@(d) ~isempty(regexpi(d.name, '^[AB][MF][0-9]+$', 'once')), modelDirs));
	
	patchL = [];
	minL = [];
	maxL = [];
	for i = 1:length(modelDirs)
		modelDir = modelDirs(i).name;
		imgFiles = dir(fullfile(KDEF.imgDir, modelDir));
		imgFiles = imgFiles(arrayfun(@(d) ~isempty(regexpi(d.name, '\.(jpe?g|png|tiff?)+$', 'once')), imgFiles));
		for f = 1:length(imgFiles)
			img = imread(fullfile(KDEF.imgDir, modelDir, imgFiles(f).name));
			img = rgb2gray(im2double(img));
			patchL = cat(1, patchL, KDEF.bgPatch.L(img));
			minL = cat(1, minL, min(img(:)));
			maxL = cat(1, maxL, max(img(:)));
		end
	end
	
	% Plot and save image lightness histogram
	hf = figure;
	subplot(2, 1, 1);
	histogram(patchL, 0:.01:1);
	legend(['Background patch lightness' newline '(top left and top right corners)'], 'Location', 'northwest');
	legend boxoff;
	subplot(2, 1, 2);
	histogram(minL, 0:.01:1); hold on;
	histogram(maxL, 0:.01:1); hold off;
	legend('Minimum lightness', 'Maximum lightness', 'Location', 'north');
	legend boxoff;
	saveas(hf, lightnessFig);
	fprintf(' saved (%s).\n', lightnessFig);
end



%%
%  Select good image files for each image id
%    KDEF imageset contains two files (in set A and set B) for each image id
%    (model × expression × angle). Let's find and use better ones.
%
if ~exist(srcInfoFile, 'file')
	fprintf('selecting good image files for each image id...');
	imgIdMap = strcat( ...
		repmat(KDEF.models, [1, length(KDEF.exprs), length(KDEF.angles)]), ...
		repmat(KDEF.exprs, [length(KDEF.models), 1, length(KDEF.angles)]), ...
		repmat(permute(KDEF.angles, [1 3 2]), [length(KDEF.models), length(KDEF.exprs)]));
	setIdMap = repmat({''}, size(imgIdMap));
	for i = 1:numel(imgIdMap)
		for s = KDEF.setPref
			if ~any(strcmp(imgIdMap{i}, KDEF.rejectedImgIds{s}))
				imgFile = strcat(KDEF.setIds{s}, imgIdMap{i}, '.JPG');
				img = imread(fullfile(KDEF.imgDir, imgFile(1:4), imgFile));
				img = rgb2gray(im2double(img));
				patchVal = KDEF.bgPatch.L(img);
				if (patchVal >= KDEF.bgPatch.cutoffL(1)) && (patchVal <= KDEF.bgPatch.cutoffL(2))
					setIdMap{i} = KDEF.setIds{s};
					break;
				end
			end
		end
	end
	save(srcInfoFile, 'setIdMap', 'imgIdMap');
	fprintf(' saved (%s).\n', srcInfoFile);
else
	load(srcInfoFile);
end



%%
%  Copy selected image files to the source directory
%
fprintf('copying selected image files to %s%s ...', srcImgDir, filesep);
if ~exist(srcImgDir, 'dir')
	mkdir(srcImgDir);
end

srcFiles = strcat(setIdMap(~cellfun(@isempty, setIdMap)), ...
	imgIdMap(~cellfun(@isempty, setIdMap)), '.JPG');
dstFiles = strcat(imgIdMap(~cellfun(@isempty, setIdMap)), '.jpg');
for i = 1:length(srcFiles)
	copyfile(fullfile(KDEF.imgDir, srcFiles{i}(1:4), srcFiles{i}), ...
		fullfile(srcImgDir, dstFiles{i}));
end
fprintf(' done.\n');



%%
%  Generate normalized grayscale images
%
fprintf('generating normalized grayscale images under %s%s ...', normImgDir, filesep);
if ~exist(normImgDir, 'dir')
	mkdir(normImgDir);
end

srcFiles = strcat(imgIdMap(~cellfun(@isempty, setIdMap)), '.jpg');
dstFiles = strcat(imgIdMap(~cellfun(@isempty, setIdMap)), '.png');
for i = 1:length(srcFiles)
	img = imread(fullfile(srcImgDir, srcFiles{i}));
	img = rgb2gray(im2double(img));
	% normalize background patch lightness while avoiding saturation
	patchL = KDEF.bgPatch.L(img);
	orgL = [min(img(:)), patchL, max(img(:))];
	newL = orgL - patchL + KDEF.bgPatch.normL;
	newL = max(0, min(1, newL));
	normImg = spline(orgL, newL, img);
	imwrite(normImg, fullfile(normImgDir, dstFiles{i}));
end
fprintf(' done.\n');



%%
%  Wrapping up
%
fprintf('all set, please proceed to Step2_DetectLandmarks\n\n');
