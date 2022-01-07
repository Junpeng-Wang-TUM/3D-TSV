function ExportBinaryFieldResult(fileName, imOpt, imVal, PSLthickness, boundaryThickness);
	global nelx_; global nely_; global nelz_;
	global numEles_;
	global carEleMapBack_;
	global carNodMapBack_;
	global fixingCond_;
	global loadingCond_;
	global boundaryElements_;
	global majorPSLpool_;
	global majorHierarchy_;
	global mediumPSLpool_;
	global mediumHierarchy_;
	global minorPSLpool_;
	global minorHierarchy_;
	
	%% 1. Get Target PSLs to Export
	miniPSLength = 2;
	%% Major
	switch imOpt(1)
		case 'Geo'
			tarMajorPSLindex = find(majorHierarchy_(:,1)>=imVal(1));
		case 'PS'
			tarMajorPSLindex = find(majorHierarchy_(:,2)>=imVal(1));
		case 'vM'
			tarMajorPSLindex = find(majorHierarchy_(:,3)>=imVal(1));
		case 'Length'
			tarMajorPSLindex = find(majorHierarchy_(:,4)>=imVal(1));
		otherwise
			error('Wrong Input!');
	end
	tarMajorPSLs = majorPSLpool_(tarMajorPSLindex);
	tarIndice = [];
	for ii=1:length(tarMajorPSLs)
		if tarMajorPSLs(ii).length > miniPSLength
			tarIndice(end+1,1) = ii;
			tarMajorPSLs(ii).eleIndexList = tarMajorPSLs(ii).eleIndexList(:)';
		end
	end
	tarMajorPSLs = tarMajorPSLs(tarIndice);	
	numTarMajorPSLs = length(tarMajorPSLs);
	
	%% Medium
	switch imOpt(2)
		case 'Geo'
			tarMediumPSLindex = find(mediumHierarchy_(:,1)>=imVal(2));
		case 'PS'
			tarMediumPSLindex = find(mediumHierarchy_(:,2)>=imVal(2));
		case 'vM'
			tarMediumPSLindex = find(mediumHierarchy_(:,3)>=imVal(2));
		case 'Length'
			tarMediumPSLindex = find(mediumHierarchy_(:,4)>=imVal(2));
		otherwise
			error('Wrong Input!');
	end
	tarMediumPSLs = mediumPSLpool_(tarMediumPSLindex);
	tarIndice = [];
	for ii=1:length(tarMediumPSLs)
		if tarMediumPSLs(ii).length > miniPSLength
			tarIndice(end+1,1) = ii;
			tarMediumPSLs(ii).eleIndexList = tarMediumPSLs(ii).eleIndexList(:)';
		end
	end
	tarMediumPSLs = tarMediumPSLs(tarIndice);		
	numTarMediumPSLs = length(tarMediumPSLs);	
	
	%% Minor
	switch imOpt(3)
		case 'Geo'
			tarMinorPSLindex = find(minorHierarchy_(:,1)>=imVal(3));
		case 'PS'
			tarMinorPSLindex = find(minorHierarchy_(:,2)>=imVal(3));
		case 'vM'
			tarMinorPSLindex = find(minorHierarchy_(:,3)>=imVal(3));
		case 'Length'
			tarMinorPSLindex = find(minorHierarchy_(:,4)>=imVal(3));
		otherwise
			error('Wrong Input!');
	end
	tarMinorPSLs = minorPSLpool_(tarMinorPSLindex);
	tarIndice = [];
	for ii=1:length(tarMinorPSLs)
		if tarMinorPSLs(ii).length > miniPSLength
			tarIndice(end+1,1) = ii;
			tarMinorPSLs(ii).eleIndexList = tarMinorPSLs(ii).eleIndexList(:)';
		end
	end
	tarMinorPSLs = tarMinorPSLs(tarIndice);	
	numTarMinorPSLs = length(tarMinorPSLs);
	
	if 0==numTarMajorPSLs && 0==numTarMediumPSLs && 0==numTarMinorPSLs, return; end	
	
	srcPSList = [tarMajorPSLs; tarMediumPSLs; tarMinorPSLs];
	
	%%2. Extract Passive Elements from PSLs
	passiveEles = [srcPSList.eleIndexList]';
	index = 2;
	while index<=PSLthickness
		passiveEles = RelateAdjacentElements(passiveEles);
		index = index + 1;
    end	

	%%3. Extract Passive Elements from PSLs
	if boundaryThickness>0
		passiveElesOnBoundary = boundaryElements_;
		index = 2;
		while index<=boundaryThickness
			passiveElesOnBoundary = RelateAdjacentElements(passiveElesOnBoundary);
			index = index + 1;
		end		
	else
		passiveElesOnBoundary = [];
	end
	
	%%4. Write
	passiveEles = unique([passiveEles(:); passiveElesOnBoundary(:)]);
	fid = fopen(fileName, 'w');
	fprintf(fid, '%s %s %s', 'domain type: 3D'); fprintf(fid, '\n');
	fprintf(fid, '%s ', 'resolution:');
	fprintf(fid, '%d %d %d\n', [nelx_ nely_ nelz_]);
	fprintf(fid, '%s %s ', 'valid elements:');
	fprintf(fid, '%d\n', numEles_);
	%%passive -> 0; active -> 1;support -> 2
	consideredEles = (1:numEles_)'; consideredEles = carEleMapBack_(consideredEles);
	consideredEles = consideredEles -1;
	consideredEles = [consideredEles ones(size(consideredEles))];
	consideredEles(passiveEles,2) = 2;
	fprintf(fid, '%d %d\n', consideredEles');
	fprintf(fid, '%s %s ', 'fixed position:');
	fprintf(fid, '%d\n', length(fixingCond_));		
	if ~isempty(fixingCond_)
		fprintf(fid, '%d %d %d %d\n', [carNodMapBack_(fixingCond_) ones(length(fixingCond_),3)]');
	end
	fprintf(fid, '%s %s ', 'loading condition:');
	fprintf(fid, '%d\n', size(loadingCond_,1));
	if ~isempty(loadingCond_)
		fprintf(fid, '%d %.6f %.6f %.6f\n', [double(carNodMapBack_(loadingCond_(:,1))) loadingCond_(:,2:end)]');	
	end		
	fclose(fid);
end

function oEleList = RelateAdjacentElements(iEleList)
	global domainType_;
	global nelx_; global nely_; global nelz_;
	global carEleMapForward_;
	global carEleMapBack_;
	
	iEleListMapBack = carEleMapBack_(iEleList);
	%%	1	4	7		10	 13	  16		19	 22	  25
	%%	2	5	8		11	 14*  17		20	 23	  26
	%%	3	6	9		12	 15   18		21	 24	  27
	%%	 bottom				middle				top
	[eleX, eleY, eleZ] = NodalizeDesignDomain([nelx_-1 nely_-1 nelz_-1], [1 1 1; nelx_ nely_ nelz_]);
	eleX = eleX(iEleListMapBack);
	eleY = eleY(iEleListMapBack);
	eleZ = eleZ(iEleListMapBack);
	tmpX = [eleX-1 eleX-1 eleX-1  eleX eleX eleX  eleX+1 eleX+1 eleX+1];
	tmpX = [tmpX tmpX tmpX]; tmpX = tmpX(:);
	tmpY = [eleY+1 eleY eleY-1  eleY+1 eleY eleY-1  eleY+1 eleY eleY-1]; 
	tmpY = [tmpY tmpY tmpY]; tmpY = tmpY(:);
	tmpZ = [eleZ eleZ eleZ eleZ eleZ eleZ eleZ eleZ eleZ];
	tmpZ = [tmpZ-1 tmpZ tmpZ+1]; tmpZ = tmpZ(:);
	xNegative = find(tmpX<1); xPositive = find(tmpX>nelx_);
	yNegative = find(tmpY<1); yPositive = find(tmpY>nely_);
	zNegative = find(tmpZ<1); zPositive = find(tmpZ>nelz_);
	allInvalidEles = unique([xNegative; xPositive; yNegative; yPositive; zNegative; zPositive]);
	tmpX(allInvalidEles) = []; tmpY(allInvalidEles) = []; tmpZ(allInvalidEles) = [];
	oEleListMapBack = nelx_*nely_*(tmpZ-1) + nely_*(tmpX-1) + nely_-tmpY + 1;
	oEleList = carEleMapForward_(oEleListMapBack);
	oEleList(oEleList<1) = []; oEleList = unique(oEleList);
end