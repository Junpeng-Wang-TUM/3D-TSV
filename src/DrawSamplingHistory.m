function DrawSamplingHistory(lw)
	%%Just for Temporary Test
	global dataName_;
	global minimumEpsilon_;
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	global PSLsAppearanceOrder_;
	lineWidthTube = lw*minimumEpsilon_/5;
	seedRadius = 4*lineWidthTube;
	[sphereX,sphereY,sphereZ] = sphere;	
	sphereX = seedRadius*sphereX;
	sphereY = seedRadius*sphereY;
	sphereZ = seedRadius*sphereZ;
	fileName = strcat(erase(dataName_,'.vtk'), '_SamplingHistory.gif');
	figure; handleSilhouette = DrawSilhouette(); view(0,0);
	disp('Rotate to a Preferable View Direction if Necessary. Press Enter to Continue!'); pause
	[az0, el0] = view;
	material metal;
	colormap([winter; pink; flip(autumn)]);
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
		tarMajorPSLindex = allPSLs(find(1==allPSLs(:,1)),2); tarMajorPSLs = majorPSLpool_(tarMajorPSLindex);
		tarMediumPSLindex = allPSLs(find(2==allPSLs(:,1)),2); tarMediumPSLs = mediumPSLpool_(tarMediumPSLindex);
		tarMinorPSLindex = allPSLs(find(3==allPSLs(:,1)),2); tarMinorPSLs = minorPSLpool_(tarMinorPSLindex);
		numTarMajorPSLs = length(tarMajorPSLs);
		numTarMediumPSLs = length(tarMediumPSLs);
		numTarMinorPSLs = length(tarMinorPSLs);
		%% Initialize Stress Component for Coloring
		color4MajorPSLs = struct('arr', []); color4MajorPSLs = repmat(color4MajorPSLs, numTarMajorPSLs, 1);
		color4MediumPSLs = struct('arr', []); color4MediumPSLs = repmat(color4MediumPSLs, numTarMediumPSLs, 1);
		color4MinorPSLs = struct('arr', []); color4MinorPSLs = repmat(color4MinorPSLs, numTarMinorPSLs, 1);
		for ii=1:numTarMajorPSLs
			color4MajorPSLs(ii).arr = tarMajorPSLs(ii).principalStressList(:,9)';
		end
		for ii=1:numTarMediumPSLs
			color4MediumPSLs(ii).arr = tarMediumPSLs(ii).principalStressList(:,5)';
		end			
		for ii=1:numTarMinorPSLs
			color4MinorPSLs(ii).arr = tarMinorPSLs(ii).principalStressList(:,1)';
		end				
		m=100; r4Minor = [1 m]; r4Medium = m+r4Minor; r4Major = m+r4Medium;
		cValOnMajor = [color4MajorPSLs.arr]; cmin = min(cValOnMajor); cmax = max(cValOnMajor);
		for ii=1:numTarMajorPSLs
			color4MajorPSLs(ii).arr = (r4Major(2)-r4Major(1))*(color4MajorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Major(1);
		end
		cValOnMedium = [color4MediumPSLs.arr]; cmin = min(cValOnMedium); cmax = max(cValOnMedium);
		for ii=1:numTarMediumPSLs
			color4MediumPSLs(ii).arr = (r4Medium(2)-r4Medium(1))*(color4MediumPSLs(ii).arr-cmin)/(cmax-cmin)+r4Medium(1);
		end
		cValOnMinor = [color4MinorPSLs.arr]; cmin = min(cValOnMinor); cmax = max(cValOnMinor);
		for ii=1:numTarMinorPSLs
			color4MinorPSLs(ii).arr = (r4Minor(2)-r4Minor(1))*(color4MinorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Minor(1);
		end
		%%Draw
		handleMajorPSL = ExpandPSLs2Tubes(tarMajorPSLs, color4MajorPSLs, lineWidthTube);
		handleMediumPSL = ExpandPSLs2Tubes(tarMediumPSLs, color4MediumPSLs, lineWidthTube);
		handleMinorPSL = ExpandPSLs2Tubes(tarMinorPSLs, color4MinorPSLs, lineWidthTube);
		handleSeed = surf(seedPatchX,seedPatchY,seedPatchZ); hold on
		handleLights = camlight('headlight','infinite');
		handleLights(2) = camlight('right','infinite');
		% handleLights(3) = camlight('left','infinite');		
		set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
		set(handleMajorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
		set(handleMediumPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
		set(handleMinorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
		set(handleSeed, 'FaceColor', [0 0 1], 'FaceAlpha', 1, 'EdgeColor', 'none');
		%%Write into '.gif'
		f = getframe(gcf);
		im = frame2im(f);
		[imind, cm] = rgb2ind(im, 256);	
		if jj==1	
			imwrite(imind, cm, fileName, 'gif', 'Loopcount', inf, 'DelayTime', 0.3);
		else
			imwrite(imind, cm, fileName, 'gif', 'writeMode', 'append', 'DelayTime', 0.3);
        end
		set([handleMajorPSL; handleMediumPSL; handleMinorPSL; handleSeed],'visible','off');
		set(handleLights,'visible','off');
		az = az0+5*jj;
		view(az, el0);		
	end
	close;
end