function iPSL = GeneratePrincipalStressLines(initialSeed, tracingType, limiSteps)
	global tracingStepWidth_;
	global traceAlg_;
	iPSL = PrincipalStressLineStruct();
	switch tracingType
		case 'MAJORPSL', psDir = [10 11 12];
		case 'MEDIUMPSL', psDir = [6 7 8];		
		case 'MINORPSL', psDir = [2 3 4];
	end
	%%1. prepare for tracing			
	[eleIndex, ~, phyCoord, cartesianStress, vonMisesStress, principalStress, opt] = ...
		PreparingForTracing(initialSeed);
	if 0==opt, return; end
	
	%%2. tracing the major PSL
	PSLphyCoordList = phyCoord;
	PSLcartesianStressList = cartesianStress;
	PSLeleIndexList = eleIndex;
	PSLvonMisesStressList = vonMisesStress;
	PSLprincipalStressList = principalStress;			
	%%2.1 tracing the major PSL along first direction (v1)		
	nextPoint = phyCoord + tracingStepWidth_*principalStress(1,psDir);
	switch traceAlg_
		case 'Euler'
			[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
				TracingPSL_Euler(nextPoint, principalStress(1,psDir), eleIndex, psDir, limiSteps);
		case 'RK2'
			[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
				TracingPSL_RK2(nextPoint, principalStress(1,psDir), eleIndex, psDir, limiSteps);			
		case 'RK4'
			[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
				TracingPSL_RK4(nextPoint, principalStress(1,psDir), eleIndex, psDir, limiSteps);		
	end	
	PSLphyCoordList = [PSLphyCoordList; phyCoordList];
	PSLcartesianStressList = [PSLcartesianStressList; cartesianStressList];
	PSLeleIndexList = [PSLeleIndexList; eleIndexList];
	PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
	PSLprincipalStressList = [PSLprincipalStressList; principalStressList];		
	%%2.2 tracing the major PSL along second direction (-v1)	
	nextPoint = phyCoord - tracingStepWidth_*principalStress(1,psDir);
	switch traceAlg_
		case 'Euler'
			[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
				TracingPSL_Euler(nextPoint, -principalStress(1,psDir), eleIndex, psDir, limiSteps);
		case 'RK2'
			[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
				TracingPSL_RK2(nextPoint, -principalStress(1,psDir), eleIndex, psDir, limiSteps);		
		case 'RK4'
			[phyCoordList, cartesianStressList, eleIndexList, ~, vonMisesStressList, principalStressList] = ...
				TracingPSL_RK4(nextPoint, -principalStress(1,psDir), eleIndex, psDir, limiSteps);			
	end		
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
		shapeFuncs = ShapeFunction(paraCoord(1), paraCoord(2), paraCoord(3));	
		phyCoord = shapeFuncs*eleNodeCoords;
		cartesianStress = shapeFuncs*eleCartesianStress;
	else
		paraCoord = [0 0 0];
		phyCoord = initialSeed(1,end-2:end);
		cartesianStress = ElementInterpolationIDW(eleNodeCoords, eleCartesianStress, phyCoord); 			
	end
	vonMisesStress = ComputeVonMisesStress(cartesianStress);
	principalStress = ComputePrincipalStress(cartesianStress);
end

function [tarSeed, opt] = LocateSeedPoint(srcSeed)
	global meshType_;
	global eleCentroidList_;
	opt = 1;
	if strcmp(meshType_, 'CARTESIAN_GRID')
		[targetEleIndex, paraCoordinates, opt] = FindAdjacentElement(srcSeed);	
	else
		disList = vecnorm(srcSeed-eleCentroidList_, 2, 2);
		[~, targetEleIndex] = min(disList); 
		[targetEleIndex, paraCoordinates, opt] = FindAdjacentElement(targetEleIndex, srcSeed);
	end
	tarSeed = [double(targetEleIndex), paraCoordinates];
end

function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_Euler(nextPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	global meshType_; 
	
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);		
	if strcmp(meshType_, 'CARTESIAN_GRID')
		[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(nextPoint);	
		index = 0;	
		while 1==bool1
			index = index + 1; if index > limiSteps, index = index-1; break; end	
			cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);	
			shapeFuncs = ShapeFunction(paraCoordinates(1), paraCoordinates(2), paraCoordinates(3));
			cartesianStressOnGivenPoint = shapeFuncs*cartesianStress;
			vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);	
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);				
			[nextDir, terminationCond] = IntegrationDirectionSelecting(iniDir, principalStress(typePSL));
			if ~terminationCond, index = index-1; break; end			
			iniDir = nextDir;
			phyCoordList(index,:) = nextPoint;
			cartesianStressList(index,:) = cartesianStressOnGivenPoint;
			eleIndexList(index,:) = elementIndex;
			vonMisesStressList(index,:) = vonMisesStress;
			principalStressList(index,:) = principalStress;			
			nextPoint = nextPoint + tracingStepWidth_*iniDir;
			[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(nextPoint);
		end		
	else
		[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, nextPoint);	
		index = 0;	
		while 1==bool1
			index = index + 1; if index > limiSteps, index = index-1; break; end
			NIdx = eNodMat_(elementIndex,:)';
			vtxStress = cartesianStressField_(NIdx, :);
			vtxCoords = nodeCoords_(NIdx,:); 
			cartesianStressOnGivenPoint = ElementInterpolationIDW(vtxCoords, vtxStress, nextPoint); 
			vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
			[nextDir, terminationCond] = IntegrationDirectionSelecting(iniDir, principalStress(typePSL));
			if ~terminationCond, index = index-1; break; end		
			iniDir = nextDir;
			phyCoordList(index,:) = nextPoint;
			cartesianStressList(index,:) = cartesianStressOnGivenPoint;
			eleIndexList(index,:) = elementIndex;
			vonMisesStressList(index,:) = vonMisesStress;
			principalStressList(index,:) = principalStress;				
			nextPoint = nextPoint + tracingStepWidth_*iniDir;
			[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, nextPoint);
		end		
	end
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end

function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK2(nextPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	global meshType_; 
	
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);	

	%%initialize initial k1 and k2
	k1 = iniDir;
	iniPot = nextPoint - k1*tracingStepWidth_;
	midPot = nextPoint - k1*tracingStepWidth_/2;
	index = 0;	
	
	if strcmp(meshType_, 'CARTESIAN_GRID')
		[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(midPot);	
		if bool1
			cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);
			shapeFuncs = ShapeFunction(paraCoordinates(1), paraCoordinates(2), paraCoordinates(3));
			cartesianStressOnGivenPoint = shapeFuncs*cartesianStress;
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
			[k2, terminationCond] = IntegrationDirectionSelecting(k1, principalStress(typePSL));
			nextPoint = iniPot + tracingStepWidth_*k2;
			[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(nextPoint);
			while bool1
				index = index + 1; if index > limiSteps, index = index-1; break; end
				%%k1
				cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);
				shapeFuncs = ShapeFunction(paraCoordinates(1), paraCoordinates(2), paraCoordinates(3));
				cartesianStressOnGivenPoint = shapeFuncs*cartesianStress;
				vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
				principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
				[k1, terminationCond] = IntegrationDirectionSelecting(iniDir, principalStress(typePSL));
				if ~terminationCond, index = index-1; break; end
				%%k2
				midPot = nextPoint + k1*tracingStepWidth_/2;
				[elementIndex2, paraCoordinates2, bool1] = FindAdjacentElement(midPot);
				if ~bool1, index = index-1; break; end
				cartesianStress2 = cartesianStressField_(eNodMat_(elementIndex2,:)', :);
				shapeFuncs = ShapeFunction(paraCoordinates2(1), paraCoordinates2(2), paraCoordinates2(3));
				cartesianStressOnGivenPoint2 = shapeFuncs*cartesianStress2;
				principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
				[k2, terminationCond] = IntegrationDirectionSelecting(k1, principalStress2(typePSL));
				%%store	
				iniDir = k1;
				phyCoordList(index,:) = nextPoint;
				cartesianStressList(index,:) = cartesianStressOnGivenPoint;
				eleIndexList(index,:) = elementIndex;			
				vonMisesStressList(index,:) = vonMisesStress;
				principalStressList(index,:) = principalStress;
				%%next point
				nextPoint = nextPoint + tracingStepWidth_*k2;		
				[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(nextPoint);				
			end
		end	
	else
		[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, midPot);
		NIdx = eNodMat_(elementIndex,:)';
		vtxStress = cartesianStressField_(NIdx, :);
		vtxCoords = nodeCoords_(NIdx,:); 
		cartesianStressOnGivenPoint = ElementInterpolationIDW(vtxCoords, vtxStress, midPot);
		principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
		[k2, terminationCond] = IntegrationDirectionSelecting(k1, principalStress(typePSL));
		nextPoint = iniPot + tracingStepWidth_*k2;
		[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(elementIndex, nextPoint);
		while bool1
			index = index + 1; if index > limiSteps, index = index-1; break; end
			NIdx = eNodMat_(elementIndex,:)';
			vtxStress = cartesianStressField_(NIdx, :);
			vtxCoords = nodeCoords_(NIdx,:); 
			cartesianStressOnGivenPoint = ElementInterpolationIDW(vtxCoords, vtxStress, nextPoint); 
			vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);						
			%%k1
			[k1, terminationCond] = IntegrationDirectionSelecting(iniDir, principalStress(typePSL));	
			if ~terminationCond, index = index-1; break; end
			%%k2
			midPot = nextPoint + k1*tracingStepWidth_/2;
			[elementIndex2, ~, bool1] = FindAdjacentElement(elementIndex, midPot);
			if ~bool1, index = index-1; break; end
			NIdx2 = eNodMat_(elementIndex2,:)';	
			vtxStress2 = cartesianStressField_(NIdx2,:);
			vtxCoords2 = nodeCoords_(NIdx2,:);
			cartesianStressOnGivenPoint2 = ElementInterpolationIDW(vtxCoords2, vtxStress2, midPot);
			principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
			[k2, terminationCond] = IntegrationDirectionSelecting(k1, principalStress2(typePSL));	
			%%store	
			iniDir = k1;
			phyCoordList(index,:) = nextPoint;
			cartesianStressList(index,:) = cartesianStressOnGivenPoint;
			eleIndexList(index,:) = elementIndex;
			vonMisesStressList(index,:) = vonMisesStress;
			principalStressList(index,:) = principalStress;
			%%next point
			nextPoint = nextPoint + tracingStepWidth_*k2;
			[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex2, nextPoint);			
		end	
	end
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end

function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK4(nextPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	global meshType_; 
	
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);

	%%initialize initial k1, k2, k3 and k4
	k1 = iniDir;
	iniPot = nextPoint - k1*tracingStepWidth_;
	midPot1 = nextPoint - k1*tracingStepWidth_/2;
	index = 0;
	
	if strcmp(meshType_, 'CARTESIAN_GRID')
		[elementIndex2, paraCoordinates2, bool1] = FindAdjacentElement(midPot1);
		if bool1
			%%k2
			cartesianStress2 = cartesianStressField_(eNodMat_(elementIndex2,:)', :);
			shapeFuncs2 = ShapeFunction(paraCoordinates2(1), paraCoordinates2(2), paraCoordinates2(3));
			cartesianStressOnGivenPoint2 = shapeFuncs2*cartesianStress2;
			principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
			[k2, terminationCond] = IntegrationDirectionSelecting(k1, principalStress2(typePSL));
			midPot2 = iniPot + tracingStepWidth_*k2/2;
			%%k3
			[elementIndex3, paraCoordinates3, bool1] = FindAdjacentElement(midPot2);
			if bool1
				cartesianStress3 = cartesianStressField_(eNodMat_(elementIndex3,:)', :);
				shapeFuncs3 = ShapeFunction(paraCoordinates3(1), paraCoordinates3(2), paraCoordinates3(3));
				cartesianStressOnGivenPoint3 = shapeFuncs3*cartesianStress3;
				principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
				[k3, terminationCond] = IntegrationDirectionSelecting(k1, principalStress3(typePSL));
				midPot3 = iniPot + tracingStepWidth_*k3;
				%%k4
				[elementIndex4, paraCoordinates4, bool1] = FindAdjacentElement(midPot3);
				if bool1
					cartesianStress4 = cartesianStressField_(eNodMat_(elementIndex4,:)', :);
					shapeFuncs4 = ShapeFunction(paraCoordinates4(1), paraCoordinates4(2), paraCoordinates4(3));
					cartesianStressOnGivenPoint4 = shapeFuncs4*cartesianStress4;
					principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
					[k4, terminationCond] = IntegrationDirectionSelecting(k1, principalStress4(typePSL));
					nextPoint = iniPot + tracingStepWidth_ * (k1 + 2*k2 + 2*k3 + k4)/6;
					[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(nextPoint);
					while bool1
						index = index + 1; if index > limiSteps, index = index-1; break; end						
						cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);
						shapeFuncs = ShapeFunction(paraCoordinates(1), paraCoordinates(2), paraCoordinates(3));
						cartesianStressOnGivenPoint = shapeFuncs*cartesianStress;
						vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
						principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);						
						%%k1
						[k1, terminationCond] = IntegrationDirectionSelecting(iniDir, principalStress(typePSL));
						if ~terminationCond, index = index-1; break; end
						midPot1 = nextPoint + k1*tracingStepWidth_/2;
						%%k2
						[elementIndex2, paraCoordinates2, bool1] = FindAdjacentElement(midPot1);
						if ~bool1, index = index-1; break; end
						cartesianStress2 = cartesianStressField_(eNodMat_(elementIndex2,:)', :);
						shapeFuncs2 = ShapeFunction(paraCoordinates2(1), paraCoordinates2(2), paraCoordinates2(3));
						cartesianStressOnGivenPoint2 = shapeFuncs2*cartesianStress2;
						principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
						[k2, ~] = IntegrationDirectionSelecting(iniDir, principalStress2(typePSL));						
						midPot2 = nextPoint + k2*tracingStepWidth_/2;
						%%k3
						[elementIndex3, paraCoordinates3, bool1] = FindAdjacentElement(midPot2);
						if ~bool1, index = index-1; break; end
						cartesianStress3 = cartesianStressField_(eNodMat_(elementIndex3,:)', :);
						shapeFuncs3 = ShapeFunction(paraCoordinates3(1), paraCoordinates3(2), paraCoordinates3(3));
						cartesianStressOnGivenPoint3 = shapeFuncs3*cartesianStress3;
						principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
						[k3, ~] = IntegrationDirectionSelecting(iniDir, principalStress3(typePSL));						
						midPot3 = nextPoint + k3*tracingStepWidth_;
						%%k4
						[elementIndex4, paraCoordinates4, bool1] = FindAdjacentElement(midPot3);
						if ~bool1, index = index-1; break; end
						cartesianStress4 = cartesianStressField_(eNodMat_(elementIndex4,:)', :);
						shapeFuncs4 = ShapeFunction(paraCoordinates4(1), paraCoordinates4(2), paraCoordinates4(3));
						cartesianStressOnGivenPoint4 = shapeFuncs4*cartesianStress4;
						principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
						[k4, ~] = IntegrationDirectionSelecting(iniDir, principalStress4(typePSL));
						%%store	
						iniDir = k1;
						phyCoordList(index,:) = nextPoint;
						cartesianStressList(index,:) = cartesianStressOnGivenPoint;
						eleIndexList(index,:) = elementIndex;			
						vonMisesStressList(index,:) = vonMisesStress;
						principalStressList(index,:) = principalStress;
						%%next point
						nextPoint = nextPoint + tracingStepWidth_ * (k1 + 2*k2 + 2*k3 + k4)/6;		
						[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(nextPoint);							
					end
				end
			end
		end
	else
		[elementIndex2, ~, bool1] = FindAdjacentElement(elementIndex, midPot1);
		if bool1
			%%k2
			NIdx2 = eNodMat_(elementIndex2,:)';
			vtxStress2 = cartesianStressField_(NIdx2, :);
			vtxCoords2 = nodeCoords_(NIdx2,:); 		
			cartesianStressOnGivenPoint2 = ElementInterpolationIDW(vtxCoords2, vtxStress2, midPot1);
			principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
			[k2, ~] = IntegrationDirectionSelecting(k1, principalStress2(typePSL));
			midPot2 = iniPot + tracingStepWidth_*k2/2;
			%%k3
			[elementIndex3, ~, bool1] = FindAdjacentElement(elementIndex2, midPot2);
			if bool1
				NIdx3 = eNodMat_(elementIndex3,:)';
				vtxStress3 = cartesianStressField_(NIdx3, :);
				vtxCoords3 = nodeCoords_(NIdx3,:); 			
				cartesianStressOnGivenPoint3 = ElementInterpolationIDW(vtxCoords3, vtxStress3, midPot2);
				principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
				[k3, ~] = IntegrationDirectionSelecting(k1, principalStress3(typePSL));
				midPot3 = iniPot + tracingStepWidth_*k3;
				%%k4
				[elementIndex4, ~, bool1] = FindAdjacentElement(elementIndex3, midPot3);
				if bool1
					NIdx4 = eNodMat_(elementIndex4,:)';
					vtxStress4 = cartesianStressField_(NIdx4, :);
					vtxCoords4 = nodeCoords_(NIdx4,:);
					cartesianStressOnGivenPoint4 = ElementInterpolationIDW(vtxCoords4, vtxStress4, midPot3);
					principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
					[k4, ~] = IntegrationDirectionSelecting(k1, principalStress4(typePSL));

					nextPoint = iniPot + tracingStepWidth_ * (k1 + 2*k2 + 2*k3 + k4)/6;
					[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, nextPoint);
					while bool1
						index = index + 1; if index > limiSteps, index = index-1; break; end
						NIdx = eNodMat_(elementIndex,:)';
						vtxStress = cartesianStressField_(NIdx, :);
						vtxCoords = nodeCoords_(NIdx,:); 		
						cartesianStressOnGivenPoint = ElementInterpolationIDW(vtxCoords, vtxStress, midPot1);
						vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
						principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint2);
						%%k1						
						[k1, terminationCond] = IntegrationDirectionSelecting(iniDir, principalStress(typePSL));
						if ~terminationCond, index = index-1; break; end
						midPot1 = nextPoint + tracingStepWidth_*k1/2;
						%%k2
						[elementIndex2, ~, bool1] = FindAdjacentElement(elementIndex, midPot1);
						if ~bool1, index = index-1; break; end
						NIdx2 = eNodMat_(elementIndex2,:)';
						vtxStress2 = cartesianStressField_(NIdx2, :);
						vtxCoords2 = nodeCoords_(NIdx2,:); 		
						cartesianStressOnGivenPoint2 = ElementInterpolationIDW(vtxCoords2, vtxStress2, midPot1);
						principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
						[k2, ~] = IntegrationDirectionSelecting(iniDir, principalStress2(typePSL));
						midPot2 = nextPoint + tracingStepWidth_*k2/2;
						%%k3
						[elementIndex3, ~, bool1] = FindAdjacentElement(elementIndex2, midPot2);
						if ~bool1, index = index-1; break; end
						NIdx3 = eNodMat_(elementIndex3,:)';
						vtxStress3 = cartesianStressField_(NIdx3, :);
						vtxCoords3 = nodeCoords_(NIdx3,:); 		
						cartesianStressOnGivenPoint3 = ElementInterpolationIDW(vtxCoords3, vtxStress3, midPot2);
						principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
						[k3, ~] = IntegrationDirectionSelecting(iniDir, principalStress3(typePSL));
						midPot3 = nextPoint + tracingStepWidth_*k3;	
						%%k4
						[elementIndex4, ~, bool1] = FindAdjacentElement(elementIndex3, midPot3);
						if ~bool1, index = index-1; break; end
						NIdx4 = eNodMat_(elementIndex4,:)';
						vtxStress4 = cartesianStressField_(NIdx4, :);
						vtxCoords4 = nodeCoords_(NIdx4,:); 		
						cartesianStressOnGivenPoint4 = ElementInterpolationIDW(vtxCoords4, vtxStress4, midPot3);
						principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
						[k4, ~] = IntegrationDirectionSelecting(iniDir, principalStress4(typePSL));
						%%store	
						iniDir = k1;
						phyCoordList(index,:) = nextPoint;
						cartesianStressList(index,:) = cartesianStressOnGivenPoint;
						eleIndexList(index,:) = elementIndex;			
						vonMisesStressList(index,:) = vonMisesStress;
						principalStressList(index,:) = principalStress;						
						%%next point
						nextPoint = nextPoint + tracingStepWidth_ * (k1 + 2*k2 + 2*k3 + k4)/6;		
						[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, nextPoint);						
					end
				end
			end
		end
	end

	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end

function [targetDirection, terminationCond] = IntegrationDirectionSelecting(originalVec, Vec)
	global permittedMaxAdjacentTangentAngleDeviation_;
	terminationCond = 1;
	normOriVec = norm(originalVec); normVec = norm(Vec);
	angle1 = acos( originalVec*Vec' / (normOriVec*normVec) );
	angle2 = acos( -originalVec*Vec' / (normOriVec*normVec) );
	if angle1 < angle2
		targetDirection = Vec;
		if angle1 > pi/permittedMaxAdjacentTangentAngleDeviation_, terminationCond = 0; end
	else
		targetDirection = -Vec;
		if angle2 > pi/permittedMaxAdjacentTangentAngleDeviation_, terminationCond = 0; end
	end
end

function [nextElementIndex, paraCoordinates, opt] = FindAdjacentElement(varargin)
	global nodeCoords_; global eleCentroidList_; 
	global eNodMat_; global nodStruct_;
	global meshState_; global eleMapBack_;
	global boundaryElements_;
	global nelx_; global nely_; global nelz_; global eleSize_;
	global vtxLowerBound_;
	
	nextElementIndex = 0; paraCoordinates = []; opt = 0;

	if 1==nargin
		physicalCoordinates = varargin{1};		
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
	elseif 2==nargin
		oldElementIndex = varargin{1};
		physicalCoordinates = varargin{2};
		tarNodes = eNodMat_(oldElementIndex,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
		tarNodes = eNodMat_(potentialElements,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]); %% balance between safety and efficiency
		disList = vecnorm(physicalCoordinates-eleCentroidList_(potentialElements,:), 2, 2);
		[~, nextElementIndex] = min(disList); nextElementIndex = potentialElements(nextElementIndex);
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% safe but low efficiency version
		% disList = vecnorm(physicalCoordinates-eleCentroidList_, 2, 2);
		% [minVal, nextElementIndex] = min(disList); 
		boundaryMetric = intersect(nextElementIndex, boundaryElements_);
		opt = 1;
		if ~isempty(boundaryMetric)
			eleNodeCoords = nodeCoords_(eNodMat_(nextElementIndex,:)',:);
			[~, ~, opt, ~] = NewtonIteration(eleNodeCoords, physicalCoordinates);
		end				
	end
end

function [paraCoordinates, res, opt, index] = NewtonIteration(vtxVec, target)
	%% solving a nonlinear system of equasions by Newton-Rhapson's method
	%%	f1(s,t,p) = tar1
	%%	f2(s,t,p) = tar2
	%%	:			:
	%%	:			:
	%%	fi(s,t,p) = tari
	opt = 0;
	normTar = norm(target);
	errThreshold = 1.0e-4; RF = 100*errThreshold;
	s = -0.0; t = -0.0; p = -0.0; maxIts = 200;
	index = 0;
	for ii=1:maxIts
		index = index+1;
		c0 = ShapeFunction(s, t, p)';	
		dShape = DeShapeFunction(s, t, p);
		dns = dShape(1,:)';
		dnt = dShape(2,:)';
		dnp = dShape(3,:)';
		d2Shape = De2ShapeFunction(s, t, p);
		dnss = d2Shape(1,:)';
		dntt = d2Shape(2,:)';
		dnpp = d2Shape(3,:)';
		dntp = d2Shape(4,:)';
		dnps = d2Shape(5,:)';
		dnst = d2Shape(6,:)';		
		
		q = vtxVec' * c0;
		dqs = vtxVec' * dns;
		dqt = vtxVec' * dnt;
		dqp = vtxVec' * dnp;
			
		dfdv1 = [dqs'; dqt'; dqp'];
		b = dfdv1*(q-target');
		if 0==normTar
			res = norm(q-target');
		else
			res = norm(b);
		end
		if res < errThreshold, break; end

		dfdss = vtxVec'*dnss;
		dfdtt = vtxVec'*dntt;
		dfdpp = vtxVec'*dnpp;
		dfdtp = vtxVec'*dntp;
		dfdps = vtxVec'*dnps;
		dfdst = vtxVec'*dnst;
		A11 = dfdss' * (q-target') + norm(dqs)^2;
		A22 = dfdtt' * (q-target') + norm(dqt)^2;
		A33 = dfdpp' * (q-target') + norm(dqp)^2;
		A21 = dfdst' * (q-target') + dqs'*dqt; A12 = A21;
		A23 = dfdtp' * (q-target') + dqt'*dqp; A32 = A23;
		A31 = dfdps' * (q-target') + dqp'*dqs; A13 = A31;
		A = [A11 A12 A13; A21 A22 A23; A31 A32 A33];
		x = A\(-b);
		s = s + x(1); t = t + x(2); p = p + x(3);
	end
	
	if res <= errThreshold && abs(s)<=RF+1 && abs(t)<=RF+1 && abs(p)<=RF+1
		opt = 1;
	end
	paraCoordinates = [s t p];
end

function N = ShapeFunction(s, t, p)
	%				*8			*7
	%			*5			*6
	%					p
	%				   |__s 
	%				  /-t
	%				*4			*3
	%			*1			*2
	%
	%			LINEAR:	8-nodes
	%--------------------------------------------------------------------------------		
	N = zeros(1,8);
	N(1) = 0.125*(1-s)*(1-t)*(1-p);
	N(2) = 0.125*(1+s)*(1-t)*(1-p);
	N(3) = 0.125*(1+s)*(1+t)*(1-p);
	N(4) = 0.125*(1-s)*(1+t)*(1-p);
	N(5) = 0.125*(1-s)*(1-t)*(1+p);
	N(6) = 0.125*(1+s)*(1-t)*(1+p);
	N(7) = 0.125*(1+s)*(1+t)*(1+p);
	N(8) = 0.125*(1-s)*(1+t)*(1+p);			
end

function dShape = DeShapeFunction(s, t, p)		
	dN1ds = -0.125*(1-t)*(1-p); dN2ds = 0.125*(1-t)*(1-p); 
	dN3ds = 0.125*(1+t)*(1-p);  dN4ds = -0.125*(1+t)*(1-p);
	dN5ds = -0.125*(1-t)*(1+p); dN6ds = 0.125*(1-t)*(1+p); 
	dN7ds = 0.125*(1+t)*(1+p);  dN8ds = -0.125*(1+t)*(1+p);
	
	dN1dt = -0.125*(1-s)*(1-p); dN2dt = -0.125*(1+s)*(1-p); 
	dN3dt = 0.125*(1+s)*(1-p);  dN4dt = 0.125*(1-s)*(1-p);
	dN5dt = -0.125*(1-s)*(1+p); dN6dt = -0.125*(1+s)*(1+p); 
	dN7dt = 0.125*(1+s)*(1+p);  dN8dt = 0.125*(1-s)*(1+p);
	
	dN1dp = -0.125*(1-s)*(1-t); dN2dp = -0.125*(1+s)*(1-t); 
	dN3dp = -0.125*(1+s)*(1+t); dN4dp = -0.125*(1-s)*(1+t);
	dN5dp = 0.125*(1-s)*(1-t);  dN6dp = 0.125*(1+s)*(1-t); 
	dN7dp = 0.125*(1+s)*(1+t);  dN8dp = 0.125*(1-s)*(1+t);
	
	dShape = [
		dN1ds dN2ds dN3ds dN4ds dN5ds dN6ds dN7ds dN8ds
		dN1dt dN2dt dN3dt dN4dt dN5dt dN6dt dN7dt dN8dt
		dN1dp dN2dp dN3dp dN4dp dN5dp dN6dp dN7dp dN8dp ];	
end

function d2Shape = De2ShapeFunction(s, t, p)	
	dN1dss = 0; dN2dss = 0; dN3dss = 0;  dN4dss = 0;	
	dN5dss = 0; dN6dss = 0; dN7dss = 0;  dN8dss = 0;
	
	dN1dtt = 0; dN2dtt = 0; dN3dtt = 0; dN4dtt = 0;
	dN5dtt = 0; dN6dtt = 0; dN7dtt = 0; dN8dtt = 0;
	
	dN1dpp = 0; dN2dpp = 0; dN3dpp = 0; dN4dpp = 0;
	dN5dpp = 0; dN6dpp = 0; dN7dpp = 0; dN8dpp = 0;
	
	dN1dst = 1-p;		dN2dst = -(1-p);		dN3dst = 1-p;		dN4dst = -(1-p);
	dN5dst = 1+p;		dN6dst = -(1+p);		dN7dst = 1+p;		dN8dst = -(1+p);
	
	dN1dsp = 1-t;		dN2dsp = -(1-t);		dN3dsp = -(1+t);	dN4dsp = 1+t;
	dN5dsp = -(1-t);	dN6dsp = 1-t;			dN7dsp = 1+t;		dN8dsp = -(1+t);
	
	dN1dtp = 1-s;		dN2dtp = 1+s;			dN3dtp = -(1+s);	dN4dtp = -(1-s);
	dN5dtp = -(1-s);	dN6dtp = -(1+s);		dN7dtp = 1+s;		dN8dtp = 1-s;
				
	d2Shape = [
		dN1dss dN2dss dN3dss dN4dss dN5dss dN6dss dN7dss dN8dss
		dN1dtt dN2dtt dN3dtt dN4dtt dN5dtt dN6dtt dN7dtt dN8dtt
		dN1dpp dN2dpp dN3dpp dN4dpp dN5dpp dN6dpp dN7dpp dN8dpp
		dN1dtp dN2dtp dN3dtp dN4dtp dN5dtp dN6dtp dN7dtp dN8dtp
		dN1dsp dN2dsp dN3dsp dN4dsp dN5dsp dN6dsp dN7dsp dN8dsp
		dN1dst dN2dst dN3dst dN4dst dN5dst dN6dst dN7dst dN8dsp ];
	d2Shape = 0.125 * d2Shape;	
end

function principalStress = ComputePrincipalStress(cartesianStress)
	principalStress = zeros(1, 12);
	A = cartesianStress([1 6 5; 6 2 4; 5 4 3]);
	[eigenVec, eigenVal] = eig(A);
	principalStress([1 5 9]) = diag(eigenVal);
	principalStress([2 3 4 6 7 8 10 11 12]) = reshape(eigenVec,1,9);
end

function val = ComputeVonMisesStress(cartesianStress)
	val = sqrt( 0.5*( (cartesianStress(1)-cartesianStress(2))^2 + ...
		(cartesianStress(2)-cartesianStress(3))^2 + (cartesianStress(3)...
			-cartesianStress(1))^2 ) + 3*( cartesianStress(6)^2 + ...
				cartesianStress(4)^2 + cartesianStress(5)^2 ) );						
end

function val = ElementInterpolationIDW(coords, vtxVals, ips)
	%% adapted from the work by Simone Fatichi -- simonef@dicea.unifi.it
	%% coords --> element vertex coordinates, Matrix: [N-by-2] for 2D, [N-by-3] for 3D, N=4 or 8 for 1st-order quad- or hex- mesh
	%% vtxVals --> entities on element vertics, Matrix: [N-by-M], e.g., M==3 or 6 for 2D or 3D stress tensor
	%% ips --> to-be interpolated coordinate, Vector: [1-by-2] for 2D or [1-by-3] for 3D
	
	e = -2;
	D = vecnorm(ips-coords,2,2);
	[sortedD, sortedMapVec] = sort(D);
    if 0==sortedD(1)
        val = vtxVals(sortedMapVec(1),:); return;
    end
	sortedVtxVals = vtxVals(sortedMapVec,:);
	wV = sortedD.^e;
	V = sortedVtxVals.*wV;	
	val = sum(V) / sum(wV);
end