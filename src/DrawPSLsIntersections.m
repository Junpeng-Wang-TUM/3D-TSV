function DrawPSLsIntersections(radius)
	global snappingOpt_;
	if snappingOpt_, disp('Not Work with Snapping Option!'); return; end
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	lineWidthTube = lw*minimumEpsilon_/2.5;
	intersectionList = [];
	for ii=1:length(majorPSLpool_)
		intersectionList(end+1,1:3) = majorPSLpool_(ii).phyCoordList(majorPSLpool_(ii).midPointPosition,:);
	end
	for ii=1:length(mediumPSLpool_)
		intersectionList(end+1,1:3) = mediumPSLpool_(ii).phyCoordList(mediumPSLpool_(ii).midPointPosition,:);
	end
	for ii=1:length(minorPSLpool_)
		intersectionList(end+1,1:3) = minorPSLpool_(ii).phyCoordList(minorPSLpool_(ii).midPointPosition,:);
	end
	intersectionList = unique(intersectionList, 'rows');
	
end