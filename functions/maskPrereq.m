function tf = maskPrereq(lmInfo, margin)
	if ~exist('margin', 'var') || isempty(margin)
		margin = [2, 2];  % nose, mouth
	end
	tf = false;

	lmMask = false(68, 1);
	lmMask([3:15, 30]) = true;
	if ~all(lmInfo.shown(lmMask))
		return;
	end

	lmNose = lmInfo.pnts(31, 1) - lmInfo.pnts(3, 1);
	rmNose = lmInfo.pnts(15, 1) - lmInfo.pnts(31, 1);
	if (lmNose < margin(1)) || (rmNose < margin(1))
		return;
	end

	lmMouth = min(lmInfo.pnts(49:51, 1)) - lmInfo.pnts(4, 1);
	rmMouth = lmInfo.pnts(14, 1) - max(lmInfo.pnts(53:55, 1));
	if (lmMouth < margin(2)) || (rmMouth < margin(2))
		return;
	end

	tf = true;
end