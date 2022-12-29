function previewCutout(lmInfo, padding, lowpass)
	if ~exist('lowpass', 'var') || isempty(lowpass)
		lowpass = 0;
	end

	imshow(imread(lmInfo.file));
	hold on;
	[cutoutX, cutoutY] = cutoutOutline(lmInfo, padding, lowpass);
	patch('XData', cutoutX, 'YData', cutoutY, 'FaceAlpha', 0, ...
		'EdgeColor', 'w', 'LineWidth', 1);
	hold off;
end