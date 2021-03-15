function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_Euler_CartesianMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
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
	nextPoint = startPoint + tracingStepWidth_*iniDir;
	[elementIndex, paraCoordinates, bool1] = SearchNextIntegratingPointOnCartesianMesh(nextPoint);
	index = 0;	
	while 1==bool1
		index = index + 1; if index > limiSteps, index = index-1; break; end	
		cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);	
		cartesianStressOnGivenPoint = ElementInterpolationTrilinear(cartesianStress, paraCoordinates);
		vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);	
		principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);				
		[nextDir, terminationCond] = BidirectionalFeatureProcessing(iniDir, principalStress(typePSL));
		if ~terminationCond, index = index-1; break; end			
		iniDir = nextDir;
		phyCoordList(index,:) = nextPoint;
		cartesianStressList(index,:) = cartesianStressOnGivenPoint;
		eleIndexList(index,:) = elementIndex;
		vonMisesStressList(index,:) = vonMisesStress;
		principalStressList(index,:) = principalStress;			
		nextPoint = nextPoint + tracingStepWidth_*iniDir;
		[elementIndex, paraCoordinates, bool1] = SearchNextIntegratingPointOnCartesianMesh(nextPoint);
	end	
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end