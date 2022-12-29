CFD.imgDir = 'CFD';

% file naming convention
CFD.dirRegex  = '^[ABLW][MF]-[0-9]+$';
CFD.fileRegex = '^CFD-([ABLW][MF])-([0-9]+)-([0-9]+)-N\.jpg$';  % neutral faces
CFD.probeFile = fullfile('AF-200', 'CFD-AF-200-228-N.jpg');

% background patch function
CFD.bgPatch.L = @(I) mean(I(1:150, [1:150, (end-149):end]), [1 2]);
% background patch normalized lightness
CFD.bgPatch.normL = 1;

% mask - required margins for mask shape estimation
CFD.mask.reqMargin = [16, 8];  % nose/mouth at least 16/8 pixels inside the facial contour

% mask - visual properties
CFD.mask.padding = [10, 10];
CFD.mask.color = [.7 .7 .7];
CFD.mask.lineColor = [.5 .5 .5];
CFD.mask.lineWidth = 2;

% manually rejected images
CFD.mask.rejectedImgIds = {
	'BF011'  % landmark detection failure
	'BF027'  % uneven mask
	'BF032'  % uneven mask
	'BF037'  % landmark detection failure
	'BF044'  % landmark detection failure
	'BM020'  % beard outside mask
	'BM040'  % mask touches collar
	'BM209'  % landmark detection failure
	'BM222'  % uneven mask
	'LF220'  % landmark detection failure
	'LF230'  % uneven mask
	'LF242'  % uneven mask
	'LM240'  % landmark detection failure
	'LM252'  % landmark detection failure
	'WF250'  % uneven mask
	'WF251'  % uneven mask
	'WF204'  % landmark detection failure
	};
