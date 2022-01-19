function [handleSilhouette, handleSeeds] = DrawSeedPoints(lw, opt, varargin)
	global majorPSLpool_; 
	global mediumPSLpool_; 
	global minorPSLpool_;
	global seedPointsHistory_;
	global minimumEpsilon_;
	global silhouetteOpacity_;

	if isempty(seedPointsHistory_)
		handleSilhouette = [];
		handleSeeds = [];
		return;
	end
	seedRadius = lw*minimumEpsilon_/4;
	switch opt
		case 'inputSeeds'
			seeds = seedPointsHistory_;
		case 'resultSeeds'
			seeds = [];
			for ii=1:length(majorPSLpool_)
				seeds(end+1,:) = majorPSLpool_(ii).phyCoordList(majorPSLpool_(ii).midPointPosition,:);
			end
			for ii=1:length(mediumPSLpool_)
				seeds(end+1,:) = mediumPSLpool_(ii).phyCoordList(mediumPSLpool_(ii).midPointPosition,:);
			end
			for ii=1:length(minorPSLpool_)
				seeds(end+1,:) = minorPSLpool_(ii).phyCoordList(minorPSLpool_(ii).midPointPosition,:);
			end			
	end
	numSeedPoints = size(seeds,1);
	[sphereX,sphereY,sphereZ] = sphere(10);
	sphereX = seedRadius*sphereX;
	sphereY = seedRadius*sphereY;
	sphereZ = seedRadius*sphereZ;
	nn = size(sphereX,1);

	patchX = sphereX; ctrX = seeds(:,1);
	patchX = repmat(patchX, numSeedPoints, 1); ctrX = repmat(ctrX, 1, nn); ctrX = reshape(ctrX', numel(ctrX), 1);
	patchX = ctrX + patchX;
	
	patchY = sphereY; ctrY = seeds(:,2);
	patchY = repmat(patchY, numSeedPoints, 1); ctrY = repmat(ctrY, 1, nn); ctrY = reshape(ctrY', numel(ctrY), 1);
	patchY = ctrY + patchY;	
	
	patchZ = sphereZ; ctrZ = seeds(:,3);
	patchZ = repmat(patchZ, numSeedPoints, 1); ctrZ = repmat(ctrZ, 1, nn); ctrZ = reshape(ctrZ', numel(ctrZ), 1);
	patchZ = ctrZ + patchZ;	
	
	if 2==nargin
		figure; axHandle_ = gca; 	
	else	
		axHandle_ = varargin{1}; 
	end
	handleSilhouette = DrawSilhouette(axHandle_);
	handleSeeds = surf(axHandle_, patchX, patchY, patchZ);
	set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', silhouetteOpacity_, 'EdgeColor', 'none');
	set(handleSeeds, 'FaceColor', [65 174 118]/255, 'FaceAlpha', 1, 'EdgeColor', 'none');
	
	%%Lighting, Reflection
	lighting(axHandle_, 'gouraud');
	material(axHandle_, 'dull');
	camlight(axHandle_, 'headlight', 'infinite');		
end