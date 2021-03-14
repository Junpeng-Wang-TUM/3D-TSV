function GenerateSpaceFillingPSLs(iEpsilon)
	global seedPoints_; global seedPointsHistory_;
	global seedPointsValence_; global tracingStepWidth_;
	global selectedPrincipalStressField_;
	global mergingOpt_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_; 
	global majorCoordList_; global mediumCoordList_; global minorCoordList_;
	global mergeTrigger_; global relaxedFactor_;
	global startCoord_;
	
	%%Taking the geometrical center as the start seed point 
	lowerBound = min(seedPointsHistory_); upperBound = max(seedPointsHistory_);
	startCoord_ = zeros(1,3);
	startCoord_(1) = (lowerBound(1)+upperBound(1))/2;
	startCoord_(2) = (lowerBound(2)+upperBound(2))/2;
	startCoord_(3) = (lowerBound(3)+upperBound(3))/2;
	
	%% Pre-process Seed Points
	% mergeTrigger_ = iEpsilon*tracingStepWidth_;
	mergeTrigger_ = iEpsilon;
    seedPoints_ = seedPointsHistory_;
	numSamplings = size(seedPoints_,1);	
    seedPointsValence_ = ones(numSamplings, 3);
	%% Exclude the irrelated Principal Stress Fields 
	for ii=1:length(selectedPrincipalStressField_)
		iPSF = selectedPrincipalStressField_(ii);
		switch iPSF
			case 'MAJOR', seedPointsValence_(:,1) = 0;
			case 'MEDIUM', seedPointsValence_(:,2) = 0;
			case 'MINOR', seedPointsValence_(:,3) = 0;
		end
	end
	PreprocessSeedPoints();
	
	%% Iteration
	if mergingOpt_
		its = 0;
		looper = sum(sum(seedPointsValence_));	
		while looper<3*numSamplings
			its = its + 1;
			valenceMetric = sum(seedPointsValence_,2);
			unFinishedSpps = find(valenceMetric<3);
			[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSpps,:),2,2));				
			spp = unFinishedSpps(tarPos);			
			valences = seedPointsValence_(spp,:);
			seed = seedPoints_(spp,:);
			if 0==valences(1)
				seedPointsValence_(spp,1) = 1;
				majorPSL = GridGrowthTrigger(seed, 'MAJOR');		
				if 0==majorPSL.length
					looper = sum(sum(seedPointsValence_)); 
					disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
						' Total.: ' sprintf('%6i',3*numSamplings)]);
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
						modifiedMediumValences = HighCurvatureModification(spps2BeMerged, 'MEDIUM');
						seedPointsValence_(modifiedMediumValences,2) = 1;					
						modifiedMinorValences = HighCurvatureModification(spps2BeMerged, 'MINOR');				
						seedPointsValence_(modifiedMinorValences,3) = 1;	
					end
				end				
			end
			
			if 0==valences(2)
				seedPointsValence_(spp,2) = 1;
				mediumPSL = GridGrowthTrigger(seed, 'MEDIUM');		
				if 0==mediumPSL.length
					looper = sum(sum(seedPointsValence_)); 
					disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
						' Total.: ' sprintf('%6i',3*numSamplings)]);
					continue; 
				end
				mediumPSLpool_(end+1,1) = mediumPSL;
				mediumCoordList_(end+1:end+mediumPSL.length,:) = mediumPSL.phyCoordList;
				sppsEmptyMediumValence = find(0==seedPointsValence_(:,2));
				if ~isempty(sppsEmptyMediumValence)
					[potentialDisListMedium, potentialPosListMedium] = GetDisListOfPointList2Curve(seedPoints_(...
							sppsEmptyMediumValence,:), mediumPSL.phyCoordList);					
					potentialSolidSppsMedium = find(potentialDisListMedium<relaxedFactor_);
					if ~isempty(potentialSolidSppsMedium)
						spps2BeMerged = sppsEmptyMediumValence(potentialSolidSppsMedium);
						seedPoints_(spps2BeMerged,:) = potentialPosListMedium(potentialSolidSppsMedium,:);								
						seedPointsValence_(spps2BeMerged,2) = 1;
						modifiedMajorValences = HighCurvatureModification(spps2BeMerged, 'MAJOR');
						samplingPointsValence_(modifiedMajorValences,1) = 1;
						modifiedMinorValences = HighCurvatureModification(spps2BeMerged, 'MINOR');
						samplingPointsValence_(modifiedMinorValences,3) = 1;
					end
				end				
			end		
			
			if 0==valences(3)
				seedPointsValence_(spp,3) = 1;			
				minorPSL = GridGrowthTrigger(seed, 'MINOR');			
				if 0==minorPSL.length
					looper = sum(sum(seedPointsValence_)); 
					disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
						' Total.: ' sprintf('%6i',3*numSamplings)]);
					continue; 
				end		
				minorPSLpool_(end+1,1) = minorPSL;
				minorCoordList_(end+1:end+minorPSL.length,:) = minorPSL.phyCoordList;										
				sppsEmptyMinorValence = find(0==seedPointsValence_(:,3));
				if ~isempty(sppsEmptyMinorValence)   
					[potentialDisListMinor, potentialPosListMinor] = GetDisListOfPointList2Curve(seedPoints_(...
							sppsEmptyMinorValence,:), minorPSL.phyCoordList);					
					potentialSolidSppsMinor = find(potentialDisListMinor<relaxedFactor_);
					if ~isempty(potentialSolidSppsMinor)
						spps2BeMerged = sppsEmptyMinorValence(potentialSolidSppsMinor);
						seedPoints_(spps2BeMerged,:) = potentialPosListMinor(potentialSolidSppsMinor,:);
						seedPointsValence_(spps2BeMerged,3) = 1;				
						modifiedMajorValences = HighCurvatureModification(spps2BeMerged, 'MAJOR');					
						seedPointsValence_(modifiedMajorValences,1) = 1;
						modifiedMediumValences = HighCurvatureModification(spps2BeMerged, 'MEDIUM');
						samplingPointsValence_(modifiedMediumValences,2) = 1;					
					end
				end					
			end
			% if 1==its, CompactPSLs(); return; end
			looper = sum(sum(seedPointsValence_));
			disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
				' Total.: ' sprintf('%6i',3*numSamplings)]);			
		end
	else
		for ii=1:numSamplings
			seed = seedPoints_(ii,:);
			majorPSL = GridGrowthTrigger(seed, 'MAJOR');
			mediumPSL = GridGrowthTrigger(seed, 'MEDIUM');
			minorPSL = GridGrowthTrigger(seed, 'MINOR');
			majorPSLpool_(end+1,1) = majorPSL;
			mediumPSLpool_(end+1,1) = mediumPSL;
			minorPSLpool_(end+1,1) = minorPSL;
			disp([' Iteration.: ' sprintf('%4i',ii) ' Progress.: ' sprintf('%6i',ii) ...
				' Total.: ' sprintf('%6i',numSamplings)]);			
		end
	end
	CompactPSLs();
end

function PreprocessSeedPoints()
	global seedPoints_;
	global seedPointsValence_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_; 
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
					modifiedMediumValences = HighCurvatureModification(spps2BeMerged, 'MEDIUM');
					seedPointsValence_(modifiedMediumValences,2) = 1;					
					modifiedMinorValences = HighCurvatureModification(spps2BeMerged, 'MINOR');
					seedPointsValence_(modifiedMinorValences,3) = 1;							
				end
			end
		end
	end

	numMediumPSLs = length(mediumPSLpool_);
	for ii=1:numMediumPSLs
		mediumPSL = mediumPSLpool_(ii);
		if mediumPSL.length>0					
			sppsEmptyMediumValence = find(0==seedPointsValence_(:,2));
            if ~isempty(sppsEmptyMediumValence)
				[potentialDisListMedium, potentialPosListMedium] = GetDisListOfPointList2Curve(...	
					seedPoints_(sppsEmptyMediumValence,:), mediumPSL.phyCoordList);
				potentialSolidSppsMedium = find(potentialDisListMedium<=relaxedFactor_);
				if ~isempty(potentialSolidSppsMedium)
					spps2BeMerged = sppsEmptyMediumValence(potentialSolidSppsMedium);							
					seedPoints_(spps2BeMerged,:) = potentialPosListMedium(potentialSolidSppsMedium,:);
					seedPointsValence_(spps2BeMerged,2) = 1;
					modifiedMajorValences = HighCurvatureModification(spps2BeMerged, 'MAJOR');
					seedPointsValence_(modifiedMajorValences,1) = 1;						
					modifiedMinorValences = HighCurvatureModification(spps2BeMerged, 'MINOR');
					seedPointsValence_(modifiedMinorValences,3) = 1;							
				end
			end
		end
	end

	numMinorPSLs = length(minorPSLpool_);
	for ii=1:numMinorPSLs
		minorPSL = minorPSLpool_(ii);
		if minorPSL.length>0	
			sppsEmptyMinorValence = find(0==seedPointsValence_(:,3));
            if ~isempty(sppsEmptyMinorValence)
				[potentialDisListMinor, potentialPosListMinor] = GetDisListOfPointList2Curve(...	
					seedPoints_(sppsEmptyMinorValence,:), minorPSL.phyCoordList);
				potentialSolidSppsMinor = find(potentialDisListMinor<=relaxedFactor_);
				if ~isempty(potentialSolidSppsMinor)
					spps2BeMerged = sppsEmptyMinorValence(potentialSolidSppsMinor);
					seedPoints_(spps2BeMerged,:) = potentialPosListMinor(potentialSolidSppsMinor,:);
					seedPointsValence_(spps2BeMerged,3) = 1;
					modifiedMajorValences = HighCurvatureModification(spps2BeMerged, 'MAJOR');
					seedPointsValence_(modifiedMajorValences,1) = 1;	
					modifiedMediumValences = HighCurvatureModification(spps2BeMerged, 'MEDIUM');
					seedPointsValence_(modifiedMediumValences,2) = 1;						
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
	global majorCoordList_; global mediumCoordList_; global minorCoordList_;
	global seedPoints_;
	global seedPointsValence_;
	global mergeTrigger_;
	global relaxedFactor_;
	
	coordList = [];
	switch psDir
		case 'MAJOR'
			if isempty(majorCoordList_), modifiedValences = []; return; end
			coordList = majorCoordList_;
			spps2BeMerged = spps2BeMerged(find(0==seedPointsValence_(spps2BeMerged,1)));
		case 'MEDIUM'
			if isempty(mediumCoordList_), modifiedValences = []; return; end
			coordList = mediumCoordList_;
			spps2BeMerged = spps2BeMerged(find(0==seedPointsValence_(spps2BeMerged,2)));			
		case 'MINOR'
			if isempty(minorCoordList_), modifiedValences = []; return; end
			coordList = minorCoordList_;
			spps2BeMerged = spps2BeMerged(find(0==seedPointsValence_(spps2BeMerged,3)));
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
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	filterThreshold = minLengthVisiblePSLs_;
	
	tarIndice = [];
	for ii=1:length(majorPSLpool_)
		if majorPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	majorPSLpool_ = majorPSLpool_(tarIndice);
	
	tarIndice = [];
	for ii=1:length(mediumPSLpool_)
		if mediumPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	mediumPSLpool_ = mediumPSLpool_(tarIndice);	

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
	global majorCoordList_; global mediumCoordList_; global minorCoordList_;
	tarPSL = srcPSL;
	if 5>=srcPSL.length, return; end
	disThreshold = 2;
	relaxedThreshold = 0.2;
	switch psDir
		case 'MAJOR'
			if isempty(majorCoordList_), return; end
			srcCoordList = majorCoordList_;		
		case 'MEDIUM'
			if isempty(mediumCoordList_), return; end
			srcCoordList = mediumCoordList_;					
		case 'MINOR'
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
