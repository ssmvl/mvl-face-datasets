function [cutoutX, cutoutY] = cutoutOutline(lmInfo, padding, lowpass)
	if ~exist('lowpass', 'var') || isempty(lowpass)
		lowpass = 0;
	end

	lmX = lmInfo.pnts(:, 1);
	lmY = lmInfo.pnts(:, 2);

	[padlX, padlY] = padLowerLandmarks(lmX(1:17), lmY(1:17), -padding(2));
	[estuX, estuY] = estUpperLandmarks(lmInfo, padding(1));

	padX = [padlX(9:17); estuX(end:-1:1); padlX(1:8)];
	padY = [padlY(9:17); estuY(end:-1:1); padlY(1:8)];
	cx = mean(lmInfo.bbox([1 3]));
	cy = mean(lmInfo.bbox([2 4]));
	[padT, padE] = cart2pol(padX - cx, padY - cy);
	padT(13:end) = padT(13:end) - (padT(13:end) > 0) * 2 * pi();

	intpT = [padT + 2 * pi(); padT; padT - 2 * pi()];
	intpE = repmat(padE, 3, 1);
	cutoutT = linspace(0, 2 * pi(), 361);
	cutoutE = spline(intpT, intpE, cutoutT);

	if lowpass > 0
		fftE = fft([cutoutE(1:360), cutoutE(1:360), cutoutE]);
		filtE = exp(-.5 * ((-[0:540, 540:-1:1]) ./ lowpass) .^ 2);
		ifftE = real(ifft(fftE .* filtE));
		cutoutE = real(ifftE(360 + (1:361)));
	end

	[cutoutX, cutoutY] = pol2cart(cutoutT, cutoutE);
	cutoutX = cutoutX + cx;
	cutoutY = cutoutY + cy;
end