function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_Euler_UnstructuredMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	siE = 1.0e-06;
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);
	nextPoint = startPoint + tracingStepWidth_*iniDir;
	[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint);
	index = 0;	
	while 1==bool1
		index = index + 1; if index > limiSteps, index = index-1; break; end
		NIdx = eNodMat_(elementIndex,:)';
		vtxStress = cartesianStressField_(NIdx, :);
		vtxCoords = nodeCoords_(NIdx,:); 
		cartesianStressOnGivenPoint = ElementInterpolationInverseDistanceWeighting(vtxCoords, vtxStress, nextPoint); 
		vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
		principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
		evs = principalStress([1 5 9]);
		if min([abs((evs(1)-evs(2))/2/(evs(1)+evs(2))) abs((evs(3)-evs(2))/2/(evs(3)+evs(2)))])<siE, index = index-1; break; end %%degenerate point
		[nextDir, terminationCond] = BidirectionalFeatureProcessing(iniDir, principalStress(typePSL));
		if ~terminationCond, index = index-1; break; end		
		iniDir = nextDir;
		phyCoordList(index,:) = nextPoint;
		cartesianStressList(index,:) = cartesianStressOnGivenPoint;
		eleIndexList(index,:) = elementIndex;
		vonMisesStressList(index,:) = vonMisesStress;
		principalStressList(index,:) = principalStress;				
		nextPoint = nextPoint + tracingStepWidth_*iniDir;
		[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint);
	end		
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end