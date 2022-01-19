function [eleIndex, opt] = PositioningOnUnstructuredMesh(targetEleIndex0, startPoint)
	global eNodMat_; 
	global nodStruct_;
	global eleCentroidList_;
	opt = IsThisPointWithinThatElement(targetEleIndex0, startPoint, 0);
	if opt
		eleIndex = targetEleIndex0;		
	else %% Search the Adjacent Elements
		tarNodes = eNodMat_(targetEleIndex0,:);
		allPotentialAdjacentElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
		potentialAdjacentElements = setdiff(allPotentialAdjacentElements, targetEleIndex0);
		for ii=1:length(potentialAdjacentElements)
			iEle = potentialAdjacentElements(ii);
			opt = IsThisPointWithinThatElement(iEle, startPoint, 0);
			if opt, eleIndex = iEle; break; end
		end
	end
	if 0==opt		
		disList = vecnorm(startPoint-eleCentroidList_(allPotentialAdjacentElements,:), 2, 2);
		[~, nearOptimalEle] = min(disList);
		eleIndex = allPotentialAdjacentElements(nearOptimalEle);
	end
end