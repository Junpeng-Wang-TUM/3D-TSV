function [nextElementIndex, p1, opt] = SearchNextIntegratingPointOnUnstructuredMesh(oldElementIndex, physicalCoordinates, sPoint, relocatingP1)
	[nextElementIndex, p1, opt] = ...
		SearchNextIntegratingPointOnUnstructuredMesh_planA(oldElementIndex, physicalCoordinates, sPoint, relocatingP1);
		
	% [nextElementIndex, p1, opt] = ...
		% SearchNextIntegratingPointOnUnstructuredMesh_planB(oldElementIndex, physicalCoordinates, sPoint, relocatingP1);
		
	% [nextElementIndex, p1, opt] = ...
		% SearchNextIntegratingPointOnUnstructuredMesh_planC(oldElementIndex, physicalCoordinates, sPoint, relocatingP1);
end

function [nextElementIndex, p1, opt] = SearchNextIntegratingPointOnUnstructuredMesh_planA(oldElementIndex, physicalCoordinates, sPoint, relocatingP1)
	global eleCentroidList_; 
	global eNodMat_; 
	global nodStruct_; 
	global eleState_;

	p1 = physicalCoordinates;
	nextElementIndex = oldElementIndex;	
	opt = IsThisPointWithinThatElement(oldElementIndex, p1, 0);

	if opt
		return;
	else	
		tarNodes = eNodMat_(oldElementIndex,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
		adjEleCtrs = eleCentroidList_(potentialElements,:);
		disList = vecnorm(p1-adjEleCtrs, 2, 2);
		[~, reSortMap] = sort(disList);
		potentialElements = potentialElements(reSortMap);
		for jj=1:length(potentialElements)
			iEle = potentialElements(jj);
			opt = IsThisPointWithinThatElement(iEle, p1, 0);
			if opt, nextElementIndex = iEle; return; end
		end		
	end
	%%Scaling down the stepsize via Dichotomy
	if relocatingP1 && 0==opt	
		nn = 5;
		ii = 1;	
		while ii<=nn
			p1 = (sPoint+p1)/2;
			disList = vecnorm(p1-adjEleCtrs, 2, 2);
			[~, reSortMap] = sort(disList);
			potentialElements = potentialElements(reSortMap);			
			for jj=1:length(potentialElements)
				iEle = potentialElements(jj);
				opt = IsThisPointWithinThatElement(iEle, p1, 0);
				if opt, nextElementIndex = iEle; return; end
			end
			ii = ii + 1;
		end
		if 0==eleState_(oldElementIndex)
			nextElementIndex = oldElementIndex; opt = 1;
		end
	end	
end

function [nextElementIndex, p1, opt] = SearchNextIntegratingPointOnUnstructuredMesh_planB(oldElementIndex, physicalCoordinates, sPoint, relocatingP1)
	global eNodMat_; 
	global nodStruct_; 
	global eleState_;
	p1 = physicalCoordinates;
	nextElementIndex = oldElementIndex;
	
	opt = IsThisPointWithinThatElement(oldElementIndex, p1, 0);
	backupPoints = [];
	if opt
		return;
	else
		tarNodes = eNodMat_(oldElementIndex,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
		for jj=1:length(potentialElements)
			iEle = potentialElements(jj);
			opt = IsThisPointWithinThatElement(iEle, p1, 0);
			if opt				
				nextElementIndex = iEle; %return;
				opt = 0;
				backupPoints(end+1,:) = [nextElementIndex p1];
				refNodes = eNodMat_(nextElementIndex,:);
				if 2<length(intersect(tarNodes, refNodes))
					opt = 1;
					return;
				end 
			end
		end		
	end
	
	%%Scaling down the stepsize via Dichotomy
	if relocatingP1 && 0==opt
		nn = 5;
		ii = 1;	
		while ii<=nn
			p1 = (sPoint+p1)/2;		
			for jj=1:length(potentialElements)
				iEle = potentialElements(jj);
				opt = IsThisPointWithinThatElement(iEle, p1, 0);
				
				if opt
					nextElementIndex = iEle; %return;
					opt = 0;					
					backupPoints(end+1,:) = [nextElementIndex p1];
					refNodes = eNodMat_(nextElementIndex,:);
					if 2<length(intersect(tarNodes, refNodes))
						opt = 1;
						return;
					end 
				end
			end
			ii = ii + 1;
		end
		
		if ~isempty(backupPoints)
			opt = 1;
			nextElementIndex = backupPoints(1,1);
			p1 = backupPoints(1,2:end);
			return;
		end
		if 0==eleState_(oldElementIndex)
			nextElementIndex = oldElementIndex; opt = 1;
		end		
	end	
end

function [nextElementIndex, p1, opt] = SearchNextIntegratingPointOnUnstructuredMesh_planC(oldElementIndex, physicalCoordinates, sPoint, relocatingP1)
	global eleCentroidList_; 
	global eNodMat_; 
	global nodStruct_;
	global eleStruct_;
	global eleState_;
	p1 = physicalCoordinates;
	nextElementIndex = oldElementIndex;	
	opt = IsThisPointWithinThatElement(oldElementIndex, p1, 0);
	
	if opt
		return;
	else
		%%Identify Intersected Cell Surface
		tarNodes = eNodMat_(oldElementIndex,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);		
		iNorms = eleStruct_(oldElementIndex).faceNormals;
		iCtrs = eleStruct_(oldElementIndex).faceCentres;
		iAlphas = zeros(6,1);
		for ii=1:6
			v1 = (p1-sPoint);
			v1 = v1/norm(v1);
			iAlphas(ii) = iNorms(ii,:)*(iCtrs(ii,:)-sPoint)' / (iNorms(ii,:)*v1');
		end
		potentialFaces = find(iAlphas>0);
		if ~isempty(potentialFaces)
			[~, sourceFace] = min(iAlphas(potentialFaces));
			sourceFace = potentialFaces(sourceFace);
			sourceNorm = iNorms(sourceFace,:);
			
			%%Relate Adjacent Cell Connected "oldElementIndex" by "sourceFace"
			nestedPotentialElements = setdiff(potentialElements, oldElementIndex);
			numNestedPotentialElements = numel(nestedPotentialElements);
			allCellFaceNormal = zeros(6*numNestedPotentialElements, 3);
			for ii=1:numNestedPotentialElements
				allCellFaceNormal(6*(ii-1)+1:6*ii,:) = eleStruct_(nestedPotentialElements(ii)).faceNormals;
			end
			mes1 = real(acos(allCellFaceNormal*sourceNorm'));
			[~, targetFace] = max(mes1);
			potentialTargetElement = nestedPotentialElements(ceil(targetFace/6));
			
			%%Check the Potential Target Cell	
			if relocatingP1
				nn = 5;
			else
				nn = 1;
			end
			ii = 1;
			while ii<=nn
				opt = IsThisPointWithinThatElement(potentialTargetElement, p1, 0);
				if opt, nextElementIndex = potentialTargetElement; return; end		
				opt = IsThisPointWithinThatElement(oldElementIndex, p1, 0);
				if opt, return; end
				ii = ii + 1;
				p1 = (sPoint+p1)/2;
			end			
		end	
		
		%%Relaxed Check for Special Cases
		p1 = physicalCoordinates;
		adjEleCtrs = eleCentroidList_(potentialElements,:);
		disList = vecnorm(p1-adjEleCtrs, 2, 2);
		[~, reSortMap] = sort(disList);
		potentialElements = potentialElements(reSortMap);
		for jj=1:length(potentialElements)
			iEle = potentialElements(jj);
			opt = IsThisPointWithinThatElement(iEle, p1, 0);
			if opt, nextElementIndex = iEle; return; end
		end		
	end
	
	%%Scaling down the stepsize via Dichotomy
	if relocatingP1 && 0==opt
		nn = 5;
		ii = 1;	
		while ii<=nn
			p1 = (sPoint+p1)/2;
			disList = vecnorm(p1-adjEleCtrs, 2, 2);
			[~, reSortMap] = sort(disList);
			potentialElements = potentialElements(reSortMap);			
			for jj=1:length(potentialElements)
				iEle = potentialElements(jj);
				opt = IsThisPointWithinThatElement(iEle, p1, 0);
				if opt, nextElementIndex = iEle; return; end
			end
			ii = ii + 1;
		end
		if 0==eleState_(oldElementIndex)
			nextElementIndex = oldElementIndex; opt = 1;
		end
	end	
end