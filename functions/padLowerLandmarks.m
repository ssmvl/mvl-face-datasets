function [padX, padY] = padLowerLandmarks(lmX, lmY, padding)
	difX = lmX([2:end, end]) - lmX([1, 1:(end - 1)]);
	difY = lmY([2:end, end]) - lmY([1, 1:(end - 1)]);
	orthX = difY ./ hypot(difX, difY);
	orthY = difX ./ hypot(difX, difY);
	padX = lmX - orthX * padding;
	padY = lmY + orthY * padding;
end