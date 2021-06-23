function GenerateSpaceFillingPSLs_evenlySpacedSeeding(iEpsilon)
	global boundingBox_; 
	global seedPoints_; global seedPointsHistory_;
	global selectedPrincipalStressField_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_; 
	global PSLsAppearanceOrder_;
	global mergeTrigger_; 

	%% Exclude the irrelated Principal Stress Fields
	
	typePSLtable = ones(1,3);
	numPSF = length(selectedPrincipalStressField_);
	for ii=1:numPSF
		iPSF = selectedPrincipalStressField_(ii);
		switch iPSF
			case 1, typePSLtable(1) = 0; 
			case 2, typePSLtable(2) = 0; 
			case 3, typePSLtable(3) = 0;
		end
	end
	
	%%1. initialize sampling points
	mergeTrigger_ = 1.2*iEpsilon; %%original
	% mergeTrigger_ = 1.3*iEpsilon; %%optimized cantilever_iLoad4 (dens: 6, seed: 2)
	% mergeTrigger_ = 1.5*iEpsilon; %%optimized cantilever_iLoad4 (dens: 4, seed: 7)
	% mergeTrigger_ = 1.2*iEpsilon; %%cantilever (dens: 4, seed: 8)	trick
	% mergeTrigger_ = 1.15*iEpsilon; %%cantilever (dens: 5, seed: 5)	
	% mergeTrigger_ = 1.23*iEpsilon; %% arched bridge (dens: 4, seed: 2), (dens: 6, seed: 2)
    % mergeTrigger_ = 1.14*iEpsilon; %%Chamfer (dens: 8, seed: 5)
	
	startCoord = (boundingBox_(2,:) + boundingBox_(1,:))/2;
	[~, pos] = min(vecnorm(startCoord-seedPointsHistory_,2,2));
	startCoord = seedPointsHistory_(pos,:);
	
	%%Major
	if 0==typePSLtable(1)
		seedPoints_ = seedPointsHistory_;
		numSeedPoints = size(seedPoints_,1);
		%%2. create the 1st streamline
		majorPSL = GridGrowthTrigger(startCoord, 'MAJOR');
		if 0==majorPSL.length
			error('Failed to Create the 1st Streamline, Please Relocate the Start Seed Point!'); 
		end
		PSLsAppearanceOrder_(end+1,:) = [1 length(majorPSLpool_)];
		majorPSLpool_(end+1,1) = majorPSL;
		spps = FindPotentialSamplingPoints(majorPSL);
		looper = 0;
		while ~isempty(spps)
			looper = looper + 1;
			seed = spps(1,:);
			spps(1,:) = [];
			majorPSL = GridGrowthTrigger(seed, 'MAJOR');
			if 0==majorPSL.length				
				disp(['Major PS Iteration.: ' sprintf('%4i',looper) ' Progress: ' sprintf('%6i %6i', ...
					[numSeedPoints-size(seedPoints_,1) numSeedPoints])]);
				continue; 
			end
			PSLsAppearanceOrder_(end+1,:) = [1 length(majorPSLpool_)];
			majorPSLpool_(end+1,1) = majorPSL;
			spps = WeedoutInvalidSpps(majorPSL, spps);
			newSpps = FindPotentialSamplingPoints(majorPSL);
			spps = [spps; newSpps];
			disp(['Major PS Iteration.: ' sprintf('%4i',looper) ' Progress: ' sprintf('%6i %6i', ...
				[numSeedPoints-size(seedPoints_,1) numSeedPoints])]);
			if isempty(spps) && ~isempty(seedPoints_)
				spps = seedPoints_(1,:);
			end				
		end
	end

	%%Major
	if 0==typePSLtable(2)
		seedPoints_ = seedPointsHistory_;
		numSeedPoints = size(seedPoints_,1);
		%%2. create the 1st streamline
		mediumPSL = GridGrowthTrigger(startCoord, 'MEDIUM');
		if 0==mediumPSL.length
			error('Failed to Create the 1st Streamline, Please Relocate the Start Seed Point!'); 
		end
		PSLsAppearanceOrder_(end+1,:) = [2 length(mediumPSLpool_)];
		mediumPSLpool_(end+1,1) = mediumPSL;
		spps = FindPotentialSamplingPoints(mediumPSL);
		looper = 0;
		while ~isempty(spps)
			looper = looper + 1;
			seed = spps(1,:);
			spps(1,:) = [];
			mediumPSL = GridGrowthTrigger(seed, 'MEDIUM');
			if 0==mediumPSL.length				
				disp(['Medium PS Iteration.: ' sprintf('%4i',looper) ' Progress: ' sprintf('%6i %6i', ...
					[numSeedPoints-size(seedPoints_,1) numSeedPoints])]);
				continue; 
			end
			PSLsAppearanceOrder_(end+1,:) = [2 length(mediumPSLpool_)];
			mediumPSLpool_(end+1,1) = mediumPSL;
			spps = WeedoutInvalidSpps(mediumPSL, spps);
			newSpps = FindPotentialSamplingPoints(mediumPSL);
			spps = [spps; newSpps];
			disp(['Medium PS Iteration.: ' sprintf('%4i',looper) ' Progress: ' sprintf('%6i %6i', ...
				[numSeedPoints-size(seedPoints_,1) numSeedPoints])]);
			if isempty(spps) && ~isempty(seedPoints_)
				spps = seedPoints_(1,:);
			end
		end
	end
	
	%%Minor
	if 0==typePSLtable(3)
		seedPoints_ = seedPointsHistory_;
		numSeedPoints = size(seedPoints_,1);
		%%2. create the 1st streamline
		minorPSL = GridGrowthTrigger(startCoord, 'MINOR');
		if 0==minorPSL.length
			error('Failed to Create the 1st Streamline, Please Relocate the Start Seed Point!'); 
		end
		PSLsAppearanceOrder_(end+1,:) = [3 length(minorPSLpool_)];
		minorPSLpool_(end+1,1) = minorPSL;
		spps = FindPotentialSamplingPoints(minorPSL);
		looper = 0;
		while ~isempty(spps)
			looper = looper + 1;
			seed = spps(1,:);
			spps(1,:) = [];
			minorPSL = GridGrowthTrigger(seed, 'MINOR');
			if 0==minorPSL.length				
				disp(['Minor PS Iteration.: ' sprintf('%4i',looper) ' Progress: ' sprintf('%6i %6i', ...
					[numSeedPoints-size(seedPoints_,1) numSeedPoints])]);
				continue; 
			end
			PSLsAppearanceOrder_(end+1,:) = [3 length(minorPSLpool_)];
			minorPSLpool_(end+1,1) = minorPSL;
			spps = WeedoutInvalidSpps(minorPSL, spps);
			newSpps = FindPotentialSamplingPoints(minorPSL);
			spps = [spps; newSpps];
			disp(['Minor PS Iteration.: ' sprintf('%4i',looper) ' Progress: ' sprintf('%6i %6i', ...
				[numSeedPoints-size(seedPoints_,1) numSeedPoints])]);
			if isempty(spps) && ~isempty(seedPoints_)
				spps = seedPoints_(1,:);
			end				
		end
	end	
	
	CompactPSLs();
end

function iPSL = GridGrowthTrigger(seed, psDir)
	global tracingStepWidth_;
	global boundingBox_;
	global snappingOpt_;
	stopCond = ceil(1.5*norm(boundingBox_(2,:)-boundingBox_(1,:))/tracingStepWidth_);	
	iPSL = GeneratePrincipalStressLines(seed, psDir, stopCond);
	if snappingOpt_, iPSL = CroppingPSLifNeeded(iPSL, psDir); end	
end

function spps = FindPotentialSamplingPoints(tarPSL)
	global seedPoints_;
	global mergeTrigger_;
	spps = []; 
	if isempty(seedPoints_), return; end
	relaxedFac1 = 0.1;
	curveLine = tarPSL.phyCoordList;
	
	disT = (curveLine(:,1) - seedPoints_(:,1)').^2;
	disT = disT + (curveLine(:,2) - seedPoints_(:,2)').^2;
	disT = disT + (curveLine(:,3) - seedPoints_(:,3)').^2;
	disT = sqrt(disT);
	[disT, ~] = min(disT,[],1);
	potentialSppPool = find(disT<(1+relaxedFac1)*mergeTrigger_);
	targetSppPool = potentialSppPool(disT(potentialSppPool)>(1-relaxedFac1)*mergeTrigger_);
	spps = seedPoints_(targetSppPool,:);
	usedSppPool = setdiff(potentialSppPool, targetSppPool);
	seedPoints_(usedSppPool,:) = [];
end

function tarSpps = WeedoutInvalidSpps(tarPSL, srcSpps)
	global mergeTrigger_;
	tarSpps = srcSpps;
	if isempty(srcSpps), return; end
	relaxedFac1 = 0.1;
	curveLine = tarPSL.phyCoordList;

	disT = (curveLine(:,1) - srcSpps(:,1)').^2;
	disT = disT + (curveLine(:,2) - srcSpps(:,2)').^2;
	disT = disT + (curveLine(:,3) - srcSpps(:,3)').^2;
	disT = sqrt(disT);
	[disT, ~] = min(disT,[],1);
	usedSppPool = find(disT<(1-relaxedFac1)*mergeTrigger_);
	tarSpps(usedSppPool,:) = [];
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
