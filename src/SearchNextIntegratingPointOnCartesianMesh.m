function [nextElementIndex, paraCoordinates, opt] = SearchNextIntegratingPointOnCartesianMesh(physicalCoordinates)
	global nodeCoords_;
	global eNodMat_;
	global meshState_; global eleMapBack_;
	global nelx_; global nely_; global nelz_; global eleSize_;
	global boundingBox_;
	
	nextElementIndex = 0; paraCoordinates = []; opt = 0;
	
	physicalCoordinates = physicalCoordinates - boundingBox_(1,:);
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
		relatedNodeCoords = nodeCoords_(relatedNodes',:)-boundingBox_(1,:);
		paraCoordinates = 2*(physicalCoordinates - relatedNodeCoords(1,:)) / eleSize_ - 1;
	end	
end