function path = initMatConvNet(path)
	if ~exist('path', 'var') || isempty(path)
		path = fullfile(fileparts(mfilename('fullpath')), ...
			'..', 'libraries', 'matconvnet-1.0-beta25');
	end

	run(fullfile(path, 'matlab', 'vl_setupnn'));
	addpath(fullfile(path, 'examples'));
end