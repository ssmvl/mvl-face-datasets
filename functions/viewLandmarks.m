function viewLandmarks(lmInfo)
	imshow(imread(lmInfo.file));
	hold on;

	bbox = lmInfo.bbox;
	bbox(3:4) = bbox(3:4) - bbox(1:2);
	rectangle('Position', bbox, 'EdgeColor', 'w', 'LineWidth', 1);

	lmX = lmInfo.pnts(lmInfo.shown, 1);
	lmY = lmInfo.pnts(lmInfo.shown, 2);
	plot(lmX, lmY, '.', 'MarkerSize', 8, 'MarkerEdgeColor', 'magenta');

	lmNo = 1:size(lmInfo.pnts, 1);
	text(lmX, lmY, num2cell(lmNo(lmInfo.shown)), 'Color', 'magenta', ...
		'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
	hold off;
end