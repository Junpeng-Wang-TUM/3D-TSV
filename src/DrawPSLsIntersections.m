function numIntersections = DrawPSLsIntersections(imOpt, imVal, lw, varargin)
	global silhouetteOpacity_;
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

	patchX = sphereX; ctrX = intersectionList(:,1);
	patchX = repmat(patchX, numIntersections, 1); ctrX = repmat(ctrX, 1, nn); ctrX = reshape(ctrX', numel(ctrX), 1);
	patchX = ctrX + patchX;
	
	patchY = sphereY; ctrY = intersectionList(:,2);
	patchY = repmat(patchY, numIntersections, 1); ctrY = repmat(ctrY, 1, nn); ctrY = reshape(ctrY', numel(ctrY), 1);
	patchY = ctrY + patchY;	
	
	patchZ = sphereZ; ctrZ = intersectionList(:,3);
	patchZ = repmat(patchZ, numIntersections, 1); ctrZ = repmat(ctrZ, 1, nn); ctrZ = reshape(ctrZ', numel(ctrZ), 1);
	patchZ = ctrZ + patchZ;		
	
	if 3==nargin
		figure; 
		handleSilhouette = DrawSilhouette();
		handleIntersections = surf(patchX,patchY,patchZ); hold on
		set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', silhouetteOpacity_, 'EdgeColor', 'none');
		set(handleIntersections, 'FaceColor', [65 174 118]/255, 'FaceAlpha', 1, 'EdgeColor', 'none');
		if 1
			lighting('gouraud');	
			camlight('headlight','infinite');		
			material([handleSilhouette(:); handleIntersections(:)], 'dull');
		end		
	else
		hold on;
		handleIntersections = surf(patchX,patchY,patchZ);
		set(handleIntersections, 'FaceColor', [0 0 1], 'FaceAlpha', 1, 'EdgeColor', 'none');
	end
	
end