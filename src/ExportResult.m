function ExportResult(fileName)
	pslDataPath = strcat(fileName, '_psl.dat');
	global majorPSLpool_;
	global minorPSLpool_;
	global majorHierarchy_; 
	global minorHierarchy_; 
	global surfaceQuadMeshNodeCoords_;
	global surfaceQuadMeshElements_;	
	global tracingStepWidth_;
	lineWidthTube = 4*tracingStepWidth_;
	
	fid = fopen(pslDataPath, 'w');
	outPutFormat1 = '%16.6e';
	outPutFormat2 = ' %.6e';
	outPutFormat3 = ' %.6f';
	outPutFormat = outPutFormat2;
	%%1. write PSLs
	%%1.1 major
	numMajorPSLs = length(majorPSLpool_);
	fprintf(fid, '%s', '#Major'); fprintf(fid, ' %d\n', numMajorPSLs);
	for ii=1:numMajorPSLs
		iPSL = majorPSLpool_(ii);		
		pslCoords = iPSL.phyCoordList; pslCoords = reshape(pslCoords', numel(pslCoords), 1)';		
		ribbonCoordsUnsmoothed = ExpandPSLs2Ribbon(iPSL, lineWidthTube, 0);
		ribbonCoordsUnsmoothed = reshape(ribbonCoordsUnsmoothed', numel(ribbonCoordsUnsmoothed), 1)';
		ribbonCoordsSmoothed = ExpandPSLs2Ribbon(iPSL, lineWidthTube, 1);
		ribbonCoordsSmoothed = reshape(ribbonCoordsSmoothed', numel(ribbonCoordsSmoothed), 1)';
		stressScalarFields4ColorCoding = [iPSL.principalStressList(:,9) iPSL.vonMisesStressList iPSL.cartesianStressList];
		
		fprintf(fid, '%d %.6f %.6f %.6f %.6f\n', [iPSL.length majorHierarchy_(ii,:)]);
		fprintf(fid, outPutFormat, pslCoords); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsUnsmoothed); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsSmoothed); fprintf(fid, '\n');
		for jj=1:8
			fprintf(fid, outPutFormat, stressScalarFields4ColorCoding(:,jj)'); fprintf(fid, '\n');
		end
	end	
	%%1.2 minor
	numMinorPSLs = length(minorPSLpool_);
	fprintf(fid, '%s', '#Minor'); fprintf(fid, ' %d\n', numMinorPSLs);
	for ii=1:numMinorPSLs
		iPSL = minorPSLpool_(ii);
		pslCoords = iPSL.phyCoordList; pslCoords = reshape(pslCoords', numel(pslCoords), 1)';		
		ribbonCoordsUnsmoothed = ExpandPSLs2Ribbon(iPSL, lineWidthTube, 0);		
		ribbonCoordsUnsmoothed = reshape(ribbonCoordsUnsmoothed', numel(ribbonCoordsUnsmoothed), 1)';
		ribbonCoordsSmoothed = ExpandPSLs2Ribbon(iPSL, lineWidthTube, 1);
		ribbonCoordsSmoothed = reshape(ribbonCoordsSmoothed', numel(ribbonCoordsSmoothed), 1)';
		stressScalarFields4ColorCoding = [iPSL.principalStressList(:,1) iPSL.vonMisesStressList iPSL.cartesianStressList];
		
		fprintf(fid, '%d %.6f %.6f %.6f %.6f\n', [iPSL.length minorHierarchy_(ii,:)]);	
		fprintf(fid, outPutFormat, pslCoords); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsUnsmoothed); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsSmoothed); fprintf(fid, '\n');
		for jj=1:8
			fprintf(fid, outPutFormat, stressScalarFields4ColorCoding(:,jj)'); fprintf(fid, '\n');
		end
	end
	
	%%2. write outline in quad mesh
	numVtx = size(surfaceQuadMeshNodeCoords_,1);
	numFace = size(surfaceQuadMeshElements_,1);
	fprintf(fid, '%s', '#Outline'); fprintf(fid, '\n');
	fprintf(fid, '%s', '#Vertices'); fprintf(fid, ' %d\n', numVtx);
	fprintf(fid, strcat(outPutFormat, outPutFormat, outPutFormat, '\n'), surfaceQuadMeshNodeCoords_');
	fprintf(fid, '%s', '#Faces'); fprintf(fid, ' %d\n', numFace);
	fprintf(fid, '%d %d %d %d\n', surfaceQuadMeshElements_'-1);
	fclose(fid);
end