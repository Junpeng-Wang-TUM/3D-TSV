function [majorPSL, mediumPSL, minorPSL] = GeneratePrincipalStressLines(initialSeed, tracingType, limiSteps)
	global tracingStepWidth_;
	majorPSL = PrincipalStressLineStruct();
	mediumPSL = PrincipalStressLineStruct();
	minorPSL = PrincipalStressLineStruct();
	switch tracingType
		case 'ALL'
			%%1. prepare for tracing			
			[eleIndex, paraCoord, phyCoord, vonMisesStress, principalStress, opt] = PreparingForTracing(initialSeed);
			if 0==opt, return; end
			
			%%2. tracing the major PSL
			PSLphyCoordList = phyCoord;
			PSLeleIndexList = eleIndex;
			PSLparaCoordList = paraCoord;
			PSLvonMisesStressList = vonMisesStress;
			PSLprincipalStressList = principalStress;
			%%2.1 tracing the major PSL along first direction (v1)		
			nextPoint = phyCoord + tracingStepWidth_*principalStress(1,10:12);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, principalStress(1,10:12), eleIndex, 'MAJORPSL', limiSteps);
			PSLphyCoordList = [PSLphyCoordList; phyCoordList];
			PSLeleIndexList = [PSLeleIndexList; eleIndexList];
			PSLparaCoordList = [PSLparaCoordList; paraCoordList];
			PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
			PSLprincipalStressList = [PSLprincipalStressList; principalStressList];		
			%%2.2 tracing the major PSL along second direction (-v1)	
			nextPoint = phyCoord - tracingStepWidth_*principalStress(1,10:12);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, -principalStress(1,10:12), eleIndex, 'MAJORPSL', limiSteps);
			if size(phyCoordList,1) > 1
				phyCoordList = flip(phyCoordList);
				eleIndexList = flip(eleIndexList);
				paraCoordList = flip(paraCoordList);
				vonMisesStressList = flip(vonMisesStressList);
				principalStressList = flip(principalStressList);
			end					
			PSLphyCoordList = [phyCoordList; PSLphyCoordList];
			PSLeleIndexList = [eleIndexList; PSLeleIndexList];
			PSLparaCoordList = [paraCoordList; PSLparaCoordList];
			PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
			PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
			majorPSL.midPointPosition = size(phyCoordList,1)+1;
			%%2.3 finish Tracing the current major PSL			
			majorPSL.length = size(PSLphyCoordList,1);
			majorPSL.eleIndexList = PSLeleIndexList;
			majorPSL.phyCoordList = PSLphyCoordList;
			majorPSL.paraCoordList = PSLparaCoordList;	
			majorPSL.vonMisesStressList = PSLvonMisesStressList;
			majorPSL.principalStressList = PSLprincipalStressList;			
			
			%%3. tracing the medium PSL
			PSLphyCoordList = phyCoord;
			PSLeleIndexList = eleIndex;
			PSLparaCoordList = paraCoord;
			PSLvonMisesStressList = vonMisesStress;
			PSLprincipalStressList = principalStress;
			%%3.1 tracing the medium PSL along first direction (v1)
			nextPoint = phyCoord + tracingStepWidth_*principalStress(1,6:8);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, principalStress(1,6:8), eleIndex, 'MEDIUMPSL', limiSteps);
			PSLphyCoordList = [PSLphyCoordList; phyCoordList];
			PSLeleIndexList = [PSLeleIndexList; eleIndexList];
			PSLparaCoordList = [PSLparaCoordList; paraCoordList];
			PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
			PSLprincipalStressList = [PSLprincipalStressList; principalStressList];	
			%%3.2 tracing the medium PSL along second direction (-v1)
			nextPoint = phyCoord - tracingStepWidth_*principalStress(1,6:8);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, -principalStress(1,6:8), eleIndex, 'MEDIUMPSL', limiSteps);
			if size(phyCoordList,1) > 1
				phyCoordList = flip(phyCoordList);
				eleIndexList = flip(eleIndexList);
				paraCoordList = flip(paraCoordList);
				vonMisesStressList = flip(vonMisesStressList);
				principalStressList = flip(principalStressList);
			end						
			PSLphyCoordList = [phyCoordList; PSLphyCoordList];
			PSLeleIndexList = [eleIndexList; PSLeleIndexList];
			PSLparaCoordList = [paraCoordList; PSLparaCoordList];
			PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
			PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
			mediumPSL.midPointPosition = size(phyCoordList,1)+1;
			%%3.3 finish Tracing the current medium PSL			
			mediumPSL.length = size(PSLphyCoordList,1);
			mediumPSL.eleIndexList = PSLeleIndexList;
			mediumPSL.phyCoordList = PSLphyCoordList;
			mediumPSL.paraCoordList = PSLparaCoordList;	
			mediumPSL.vonMisesStressList = PSLvonMisesStressList;
			mediumPSL.principalStressList = PSLprincipalStressList;
			
			%%4. tracing the minimum PSL
			PSLphyCoordList = phyCoord;
			PSLeleIndexList = eleIndex;
			PSLparaCoordList = paraCoord;
			PSLvonMisesStressList = vonMisesStress;
			PSLprincipalStressList = principalStress;
			%%4.1 tracing the minor PSL along first direction (v1)
			nextPoint = phyCoord + tracingStepWidth_*principalStress(1,2:4);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, principalStress(1,2:4), eleIndex, 'MINORPSL', limiSteps);
			PSLphyCoordList = [PSLphyCoordList; phyCoordList];
			PSLeleIndexList = [PSLeleIndexList; eleIndexList];
			PSLparaCoordList = [PSLparaCoordList; paraCoordList];
			PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
			PSLprincipalStressList = [PSLprincipalStressList; principalStressList];			
			%%4.2 tracing the minor PSL along second direction (-v1)
			nextPoint = phyCoord - tracingStepWidth_*principalStress(1,2:4);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, -principalStress(1,2:4), eleIndex, 'MINORPSL', limiSteps);
			if size(phyCoordList,1) > 1
				phyCoordList = flip(phyCoordList);
				eleIndexList = flip(eleIndexList);
				paraCoordList = flip(paraCoordList);
				vonMisesStressList = flip(vonMisesStressList);
				principalStressList = flip(principalStressList);
			end						
			PSLphyCoordList = [phyCoordList; PSLphyCoordList];
			PSLeleIndexList = [eleIndexList; PSLeleIndexList];				
			PSLparaCoordList = [paraCoordList; PSLparaCoordList];
			PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
			PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
			minorPSL.midPointPosition = size(phyCoordList,1)+1;		
			%%4.3 finish Tracing the current minor PSL			
			minorPSL.length = size(PSLphyCoordList,1);
			minorPSL.eleIndexList = PSLeleIndexList;
			minorPSL.phyCoordList = PSLphyCoordList;
			minorPSL.paraCoordList = PSLparaCoordList;	
			minorPSL.vonMisesStressList = PSLvonMisesStressList;
			minorPSL.principalStressList = PSLprincipalStressList;			
		case 'MAJORPSL'
			%%1. prepare for tracing			
			[eleIndex, paraCoord, phyCoord, vonMisesStress, principalStress, opt] = ...
				PreparingForTracing(initialSeed);
			if 0==opt, return; end
			
			%%2. tracing the major PSL
			PSLphyCoordList = phyCoord;
			PSLeleIndexList = eleIndex;
			PSLparaCoordList = paraCoord;
			PSLvonMisesStressList = vonMisesStress;
			PSLprincipalStressList = principalStress;			
			%%2.1 tracing the major PSL along first direction (v1)		
			nextPoint = phyCoord + tracingStepWidth_*principalStress(1,10:12);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, principalStress(1,10:12), eleIndex, 'MAJORPSL', limiSteps);
			PSLphyCoordList = [PSLphyCoordList; phyCoordList];
			PSLeleIndexList = [PSLeleIndexList; eleIndexList];
			PSLparaCoordList = [PSLparaCoordList; paraCoordList];
			PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
			PSLprincipalStressList = [PSLprincipalStressList; principalStressList];		
			%%2.2 tracing the major PSL along second direction (-v1)	
			nextPoint = phyCoord - tracingStepWidth_*principalStress(1,10:12);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, -principalStress(1,10:12), eleIndex, 'MAJORPSL', limiSteps);
			if size(phyCoordList,1) > 1
				phyCoordList = flip(phyCoordList);
				eleIndexList = flip(eleIndexList);
				paraCoordList = flip(paraCoordList);
				vonMisesStressList = flip(vonMisesStressList);
				principalStressList = flip(principalStressList);
			end						
			PSLphyCoordList = [phyCoordList; PSLphyCoordList];
			PSLeleIndexList = [eleIndexList; PSLeleIndexList];
			PSLparaCoordList = [paraCoordList; PSLparaCoordList];
			PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
			PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
			majorPSL.midPointPosition = size(phyCoordList,1)+1;
			%%2.3 finish Tracing the current major PSL			
			majorPSL.length = size(PSLphyCoordList,1);
			majorPSL.eleIndexList = PSLeleIndexList;
			majorPSL.phyCoordList = PSLphyCoordList;
			majorPSL.paraCoordList = PSLparaCoordList;	
			majorPSL.vonMisesStressList = PSLvonMisesStressList;
			majorPSL.principalStressList = PSLprincipalStressList;
		case 'MEDIUMPSL'
			%%1. prepare for tracing			
			[eleIndex, paraCoord, phyCoord, vonMisesStress, principalStress, opt] = ...
				PreparingForTracing(initialSeed);
			if 0==opt, return; end
			
			%%2. tracing the medium PSL
			PSLphyCoordList = phyCoord;
			PSLeleIndexList = eleIndex;
			PSLparaCoordList = paraCoord;
			PSLvonMisesStressList = vonMisesStress;
			PSLprincipalStressList = principalStress;
			%%2.1 tracing the medium PSL along first direction (v1)
			nextPoint = phyCoord + tracingStepWidth_*principalStress(1,6:8);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, principalStress(1,6:8), eleIndex, 'MEDIUMPSL', limiSteps);
			PSLphyCoordList = [PSLphyCoordList; phyCoordList];
			PSLeleIndexList = [PSLeleIndexList; eleIndexList];
			PSLparaCoordList = [PSLparaCoordList; paraCoordList];
			PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
			PSLprincipalStressList = [PSLprincipalStressList; principalStressList];	
			%%2.2 tracing the medium PSL along second direction (-v1)
			nextPoint = phyCoord - tracingStepWidth_*principalStress(1,6:8);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, -principalStress(1,6:8), eleIndex, 'MEDIUMPSL', limiSteps);
			if size(phyCoordList,1) > 1
				phyCoordList = flip(phyCoordList);
				eleIndexList = flip(eleIndexList);
				paraCoordList = flip(paraCoordList);
				vonMisesStressList = flip(vonMisesStressList);
				principalStressList = flip(principalStressList);
			end						
			PSLphyCoordList = [phyCoordList; PSLphyCoordList];
			PSLeleIndexList = [eleIndexList; PSLeleIndexList];
			PSLparaCoordList = [paraCoordList; PSLparaCoordList];
			PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
			PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
			mediumPSL.midPointPosition = size(phyCoordList,1)+1;
			%%2.3 finish Tracing the current medium PSL			
			mediumPSL.length = size(PSLphyCoordList,1);
			mediumPSL.eleIndexList = PSLeleIndexList;
			mediumPSL.phyCoordList = PSLphyCoordList;
			mediumPSL.paraCoordList = PSLparaCoordList;	
			mediumPSL.vonMisesStressList = PSLvonMisesStressList;
			mediumPSL.principalStressList = PSLprincipalStressList;			
		case 'MINORPSL'
			%%1. prepare for tracing			
			[eleIndex, paraCoord, phyCoord, vonMisesStress, principalStress, opt] = ...
				PreparingForTracing(initialSeed);
			if 0==opt, return; end
			
			%%2. tracing the minor PSL
			PSLphyCoordList = phyCoord;
			PSLeleIndexList = eleIndex;
			PSLparaCoordList = paraCoord;
			PSLvonMisesStressList = vonMisesStress;
			PSLprincipalStressList = principalStress;
			%%2.1 tracing the minor PSL along first direction (v1)
			nextPoint = phyCoord + tracingStepWidth_*principalStress(1,2:4);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, principalStress(1,2:4), eleIndex, 'MINORPSL', limiSteps);
			PSLphyCoordList = [PSLphyCoordList; phyCoordList];
			PSLeleIndexList = [PSLeleIndexList; eleIndexList];
			PSLparaCoordList = [PSLparaCoordList; paraCoordList];
			PSLvonMisesStressList = [PSLvonMisesStressList; vonMisesStressList];
			PSLprincipalStressList = [PSLprincipalStressList; principalStressList];			
			%%2.2 tracing the minor PSL along second direction (-v1)
			nextPoint = phyCoord - tracingStepWidth_*principalStress(1,2:4);
			[phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
				TracingPSL(nextPoint, -principalStress(1,2:4), eleIndex, 'MINORPSL', limiSteps);
			if size(phyCoordList,1) > 1
				phyCoordList = flip(phyCoordList);
				eleIndexList = flip(eleIndexList);
				paraCoordList = flip(paraCoordList);
				vonMisesStressList = flip(vonMisesStressList);
				principalStressList = flip(principalStressList);
			end						
			PSLphyCoordList = [phyCoordList; PSLphyCoordList];
			PSLeleIndexList = [eleIndexList; PSLeleIndexList];
			PSLparaCoordList = [paraCoordList; PSLparaCoordList];
			PSLvonMisesStressList = [vonMisesStressList; PSLvonMisesStressList];
			PSLprincipalStressList = [principalStressList; PSLprincipalStressList];
			minorPSL.midPointPosition = size(phyCoordList,1)+1;			
			%%2.3 finish Tracing the current minor PSL			
			minorPSL.length = size(PSLphyCoordList,1);
			minorPSL.eleIndexList = PSLeleIndexList;
			minorPSL.phyCoordList = PSLphyCoordList;
			minorPSL.paraCoordList = PSLparaCoordList;	
			minorPSL.vonMisesStressList = PSLvonMisesStressList;
			minorPSL.principalStressList = PSLprincipalStressList;			
		otherwise
			error('Unexpected input type!');
	end
end

function [eleIndex, paraCoord, phyCoord, vonMisesStress, principalStress, varargout] = PreparingForTracing(initialSeed)
	global nodeCoords_; global eNodMat_;
	global cartesianStressField_;
	global meshType_;
	eleIndex = 0;
	paraCoord = 0; 
	phyCoord = 0; 
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
		shapeFuncs = ShapeFunction(paraCoord(1), paraCoord(2), paraCoord(3), 'LINEAR');	
		phyCoord = shapeFuncs*eleNodeCoords;
		interpolatedCartesianStress = shapeFuncs*eleCartesianStress;
	else
		paraCoord = [0 0 0];
		phyCoord = initialSeed(1,end-2:end);
		interpolatedCartesianStress = ElementInterpolationIDW(eleNodeCoords, eleCartesianStress, phyCoord); 			
	end
	vonMisesStress = ComputeVonMisesStress(interpolatedCartesianStress);
	principalStress = ComputePrincipalStress(interpolatedCartesianStress);
end

function [tarSeed, opt] = LocateSeedPoint(srcSeed)
	global eleCentroidList_;
	opt = 1;
	if 3==length(srcSeed)
		disList = vecnorm(srcSeed-eleCentroidList_, 2, 2);
		[~, targetEleIndex] = min(disList);	
		[targetEleIndex, paraCoordinates, opt] = FindAdjacentElement(targetEleIndex, srcSeed);
		%if 0==opt, error('Seed is outside of the domain!'); end
		tarSeed = [double(targetEleIndex), paraCoordinates];		
	elseif 4==length(srcSeed)
		tarSeed = srcSeed;
	else
		error('Wrong seed form!')
	end
end

function [phyCoordList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL(nextPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	global meshType_; 
	
	phyCoordList = [];
	eleIndexList = [];
	paraCoordList = [];
	vonMisesStressList = [];
	principalStressList = [];
	
	if strcmp(meshType_, 'CARTESIAN_GRID')
		[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(elementIndex, nextPoint);	
		index = 0;	
		while 1==bool1
			index = index + 1; if index > limiSteps, break; end	
			cartesianStress = cartesianStressField_(eNodMat_(elementIndex,:)', :);	
			shapeFuncs = ShapeFunction(paraCoordinates(1), paraCoordinates(2), paraCoordinates(3), 'LINEAR');
			cartesianStressOnGivenPoint = shapeFuncs*cartesianStress;
			vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
			switch typePSL					
				case 'MINORPSL'
					nextDir = IntegrationDirectionSelecting(iniDir, principalStress(2:4), -principalStress(2:4));
				case 'MEDIUMPSL'
					nextDir = IntegrationDirectionSelecting(iniDir, principalStress(6:8), -principalStress(6:8));			
				case 'MAJORPSL'
					nextDir = IntegrationDirectionSelecting(iniDir, principalStress(10:12), -principalStress(10:12));				
				otherwise
					error('Unexpected input type!');
			end		
			if 0 == AngleTerminationCondition3D(iniDir, nextDir), break; end
			iniDir = nextDir;
			phyCoordList(end+1,:) = nextPoint;
			eleIndexList(end+1,:) = elementIndex;
			paraCoordList(end+1,:) = paraCoordinates;
			vonMisesStressList(end+1,:) = vonMisesStress;
			principalStressList(end+1,:) = principalStress;
			nextPoint = nextPoint + tracingStepWidth_*iniDir;
			[elementIndex, paraCoordinates, bool1] = FindAdjacentElement(elementIndex, nextPoint);
		end		
	else
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%==Inverse Distance Weight Interpolation
		[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, nextPoint);	
		index = 0;	
		while 1==bool1
			index = index + 1; if index > limiSteps, break; end
			NIdx = eNodMat_(elementIndex,:)';
			vtxStress = cartesianStressField_(NIdx, :);
			vtxCoords = nodeCoords_(NIdx,:); 
			cartesianStressOnGivenPoint = ElementInterpolationIDW(vtxCoords, vtxStress, nextPoint); 
			vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
			switch typePSL					
				case 'MINORPSL'
					nextDir = IntegrationDirectionSelecting(iniDir, principalStress(2:4), -principalStress(2:4));
				case 'MEDIUMPSL'
					nextDir = IntegrationDirectionSelecting(iniDir, principalStress(6:8), -principalStress(6:8));			
				case 'MAJORPSL'
					nextDir = IntegrationDirectionSelecting(iniDir, principalStress(10:12), -principalStress(10:12));				
				otherwise
					error('Unexpected input type!');
			end	
			if 0 == AngleTerminationCondition3D(iniDir, nextDir), break; end
			iniDir = nextDir;
			phyCoordList(end+1,:) = nextPoint;
			eleIndexList(end+1,:) = elementIndex;
			paraCoordList(end+1,:) = [0 0 0];
			vonMisesStressList(end+1,:) = vonMisesStress;
			principalStressList(end+1,:) = principalStress;
			nextPoint = nextPoint + tracingStepWidth_*iniDir;
			[elementIndex, ~, bool1] = FindAdjacentElement(elementIndex, nextPoint);
		end		
	end
end

function val = AngleTerminationCondition3D(dirct1, dirct2)
	global interceptionThreshold_;
	angle = acos((dirct1*dirct2') / (norm(dirct1)*norm(dirct2)));
	if angle > pi/interceptionThreshold_
		val = 0;
	else
		val = 1;
	end
end

function targetDirection = IntegrationDirectionSelecting(originalVec, Vec1, Vec2)
	normOriVec = norm(originalVec); normVec1 = norm(Vec1); normVec2 = norm(Vec2);
	angle1 = acos( originalVec*Vec1' / (normOriVec*normVec1) );
	angle2 = acos( originalVec*Vec2' / (normOriVec*normVec2) );
	if angle1 < angle2
		targetDirection = Vec1;
	else
		targetDirection = Vec2;
	end
end

function [nextElementIndex, paraCoordinates, opt] = FindAdjacentElement(oldElementIndex, physicalCoordinates)
	global domainType_; global nodeCoords_; global eleCentroidList_; 
	global eNodMat_; global nodStruct_;
	global meshType_; global meshState_; global eleMapBack_;
	global boundaryElements_;
	global vtxLowerBound_; 
	nextElementIndex = 0; paraCoordinates = []; opt = 0;
	
	if strcmp(meshType_, 'CARTESIAN_GRID')
		global nelx_; global nely_; global nelz_; global eleSize_;
		physicalCoordinates = physicalCoordinates(:)'-vtxLowerBound_;
		physicalCoordinates = double(single(physicalCoordinates));
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
	else				
		tarNodes = eNodMat_(oldElementIndex,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
		tarNodes = eNodMat_(potentialElements,:); 
		potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]); %% balance between safety and efficiency
		disList = vecnorm(physicalCoordinates-eleCentroidList_(potentialElements,:), 2, 2);
		[minVal, nextElementIndex] = min(disList); nextElementIndex = potentialElements(nextElementIndex);
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
	for ii=1:1:maxIts
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
	s = s(:); t = t(:); p = p(:);
	N = repmat(s,1,8);
	N(:,1) = 0.125*(1-s).*(1-t).*(1-p);
	N(:,2) = 0.125*(1+s).*(1-t).*(1-p);
	N(:,3) = 0.125*(1+s).*(1+t).*(1-p);
	N(:,4) = 0.125*(1-s).*(1+t).*(1-p);
	N(:,5) = 0.125*(1-s).*(1-t).*(1+p);
	N(:,6) = 0.125*(1+s).*(1-t).*(1+p);
	N(:,7) = 0.125*(1+s).*(1+t).*(1+p);
	N(:,8) = 0.125*(1-s).*(1+t).*(1+p);		
end

function dShape = DeShapeFunction(s, t, p)	
	s = s(:); t = t(:); p = p(:);
	dN1ds = -0.125*(1-t).*(1-p); dN2ds = 0.125*(1-t).*(1-p); 
	dN3ds = 0.125*(1+t).*(1-p);  dN4ds = -0.125*(1+t).*(1-p);
	dN5ds = -0.125*(1-t).*(1+p); dN6ds = 0.125*(1-t).*(1+p); 
	dN7ds = 0.125*(1+t).*(1+p);  dN8ds = -0.125*(1+t).*(1+p);
	
	dN1dt = -0.125*(1-s).*(1-p); dN2dt = -0.125*(1+s).*(1-p); 
	dN3dt = 0.125*(1+s).*(1-p);  dN4dt = 0.125*(1-s).*(1-p);
	dN5dt = -0.125*(1-s).*(1+p); dN6dt = -0.125*(1+s).*(1+p); 
	dN7dt = 0.125*(1+s).*(1+p);  dN8dt = 0.125*(1-s).*(1+p);
	
	dN1dp = -0.125*(1-s).*(1-t); dN2dp = -0.125*(1+s).*(1-t); 
	dN3dp = -0.125*(1+s).*(1+t); dN4dp = -0.125*(1-s).*(1+t);
	dN5dp = 0.125*(1-s).*(1-t);  dN6dp = 0.125*(1+s).*(1-t); 
	dN7dp = 0.125*(1+s).*(1+t);  dN8dp = 0.125*(1-s).*(1+t);
	
	numCoord = length(s);
	dShape = repmat(s,3,8);
	dShape(1:3:end,:) = [dN1ds dN2ds dN3ds dN4ds dN5ds dN6ds dN7ds dN8ds];
	dShape(2:3:end,:) = [dN1dt dN2dt dN3dt dN4dt dN5dt dN6dt dN7dt dN8dt];
	dShape(3:3:end,:) = [dN1dp dN2dp dN3dp dN4dp dN5dp dN6dp dN7dp dN8dp];	
end

function d2Shape = De2ShapeFunction(s, t, p)	
	s = s(:); t = t(:); p = p(:);
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
				
	d2Shape = repmat(s,6,8);
	d2Shape(1:6:end) = repmat([dN1dss dN2dss dN3dss dN4dss dN5dss dN6dss dN7dss dN8dss], numCoord, 1);
	d2Shape(2:6:end) = repmat([dN1dtt dN2dtt dN3dtt dN4dtt dN5dtt dN6dtt dN7dtt dN8dtt], numCoord, 1);
	d2Shape(3:6:end) = repmat([dN1dpp dN2dpp dN3dpp dN4dpp dN5dpp dN6dpp dN7dpp dN8dpp], numCoord, 1);
	d2Shape(4:6:end) = [dN1dtp dN2dtp dN3dtp dN4dtp dN5dtp dN6dtp dN7dtp dN8dtp];
	d2Shape(5:6:end) = [dN1dsp dN2dsp dN3dsp dN4dsp dN5dsp dN6dsp dN7dsp dN8dsp];
	d2Shape(6:6:end) = [dN1dst dN2dst dN3dst dN4dst dN5dst dN6dst dN7dst dN8dsp];
	d2Shape = 0.125 * d2Shape;
end

function principalStress = ComputePrincipalStress(cartesianStress)
	principalStress = zeros(size(cartesianStress,1), 1+3+1+3+1+3);
	for ii=1:size(cartesianStress,1)
		A = zeros(3);
		A(1,1) = cartesianStress(ii,1);
		A(1,2) = cartesianStress(ii,6);
		A(1,3) = cartesianStress(ii,5);
		A(2,1) = A(1,2);
		A(2,2) = cartesianStress(ii,2);
		A(2,3) = cartesianStress(ii,4);
		A(3,1) = A(1,3);
		A(3,2) = A(2,3);
		A(3,3) = cartesianStress(ii,3);		
		[eigenVec, eigenVal] = eig(A);
		principalStress(ii,1) = eigenVal(1,1); principalStress(ii,2:4) = eigenVec(:,1);
		principalStress(ii,5) = eigenVal(2,2); principalStress(ii,6:8) = eigenVec(:,2);
		principalStress(ii,9) = eigenVal(3,3); principalStress(ii,10:12) = eigenVec(:,3);
	end			
end

function val = ComputeVonMisesStress(cartesianStress)
	val = sqrt( 0.5*( (cartesianStress(:,1)-cartesianStress(:,2)).^2 + ...
		(cartesianStress(:,2)-cartesianStress(:,3)).^2 + (cartesianStress(:,3)...
			-cartesianStress(:,1)).^2 ) + 3*( cartesianStress(:,6).^2 + ...
				cartesianStress(:,4).^2 + cartesianStress(:,5).^2 ) );		
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