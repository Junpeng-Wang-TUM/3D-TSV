function [handleSilhouette, handleSeeds] = DrawSeedPoints(varargin)
	global seedPointsHistory_;
	global minimumEpsilon_;
	lw = 0.5;
	seedRadius = lw*minimumEpsilon_/4;
	numSeedPoints = size(seedPointsHistory_,1);
	[sphereX,sphereY,sphereZ] = sphere(10);
	sphereX = seedRadius*sphereX;
	sphereY = seedRadius*sphereY;
	sphereZ = seedRadius*sphereZ;
	nn = size(sphereX,1);

	patchX = sphereX; ctrX = seedPointsHistory_(:,1);
	patchX = repmat(patchX, numSeedPoints, 1); ctrX = repmat(ctrX, 1, nn); ctrX = reshape(ctrX', numel(ctrX), 1);
	patchX = ctrX + patchX;
	
	patchY = sphereY; ctrY = seedPointsHistory_(:,2);
	patchY = repmat(patchY, numSeedPoints, 1); ctrY = repmat(ctrY, 1, nn); ctrY = reshape(ctrY', numel(ctrY), 1);
	patchY = ctrY + patchY;	
	
	patchZ = sphereZ; ctrZ = seedPointsHistory_(:,3);
	patchZ = repmat(patchZ, numSeedPoints, 1); ctrZ = repmat(ctrZ, 1, nn); ctrZ = reshape(ctrZ', numel(ctrZ), 1);
	patchZ = ctrZ + patchZ;	
	
	if 0==nargin
		figure; axHandle_ = gca; lightsOpt = 1;
		handleSilhouette = DrawSilhouette(axHandle_);
	else
		global handleSilhouette_;
		axHandle_ = varargin{1}; lightsOpt = 0; 
		handleSilhouette = handleSilhouette_;
	end		
	handleSeeds = surf(axHandle_, patchX, patchY, patchZ); hold on
	set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
	set(handleSeeds, 'FaceColor', [65 174 118]/255, 'FaceAlpha', 1, 'EdgeColor', 'none');
	if lightsOpt
		lighting(axHandle_, 'gouraud');
		Lopt = 'LA'; %% 'LA', 'LB'
		Mopt = 'MC'; %% 'M0', 'MA', 'MB', 'MC'		
		switch Lopt
			case 'LA'
				camlight(axHandle_, 'headlight','infinite');
				camlight(axHandle_, 'right','infinite');
				camlight(axHandle_, 'left','infinite');					
			case 'LB'
				camlight(axHandle_, 'headlight','infinite');				
		end		
		switch Mopt
			case 'M0',
			case 'MA', material([handleSilhouette(:); handleSeeds(:)], 'dull'); 
			case 'MB', material([handleSilhouette(:); handleSeeds(:)], 'shiny'); 
			case 'MC', material([handleSilhouette(:); handleSeeds(:)], 'metal'); 
		end
	end		
end