CFD.imgDir = 'CFD';

% file naming convention
CFD.dirRegex  = '^[ABLW][MF]-[0-9]+$';
CFD.fileRegex = '^CFD-([ABLW][MF])-([0-9]+)-([0-9]+)-N\.jpg$';  % neutral faces
CFD.probeFile = fullfile('AF-200', 'CFD-AF-200-228-N.jpg');

% cutout properties
CFD.cutout.padding = [75, 25];  % eyebrows padding, lower contour padding
CFD.cutout.lowpass = 25;   % cycles per revolution
CFD.cutout.imScale = 1.5;  % 1.5 times of the square root of the cutout area

% dataset image size
CFD.datasetImSize = 500;

% for lightness-matched images
CFD.lightness.normL = .60;
CFD.lightness.gainL = .65;

% for outline-matched images
CFD.outline.upperBound = round(CFD.datasetImSize * (1/3));
CFD.outline.lowerBound = round(CFD.datasetImSize * (2/3));
CFD.outline.imgsPerCategory = 5;  

% manually rejected images (cutout failures)
CFD.cutout.rejectedImgIds = {
	'AF210'  % hair
	'AF220'  % hair/shade
	'AF229'  % hair
	'AF231'  % hair
	'AF232'  % hair/shade
	'AF241'  % hair/shade
	'AF247'  % hair/shade
	'AM201'  % hair/shade
	'AM202'  % hair
	'AM206'  % hair
	'AM215'  % hair
	'AM224'  % hair
	'AM226'  % hair/shade
	'AM228'  % hair
	'AM233'  % shade
	'AM244'  % hair
	'AM245'  % hair
	'AM250'  % hair
	'AM252'  % hair
	'BF011'  % landmark detection failure
	'BF012'  % hair
	'BF016'  % shade
	'BF018'  % hair
	'BF028'  % hair
	'BF037'  % landmark detection failure
	'BF038'  % non-neutral facial expression
	'BF044'  % landmark detection failure
	'BF049'  % hair
	'BF226'  % hair
	'BF237'  % hair
	'BF253'  % shade
	'BM004'  % uneven contour
	'BM020'  % uneven contour
	'BM200'  % too narrow chin
	'BM209'  % landmark detection failure
	'BM216'  % hair
	'BM228'  % uneven contour
	'BM244'  % landmark detection failure
	'LF202'  % hair
	'LF209'  % hair
	'LF210'  % hair
	'LF211'  % uneven contour
	'LF219'  % hair/shade
	'LF220'  % landmark detection failure
	'LF223'  % hair
	'LF226'  % shade
	'LF230'  % shade
	'LF231'  % hair
	'LF232'  % hair
	'LF242'  % hair/shade
	'LF244'  % hair
	'LF248'  % uneven contour
	'LM203'  % shade
	'LM207'  % hair
	'LM209'  % uneven contour
	'LM211'  % hair
	'LM228'  % landmark detection failure
	'LM233'  % uneven chin width
	'LM240'  % landmark detection failure
	'LM252'  % landmark detection failure
	'LM253'  % hair
	'WF002'  % landmark detection failure
	'WF007'  % hair
	'WF010'  % hair
	'WF012'  % head tilt
	'WF014'  % hair
	'WF017'  % hair
	'WF018'  % hair
	'WF025'  % uneven contour
	'WF026'  % landmark detection failure
	'WF028'  % hair/shade
	'WF029'  % uneven contour
	'WF036'  % hair
	'WF039'  % hair
	'WF202'  % uneven contour
	'WF204'  % landmark detection failure
	'WF207'  % uneven contour
	'WF210'  % hair
	'WF212'  % uneven contour
	'WF213'  % hair
	'WF235'  % hair
	'WF238'  % hair/shade
	'WF250'  % landmark detection failure
	'WM001'  % hair
	'WM015'  % hair
	'WM017'  % uneven contour
	'WM033'  % hair
	'WM036'  % hair
	'WM037'  % hair
	'WM038'  % hair/shade
	'WM039'  % hair
	'WM209'  % hair
	'WM210'  % hair
	'WM219'  % hair
	'WM225'  % hair
	'WM236'  % hair
	'WM237'  % hair
	'WM239'  % hair
	};
