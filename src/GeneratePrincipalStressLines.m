function iPSL = GeneratePrincipalStressLines(initialSeed, tracingType, limiSteps)
	global tracingStepWidth_;
	global traceAlg_;
	global tracingFuncHandle_;
	iPSL = PrincipalStressLineStruct();
	switch tracingType
		case 'MAJORPSL', psDir = [10 11 12];
		case 'MEDIUMPSL', psDir = [6 7 8];		
		case 'MINORPSL', psDir = [2 3 4];
	end
	%%1. prepare for tracing			
	[eleIndex, ~, phyCoord, cartesianStress, vonMisesStress, principalStress, opt] = PreparingForTracing(initialSeed);
	if 0==opt, return; end
	
	%%2. tracing PSL
	PSLphyCoordList = phyCoord;
	PSLcartesianStressList = cartesianStress;
	PSLeleIndexList = eleIndex;
	PSLvonMisesStressList = vonMisesStress;
	PSLprincipalStressList = principalStress;			
	%%2.1 along first direction (v1)		
	nextPoint = phyCoord + tracingStepWidth_*principalStress(1,psDir);
	[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
		tracingFuncHandle_(nextPoint, principalStress(1,psDir), eleIndex, psDir, limiSteps);	
	PSLphyCoordList = [PSLphyCoordList; phyCoordList];
	PSLcartesianStressList = [PSLcartesianStressList; cartesianStressList];
	PSLeleIndexList = [PSLeleIndexList; eleIndexList];
	PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
	PSLprincipalStressList = [PSLprincipalStressList; principalStressList];		
	%%2.2 along second direction (-v1)	
	nextPoint = phyCoord - tracingStepWidth_*principalStress(1,psDir);
	[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
		tracingFuncHandle_(nextPoint, -principalStress(1,psDir), eleIndex, psDir, limiSteps);	
	if size(phyCoordList,1) > 1
		phyCoordList = flip(phyCoordList);
		cartesianStressList = flip(cartesianStressList);
		eleIndexList = flip(eleIndexList);
		vonMisesStressList = flip(vonMisesStressList);
		principalStressList = flip(principalStressList);
	end						
	PSLphyCoordList = [phyCoordList; PSLphyCoordList];
	PSLcartesianStressList = [cartesianStressList; PSLcartesianStressList];
	PSLeleIndexList = [eleIndexList; PSLeleIndexList];
	PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
	PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
	%%2.3 finish Tracing the current major PSL	
	iPSL.midPointPosition = size(phyCoordList,1)+1;
	iPSL.length = size(PSLphyCoordList,1);
	iPSL.eleIndexList = PSLeleIndexList;
	iPSL.phyCoordList = PSLphyCoordList;
	iPSL.cartesianStressList = PSLcartesianStressList;	
	iPSL.vonMisesStressList = PSLvonMisesStressList;
	iPSL.principalStressList = PSLprincipalStressList;	
end

function [eleIndex, paraCoord, phyCoord, cartesianStress, vonMisesStress, principalStress, varargout] = PreparingForTracing(initialSeed)
	global nodeCoords_; global eNodMat_;
	global cartesianStressField_;
	global meshType_;
	eleIndex = 0;
	paraCoord = 0; 
	phyCoord = 0; 
	cartesianStress = 0;
	vonMisesStress = 0; 
	principalStress = 0;
	[formatedSeed, opt] = LocateSeedPoint(initialSeed);
	varargout{1} = opt;
	if 0==opt, return; end
	eleIndex = formatedSeed(1,1);
	NIdx = eNodMat_(eleIndex,:)';
	eleNodeCoords = nodeCoords_(NIdx,:);
	eleCartesianStress = cartesianStressField_(NIdx,:);				
	if strcmp(meshType_, 'CARTESIAN_GRID')	
		paraCoord = formatedSeed(1, 2:4);
		[phyCoord, shapeFuncs] = ElementInterpolationTrilinear(eleNodeCoords, paraCoord);
		cartesianStress = shapeFuncs*eleCartesianStress;
	else
		paraCoord = [0 0 0];
		phyCoord = initialSeed(1,end-2:end);
		cartesianStress = ElementInterpolationInverseDistanceWeighting(eleNodeCoords, eleCartesianStress, phyCoord); 		
	end
	vonMisesStress = ComputeVonMisesStress(cartesianStress);
	principalStress = ComputePrincipalStress(cartesianStress);
end

function [tarSeed, opt] = LocateSeedPoint(srcSeed)
	global meshType_;
	global eleCentroidList_;
	opt = 1;
	if strcmp(meshType_, 'CARTESIAN_GRID')	
		[targetEleIndex, paraCoordinates, opt] = PositioningOnCartesianMesh(srcSeed);
		tarSeed = [double(targetEleIndex), paraCoordinates];
	else
		disList = vecnorm(srcSeed-eleCentroidList_, 2, 2);
		[~, targetEleIndex] = min(disList); 
		[targetEleIndex, opt] = PositioningOnUnstructuredMesh_old(targetEleIndex, srcSeed);
		tarSeed = targetEleIndex;
	end
end