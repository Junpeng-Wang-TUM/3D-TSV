function [nextElementIndex, opt] = SearchNextIntegratingPointOnUnstructuredMesh(oldElementIndex, physicalCoordinates)
	global eleCentroidList_; 
	global eNodMat_; global nodStruct_; global boundaryElements_;
	tarNodes = eNodMat_(oldElementIndex,:); 
	potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
	disList = vecnorm(physicalCoordinates-eleCentroidList_(potentialElements,:), 2, 2);
	[~, nextElementIndex] = min(disList); nextElementIndex = potentialElements(nextElementIndex);
	[nextElementIndex, opt] = PositioningOnUnstructuredMesh(nextElementIndex, physicalCoordinates);
	%%additional security check
	if 0==opt && isempty(intersect(nextElementIndex, boundaryElements_)) 
		disList = vecnorm(physicalCoordinates-eleCentroidList_, 2, 2);
		[~, targetEleIndex0] = min(disList);	
		[nextElementIndex, opt] = PositioningOnUnstructuredMesh(targetEleIndex0, physicalCoordinates);
	end
end
