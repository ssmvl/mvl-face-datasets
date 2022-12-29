clear;
addpath(fullfile('..', '..', 'functions'));

Vars_CFD;

load('landmarks.mat');

imgMarginFig = 'cutout-margin.fig';
lmCutoutFile = 'landmarks-cutout.mat';
cutoutImgDir = 'imgs-face-cutout';

%%
%  Generate face-cutout images
%
if ~exist(cutoutImgDir, 'dir')
	mkdir(cutoutImgDir);
end

imgMargin = [];
lmInfo = lmInfo(arrayfun(@(lm) ~isempty(lm.pnts), lmInfo));
fprintf('generating cutout images from %d face images:\n', length(lmInfo));
for i = 1:length(lmInfo)
	if any(strcmp(lmInfo(i).imgId, CFD.cutout.rejectedImgIds))
		lmInfo(i).bbox = [];
		lmInfo(i).pnts = [];
		lmInfo(i).shown = logical([]);
		fprintf('!');
	else
		[cutoutX, cutoutY] = cutoutOutline(lmInfo(i), CFD.cutout.padding, CFD.cutout.lowpass);
		img = imread(lmInfo(i).file);

		hfig = figure('Color', [1 1 1]);
		imshow(img, 'Border', 'tight', 'Interpolation', 'bilinear');
		imgClean = im2double(getframe(hfig.Children(1)).cdata);
		close(hfig);
		% update landmark information (scaling, workaround for small screens)
		wScale = size(imgClean, 2) / size(img, 2);
		hScale = size(imgClean, 1) / size(img, 1);
		lmInfo(i).bbox = lmInfo(i).bbox .* [wScale, hScale, wScale, hScale];
		lmInfo(i).pnts(:, 1) = lmInfo(i).pnts(:, 1) * wScale;
		lmInfo(i).pnts(:, 2) = lmInfo(i).pnts(:, 2) * hScale;

		hfig = figure('Color', [0 0 0]);
		imshow(zeros(size(img)));
		patch(cutoutX, cutoutY, [1 1 1], 'LineStyle', 'none');
		imgAlpha = rgb2gray(im2double(getframe(hfig.Children(1)).cdata));
		close(hfig);

		cx = mean(lmInfo(i).pnts([28 29], 1));
		cy = (min(cutoutY) + max(cutoutY)) / 2;
		imSize = round(sqrt(sum(imgAlpha(:))) * CFD.cutout.imScale);
		xidx = round((1:imSize) - (1 + imSize) / 2 + cx);
		yidx = round((1:imSize) - (1 + imSize) / 2 + cy);
		cutoutFile = fullfile(cutoutImgDir, strcat(lmInfo(i).imgId, '.png'));
		imwrite(imgClean(yidx, xidx, :), cutoutFile, 'Alpha', imgAlpha(yidx, xidx));
		% update landmark information (cutout)
		wOffset = min(xidx) - 1;
		hOffset = min(yidx) - 1;
		lmInfo(i).file = cutoutFile;
		lmInfo(i).bbox = lmInfo(i).bbox - [wOffset, hOffset, wOffset, hOffset];
		lmInfo(i).pnts(:, 1) = lmInfo(i).pnts(:, 1) - wOffset;
		lmInfo(i).pnts(:, 2) = lmInfo(i).pnts(:, 2) - hOffset;
		lmInfo(i).cxcy = [cx - wOffset, cy - hOffset];
		lmInfo(i).imSize = imSize;
		lmInfo(i).margin = min(cutoutY) - min(yidx);
		fprintf('.');
	end
	if mod(i, 50) == 0
		fprintf('\n');
	end
end
if mod(length(lmInfo), 50) ~= 0
	fprintf('\n');
end
save(lmCutoutFile, 'lmInfo');



%%
%  Plot and save upper and lower margins in the cutout images
%
hf = figure;
histogram([lmInfo.margin]);
legend('Upper/lower margin', 'Location', 'northwest');
legend boxoff;
saveas(hf, imgMarginFig);



%%
%  Wrapping up
%
fprintf('all set, please proceed to Step4_BuildDataset\n\n');
