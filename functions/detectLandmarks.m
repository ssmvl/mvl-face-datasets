function lmInfo = detectLandmarks(I, modelArgs, path)
	if ~exist('path', 'var') || isempty(path)
		path = fullfile(fileparts(mfilename('fullpath')), ...
			'..', 'libraries', 'OpenFace-OpenFace_2.2.0', 'matlab_version');
	end

	curDir = cd(fullfile(path, 'face_detection', 'mtcnn'));
	cleanup = onCleanup(@() cd(curDir));
	try
		bboxes = detect_face_mtcnn(I);
	catch
		bboxes = [];
	end

	if size(bboxes, 1) == 1
		[shape, ~, ~, ~, ~, view_used] = Fitting_from_bb_multi_hyp( ...
			rgb2gray(I), [], bboxes, modelArgs{:});
		lmInfo.bbox = bboxes;
		lmInfo.pnts = shape + 1;  % MATLAB workaround
		lmInfo.shown = logical(modelArgs{2}(1).visibilities(view_used, :)');
	else
		lmInfo.bbox = [];
		lmInfo.pnts = [];
		lmInfo.shown = logical([]);
	end
end