function [nextElementIndex, paraCoordinates, opt] = PositioningOnCartesianMesh(physicalCoordinates)
	global nodeCoords_;
	global eNodMat_;
	global meshState_; global eleMapBack_;
	global nelx_; global nely_; global nelz_; global eleSize_;
	global vtxLowerBound_;
	
	nextElementIndex = 0; paraCoordinates = []; opt = 0;
	
	physicalCoordinates = physicalCoordinates - vtxLowerBound_;
	if 0==physicalCoordinates(1)
		eleX = 1;				
	else
		eleX = ceil(physicalCoordinates(1)/eleSize_);
		if eleX<1 || eleX>nelx_, return; end
	end
	if 0==physicalCoordinates(2)
		eleY = 1;
	else
		eleY = ceil(physicalCoordinates(2)/eleSize_);
		if eleY<1 || eleY>nely_, return; end
	end
	if 0==physicalCoordinates(3)
		eleZ = 1;
	else
		eleZ = ceil(physicalCoordinates(3)/eleSize_);
		if eleZ<1 || eleZ>nelz_, return; end
	end			
	
	tarEle = nelx_*nely_*(eleZ-1) + nely_*(eleX-1)+(nely_-eleY+1);
	if meshState_(tarEle)
		nextElementIndex = eleMapBack_(tarEle);
		opt = 1;
		relatedNodes = eNodMat_(nextElementIndex,:);
		relatedNodeCoords = nodeCoords_(relatedNodes',:)-vtxLowerBound_;
		paraCoordinates = 2*(physicalCoordinates - relatedNodeCoords(1,:)) / eleSize_ - 1;
	end	
end