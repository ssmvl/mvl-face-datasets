function [estX, estY] = estUpperLandmarks(lmInfo, padding)
	lmX = lmInfo.pnts(:, 1);
	lmY = lmInfo.pnts(:, 2);

	cx = mean(lmInfo.bbox([1 3]));
	cy = mean(lmInfo.bbox([2 4]));
	baseX = lmX([19, 26]);
	baseY = lmY([19, 26]);
	[srcT, srcE] = cart2pol(baseX - cx, baseY - cy);
	estT = linspace(srcT(1), srcT(end), 7)';
	estE = linspace(srcE(1), srcE(end), 7)' + padding;
	[estX, estY] = pol2cart(estT, estE);
	estX = estX(2:(end - 1)) + cx;
	estY = estY(2:(end - 1)) + cy;
end