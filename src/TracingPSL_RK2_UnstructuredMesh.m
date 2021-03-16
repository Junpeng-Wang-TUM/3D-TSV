function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK2_UnstructuredMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);	

	%%initialize initial k1 and k2
	k1 = iniDir;
	midPot = startPoint + k1*tracingStepWidth_/2;
	index = 0;	
	[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot);
	NIdx = eNodMat_(elementIndex,:)';
	vtxStress = cartesianStressField_(NIdx, :);
	vtxCoords = nodeCoords_(NIdx,:); 
	cartesianStressOnGivenPoint = ElementInterpolationInverseDistanceWeighting(vtxCoords, vtxStress, midPot);
	principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
	[k2, terminationCond] = BidirectionalFeatureProcessing(k1, principalStress(typePSL));
	nextPoint = startPoint + tracingStepWidth_*k2;
	[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint);
	while bool1
		index = index + 1; if index > limiSteps, index = index-1; break; end
		NIdx = eNodMat_(elementIndex,:)';
		vtxStress = cartesianStressField_(NIdx, :);
		vtxCoords = nodeCoords_(NIdx,:); 
		cartesianStressOnGivenPoint = ElementInterpolationInverseDistanceWeighting(vtxCoords, vtxStress, nextPoint); 
		vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
		principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);						
		%%k1
		[k1, terminationCond] = BidirectionalFeatureProcessing(iniDir, principalStress(typePSL));	
		if ~terminationCond, index = index-1; break; end
		%%k2
		midPot = nextPoint + k1*tracingStepWidth_/2;
		[elementIndex2, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot);
		if ~bool1, index = index-1; break; end
		NIdx2 = eNodMat_(elementIndex2,:)';	
		vtxStress2 = cartesianStressField_(NIdx2,:);
		vtxCoords2 = nodeCoords_(NIdx2,:);
		cartesianStressOnGivenPoint2 = ElementInterpolationInverseDistanceWeighting(vtxCoords2, vtxStress2, midPot);
		principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
		[k2, terminationCond] = BidirectionalFeatureProcessing(k1, principalStress2(typePSL));	
		%%store	
		iniDir = k1;
		phyCoordList(index,:) = nextPoint;
		cartesianStressList(index,:) = cartesianStressOnGivenPoint;
		eleIndexList(index,:) = elementIndex;
		vonMisesStressList(index,:) = vonMisesStress;
		principalStressList(index,:) = principalStress;
		%%next point
		nextPoint = nextPoint + tracingStepWidth_*k2;
		[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex2, nextPoint);	
	end	
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end