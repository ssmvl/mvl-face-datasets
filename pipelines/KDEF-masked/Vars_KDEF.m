KDEF.imgDir = 'KDEF';

% file naming convention
KDEF.setIds = {'A', 'B'};
KDEF.models = cat(1, ...
	arrayfun(@(n) sprintf('F%02d', n), (1:35)', 'UniformOutput', false), ...
	arrayfun(@(n) sprintf('M%02d', n), (1:35)', 'UniformOutput', false));
KDEF.exprs  = {'AF', 'AN', 'DI', 'HA', 'NE', 'SA', 'SU'};
KDEF.angles = {'HL', 'S', 'HR'};  % FL and FR angles will not be used

% background patch function
KDEF.bgPatch.L = @(I) mean(I(1:75, [1:75, (end-74):end]), [1 2]);
% background patch lightness cutoff
KDEF.bgPatch.cutoffL = [.40, .68];
% background patch normalized lightness
KDEF.bgPatch.normL = .60;

% manually rejected images (when using set B as a default set)
KDEF.setPref = [2 1];
KDEF.rejectedImgIds{1} = {
	'M15NES'   % bg. patch normalization fail (underexposure)
	};
KDEF.rejectedImgIds{2} = {
	'F08SAHL'  % to prevent landmark detection failure
	'F17AFHR'  % unclean background
	'F17AFS'   % non-straight position
	'M01ANS'   % unclean background
	'M27DIS'   % bg. patch normalization fail (underexposure)
	'M28ANS'   % bg. patch normalization fail (underexposure)
	};

% mask - required margins for mask shape estimation
KDEF.mask.reqMargin  = [8, 4];  % nose/mouth at least 8/4 pixels inside the facial contour

% mask - visual properties
KDEF.mask.padding = {
	[6, 6]  % padding for straight angle images
	[8, 8]  % padding for half left, half right angle images
	};
KDEF.mask.color = [.6 .6 .6];
KDEF.mask.lineColor = [.4 .4 .4];
KDEF.mask.lineWidth = 1;

% manually rejected images
KDEF.mask.rejectedImgIds = {
	'F02DIHL'  % landmark detection failure
	'F02HAHL'  % landmark detection failure
	'F21ANS'   % landmark detection failure
	'F21NES'   % landmark detection failure
	'F30AFS'   % landmark detection failure
	'F30ANS'   % landmark detection failure
	'F30DIS'   % landmark detection failure
	'F30NES'   % landmark detection failure
	'F32HAHL'  % chin outside the mask
	'M03SAHL'  % nose outside the mask
	'M05SUHR'  % lips outside the mask
	'M08HAHR'  % chin outside the mask
	'M10AFHL'  % nose outside the mask
	'M10AFHR'  % chin outside the mask
	'M10ANHR'  % landmark detection failure
	'M10DIHL'  % nose outside the mask
	'M10HAHR'  % chin outside the mask
	'M12AFHL'  % nose outside the mask
	'M12DIHL'  % landmark detection failure
	'M13ANHR'  % landmark detection failure
	'M17ANHL'  % landmark detection failure
	'M17ANHR'  % landmark detection failure
	'M18ANHR'  % landmark detection failure
	'M18ANS'   % landmark detection failure
	'M22DIHL'  % nose outside the facial contour
	'M29ANS'   % landmark detection failure
	'M30AFHL'  % nose outside the facial contour
	'M30ANHL'  % nose outside the facial contour
	'M30NEHL'  % nose outside the facial contour
	'M32ANHL'  % lips outside the facial contour
	};
