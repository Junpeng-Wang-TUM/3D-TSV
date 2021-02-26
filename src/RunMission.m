function [opt, pslDataNameOutput] = RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, varargin)
	%%1. Global Variable Statement and Import Dataset
	%% Syntax:
	%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
	%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, maxAngleDevi, snappingOpt, minPSLength, volumeSeedingOpt);
	
	%% arg1: "fileName", char array
	%% path + fullname of dataset, e.g., 'D:/data/name.vtk'
	%% arg2: "seedStrategy", char array 
	%% can be 'Volume', 'Surface', 'LoadingArea', 'ApproxTopology'
	%% arg3: "minimumEpsilon", Scalar var in double float
	%% Generally ranging from 5 to 10, the smaller, the more PSLs to be generated
	%% arg4: "numLevels", Scalar var in double float
	%% Generally ranging from 1 to 5	
	%% arg5: "maxAngleDevi", Scalar var in double float
	%% Permitted Maximum Adjacent Tangent Angle Deviation, Generally ranging from 6 to 20
	%% arg6: "snappingOpt", Scalar var in any format
	%% Snapping PSLs (=='TRUE') or not (=='FALSE') when they are too close
	%% arg7: "minPSLength", Scalar var in double float/integer
	%% Generally ranging from 5 to 20, PSLs with more "minPSLength" integrating points can only be shown
	%% arg8: "volumeSeedingOpt", Scalar var in double float/integer
	%% Generally ranging from 2 to 10, Seed Point Density Control for "Volume" Seeding Strategy of Cartesian Mesh
	
	%% NOTE: Regarding arguments "minimumEpsilon" and "numLevels",
	%% Generally NOT Recommend minimumEpsilon*2^(numLevels-1) > min([resX, resY, resZ]) for Common Use
	opt = 0; pslDataNameOutput = [];
	if ~(4==nargin || 8==nargin), error('Wrong Input!'); end
	GlobalVariables;
	global majorPSLindexList_;
	global minorPSLindexList_;
	if ~strcmp(dataName_, fileName)		
		ImportStressFields(fileName);
		dataName_ = fileName;
	end
	if 8==nargin
		permittedMaxAdjacentTangentAngleDeviation_ = varargin{1};
		snappingOpt_ = varargin{2};
		minLengthVisiblePSLs_ = varargin{3};
		seedSpan4VolumeOptCartesianMesh_ = varargin{4};
	else
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

    %%4. building hierarchy
    BuildPSLs4Hierarchy();
	
	%%5. write results
	pslDataNameOutput = erase(dataName_,'.vtk');
	ExportResult(pslDataNameOutput);
	opt = 1;
end