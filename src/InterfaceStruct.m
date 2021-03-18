function val = InterfaceStruct()
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
	%% Our methods (=='TRUE') or simply tracing from each seed point (=='FALSE')
	%% arg8: "snappingOpt", Scalar var in any format
	%% Snapping PSLs (=='TRUE') or not (=='FALSE') when they are too close
	%% arg9: "maxAngleDevi", Scalar var in double float
	%% Permitted Maximum Adjacent Tangent Angle Deviation, default 6
	%% arg10: "multiMergingThresholds", triple array [major, medium, minor]
	%% Allow the Different Types of PSLs to have Different Merging Thresholds
	%% arg11: "traceAlgorithm"
	%% can be 'Euler', 'RK2', 'RK4'
	val = struct(...
		'fileName', 						'datasetDir',		...
		'lineDensCtrl',						'default',			...
		'numLevels',						'default',			...
		'seedStrategy',						'Volume',			...
		'seedDensCtrl',						'default',			...
		'selectedPrincipalStressField',		["MAJOR", "MINOR"],	...
		'mergingOpt',						1,					...
		'snappingOpt',						0,					...
		'maxAngleDevi',						6,					...
		'multiMergingThresholds',			[1 1 1],			...
		'traceAlgorithm',					'RK2'				...		
	);
end