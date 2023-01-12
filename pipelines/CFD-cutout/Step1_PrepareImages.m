clear;

Vars_CFD;

srcImgDir  = 'imgs-source';
normImgDir = 'imgs-normalized';

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
%  Wrapping up
%
fprintf('all set, please proceed to Step2_DetectLandmarks\n\n');
