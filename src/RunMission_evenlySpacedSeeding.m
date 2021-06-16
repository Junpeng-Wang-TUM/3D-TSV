function [opt, pslDataNameOutput] = RunMission_evenlySpacedSeeding(userInterface)	
	%%1. Initialize Experiment Environment
	%%1.1 variable declaration	
	tStart = tic;
	global tracingFuncHandle_;
	global tracingStepWidth_;
	global majorPSLindexList_;
	global mediumPSLindexList_;
	global minorPSLindexList_;	
	opt = 0; pslDataNameOutput = [];
	if ~(1==nargin || 3==nargin || 10==nargin), error('Wrong Input!'); end
	GlobalVariables;	
	%%1.2 Decode input arguments
	fileName = userInterface.fileName;
	if ~strcmp(dataName_, fileName)		
		ImportStressFields(fileName);
		dataName_ = fileName;
	end
	
	dimentions = sort(boundingBox_(2,:)-boundingBox_(1,:)); %%Ascending
	lineDensCtrl = userInterface.lineDensCtrl;
	if strcmp(lineDensCtrl, 'default')
		lineDensCtrl = (8000/(dimentions(2)/dimentions(1))/(dimentions(3)/dimentions(2)))^(1/3);
	end
	minimumEpsilon_ = dimentions(1)/lineDensCtrl;
	
	numLevels = userInterface.numLevels;
	if strcmp(numLevels, 'default')
		numLevels = max(round(log2(lineDensCtrl)),2); %% or simply
		%% numLevels = 1;	
	end
	
	seedStrategy = userInterface.seedStrategy;
	
	seedDensCtrl = userInterface.seedDensCtrl;
	if strcmp(seedDensCtrl, 'default')
		if strcmp(meshType_, 'CARTESIAN_GRID'), seedDensCtrl = max(ceil(minimumEpsilon_/eleSize_/1.7), 2);
		else, seedDensCtrl = 2; end		
	end
	
	selectedPrincipalStressField_ = userInterface.selectedPrincipalStressField;
	numPSF = length(selectedPrincipalStressField_);
	for ii=1:numPSF
		iPSF = selectedPrincipalStressField_(ii);
		switch iPSF
			case 1, PSLsAppearanceOrder_(end+1,:) = [1 0];
			case 2, PSLsAppearanceOrder_(end+1,:) = [2 0];
			case 3, PSLsAppearanceOrder_(end+1,:) = [3 0];
		end
	end
	
	mergingOpt_ = userInterface.mergingOpt;
	if ~mergingOpt_, numLevels = 1; end
	numLevels = 1;
	multiMergingThresholdsCtrl_ = userInterface.multiMergingThresholds;
	
	snappingOpt_ = userInterface.snappingOpt;
	
	permittedMaxAdjacentTangentAngleDeviation_ = userInterface.maxAngleDevi;
	
	traceAlg_ = userInterface.traceAlgorithm;
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
	GenerateSeedPoints(seedStrategy, seedDensCtrl);
	
	%%3. PSL generation
	tracingStepWidth_ = integratingStepScalingFac_ * eleSize_;
	majorPSLindexList_ = struct('arr', []); majorPSLindexList_ = repmat(majorPSLindexList_, 1, numLevels);
	mediumPSLindexList_ = struct('arr', []); mediumPSLindexList_ = repmat(mediumPSLindexList_, 1, numLevels);     
	minorPSLindexList_ = struct('arr', []); minorPSLindexList_ = repmat(minorPSLindexList_, 1, numLevels);	
	index = 1;
	while index<=numLevels
		iEpsilon = minimumEpsilon_ * 2^(numLevels-index);
		GenerateSpaceFillingPSLs_evenlySpacedSeeding(iEpsilon);
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