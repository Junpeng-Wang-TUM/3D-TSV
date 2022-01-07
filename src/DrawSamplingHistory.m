function DrawSamplingHistory(lw)
	%%Just for Temporary Test
	global dataName_;
	global minimumEpsilon_;
	global majorPSLpool_; 
	global mediumPSLpool_; 
	global minorPSLpool_;
	global PSLsAppearanceOrder_;
	global silhouetteOpacity_;
    global axHandle_;
	
	global majorPSLs_tubeGeometry_gridX_;
	global majorPSLs_tubeGeometry_gridY_;
	global majorPSLs_tubeGeometry_gridZ_;
	global majorPSLs_tubeGeometry_indices_;
	global majorPSLs_ribbonGeometry_vertices_;
	global majorPSLs_ribbonGeometry_faces_;
	global majorPSLs_ribbonGeometry_indices_;
	
	global mediumPSLs_tubeGeometry_gridX_;
	global mediumPSLs_tubeGeometry_gridY_;
	global mediumPSLs_tubeGeometry_gridZ_;
	global mediumPSLs_tubeGeometry_indices_;
	global mediumPSLs_ribbonGeometry_vertices_;
	global mediumPSLs_ribbonGeometry_faces_;
	global mediumPSLs_ribbonGeometry_indices_;

	global minorPSLs_tubeGeometry_gridX_;
	global minorPSLs_tubeGeometry_gridY_;
	global minorPSLs_tubeGeometry_gridZ_;
	global minorPSLs_tubeGeometry_indices_;
	global minorPSLs_ribbonGeometry_vertices_;
	global minorPSLs_ribbonGeometry_faces_;
	global minorPSLs_ribbonGeometry_indices_;
	
	seedRadius = 4*lw*minimumEpsilon_/5;
	CreatePSLsGeometry(lw);
	
	[sphereX,sphereY,sphereZ] = sphere;	
	sphereX = seedRadius*sphereX;
	sphereY = seedRadius*sphereY;
	sphereZ = seedRadius*sphereZ;
	
	[~,~,fileExtension] = fileparts(dataName_);
	fileName = strcat(erase(dataName_, fileExtension), '_SamplingHistory.mp4');
	v = VideoWriter(fileName, 'MPEG-4');
	v.Quality = 100;
	v.FrameRate = 10;	
	open(v);
	
	figure; 
	axHandle_ = gca;
    handleSilhouette = DrawSilhouette(axHandle_);
	disp('Rotate to a Preferable View Direction if Necessary. Press Enter to Continue!'); pause
	[az0, el0] = view;
	lighting(axHandle_, 'gouraud');
	light(axHandle_, 'visible', 'off');
	
	for jj=1:size(PSLsAppearanceOrder_)
		%%Fetch Seed
		iAO = PSLsAppearanceOrder_(jj,:);
		switch iAO(1)
			case 1, iSeed = majorPSLpool_(iAO(2)).phyCoordList(majorPSLpool_(iAO(2)).midPointPosition,:);
			case 2, iSeed = mediumPSLpool_(iAO(2)).phyCoordList(mediumPSLpool_(iAO(2)).midPointPosition,:);
			case 3, iSeed = minorPSLpool_(iAO(2)).phyCoordList(minorPSLpool_(iAO(2)).midPointPosition,:);
		end
		seedPatchX = iSeed(1)+sphereX;
		seedPatchY = iSeed(2)+sphereY;
		seedPatchZ = iSeed(3)+sphereZ;
		
		%%Fetch PSLs
		allPSLs = PSLsAppearanceOrder_(1:jj,:);
		tarMajorPSLindex = allPSLs(find(1==allPSLs(:,1)),2); 
		tarMajorPSLs = majorPSLpool_(tarMajorPSLindex);
		tarMediumPSLindex = allPSLs(find(2==allPSLs(:,1)),2); 
		tarMediumPSLs = mediumPSLpool_(tarMediumPSLindex);
		tarMinorPSLindex = allPSLs(find(3==allPSLs(:,1)),2); 
		tarMinorPSLs = minorPSLpool_(tarMinorPSLindex);
		numTarMajorPSLs = length(tarMajorPSLs);
		numTarMediumPSLs = length(tarMediumPSLs);
		numTarMinorPSLs = length(tarMinorPSLs);
		
		%%Draw
		handleMajorPSL = [];
		if numTarMajorPSLs>0
			hold(axHandle_, 'on');
			surfacesToBeShow = [majorPSLs_tubeGeometry_indices_(tarMajorPSLindex).arr];
			gridX = majorPSLs_tubeGeometry_gridX_(:,surfacesToBeShow);
			gridY = majorPSLs_tubeGeometry_gridY_(:,surfacesToBeShow);
			gridZ = majorPSLs_tubeGeometry_gridZ_(:,surfacesToBeShow);
			handleMajorPSL = surf(axHandle_, gridX, gridY, gridZ);
			shading(axHandle_, 'interp');
		end	
		
		handleMediumPSL = []; 
		if numTarMediumPSLs>0
			hold(axHandle_, 'on');
			surfacesToBeShow = [mediumPSLs_tubeGeometry_indices_(tarMediumPSLindex).arr];
			gridX = mediumPSLs_tubeGeometry_gridX_(:,surfacesToBeShow);
			gridY = mediumPSLs_tubeGeometry_gridY_(:,surfacesToBeShow);
			gridZ = mediumPSLs_tubeGeometry_gridZ_(:,surfacesToBeShow);
			handleMediumPSL = surf(axHandle_, gridX, gridY, gridZ);
			shading(axHandle_, 'interp');
		end
		
		handleMinorPSL = [];
		if numTarMinorPSLs>0
			hold(axHandle_, 'on');
			surfacesToBeShow = [minorPSLs_tubeGeometry_indices_(tarMinorPSLindex).arr];
			gridX = minorPSLs_tubeGeometry_gridX_(:,surfacesToBeShow);
			gridY = minorPSLs_tubeGeometry_gridY_(:,surfacesToBeShow);
			gridZ = minorPSLs_tubeGeometry_gridZ_(:,surfacesToBeShow);
			handleMinorPSL = surf(axHandle_, gridX, gridY, gridZ);
			shading(axHandle_, 'interp');
		end			
		
		handleSeed = surf(axHandle_, seedPatchX, seedPatchY, seedPatchZ); 
		hold(axHandle_, 'on');
		handleLights = camlight(axHandle_, 'headlight','infinite');
		material(axHandle_, 'dull');		
		set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', silhouetteOpacity_, 'EdgeColor', 'none');
		set(handleMajorPSL, 'FaceColor', [252 141 98]/255, 'FaceAlpha', 1, 'EdgeAlpha', 0);
		set(handleMediumPSL, 'FaceColor', [141 160 203]/255, 'FaceAlpha', 1, 'EdgeAlpha', 0);
		set(handleMinorPSL, 'FaceColor', [102 194 165]/255, 'FaceAlpha', 1, 'EdgeAlpha', 0);
		set(handleSeed, 'FaceColor', [0 0 1], 'FaceAlpha', 1, 'EdgeColor', 'none');
		
		%%Write into '.mp4'
		f = getframe(gcf);
		writeVideo(v,f);
		set([handleMajorPSL; handleMediumPSL; handleMinorPSL; handleSeed], 'visible', 'off');
		set(handleLights, 'visible', 'off');
		az = az0+5*jj;
		view(axHandle_, az, el0);		
	end
	close(v);
	set([handleMajorPSL; handleMediumPSL; handleMinorPSL], 'visible', 'on');
	camlight(axHandle_, 'headlight','infinite');
end