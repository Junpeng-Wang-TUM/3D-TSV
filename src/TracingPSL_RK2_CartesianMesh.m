function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK2_CartesianMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
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
	[elementIndex, paraCoordinates, bool1] = PositioningOnCartesianMesh(midPot);		
	if bool1
		cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);
		cartesianStressOnGivenPoint = ElementInterpolationTrilinear(cartesianStress, paraCoordinates);
		principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
		[k2, terminationCond] = BidirectionalFeatureProcessing(k1, principalStress(typePSL));
		nextPoint = startPoint + tracingStepWidth_*k2;
		[elementIndex, paraCoordinates, bool1] = PositioningOnCartesianMesh(nextPoint);
		while bool1
			index = index + 1; if index > limiSteps, index = index-1; break; end
			%%k1
			cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);
			cartesianStressOnGivenPoint = ElementInterpolationTrilinear(cartesianStress, paraCoordinates);
			vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
			[k1, terminationCond] = BidirectionalFeatureProcessing(iniDir, principalStress(typePSL));
			if ~terminationCond, index = index-1; break; end
			%%k2
			midPot = nextPoint + k1*tracingStepWidth_/2;
			[elementIndex2, paraCoordinates2, bool1] = PositioningOnCartesianMesh(midPot);
			if ~bool1, index = index-1; break; end
			cartesianStress2 = cartesianStressField_(eNodMat_(elementIndex2,:)', :);
			cartesianStressOnGivenPoint2 = ElementInterpolationTrilinear(cartesianStress2, paraCoordinates2);
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
			[elementIndex, paraCoordinates, bool1] = PositioningOnCartesianMesh(nextPoint);				
		end
	end
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end