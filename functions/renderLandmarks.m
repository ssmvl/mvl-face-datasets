function N = renderLandmarks(lmInfo, markerSize, lineWidth)
	if ~exist('markerSize', 'var') || isempty(markerSize)
		markerSize = 3;
	end
	if ~exist('lineWidth', 'var') || isempty(lineWidth)
		lineWidth = 1;
	end

	I = imread(lmInfo.file);
	I = im2double(I);
	if size(I, 3) == 1
		N = repmat(I, [1 1 3]);
	else
		N = I;
	end

	bboxIdx = round(lmInfo.bbox' + repmat((1:lineWidth) - mean(1:lineWidth), 4, 1));
	N(bboxIdx(2, 1):bboxIdx(4, end), [bboxIdx(1, :), bboxIdx(3, :)], :) = 1;
	N([bboxIdx(2, :), bboxIdx(4, :)], bboxIdx(1, 1):bboxIdx(3, end), :) = 1;

	markerIdx = (1:markerSize) - round(markerSize / 2);
	for i = 1:size(lmInfo.pnts, 1)
		if lmInfo.shown(i)
			lmX = round(lmInfo.pnts(i, 1));
			lmY = round(lmInfo.pnts(i, 2));
			N(lmY + markerIdx, lmX + markerIdx, [1 3]) = 1;
			N(lmY + markerIdx, lmX + markerIdx, 2) = 0;
		end
	end
end