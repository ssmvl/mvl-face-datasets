function [path, modelArgs] = initOpenFace(path)
	if ~exist('path', 'var') || isempty(path)
		path = fullfile(fileparts(mfilename('fullpath')), '..', ...
			'libraries', 'OpenFace-OpenFace_2.2.0', 'matlab_version');
	end

	addpath(fullfile(path, 'PDM_helpers'));
	addpath(genpath(fullfile(path, 'fitting')));
	addpath(fullfile(path, 'models'));
	addpath(genpath(fullfile(path, 'face_detection')));
	addpath(fullfile(path, 'CCNF'));
	addpath(fullfile(path, 'face_detection', 'mtcnn'));

	curDir = cd(fullfile(path, 'models'));
	cleanup = onCleanup(@() cd(curDir));
	[patches, pdm, clmParams, earlyTermParams] = Load_CECLM_general();

	views = [0, 0, 0; 0, -30, 0; 0, 30, 0; 0, 0, 30; 0, 0, -30];
	views = views * pi / 180;
	modelArgs = {pdm, patches, clmParams, views, earlyTermParams};
end