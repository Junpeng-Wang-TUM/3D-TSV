function GenerateSpaceFillingPSLs(iEpsilon)
	global seedPoints_; global seedPointsHistory_;
	global seedPointsValence_; global tracingStepWidth_;
	global majorPSLpool_; global minorPSLpool_; 
	global majorCoordList_; global minorCoordList_;
	global mergeTrigger_; global relaxedFactor_;
	global startCoord_;

	%% Pre-process Seed Points
	mergeTrigger_ = iEpsilon*tracingStepWidth_;
    seedPoints_ = seedPointsHistory_;
	numSamplings = size(seedPoints_,1);	
    seedPointsValence_ = zeros(numSamplings, 2);	
	PreprocessSeedPoints();
	
	%% Iteration
	its = 0;
	looper = sum(sum(seedPointsValence_));	
	while looper<2*numSamplings
		its = its + 1;
		valenceMetric = sum(seedPointsValence_,2);
		unFinishedSpps = find(valenceMetric<2);
		if 0==looper
			lowerBound = min(seedPoints_); upperBound = max(seedPoints_);
			startCoord_ = zeros(1,3);
			%%Start from the geometrical center of stress field
			startCoord_(1) = (lowerBound(1)+upperBound(1))/2;
			startCoord_(2) = (lowerBound(2)+upperBound(2))/2;
			startCoord_(3) = (lowerBound(3)+upperBound(3))/2;
			[~, spp] = min(vecnorm(startCoord_-seedPoints_,2,2));
		else
			tmp	= seedPointsValence_(unFinishedSpps,:);
			tmp = find(1==sum(tmp,2));
			if ~isempty(tmp), unFinishedSpps = unFinishedSpps(tmp); end
			[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSpps,:),2,2));					
			spp = unFinishedSpps(tarPos);
		end
		valences = seedPointsValence_(spp,:);
		seed = seedPoints_(spp,:);
		
		if 0==valences(1)
			seedPointsValence_(spp,1) = 1;
			majorPSL = GridGrowthTrigger(seed, 'MAJORPSL');		
			if 0==majorPSL.length
				looper = sum(sum(seedPointsValence_)); 
				disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
					' Total.: ' sprintf('%6i',2*numSamplings)]);
				continue; 
			end
			majorPSLpool_(end+1,1) = majorPSL;
			majorCoordList_(end+1:end+majorPSL.length,:) = majorPSL.phyCoordList;
			sppsEmptyMajorValence = find(0==seedPointsValence_(:,1));
            if ~isempty(sppsEmptyMajorValence)
				[potentialDisListMajor, potentialPosListMajor] = GetDisListOfPointList2Curve(seedPoints_(...
						sppsEmptyMajorValence,:), majorPSL.phyCoordList);					
				potentialSolidSppsMajor = find(potentialDisListMajor<relaxedFactor_);
				if ~isempty(potentialSolidSppsMajor)
					spps2BeMerged = sppsEmptyMajorValence(potentialSolidSppsMajor);
					seedPoints_(spps2BeMerged,:) = potentialPosListMajor(potentialSolidSppsMajor,:);								
					seedPointsValence_(spps2BeMerged,1) = 1;				
					modifiedMinorValences = HighCurvatureModification(spps2BeMerged, 'MINORPSL');				
					seedPointsValence_(modifiedMinorValences,2) = 1;	
				end
			end				
		end
		
		if 0==valences(2)
			seedPointsValence_(spp,2) = 1;			
			minorPSL = GridGrowthTrigger(seed, 'MINORPSL');			
			if 0==minorPSL.length
				looper = sum(sum(seedPointsValence_)); 
				disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
					' Total.: ' sprintf('%6i',2*numSamplings)]);
				continue; 
			end		
			minorPSLpool_(end+1,1) = minorPSL;
			minorCoordList_(end+1:end+minorPSL.length,:) = minorPSL.phyCoordList;										
			sppsEmptyMinorValence = find(0==seedPointsValence_(:,2));
            if ~isempty(sppsEmptyMinorValence)   
				[potentialDisListMinor, potentialPosListMinor] = GetDisListOfPointList2Curve(seedPoints_(...
						sppsEmptyMinorValence,:), minorPSL.phyCoordList);					
				potentialSolidSppsMinor = find(potentialDisListMinor<relaxedFactor_);
				if ~isempty(potentialSolidSppsMinor)
					spps2BeMerged = sppsEmptyMinorValence(potentialSolidSppsMinor);
					seedPoints_(spps2BeMerged,:) = potentialPosListMinor(potentialSolidSppsMinor,:);
					seedPointsValence_(spps2BeMerged,2) = 1;				
					modifiedMajorValences = HighCurvatureModification(spps2BeMerged, 'MAJORPSL');					
					seedPointsValence_(modifiedMajorValences,1) = 1;									
				end
			end					
		end
		
		looper = sum(sum(seedPointsValence_));
		disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
			' Total.: ' sprintf('%6i',2*numSamplings)]);			
	end
	CompactPSLs();
end

function PreprocessSeedPoints()
	global seedPoints_;
	global seedPointsValence_;
	global majorPSLpool_; global minorPSLpool_; 
	global relaxedFactor_;
	
	numMajorPSLs = length(majorPSLpool_);
	for ii=1:numMajorPSLs
		majorPSL = majorPSLpool_(ii);
		if majorPSL.length>0					
			sppsEmptyMajorValence = find(0==seedPointsValence_(:,1));
            if ~isempty(sppsEmptyMajorValence)
				[potentialDisListMajor, potentialPosListMajor] = GetDisListOfPointList2Curve(...	
					seedPoints_(sppsEmptyMajorValence,:), majorPSL.phyCoordList);
				potentialSolidSppsMajor = find(potentialDisListMajor<=relaxedFactor_);
				if ~isempty(potentialSolidSppsMajor)
					spps2BeMerged = sppsEmptyMajorValence(potentialSolidSppsMajor);							
					seedPoints_(spps2BeMerged,:) = potentialPosListMajor(potentialSolidSppsMajor,:);
					seedPointsValence_(spps2BeMerged,1) = 1;						
					modifiedMinorValences = HighCurvatureModification(spps2BeMerged, 'MINORPSL');
					seedPointsValence_(modifiedMinorValences,2) = 1;							
				end
			end
		end
	end

	numMinorPSLs = length(minorPSLpool_);
	for ii=1:numMinorPSLs
		minorPSL = minorPSLpool_(ii);
		if minorPSL.length>0	
			sppsEmptyMinorValence = find(0==seedPointsValence_(:,2));
            if ~isempty(sppsEmptyMinorValence)
				[potentialDisListMinor, potentialPosListMinor] = GetDisListOfPointList2Curve(...	
					seedPoints_(sppsEmptyMinorValence,:), minorPSL.phyCoordList);
				potentialSolidSppsMinor = find(potentialDisListMinor<=relaxedFactor_);
				if ~isempty(potentialSolidSppsMinor)
					spps2BeMerged = sppsEmptyMinorValence(potentialSolidSppsMinor);
					seedPoints_(spps2BeMerged,:) = potentialPosListMinor(potentialSolidSppsMinor,:);
					seedPointsValence_(spps2BeMerged,2) = 1;
					modifiedMajorValences = HighCurvatureModification(spps2BeMerged, 'MAJORPSL');
					seedPointsValence_(modifiedMajorValences,1) = 1;													
				end
			end
		end
	end		
end

function iPSL = GridGrowthTrigger(seed, psDir)
	global vtxLowerBound_; global vtxUpperBound_; global tracingStepWidth_;
	global snappingOpt_;
	stopCond = ceil(1.5*norm(vtxUpperBound_-vtxLowerBound_)/tracingStepWidth_);	
	iPSL = GeneratePrincipalStressLines(seed, psDir, stopCond);
	if snappingOpt_, iPSL = CroppingPSLifNeeded(iPSL, psDir); end	
end

function [potentialDisList, potentialPosList] = GetDisListOfPointList2Curve(pointList, curveLine)
	global mergeTrigger_;
	disT = (curveLine(:,1) - pointList(:,1)').^2;
	disT = disT + (curveLine(:,2) - pointList(:,2)').^2;
	disT = disT + (curveLine(:,3) - pointList(:,3)').^2;
	disT = sqrt(disT);	
	[minVal, minValPos] = min(disT,[],1);
	potentialDisList = minVal';
	potentialDisList = potentialDisList/mergeTrigger_;
	potentialPosList = curveLine(minValPos,:);	
end

function modifiedValences = HighCurvatureModification(spps2BeMerged, psDir)
	global majorCoordList_; global minorCoordList_;
	global seedPoints_;
	global seedPointsValence_;
	global mergeTrigger_;
	global relaxedFactor_;
	
	coordList = [];
	switch psDir
		case 'MAJORPSL'
			if isempty(majorCoordList_), modifiedValences = []; return; end
			coordList = majorCoordList_;
			spps2BeMerged = spps2BeMerged(find(0==seedPointsValence_(spps2BeMerged,1)));
		case 'MINORPSL'
			if isempty(minorCoordList_), modifiedValences = []; return; end
			coordList = minorCoordList_;
			spps2BeMerged = spps2BeMerged(find(0==seedPointsValence_(spps2BeMerged,2)));
	end
	pointList = seedPoints_(spps2BeMerged,:);
	disT = (coordList(:,1) - pointList(:,1)').^2;
	disT = disT + (coordList(:,2) - pointList(:,2)').^2;
	disT = disT + (coordList(:,3) - pointList(:,3)').^2;
	disT = sqrt(disT);		
	minVal = min(disT);
	minVal = minVal/mergeTrigger_;
	modifiedValences = find(minVal<relaxedFactor_);	
	modifiedValences = spps2BeMerged(modifiedValences);
end

function CompactPSLs()
	global minLengthVisiblePSLs_;
	global majorPSLpool_; global minorPSLpool_;
	filterThreshold = minLengthVisiblePSLs_;
	
	tarIndice = [];
	for ii=1:length(majorPSLpool_)
		if majorPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	majorPSLpool_ = majorPSLpool_(tarIndice);

	tarIndice = [];
	for ii=1:length(minorPSLpool_)
		if minorPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	minorPSLpool_ = minorPSLpool_(tarIndice);	
end

function tarPSL = CroppingPSLifNeeded(srcPSL, psDir)
	global mergeTrigger_;
	global majorCoordList_; global minorCoordList_;
	tarPSL = srcPSL;
	if 5>=srcPSL.length, return; end
	disThreshold = 2;
	relaxedThreshold = 0.1;
	switch psDir
		case 'MAJORPSL'
			if isempty(majorCoordList_), return; end
			srcCoordList = majorCoordList_;								
		case 'MINORPSL'
			if isempty(minorCoordList_), return; end
			srcCoordList = minorCoordList_;		
	end
	
	if srcPSL.midPointPosition == srcPSL.length || srcPSL.midPointPosition == 1
		if 1==srcPSL.midPointPosition
			tarCoordList = tarPSL.phyCoordList;
			disT = (srcCoordList(:,1) - tarCoordList(:,1)').^2;
			disT = disT + (srcCoordList(:,2) - tarCoordList(:,2)').^2;	
			disT = disT + (srcCoordList(:,3) - tarCoordList(:,3)').^2;
			disT = sqrt(disT);
			miniDisList2SrcPSL = min(disT);
			tarPositions = find(miniDisList2SrcPSL<mergeTrigger_/disThreshold);
			%if isempty(tarPositions), return; end
			if length(tarPositions)/size(tarCoordList,1)<relaxedThreshold, return; end
			if length(tarPositions) == size(tarCoordList,1), tarPSL = PrincipalStressLineStruct(); return; end
			startPos = 1; endPos = min(tarPositions);
		else
			tarCoordList = flip(tarPSL.phyCoordList,1);
			disT = (srcCoordList(:,1) - tarCoordList(:,1)').^2;
			disT = disT + (srcCoordList(:,2) - tarCoordList(:,2)').^2;	
			disT = disT + (srcCoordList(:,3) - tarCoordList(:,3)').^2;
			disT = sqrt(disT);
			miniDisList2SrcPSL = min(disT);
			tarPositions = find(miniDisList2SrcPSL<mergeTrigger_/disThreshold);
			%if isempty(tarPositions), return; end
			if length(tarPositions)/size(tarCoordList,1)<relaxedThreshold, return; end
			if length(tarPositions) == size(tarCoordList,1), tarPSL = PrincipalStressLineStruct(); return; end
			startPos = srcPSL.length - min(tarPositions) + 1; endPos = srcPSL.length;
		end	
	else
		tarCoordList = tarPSL.phyCoordList(srcPSL.midPointPosition:srcPSL.length,:);
		disT = (srcCoordList(:,1) - tarCoordList(:,1)').^2;
		disT = disT + (srcCoordList(:,2) - tarCoordList(:,2)').^2;	
		disT = disT + (srcCoordList(:,3) - tarCoordList(:,3)').^2;
		disT = sqrt(disT);
		miniDisList2SrcPSL = min(disT);
		tarPositions = find(miniDisList2SrcPSL<mergeTrigger_/disThreshold);		
		%if isempty(tarPositions)
		if length(tarPositions)/size(tarCoordList,1)<relaxedThreshold
			endPos = srcPSL.length;
		elseif length(tarPositions) == size(tarCoordList,1)
			endPos = srcPSL.midPointPosition;
		else
			endPos = srcPSL.midPointPosition+min(tarPositions)-1;
		end
		
		tarCoordList = flip(tarPSL.phyCoordList(1:srcPSL.midPointPosition,:),1);
		disT = (srcCoordList(:,1) - tarCoordList(:,1)').^2;
		disT = disT + (srcCoordList(:,2) - tarCoordList(:,2)').^2;	
		disT = disT + (srcCoordList(:,3) - tarCoordList(:,3)').^2;
		disT = sqrt(disT);
		miniDisList2SrcPSL = min(disT);
		tarPositions = find(miniDisList2SrcPSL<mergeTrigger_/disThreshold);		
		%if isempty(tarPositions)
		if length(tarPositions)/size(tarCoordList,1)<relaxedThreshold
			startPos = 1;
		elseif length(tarPositions) == size(tarCoordList,1)
			startPos = srcPSL.midPointPosition;
		else		
			startPos = size(tarCoordList,1) - min(tarPositions) + 1;
		end
	end
	tarPSL.eleIndexList = srcPSL.eleIndexList(startPos:endPos,:);
	tarPSL.phyCoordList = srcPSL.phyCoordList(startPos:endPos,:);
	tarPSL.cartesianStressList = srcPSL.cartesianStressList(startPos:endPos,:);
	tarPSL.vonMisesStressList = srcPSL.vonMisesStressList(startPos:endPos,:);
	tarPSL.principalStressList = srcPSL.principalStressList(startPos:endPos,:);
	tarPSL.length = length(tarPSL.eleIndexList);
	tarPSL.midPointPosition = 1;		
end
