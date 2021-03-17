function [opt, pslDataNameOutput] = RunMission(fileName, varargin)	
	%% Syntax:
	%% RunMission(fileName);
	%% RunMission(fileName, lineDensCtrl, numLevels);
	%% RunMission(fileName, lineDensCtrl, numLevels, seedStrategy, seedDensCtrl, selectedPrincipalStressField, ...
	%%	mergingOpt, snappingOpt, maxAngleDevi, traceAlgorithm);
	%% =====================================================================
	%% arg1: "fileName", char array
	%% path + fullname of dataset, e.g., 'D:/data/name.vtk'
	%% arg2: "lineDensCtrl", Scalar var in double float
	%% minimum feature size of the stress field divided by "lineDensCtrl" is used as the merging threshold Epsilon,
	%%	the smaller, the more PSLs to be generated	
	%% arg3: "numLevels", Scalar var in double float, Generally lineDensCtrl/2^(numLevels-1) > 1	
	%% arg4: "seedStrategy", char array 
	%% can be 'Volume', 'Surface', 'LoadingArea', 'FixedArea'
	%% arg5: "seedDensCtrl", Scalar var in double float/integer & >=1
	%% Control the Density of Seed Points, go to "GenerateSeedPoints.m" to see how it works
	%% for meshType_ == 'CARTESIAN_GRID' & seedStrategy = 'Volume', it's the step size of sampling on vertices along X-, Y-, Z-directions 
	%% 	else, it's the step size of sampling on the selected seed points. The smaller, the more seed points to be generated	
	%% arg6: "selectedPrincipalStressField", char array
	%% default ["MAJOR", "MINOR"], can be ["MAJOR", "MEDIUM", "MINOR"], "MAJOR", "MINOR", etc
	%% arg7: "mergingOpt", Scalar var in any format
	%% Our methods (=='TRUE') or brutally tracing from each seed point (=='FALSE')
	%% arg8: "snappingOpt", Scalar var in any format
	%% Snapping PSLs (=='TRUE') or not (=='FALSE') when they are too close
	%% arg9: "maxAngleDevi", Scalar var in double float
	%% Permitted Maximum Adjacent Tangent Angle Deviation, default 6
	%% arg10: "traceAlgorithm"
	%% can be 'Euler', 'RK2', 'RK4'
	
	%%1. Initialize Experiment Environment
	%%1.1 variable declaration
	tStart = tic;
	global tracingFuncHandle_;
	global majorPSLindexList_;
	global mediumPSLindexList_;
	global minorPSLindexList_;	
	opt = 0; pslDataNameOutput = [];
	if ~(1==nargin || 3==nargin || 10==nargin), error('Wrong Input!'); end
	GlobalVariables;
	%%1.2 Import dataset if needed
	if ~strcmp(dataName_, fileName)		
		ImportStressFields(fileName);
		dataName_ = fileName;
	end
	%%1.3 Decode input arguments
	minFeatureSize = min(vtxUpperBound_-vtxLowerBound_);
	maxFeatureSize = max(vtxUpperBound_-vtxLowerBound_);
	switch nargin
		case 1
			%%Easy-to-Run, all control parameters are default
			if maxFeatureSize/minFeatureSize>2, lineDensCtrl = 10; 
			else, lineDensCtrl = 15; end
			minimumEpsilon_ = minFeatureSize/lineDensCtrl;
			numLevels = 3;
			seedStrategy = 'Volume';
			if strcmp(meshType_, 'CARTESIAN_GRID'), seedDensCtrl = max(ceil(minimumEpsilon_/eleSize_/1.7), 2);
			else, seedDensCtrl = 2; end					
		case 3
			lineDensCtrl = varargin{1}; minimumEpsilon_ = minFeatureSize/lineDensCtrl;
			numLevels = varargin{2};	
			seedStrategy = 'Volume';
			if strcmp(meshType_, 'CARTESIAN_GRID'), seedDensCtrl = max(ceil(minimumEpsilon_/eleSize_/1.7), 2);
			else, seedDensCtrl = 2; end			
		case 10
			lineDensCtrl = varargin{1}; minimumEpsilon_ = minFeatureSize/lineDensCtrl;	
			numLevels = varargin{2};		
			seedStrategy = varargin{3};
			seedDensCtrl = varargin{4};
			selectedPrincipalStressField_ = varargin{5};
			mergingOpt_ = varargin{6};
			snappingOpt_ = varargin{7};
			permittedMaxAdjacentTangentAngleDeviation_ = varargin{8};
			traceAlg_ = varargin{9};			
	end
	if ~mergingOpt_, numLevels = 1; end
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
	numPSF = length(selectedPrincipalStressField_);
	for ii=1:numPSF
		iPSF = selectedPrincipalStressField_(ii);
		switch iPSF
			case 'MAJOR', PSLsAppearanceOrder_(end+1,:) = [1 0];
			case 'MEDIUM', PSLsAppearanceOrder_(end+1,:) = [2 0];
			case 'MINOR', PSLsAppearanceOrder_(end+1,:) = [3 0];
		end
	end	

	%%2. Seeding
	GenerateSeedPoints(seedStrategy, seedDensCtrl);
	
	%%3. PSL generation
	tracingStepWidth_ = eleSize_*1;
	majorPSLindexList_ = struct('arr', []); majorPSLindexList_ = repmat(majorPSLindexList_, 1, numLevels);
	mediumPSLindexList_ = struct('arr', []); mediumPSLindexList_ = repmat(mediumPSLindexList_, 1, numLevels);     
	minorPSLindexList_ = struct('arr', []); minorPSLindexList_ = repmat(minorPSLindexList_, 1, numLevels);	
	index = 1;
	while index<=numLevels
		iEpsilon = minimumEpsilon_ * 2^(numLevels-index);
		GenerateSpaceFillingPSLs(iEpsilon);
		majorPSLindexList_(index).arr = 1:length(majorPSLpool_);
		mediumPSLindexList_(index).arr = 1:length(mediumPSLpool_);
		minorPSLindexList_(index).arr = 1:length(minorPSLpool_);
		index = index + 1;
	end	
	
    %%4. building hierarchy
    BuildPSLs4Hierarchy();
	
	%%5. write results
	pslDataNameOutput = strcat(erase(dataName_,'.vtk'), '_psl.dat');
	ExportResult(pslDataNameOutput);
	opt = 1;
	tEnd = toc(tStart);
	PrintAlgorithmStatistics(tEnd);
end
