clear;

Vars_CFD;

lightnessFig = 'img-lightness.fig';
srcImgDir    = 'imgs-source';
normImgDir   = 'imgs-normalized';

%%
%  Check CFD imageset directory
%
if ~exist(fullfile(CFD.imgDir, CFD.probeFile), 'file')
	curDir = strcat(fileparts(mfilename('fullpath')), filesep);
	warning(['Please download the CFD 3.0 dataset from https://www.chicagofaces.org/, ' ...
		'unpack the zip file, find the CFD%s directory under the Images%s directory, ' ...
		'and place it under %s'], filesep, filesep, curDir);
	return;
end



%%
%  Check lightness values of all images
%    Lightness values of background patches are pretty consistent (mostly 1)
%    in CFD. So, simple normailzation will suffice.
%
if ~exist(lightnessFig, 'file')
	fprintf('checking image lightness...');
	modelDirs = dir(CFD.imgDir);
	modelDirs = modelDirs(arrayfun(@(d) ~isempty(regexpi(d.name, CFD.dirRegex, 'once')), modelDirs));
	
	patchL = [];
	minL = [];
	maxL = [];
	for i = 1:length(modelDirs)
		modelDir = modelDirs(i).name;
		imgFiles = dir(fullfile(CFD.imgDir, modelDir));
		imgFiles = imgFiles(arrayfun(@(d) ~isempty(regexpi(d.name, '\.(jpe?g|png|tiff?)+$', 'once')), imgFiles));
		for f = 1:length(imgFiles)
			img = imread(fullfile(CFD.imgDir, modelDir, imgFiles(f).name));
			img = rgb2gray(im2double(img));
			patchL = cat(1, patchL, CFD.bgPatch.L(img));
			minL = cat(1, minL, min(img(:)));
			maxL = cat(1, maxL, max(img(:)));
		end
	end
	
	% Plot and save image lightness histogram
	hf = figure;
	subplot(2, 1, 1);
	histogram(patchL, 0:.01:1);
	legend(['Background patch lightness' newline '(top left and top right corners)'], 'Location', 'north');
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
%  Copy neutral expression image files to the source directory
%
fprintf('copying image files to %s%s ...', srcImgDir, filesep);
if ~exist(srcImgDir, 'dir')
	mkdir(srcImgDir);
end

modelDirs = dir(CFD.imgDir);
modelDirs = modelDirs(arrayfun(@(d) ~isempty(regexpi(d.name, CFD.dirRegex, 'once')), modelDirs));
for i = 1:length(modelDirs)
	modelDir = modelDirs(i).name;
	imgFiles = dir(fullfile(CFD.imgDir, modelDir));
	imgFiles = imgFiles(arrayfun(@(d) ~isempty(regexpi(d.name, CFD.fileRegex, 'once')), imgFiles));

	dstFile = regexprep(imgFiles(1).name, CFD.fileRegex, '$1$2\.jpg');
	copyfile(fullfile(CFD.imgDir, modelDir, imgFiles(1).name), fullfile(srcImgDir, dstFile));
end
fprintf(' done.\n');



%%
%  Generate normalized grayscale images
%
fprintf('generating normalized grayscale images under %s%s ...', normImgDir, filesep);
if ~exist(normImgDir, 'dir')
	mkdir(normImgDir);
end

srcFiles = dir(srcImgDir);
srcFiles = srcFiles(arrayfun(@(f) ~isempty(regexpi(f.name, '^[ABLW][MF][0-9]+\.jpg$', 'once')), srcFiles));
for i = 1:length(srcFiles)
	img = imread(fullfile(srcImgDir, srcFiles(i).name));
	img = rgb2gray(im2double(img));
	normImg = min(1, img - CFD.bgPatch.L(img) + 1);

	dstFile = regexprep(srcFiles(i).name, '\.jpg$', '.png');
	imwrite(normImg, fullfile(normImgDir, dstFile));
end
fprintf(' done.\n');



%%
%  Wrapping up
%
fprintf('all set, please proceed to Step2_DetectLandmarks\n\n');
