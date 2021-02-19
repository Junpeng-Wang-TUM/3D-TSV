function ConstructPatchBasedPSLgeometry(lw)
	global majorPSLpool_; global minorPSLpool_;
	global tubePatchMajorPSLs_; global tubePatchMinorPSLs_;
	global ribbonPatchMajorPSLs_; global ribbonPatchMinorPSLs_;
	global ribbonOutlinePatchMajorPSLs_; global ribbonOutlinePatchMinorPSLs_;
	global ribbonSmoothingOpt_;
	tubePatchMajorPSLs_ = PatchStruct(); tubePatchMinorPSLs_ = PatchStruct();
	ribbonPatchMajorPSLs_ = PatchStruct(); ribbonPatchMinorPSLs_ = PatchStruct();
	ribbonOutlinePatchMajorPSLs_ = PatchStruct(); ribbonOutlinePatchMinorPSLs_ = PatchStruct();
	
	index = 0;
	for ii=1:length(majorPSLpool_)
		iPSL = majorPSLpool_(ii);
		iPSLength = iPSL.length;
		if iPSLength>2
			index = index + 1;
			
			[xPatchsTube, yPatchsTube, zPatchsTube, cPatchsTube] = ExpandPSLtoTube(iPSL, lw, 'MAJORPSL');
			existingTubePatches = size(tubePatchMajorPSLs_.xPatchs,2);
			majorPSLpool_(ii).tubePatchIndices = existingTubePatches+1:existingTubePatches+iPSLength+3;
			if 1==index
				tubePatchMajorPSLs_.xPatchs = xPatchsTube;
				tubePatchMajorPSLs_.yPatchs = yPatchsTube;
				tubePatchMajorPSLs_.zPatchs = zPatchsTube;
				tubePatchMajorPSLs_.cPatchs = cPatchsTube;			
			else
				tubePatchMajorPSLs_.xPatchs(:, end+1:end+iPSLength+3) = xPatchsTube;
				tubePatchMajorPSLs_.yPatchs(:, end+1:end+iPSLength+3) = yPatchsTube;
				tubePatchMajorPSLs_.zPatchs(:, end+1:end+iPSLength+3) = zPatchsTube;
				tubePatchMajorPSLs_.cPatchs(:, end+1:end+iPSLength+3, :) = cPatchsTube;
			end
			
			[xPatchsRibbon, yPatchsRibbon, zPatchsRibbon, ...
				xPatchsRibbonOutline, yPatchsRibbonOutline, zPatchsRibbonOutline] = ExpandPSLtoRibbon(iPSL, lw, 'MAJORPSL');
				
				
		end
	end
	
	index = 0;
	for ii=1:length(minorPSLpool_)
		iPSL = minorPSLpool_(ii);
		iPSLength = iPSL.length;
		if iPSLength>2
			index = index + 1;
			[xPatchsTube, yPatchsTube, zPatchsTube, cPatchsTube] = ExpandPSLtoTube(iPSL, lw, 'MINORPSL');
			existingTubePatches = size(tubePatchMinorPSLs_.xPatchs,2);
			minorPSLpool_(ii).tubePatchIndices = existingTubePatches+1:existingTubePatches+iPSLength+3;
			if 1==index
				tubePatchMinorPSLs_.xPatchs = xPatchsTube;
				tubePatchMinorPSLs_.yPatchs = yPatchsTube;
				tubePatchMinorPSLs_.zPatchs = zPatchsTube;
				tubePatchMinorPSLs_.cPatchs = cPatchsTube;			
			else
				tubePatchMinorPSLs_.xPatchs(:, end+1:end+iPSLength+3) = xPatchsTube;
				tubePatchMinorPSLs_.yPatchs(:, end+1:end+iPSLength+3) = yPatchsTube;
				tubePatchMinorPSLs_.zPatchs(:, end+1:end+iPSLength+3) = zPatchsTube;
				tubePatchMinorPSLs_.cPatchs(:, end+1:end+iPSLength+3, :) = cPatchsTube;
			end


		end
	end	
end

function [gridX, gridY, gridZ, gridC] = ExpandPSLtoTube(iPSL, r, psDir)	
	n = 8; ct=0.5*r;
	curveCoords = iPSL.phyCoordList;
	gridXYZ = zeros(3,n+1,1);
	npoints = size(curveCoords,2);
	%deltavecs: average for internal points. first strecth for endpoitns.		
	dv = curveCoords(:,[2:end,end])-curveCoords(:,[1,1:end-1]);		
	%make nvec not parallel to dv(:,1)
	nvec=zeros(3,1); [buf,idx]=min(abs(dv(:,1))); nvec(idx)=1;
	xyz=repmat([0],[3,n+1,npoints+2]);
	%precalculate cos and sing factors:
	cfact=repmat(cos(linspace(0,2*pi,n+1)),[3,1]);
	sfact=repmat(sin(linspace(0,2*pi,n+1)),[3,1]);
	%Main loop: propagate the normal (nvec) along the tube
	xyz = zeros(3,n+1,npoints+2);
	for k=1:npoints
		convec=cross(nvec,dv(:,k));
		convec=convec./norm(convec);
		nvec=cross(dv(:,k),convec);
		nvec=nvec./norm(nvec);
		%update xyz:
		xyz(:,:,k+1)=repmat(curveCoords(:,k),[1,n+1]) + cfact.*repmat(r*nvec,[1,n+1]) + sfact.*repmat(r*convec,[1,n+1]);
	end;
	%finally, cap the ends:
	xyz(:,:,1)=repmat(curveCoords(:,1),[1,n+1]);
	xyz(:,:,end)=repmat(curveCoords(:,end),[1,n+1]);
	gridXYZ(:,:,end+1:end+npoints+2) = xyz;	
	gridX = squeeze(gridXYZ(1,:,:));
	gridY = squeeze(gridXYZ(2,:,:));
	gridZ = squeeze(gridXYZ(3,:,:));
	
	%%===Color (9): None, sigma_1/3, vM, sigma_x, sigma_y, sigma_z, tadisyz, tadiszx, tadisxy 
	numColorSchemes = 9;
	gridC = zeros(n+1, npoints+3, numColorSchemes);
	
	%%2nd - sigma_1/3
	colorSchemeIdx = 2;
	if strcmp(psDir, 'MAJORPSL')
		c = iPSL.principalStressList(:,9)';
		iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;
	end
	if strcmp(psDir, 'MINORPSL')
		c = iPSL.principalStressList(:,1)';
		iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;
	end
	%%3rd - vM
	colorSchemeIdx = 3;
	c = iPSL.vonMisesStressList'; 
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;
	%%4th - sigma_x
	colorSchemeIdx = 4;
	c = iPSL.cartesianStressList(:,1)';
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;	
	%%5th - sigma_y
	colorSchemeIdx = 5;
	c = iPSL.cartesianStressList(:,2)';
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;	
	%%6th - sigma_z
	colorSchemeIdx = 6;
	c = iPSL.cartesianStressList(:,3)';
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;	
	%%7th - tadisyz
	colorSchemeIdx = 7;
	c = iPSL.cartesianStressList(:,4)';
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;	
	%%8th - tadiszx
	colorSchemeIdx = 8;
	c = iPSL.cartesianStressList(:,5)';
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;
	%%9th - tadisxy
	colorSchemeIdx = 9;
	c = iPSL.cartesianStressList(:,6)';
	iColor = [0 c(1) c c(end)]; iColor = repmat(iColor, n+1, 1); gridC(:,:,colorSchemeIdx) = iColor;	
end

function [xPatchsRibbon, yPatchsRibbon, zPatchsRibbon, cPatchsRibbon, xPatchsRibbonOutline, ...
			yPatchsRibbonOutline, zPatchsRibbonOutline, cPatchsRibbonOutline] = ExpandPSLtoRibbon(iPSL, lw, psDir)
	global ribbonSmoothingOpt_;
	%%2. Expand PSL to ribbon
	%%			RIBBON
	%%	===========================
	%%		   dir2 |	
	%%				 ---dir1
	%%			   / dir3
	%%	===========================
	%%
	twistThreshold = 4/180*pi;
	coordList = [];
	quadMap = [];
	faceColorList = [];
	outLines = repmat(FlexibleArrList(), numPSLs, 1);
	outlineColorList = repmat(FlexibleArrList(), numPSLs, 1);


	%%2.1 ribbon boundary nodes
	iPSLength = iPSL.length;
	iCoordList = zeros(2*iPSLength,3);
	iDirConsistencyMetric = zeros(iPSLength,3);
	midPots = PSLs(ii).phyCoordList;
	
	dirVecs = PSLs(ii).principalStressList(:, [6 7 8]);
	angList = zeros(iPSLength-1,1);
	for jj=2:iPSLength
		vec0 = dirVecs(jj-1,:);
		vec1 = dirVecs(jj,:); vec2 = -vec1;
		ang1 = acos(vec0 * vec1'); ang2 = acos(vec0 * vec2');
		angList(jj-1) = ang1;
		if ang2<ang1
			angList(jj-1) = ang2;
			dirVecs(jj,:) = vec2;
		end
	end
	if ribbonSmoothingOpt_
		angDeviationMetric = sum(angList)/(iPSLength-1);	
		if angDeviationMetric>twistThreshold
			for jj=2:iPSLength
				vec0 = dirVecs(jj-1,:);
				vec1 = dirVecs(jj,:);
				ang1 = acos(vec0 * vec1');
				if ang1>angDeviationMetric
					dirVecs(jj,:) = vec0;
				end
			end
		end
	end		
	dirVecs = dirVecs * lw;
	
	coords1 = midPots + dirVecs;
	coords2 = midPots - dirVecs;
	iCoordList(1:2:end,:) = coords1;
	iCoordList(2:2:end,:) = coords2;
	outLines(ii).arr = [coords1; flip(coords2,1); coords1(1,:)];
	iOutlineColorList = [featureDir3(ii).arr; flip(featureDir3(ii).arr); featureDir3(ii).arr(1)];
	outlineColorList(ii).arr = iOutlineColorList;
	
	%%2.2 create quad patches
	numExistingNodes = size(coordList,1);
	numNewlyGeneratedNodes = 2*iPSLength;
	newGeneratedNodes = numExistingNodes + (1:1:numNewlyGeneratedNodes);
	newGeneratedNodes = reshape(newGeneratedNodes, 2, iPSLength);
	iQuadMap = [newGeneratedNodes(1,1:end-1); newGeneratedNodes(2,1:end-1); ...
		newGeneratedNodes(2,2:end); newGeneratedNodes(1,2:end)];
		

	%%draw ribbon
	xPatchs = iCoordList(:,1); xPatchs = xPatchs(iQuadMap);
	yPatchs = iCoordList(:,2); yPatchs = yPatchs(iQuadMap);
	zPatchs = iCoordList(:,3); zPatchs = zPatchs(iQuadMap);
	iFaceColorList = featureDir1(ii).arr;
	iFaceColorList = reshape(repmat(iFaceColorList', 2, 1), 2*iPSLength, 1);	
	cPatchs = iFaceColorList(iQuadMap);
	hdFace = patch(axHandle_, xPatchs, yPatchs, zPatchs, cPatchs);
	set(hdFace, 'EdgeColor', 'None');
	%%draw outline
	for ii=1:numPSLs
		x = outLines(ii).arr(:,1)'; 
		y = outLines(ii).arr(:,2)'; 
		z = outLines(ii).arr(:,3)'; 
		col = outlineColorList(ii).arr';
		hold(axHandle_, 'on'); hdOutline(ii) = surface(axHandle_, [x;x], [y;y], [z;z], [col;col]);	
	end
end