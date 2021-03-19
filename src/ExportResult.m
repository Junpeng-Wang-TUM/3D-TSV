function ExportResult(fileName)	
	global meshType_;
	global majorPSLpool_;
	global mediumPSLpool_;
	global minorPSLpool_;
	global majorHierarchy_;
	global mediumHierarchy_;	
	global minorHierarchy_; 
	global PSLsAppearanceOrder_;
	global surfaceQuadMeshNodeCoords_;
	global surfaceQuadMeshElements_;	
	global tracingStepWidth_;
	lineWidthTube = 4*tracingStepWidth_;
	
	fid = fopen(fileName, 'w');
	outPutFormat1 = '%16.6e';
	outPutFormat2 = ' %.6e';
	outPutFormat3 = ' %.6f';
	outPutFormat = outPutFormat2;
	%%1. write PSLs
	%%1.1 major
	numMajorPSLs = length(majorPSLpool_);
	majorPSLsGlobalAppearanceOrder = find(1==PSLsAppearanceOrder_(:,1));
	fprintf(fid, '%s', '#Major'); fprintf(fid, ' %d\n', numMajorPSLs);
	for ii=1:numMajorPSLs
		iPSL = majorPSLpool_(ii);
		iSeed = iPSL.phyCoordList(iPSL.midPointPosition,:);
		pslCoords = iPSL.phyCoordList; pslCoords = reshape(pslCoords', numel(pslCoords), 1)';		
		ribbonCoordsUnsmoothed = ExpandPSLs2Ribbon(iPSL, [6 7 8], lineWidthTube, 0);
		ribbonCoordsUnsmoothed = reshape(ribbonCoordsUnsmoothed', numel(ribbonCoordsUnsmoothed), 1)';
		ribbonCoordsSmoothed = ExpandPSLs2Ribbon(iPSL, [6 7 8], lineWidthTube, 1);
		ribbonCoordsSmoothed = reshape(ribbonCoordsSmoothed', numel(ribbonCoordsSmoothed), 1)';
		stressScalarFields4ColorCoding = [iPSL.principalStressList(:,9) iPSL.vonMisesStressList iPSL.cartesianStressList];
		
		fprintf(fid, '%d %.6f %.6f %.6f %.6f', [iPSL.length majorHierarchy_(ii,:)]);	
		fprintf(fid, ' %d %.6f %.6f %.6f\n', [majorPSLsGlobalAppearanceOrder(ii) iSeed]);	
		fprintf(fid, outPutFormat, pslCoords); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsUnsmoothed); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsSmoothed); fprintf(fid, '\n');
		for jj=1:8
			fprintf(fid, outPutFormat, stressScalarFields4ColorCoding(:,jj)'); fprintf(fid, '\n');
		end
	end
	%%1.2 medium
	numMediumPSLs = length(mediumPSLpool_);
	mediumPSLsGlobalAppearanceOrder = find(2==PSLsAppearanceOrder_(:,1));
	fprintf(fid, '%s', '#Medium'); fprintf(fid, ' %d\n', numMediumPSLs);
	for ii=1:numMediumPSLs
		iPSL = mediumPSLpool_(ii);
		iSeed = iPSL.phyCoordList(iPSL.midPointPosition,:);
		pslCoords = iPSL.phyCoordList; pslCoords = reshape(pslCoords', numel(pslCoords), 1)';		
		ribbonCoordsUnsmoothed = ExpandPSLs2Ribbon(iPSL, [2 3 4], lineWidthTube, 0);
		ribbonCoordsUnsmoothed = reshape(ribbonCoordsUnsmoothed', numel(ribbonCoordsUnsmoothed), 1)';
		ribbonCoordsSmoothed = ExpandPSLs2Ribbon(iPSL, [2 3 4], lineWidthTube, 1);
		ribbonCoordsSmoothed = reshape(ribbonCoordsSmoothed', numel(ribbonCoordsSmoothed), 1)';
		stressScalarFields4ColorCoding = [iPSL.principalStressList(:,5) iPSL.vonMisesStressList iPSL.cartesianStressList];

		fprintf(fid, '%d %.6f %.6f %.6f %.6f', [iPSL.length mediumHierarchy_(ii,:)]);		
		fprintf(fid, ' %d %.6f %.6f %.6f\n', [mediumPSLsGlobalAppearanceOrder(ii) iSeed]);		
		fprintf(fid, outPutFormat, pslCoords); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsUnsmoothed); fprintf(fid, '\n');
		fprintf(fid, outPutFormat, ribbonCoordsSmoothed); fprintf(fid, '\n');
		for jj=1:8
			fprintf(fid, outPutFormat, stressScalarFields4ColorCoding(:,jj)'); fprintf(fid, '\n');
		end
	end		
	%%1.3 minor
	numMinorPSLs = length(minorPSLpool_);
	minorPSLsGlobalAppearanceOrder = find(3==PSLsAppearanceOrder_(:,1));
	fprintf(fid, '%s', '#Minor'); fprintf(fid, ' %d\n', numMinorPSLs);
	for ii=1:numMinorPSLs
		iPSL = minorPSLpool_(ii);
		iSeed = iPSL.phyCoordList(iPSL.midPointPosition,:);
		pslCoords = iPSL.phyCoordList; pslCoords = reshape(pslCoords', numel(pslCoords), 1)';		
		ribbonCoordsUnsmoothed = ExpandPSLs2Ribbon(iPSL, [6 7 8], lineWidthTube, 0);		
		ribbonCoordsUnsmoothed = reshape(ribbonCoordsUnsmoothed', numel(ribbonCoordsUnsmoothed), 1)';
		ribbonCoordsSmoothed = ExpandPSLs2Ribbon(iPSL, [6 7 8], lineWidthTube, 1);
		ribbonCoordsSmoothed = reshape(ribbonCoordsSmoothed', numel(ribbonCoordsSmoothed), 1)';
		stressScalarFields4ColorCoding = [iPSL.principalStressList(:,1) iPSL.vonMisesStressList iPSL.cartesianStressList];
		
		fprintf(fid, '%d %.6f %.6f %.6f %.6f', [iPSL.length minorHierarchy_(ii,:)]);		
		fprintf(fid, ' %d %.6f %.6f %.6f\n', [minorPSLsGlobalAppearanceOrder(ii) iSeed]);					
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
	fprintf(fid, '%s', '#Outline'); 
	if strcmp(meshType_, 'CARTESIAN_GRID')
		fprintf(fid, '  %s', 'Cartesian'); 
	else
		fprintf(fid, '  %s', 'Unstructured'); 
	end
	fprintf(fid, '\n');
	fprintf(fid, '%s', '#Vertices'); fprintf(fid, ' %d\n', numVtx);
	fprintf(fid, strcat(outPutFormat, outPutFormat, outPutFormat, '\n'), surfaceQuadMeshNodeCoords_');
	fprintf(fid, '%s', '#Faces'); fprintf(fid, ' %d\n', numFace);
	fprintf(fid, '%d %d %d %d\n', surfaceQuadMeshElements_'-1);
	fclose(fid);
end