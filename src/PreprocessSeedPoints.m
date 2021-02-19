function PreprocessSeedPoints()
	global functionality_;
	global seedPoints_;
	global samplingPointsValence_;
	global majorPSLpool_; global minorPSLpool_; 
	global mergeTrigger_; global relaxedFactor_;
	
	numMajorPSLs = length(majorPSLpool_);
	for ii=1:numMajorPSLs
		majorPSL = majorPSLpool_(ii);
		if majorPSL.length>0					
			sppsEmptyMajorValence = find(0==samplingPointsValence_(:,1));
			if length(sppsEmptyMajorValence)>0
				[potentialDisListMajor, potentialPosListMajor] = LocateSP2TarPSL(...	
					seedPoints_(sppsEmptyMajorValence,:), majorPSL.phyCoordList);
				potentialSolidSppsMajor = find(potentialDisListMajor<=relaxedFactor_);
				if ~isempty(potentialSolidSppsMajor)
					spps2BeMerged = sppsEmptyMajorValence(potentialSolidSppsMajor);							
					seedPoints_(spps2BeMerged,:) = ...
						potentialPosListMajor(potentialSolidSppsMajor,:);
					samplingPointsValence_(spps2BeMerged,1) = 1;						
					modifiedMinorValences = HighCurvatureModification(...
						spps2BeMerged, 'MINORPSL');
					samplingPointsValence_(modifiedMinorValences,2) = 1;							
				end
			end
		end
	end

	numMinorPSLs = length(minorPSLpool_);
	for ii=1:numMinorPSLs
		minorPSL = minorPSLpool_(ii);
		if minorPSL.length>0	
			sppsEmptyMinorValence = find(0==samplingPointsValence_(:,2));
			if length(sppsEmptyMinorValence)>0	
				[potentialDisListMinor, potentialPosListMinor] = LocateSP2TarPSL(...	
					seedPoints_(sppsEmptyMinorValence,:), minorPSL.phyCoordList);
				potentialSolidSppsMinor = find(potentialDisListMinor<=relaxedFactor_);
				if ~isempty(potentialSolidSppsMinor)
					spps2BeMerged = sppsEmptyMinorValence(potentialSolidSppsMinor);
					seedPoints_(spps2BeMerged,:) = ...
						potentialPosListMinor(potentialSolidSppsMinor,:);
					samplingPointsValence_(spps2BeMerged,2) = 1;
					modifiedMajorValences = HighCurvatureModification(...
						spps2BeMerged, 'MAJORPSL');
					samplingPointsValence_(modifiedMajorValences,1) = 1;													
				end
			end
		end
	end		
end

function [potentialDisList, potentialPosList] = LocateSP2TarPSL(pointList, curveLine)
	global GPU_;
	global mergeTrigger_;
	if strcmp(GPU_, 'ON')
		pointList = gpuArray(pointList);
		curveLine = gpuArray(curveLine);	
	end
	disX = curveLine(:,1) - pointList(:,1)';
	disY = curveLine(:,2) - pointList(:,2)';
	disZ = curveLine(:,3) - pointList(:,3)';
	disT = sqrt(disX.^2 + disY.^2 + disZ.^2);
	[minVal, minValPos] = min(disT,[],1);
	if strcmp(GPU_, 'ON')
		minVal = gather(minVal);
		minValPos = gather(minValPos);	
	end
	potentialDisList = minVal';
	potentialDisList = potentialDisList/mergeTrigger_;
	potentialPosList = curveLine(minValPos,:);	
end

function modifiedValences = HighCurvatureModification(spps2BeMerged, psDir)
	global majorCoordList_; global minorCoordList_;
	global seedPoints_;
	global mergeTrigger_;
	global relaxedFactor_;
	global GPU_;
	global domainType_;
	modifiedValences = [];
	pointList = seedPoints_(spps2BeMerged,:);
	coordList = [];
	switch psDir
		case 'MAJORPSL'
			if isempty(majorCoordList_), modifiedValences = []; return; end
			coordList = majorCoordList_;
		case 'MINORPSL'
			if isempty(minorCoordList_), modifiedValences = []; return; end
			coordList = minorCoordList_;				
	end	

	if strcmp(GPU_, 'ON')
		coordList = gpuArray(coordList);
		pointList = gpuArray(pointList);
	end
	disT = (coordList(:,1) - pointList(:,1)').^2;
	disT = disT + (coordList(:,2) - pointList(:,2)').^2;
	disT = disT + (coordList(:,3) - pointList(:,3)').^2;
	disT = sqrt(disT);		
	minVal = min(disT);
	minVal = minVal/mergeTrigger_;
	if strcmp(GPU_, 'ON'), minVal = gather(minVal); end
	modifiedValences = find(minVal<relaxedFactor_);	
	disRatio = minVal(modifiedValences);
	modifiedValences = spps2BeMerged(modifiedValences);
end