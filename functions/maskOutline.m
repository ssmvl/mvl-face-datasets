function [maskX, maskY] = maskOutline(lmInfo, padding, nPnts)
	if ~exist('nPnts', 'var') || isempty(nPnts)
		nPnts = [100, 200];  % upper contour, lower contour
	end

	lmX = lmInfo.pnts(:, 1);
	lmY = lmInfo.pnts(:, 2);

	cxLower = mean(lmX([3, 15]));
	cyLower = mean(lmY([3, 15]));
	[padlX, padlY] = padLowerLandmarks(lmX(3:15), lmY(3:15), padding(2));
	[padlT, padlE] = cart2pol(padlX - cxLower, padlY - cyLower);
	padlT = padlT + ((padlT < (-pi / 2)) * 2 * pi);
	lowerT = linspace(padlT(1), padlT(end), nPnts(2));
	lowerE = spline(padlT, padlE, lowerT);
	[lowerX, lowerY] = pol2cart(lowerT, lowerE);
	lowerX = lowerX + cxLower;
	lowerY = lowerY + cyLower;

	lmuX = [lowerX(1), lmX(30) - padding(1), lmX(30) + padding(1), lowerX(end)];
	lmuY = [lowerY(1), lmY(30), lmY(30), lowerY(end)];
 	upperX = linspace(lmX(3), lmX(15), nPnts(1));
	upperY = pchip(lmuX, lmuY, upperX);

	maskX = [lowerX, upperX((end - 1):-1:1)];
	maskY = [lowerY, upperY((end - 1):-1:1)];
end