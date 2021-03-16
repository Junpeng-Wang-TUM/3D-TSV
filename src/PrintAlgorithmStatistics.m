function PrintAlgorithmStatistics(tEnd)
	global dataName_;
	global numEles_; 
	global seedPointsHistory_;
	global majorPSLpool_; 
	global mediumPSLpool_; 
	global minorPSLpool_; 	
	numMajorPSLs = numel(majorPSLpool_);
	numMediumPSLs = numel(mediumPSLpool_);
	numMinorPSLs = numel(minorPSLpool_);
	disp('==========================================================================');
	disp('===================================DONE===================================');
	disp('==========================================================================');
	disp(['In the Run of Dataset ---------------------------------------------------- ' sprintf('%s', dataName_)]);
	disp(['#Number of Simulation Grids ---------------------------------------------- ', sprintf('%d', numEles_)]);
	disp(['#Number of Seed Points --------------------------------------------------- ', sprintf('%d', size(seedPointsHistory_,1))]);
	disp(['#Number of Major PSLs ---------------------------------------------------- ', sprintf('%d', numMajorPSLs)]);
	disp(['#Number of Medium PSLs --------------------------------------------------- ', sprintf('%d', numMediumPSLs)]);
	disp(['#Number of Minor PSLs ---------------------------------------------------- ', sprintf('%d', numMinorPSLs)]);
	disp(['#Number of Generated PSLs in Total --------------------------------------- ', sprintf('%d', numMajorPSLs+numMediumPSLs+numMinorPSLs)]);
	disp(['Time Costs Totally ------------------------------------------------------- ' sprintf('%.1f',tEnd) 's']);
end