function numIntersections = DrawPSLsIntersections(imOpt, imVal, lw, varargin)
	global snappingOpt_;
	numIntersections = 0;
	if snappingOpt_, disp('Not Work with Snapping Option!'); return; end
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	global majorHierarchy_; global mediumHierarchy_; global minorHierarchy_;
	global minimumEpsilon_;
	seedRadius = lw*minimumEpsilon_/2.5;
	intersectionList = [];
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
	for ii=1:length(tarMajorPSLs)
		intersectionList(end+1,1:3) = tarMajorPSLs(ii).phyCoordList(tarMajorPSLs(ii).midPointPosition,:);
	end
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
	for ii=1:length(tarMediumPSLs)
		intersectionList(end+1,1:3) = tarMediumPSLs(ii).phyCoordList(tarMediumPSLs(ii).midPointPosition,:);
	end
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
	for ii=1:length(tarMinorPSLs)
		intersectionList(end+1,1:3) = tarMinorPSLs(ii).phyCoordList(tarMinorPSLs(ii).midPointPosition,:);
	end
	intersectionList = unique(intersectionList, 'rows');
	numIntersections = size(intersectionList,1);
	[sphereX,sphereY,sphereZ] = sphere;
	sphereX = seedRadius*sphereX;
	sphereY = seedRadius*sphereY;
	sphereZ = seedRadius*sphereZ;
	
	nn = size(sphereX,1);
	patchX = []; patchY = []; patchZ = [];
	for ii=1:numIntersections
		patchX(end+1:end+nn,:) = intersectionList(ii,1)+sphereX;
		patchY(end+1:end+nn,:) = intersectionList(ii,2)+sphereY;
		patchZ(end+1:end+nn,:) = intersectionList(ii,3)+sphereZ;	
	end
	if 3==nargin
		figure; 
		handleSilhouette = DrawSilhouette();
		handleIntersections = surf(patchX,patchY,patchZ); hold on
		set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
		set(handleIntersections, 'FaceColor', [0 0 1], 'FaceAlpha', 1, 'EdgeColor', 'none');
		if 1
			lighting gouraud;
			Lopt = 'LA'; %% 'LA', 'LB'
			Mopt = 'MC'; %% 'M0', 'MA', 'MB', 'MC'
			
			switch Lopt
				case 'LA'
					camlight('headlight','infinite');
					camlight('right','infinite');
					camlight('left','infinite');					
				case 'LB'
					camlight('headlight','infinite');				
			end
			
			switch Mopt
				case 'M0'
				
				case 'MA'
					material dull
				case 'MB'
					material shiny
				case 'MC'
					material metal
			end
		end		
	else
		hold on;
		handleIntersections = surf(patchX,patchY,patchZ);
		set(handleIntersections, 'FaceColor', [0 0 1], 'FaceAlpha', 1, 'EdgeColor', 'none');
	end
	
end