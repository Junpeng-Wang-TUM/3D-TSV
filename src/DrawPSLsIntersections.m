function numIntersections = DrawPSLsIntersections(lw)
	global snappingOpt_;
	numIntersections = 0;
	if snappingOpt_, disp('Not Work with Snapping Option!'); return; end
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	global minimumEpsilon_;
	seedRadius = lw*minimumEpsilon_/2.5;
	intersectionList = [];
	for ii=1:length(majorPSLpool_)
		intersectionList(end+1,1:3) = majorPSLpool_(ii).phyCoordList(majorPSLpool_(ii).midPointPosition,:);
	end
	for ii=1:length(mediumPSLpool_)
		intersectionList(end+1,1:3) = mediumPSLpool_(ii).phyCoordList(mediumPSLpool_(ii).midPointPosition,:);
	end
	for ii=1:length(minorPSLpool_)
		intersectionList(end+1,1:3) = minorPSLpool_(ii).phyCoordList(minorPSLpool_(ii).midPointPosition,:);
	end
	intersectionList = unique(intersectionList, 'rows');
	numIntersections = size(intersectionList,1);
	[sphereX,sphereY,sphereZ] = sphere;
	sphereX = seedRadius*sphereX;
	sphereY = seedRadius*sphereY;
	sphereZ = seedRadius*sphereZ;
	
	nn = size(sphereX);
	patchX = []; patchY = []; patchZ = [];
	for ii=1:numIntersections
		patchX(end+1:end+nn,:) = intersectionList(ii,1)+sphereX;
		patchY(end+1:end+nn,:) = intersectionList(ii,2)+sphereY;
		patchZ(end+1:end+nn,:) = intersectionList(ii,3)+sphereZ;	
	end
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
end