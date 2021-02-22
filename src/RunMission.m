function RunMission(fileName, seedStrategy, minimumEpsilon, numLevels)
	%%1. Global Variable Statement and Import Dataset
	GlobalVariables;
	global majorPSLindexList_;
	global minorPSLindexList_;	
	if ~strcmp(dataName_, fileName)		
		ImportStressFields(fileName);
		dataName_ = fileName;
	end
	if isempty(seedSpan4VolumeOptCartesianMesh_)
		seedSpan4VolumeOptCartesianMesh_ = ceil(minimumEpsilon/1.7);
	end

	%%2. Seeding
	GenerateSeedPoints(seedStrategy);
	
	%%3. PSL generation
	tracingStepWidth_ = eleSize_*1;	
    majorPSLindexList_ = struct('arr', []); majorPSLindexList_ = repmat(majorPSLindexList_, 1, numLevels);        
    minorPSLindexList_ = struct('arr', []); minorPSLindexList_ = repmat(minorPSLindexList_, 1, numLevels);	
    index = 1;
    while index<=numLevels
        % mergeTrigger_ = minimumEpsilon * 2^(numLevels-index) * tracingStepWidth_;
		iEpsilon = minimumEpsilon * 2^(numLevels-index);
        GenerateSpaceFillingPSLs(iEpsilon);
        majorPSLindexList_(index).arr = 1:length(majorPSLpool_);
        minorPSLindexList_(index).arr = 1:length(minorPSLpool_);
		index = index + 1;
    end

    %% building hierarchy
    BuildPSLs4Hierarchy();
end