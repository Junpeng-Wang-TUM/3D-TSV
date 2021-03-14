function [opt, pslDataNameOutput] = RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, varargin)
	%%1. Global Variable Statement and Import Dataset
	%% Syntax:
	%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
	%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, maxAngleDevi, snappingOpt, minPSLength, volumeSeedingOpt, traceAlgorithm);
	
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
	%% arg9: "traceAlgorithm"
	%% can be 'Euler', 'RK2', 'RK4'
	
	%% NOTE: Regarding arguments "minimumEpsilon" and "numLevels",
	%% Generally NOT Recommend minimumEpsilon*2^(numLevels-1) > min([resX, resY, resZ]) for Common Use
	opt = 0; pslDataNameOutput = [];
	if ~(4==nargin || 9==nargin), error('Wrong Input!'); end
	GlobalVariables;
	global tracingFuncHandle_;
	global majorPSLindexList_;
	global mediumPSLindexList_;
	global minorPSLindexList_;
	if ~strcmp(dataName_, fileName)		
		ImportStressFields(fileName);
		dataName_ = fileName;
	end
	if 9==nargin
		permittedMaxAdjacentTangentAngleDeviation_ = varargin{1};
		snappingOpt_ = varargin{2};
		minLengthVisiblePSLs_ = varargin{3};
		seedSpan4VolumeOptCartesianMesh_ = varargin{4};
		traceAlg_ = varargin{5};
	else
		seedSpan4VolumeOptCartesianMesh_ = ceil(minimumEpsilon/1.7);
	end
	
	if strcmp(meshType_, 'CARTESIAN_GRID')
		switch traceAlg_
			case 'Euler', tracingFuncHandle_ = @TracingPSL_Euler_CartesianMesh;
			case 'RK2', tracingFuncHandle_ = @TracingPSL_RK2_CartesianMesh;
			case 'RK4', tracingFuncHandle_ = @TracingPSL_RK4_CartesianMesh;
		end	
	else
		switch traceAlg_
			case 'Euler', tracingFuncHandle_ = @TracingPSL_Euler_UnstructuredMesh;
			case 'RK2', tracingFuncHandle_ = @TracingPSL_RK2_UnstructuredMesh;
			case 'RK4', tracingFuncHandle_ = @TracingPSL_RK4_UnstructuredMesh;
		end		
	end

	%%2. Seeding
	GenerateSeedPoints(seedStrategy);
	
	%%3. PSL generation
	tracingStepWidth_ = eleSize_*1;
	majorPSLindexList_ = struct('arr', []); majorPSLindexList_ = repmat(majorPSLindexList_, 1, numLevels);
	mediumPSLindexList_ = struct('arr', []); mediumPSLindexList_ = repmat(mediumPSLindexList_, 1, numLevels);     
	minorPSLindexList_ = struct('arr', []); minorPSLindexList_ = repmat(minorPSLindexList_, 1, numLevels);	
	index = 1;
	while index<=numLevels
		iEpsilon = minimumEpsilon * 2^(numLevels-index);
		GenerateSpaceFillingPSLs(iEpsilon);
		majorPSLindexList_(index).arr = 1:length(majorPSLpool_);
		mediumPSLindexList_(index).arr = 1:length(mediumPSLpool_);
		minorPSLindexList_(index).arr = 1:length(minorPSLpool_);
		index = index + 1;
	end	
	
    %%4. building hierarchy
    BuildPSLs4Hierarchy();
	%%5. write results
	pslDataNameOutput = strcat(erase(dataName_,'.vtk'), '_psl.dat');;
	ExportResult(pslDataNameOutput);
	opt = 1;
end