function GenerateSpaceFillingPSLs(iEpsilon)
	global seedPoints_; global seedPointsHistory_;
	global seedPointsValence_; 
	global selectedPrincipalStressField_;
	global mergingOpt_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_; 
	global majorCoordList_; global mediumCoordList_; global minorCoordList_;
	global PSLsAppearanceOrder_;
	global mergeTrigger_; global relaxedFactor_; global multiMergingThresholdsCtrl_;
	global startCoord_;
	
	%%Taking the geometrical center as the start seed point 
	lowerBound = min(seedPointsHistory_); upperBound = max(seedPointsHistory_);
	startCoord_ = zeros(1,3);
	startCoord_(1) = lowerBound(1)+(upperBound(1)-lowerBound(1))/2;
	startCoord_(2) = lowerBound(2)+(upperBound(2)-lowerBound(2))/2;
	startCoord_(3) = lowerBound(3)+(upperBound(3)-lowerBound(3))/2;
	
	%% Pre-process Seed Points
	mergeTrigger_ = iEpsilon;
    seedPoints_ = seedPointsHistory_;
	numSeedPoints = size(seedPoints_,1);	
    seedPointsValence_ = ones(numSeedPoints, 3);
	%% Exclude the irrelated Principal Stress Fields 
	numPSF = length(selectedPrincipalStressField_);
	for ii=1:numPSF
		iPSF = selectedPrincipalStressField_(ii);
		switch iPSF
			case 1, seedPointsValence_(:,1) = 0; 
			case 2, seedPointsValence_(:,2) = 0; 
			case 3, seedPointsValence_(:,3) = 0;
		end
	end
	PreprocessSeedPoints();
	%% Iteration
	if mergingOpt_
		its = 0;
		looper = sum(sum(seedPointsValence_));	
		while looper<3*numSeedPoints
			its = its + 1;
			valenceMetric = sum(seedPointsValence_,2);
			%% 1st Priority: semi-empty seeds > empty seeds, which helps get PSLs intersection
			%% 2nd Priority: seeds with same valence, the one closest to the start point goes first
			switch numPSF
				case 1
					unFinishedSppsValence2 = find(2==valenceMetric);
					[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSppsValence2,:),2,2));
					spp = unFinishedSppsValence2(tarPos);
				case 2
					unFinishedSppsValence2 = find(2==valenceMetric); 
					if ~isempty(unFinishedSppsValence2) %% 1st Priority
						[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSppsValence2,:),2,2)); %% 2nd Priority
						spp = unFinishedSppsValence2(tarPos);
					else
						unFinishedSppsValence1 = find(1==valenceMetric);
						[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSppsValence1,:),2,2)); %% 2nd Priority
						spp = unFinishedSppsValence1(tarPos);			
					end					
				case 3
					unFinishedSppsValence12 = find(3>valenceMetric); 
					unFinishedSppsValence12 = unFinishedSppsValence12(valenceMetric(unFinishedSppsValence12)>0); 
					if ~isempty(unFinishedSppsValence12) %% 1st Priority
						[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSppsValence12,:),2,2)); %% 2nd Priority
						spp = unFinishedSppsValence12(tarPos);
					else
						unFinishedSppsValence0 = find(0==valenceMetric);
						[~, tarPos] = min(vecnorm(startCoord_-seedPoints_(unFinishedSppsValence0,:),2,2)); %% 2nd Priority
						spp = unFinishedSppsValence0(tarPos);		
					end						
			end
			valences = seedPointsValence_(spp,:);						
			seed = seedPoints_(spp,:);
			if 0==valences(1)
				seedPointsValence_(spp,1) = 1;
				majorPSL = GridGrowthTrigger(seed, 'MAJOR');		
				if 0==majorPSL.length
					looper = sum(sum(seedPointsValence_)); 
					disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
						' Total.: ' sprintf('%6i',3*numSeedPoints)]);
					continue; 
				end			
				majorPSLpool_(end+1,1) = majorPSL;				
				majorCoordList_(end+1:end+majorPSL.length,:) = majorPSL.phyCoordList;
				PSLsAppearanceOrder_(end+1,:) = [1 length(majorPSLpool_)];
				sppsEmptyMajorValence = find(0==seedPointsValence_(:,1));
				if ~isempty(sppsEmptyMajorValence)
					[potentialDisListMajor, potentialPosListMajor] = GetDisListOfPointList2Curve(seedPoints_(...
							sppsEmptyMajorValence,:), majorPSL.phyCoordList);					
					potentialSolidSppsMajor = find(potentialDisListMajor<multiMergingThresholdsCtrl_(1)*relaxedFactor_);
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
						' Total.: ' sprintf('%6i',3*numSeedPoints)]);
					continue; 
				end
				mediumPSLpool_(end+1,1) = mediumPSL;
				mediumCoordList_(end+1:end+mediumPSL.length,:) = mediumPSL.phyCoordList;
				PSLsAppearanceOrder_(end+1,:) = [2 length(mediumPSLpool_)];
				sppsEmptyMediumValence = find(0==seedPointsValence_(:,2));
				if ~isempty(sppsEmptyMediumValence)
					[potentialDisListMedium, potentialPosListMedium] = GetDisListOfPointList2Curve(seedPoints_(...
							sppsEmptyMediumValence,:), mediumPSL.phyCoordList);					
					potentialSolidSppsMedium = find(potentialDisListMedium<multiMergingThresholdsCtrl_(2)*relaxedFactor_);
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
			
			if 0==valences(3)
				seedPointsValence_(spp,3) = 1;			
				minorPSL = GridGrowthTrigger(seed, 'MINOR');			
				if 0==minorPSL.length
					looper = sum(sum(seedPointsValence_)); 
					disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
						' Total.: ' sprintf('%6i',3*numSeedPoints)]);
					continue; 
				end		
				minorPSLpool_(end+1,1) = minorPSL;
				minorCoordList_(end+1:end+minorPSL.length,:) = minorPSL.phyCoordList;
				PSLsAppearanceOrder_(end+1,:) = [3 length(minorPSLpool_)];				
				sppsEmptyMinorValence = find(0==seedPointsValence_(:,3));
				if ~isempty(sppsEmptyMinorValence)   
					[potentialDisListMinor, potentialPosListMinor] = GetDisListOfPointList2Curve(seedPoints_(...
							sppsEmptyMinorValence,:), minorPSL.phyCoordList);					
					potentialSolidSppsMinor = find(potentialDisListMinor<multiMergingThresholdsCtrl_(3)*relaxedFactor_);
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
			looper = sum(sum(seedPointsValence_));
			disp([' Iteration.: ' sprintf('%4i',its) ' Progress.: ' sprintf('%6i',looper) ...
				' Total.: ' sprintf('%6i',3*numSeedPoints)]);			
		end
	else
		for ii=1:numSeedPoints
			seed = seedPoints_(ii,:);		
			for jj=1:numPSF
				iPSF = selectedPrincipalStressField_(jj);
				switch iPSF
					case 1
						majorPSL = GridGrowthTrigger(seed, 'MAJOR'); 
						if 0==majorPSL.length, continue; end
						majorPSLpool_(end+1,1) = majorPSL;
						majorCoordList_(end+1:end+majorPSL.length,:) = majorPSL.phyCoordList;
						PSLsAppearanceOrder_(end+1,:) = [1 length(majorPSLpool_)];
						
					case 2
						mediumPSL = GridGrowthTrigger(seed, 'MEDIUM');
						if 0==mediumPSL.length, continue; end
						mediumPSLpool_(end+1,1) = mediumPSL;
						mediumCoordList_(end+1:end+mediumPSL.length,:) = mediumPSL.phyCoordList;
						PSLsAppearanceOrder_(end+1,:) = [2 length(mediumPSLpool_)];
					case 3
						minorPSL = GridGrowthTrigger(seed, 'MINOR');	
						if 0==minorPSL.length, continue; end
						minorPSLpool_(end+1,1) = minorPSL;
						minorCoordList_(end+1:end+minorPSL.length,:) = minorPSL.phyCoordList;
						PSLsAppearanceOrder_(end+1,:) = [3 length(minorPSLpool_)];
				end
			end					
			disp([' Progress.: ' sprintf('%6i',ii) ' Total.: ' sprintf('%6i',numSeedPoints)]);			
		end
	end
	CompactPSLs();
end

function PreprocessSeedPoints()
	global seedPoints_;
	global seedPointsValence_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_; 
	global relaxedFactor_;
	global multiMergingThresholdsCtrl_;
	
	numMajorPSLs = length(majorPSLpool_);
	for ii=1:numMajorPSLs
		majorPSL = majorPSLpool_(ii);
		if majorPSL.length>0					
			sppsEmptyMajorValence = find(0==seedPointsValence_(:,1));
            if ~isempty(sppsEmptyMajorValence)
				[potentialDisListMajor, potentialPosListMajor] = GetDisListOfPointList2Curve(...	
					seedPoints_(sppsEmptyMajorValence,:), majorPSL.phyCoordList);
				potentialSolidSppsMajor = find(potentialDisListMajor<=multiMergingThresholdsCtrl_(1)*relaxedFactor_);
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
				potentialSolidSppsMedium = find(potentialDisListMedium<=multiMergingThresholdsCtrl_(2)*relaxedFactor_);
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
				potentialSolidSppsMinor = find(potentialDisListMinor<=multiMergingThresholdsCtrl_(3)*relaxedFactor_);
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
	global tracingStepWidth_;
	global boundingBox_;
	global snappingOpt_;
	stopCond = ceil(1.5*norm(boundingBox_(2,:)-boundingBox_(1,:))/tracingStepWidth_);	
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
	global multiMergingThresholdsCtrl_; 

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
	minVal = min(disT, [], 1);
	minVal = minVal/mergeTrigger_;
	switch psDir
		case 'MAJOR'
			modifiedValences = find(minVal<multiMergingThresholdsCtrl_(1)*relaxedFactor_);	
		case 'MEDIUM'
			modifiedValences = find(minVal<multiMergingThresholdsCtrl_(2)*relaxedFactor_);	
		case 'MINOR'
			modifiedValences = find(minVal<multiMergingThresholdsCtrl_(3)*relaxedFactor_);	
	end	
	modifiedValences = spps2BeMerged(modifiedValences);
end

function CompactPSLs()
	global minLengthVisiblePSLs_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	global PSLsAppearanceOrder_;
	filterThreshold = minLengthVisiblePSLs_;
	
	numMajorPSLs = length(majorPSLpool_);
	tarIndice = [];
	for ii=1:numMajorPSLs
		if majorPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	majorPSLpool_ = majorPSLpool_(tarIndice);
	tmp = find(1==PSLsAppearanceOrder_(:,1));
	if ~isempty(tmp)
		PSLsAppearanceOrder_(tmp(tarIndice),2) = (1:length(tarIndice))';
		PSLsAppearanceOrder_(tmp(setdiff((1:numMajorPSLs)', tarIndice)),:) = []; 	
	end

	numMediumPSLs = length(mediumPSLpool_);
	tarIndice = [];
	for ii=1:numMediumPSLs
		if mediumPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	mediumPSLpool_ = mediumPSLpool_(tarIndice);	
	tmp = find(2==PSLsAppearanceOrder_(:,1));
	if ~isempty(tmp)
		PSLsAppearanceOrder_(tmp(tarIndice),2) = (1:length(tarIndice))';
		PSLsAppearanceOrder_(tmp(setdiff((1:numMediumPSLs)', tarIndice)),:) = []; 	
	end

	numMinorPSLs = length(minorPSLpool_);
	tarIndice = [];
	for ii=1:numMinorPSLs
		if minorPSLpool_(ii).length > filterThreshold
			tarIndice(end+1,1) = ii;
		end
	end
	minorPSLpool_ = minorPSLpool_(tarIndice);
	tmp = find(3==PSLsAppearanceOrder_(:,1));
	if ~isempty(tmp)
		PSLsAppearanceOrder_(tmp(tarIndice),2) = (1:length(tarIndice))';
		PSLsAppearanceOrder_(tmp(setdiff((1:numMinorPSLs)', tarIndice)),:) = [];
	end
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
