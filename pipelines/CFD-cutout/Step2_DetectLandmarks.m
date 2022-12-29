clear;
addpath(fullfile('..', '..', 'functions'));

lmInfoFile = 'landmarks.mat';
lmInfoVars = {'srcImgDir', 'lmImgDir', 'imgIds', 'lmInfo'};

%%
%  Set or load variables
%    If you run this script after a manual interrution (Ctrl + C), this script
%    will start from where it was interrupted.
%
if exist(lmInfoFile, 'file')
	load(lmInfoFile);
	imgIdsLeft = setdiff(imgIds, { lmInfo.imgId }');
else
	srcImgDir = 'imgs-source';
	lmImgDir  = 'imgs-landmarks';

	imgFiles = dir(srcImgDir);
	imgFiles = imgFiles(arrayfun(@(f) ~isempty(regexpi(f.name, '^[ABLW][MF][0-9]+\.jpg$', 'once')), imgFiles));
	imgIds = arrayfun(@(f) regexprep(f.name, '\.jpg$', ''), imgFiles, 'UniformOutput', false);
	imgIdsLeft = imgIds;
	lmInfo = struct([]);
end



%%
%  Initialize MatConvNet and OpenFace
%
initMatConvNet();
[~, modelArgs] = initOpenFace();



%%
%  Detect facial landmarks
%
if ~exist(lmImgDir, 'dir')
	mkdir(lmImgDir);
end

fprintf('total %d images, %d images processed, %d to go:\n', ...
	length(imgIds), length(lmInfo), length(imgIdsLeft));
for i = 1:length(imgIdsLeft)
	imgFile  = fullfile(srcImgDir,  strcat(imgIdsLeft{i}, '.jpg'));

	lm = detectLandmarks(imread(imgFile), modelArgs);
	lm.imgId = imgIdsLeft{i};
	lm.file  = imgFile;
	if isempty(lm.pnts)
		fprintf('!');
	else
		fprintf('.');
		imwrite(renderLandmarks(lm, 7, 3), fullfile(lmImgDir, strcat(imgIdsLeft{i}, '.png')));	
	end
	if mod(i, 50) == 0
		fprintf('\n');
	end

	lmInfo = cat(1, lmInfo, lm);
	save(lmInfoFile, lmInfoVars{:});
end
if mod(length(imgIdsLeft), 50) ~= 0
	fprintf('\n');
end



%%
%  Wrapping up
%
fprintf('all set, please proceed to Step3_CutoutImages\n\n');
