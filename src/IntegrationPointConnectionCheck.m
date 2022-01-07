function IntegrationPointConnectionCheck(imVal, lw, miniPSLength, varargin)
	%% imVal: [1,0.5, 0.3]; %% PSLs with IM>=imVal shown
	%% lw: %% tubeRadius = lw*minimumEpsilon_/5, ribbonWidth = 3*tubeRadius
	global boundingBox_;
	global majorPSLpool_; 
	global mediumPSLpool_; 
	global minorPSLpool_;
	global majorHierarchy_; 
	global mediumHierarchy_; 
	global minorHierarchy_;
	global minimumEpsilon_;
	global silhouetteOpacity_;
	global eNodMat_;
	global axHandle_;
	
	lineWidthTube = min([lw*minimumEpsilon_/5, min(boundingBox_(2,:)-boundingBox_(1,:))/10]);
	lineWidthRibbon = 3*lineWidthTube;
	%% Get Target PSLs to Draw
	%% Major
	tarMajorPSLindex = find(majorHierarchy_(:,1)>=imVal(1));
	tarMajorPSLs = majorPSLpool_(tarMajorPSLindex);
	tarIndice = [];
	for ii=1:length(tarMajorPSLs)
		if tarMajorPSLs(ii).length > miniPSLength, tarIndice(end+1,1) = ii; end
	end
	tarMajorPSLs = tarMajorPSLs(tarIndice);	
	numTarMajorPSLs = length(tarMajorPSLs);
	
	%% Medium
	tarMediumPSLindex = find(mediumHierarchy_(:,1)>=imVal(2));
	tarMediumPSLs = mediumPSLpool_(tarMediumPSLindex);
	tarIndice = [];
	for ii=1:length(tarMediumPSLs)
		if tarMediumPSLs(ii).length > miniPSLength, tarIndice(end+1,1) = ii; end
	end
	tarMediumPSLs = tarMediumPSLs(tarIndice);		
	numTarMediumPSLs = length(tarMediumPSLs);	
	
	%% Minor
	tarMinorPSLindex = find(minorHierarchy_(:,1)>=imVal(3));
	tarMinorPSLs = minorPSLpool_(tarMinorPSLindex);
	tarIndice = [];
	for ii=1:length(tarMinorPSLs)
		if tarMinorPSLs(ii).length > miniPSLength, tarIndice(end+1,1) = ii; end
	end
	tarMinorPSLs = tarMinorPSLs(tarIndice);	
	numTarMinorPSLs = length(tarMinorPSLs);
	
	if 0==numTarMajorPSLs && 0==numTarMediumPSLs && 0==numTarMinorPSLs, return; end
	%% Evaluate the Connection for Coloring
	color4MajorPSLs = struct('arr', []); color4MajorPSLs = repmat(color4MajorPSLs, numTarMajorPSLs, 1);
	color4MediumPSLs = struct('arr', []); color4MediumPSLs = repmat(color4MediumPSLs, numTarMediumPSLs, 1);
	color4MinorPSLs = struct('arr', []); color4MinorPSLs = repmat(color4MinorPSLs, numTarMinorPSLs, 1);	
	for ii=1:numTarMajorPSLs
		iLgth = tarMajorPSLs(ii).length;
		color4MajorPSLs(ii).arr = ones(1, tarMajorPSLs(ii).length);
		for jj=1:iLgth
			iEle0 = tarMajorPSLs(ii).eleIndexList(jj);
			if 1==jj
				iEle1 = tarMajorPSLs(ii).eleIndexList(2);
				opt = ~isempty(intersect(eNodMat_(iEle0,:), eNodMat_(iEle1,:)));
			elseif iLgth==jj
				iEleMinus1 = tarMajorPSLs(ii).eleIndexList(end-1);
				opt = ~isempty(intersect(eNodMat_(iEleMinus1,:), eNodMat_(iEle0,:)));
			else
				iEleMinus1 = tarMajorPSLs(ii).eleIndexList(jj-1);
				iEle1 = tarMajorPSLs(ii).eleIndexList(jj+1);
				opt = ~isempty(intersect(eNodMat_(iEle0,:), eNodMat_(iEle1,:))) && ~isempty(intersect(eNodMat_(iEleMinus1,:), eNodMat_(iEle0,:)));
			end
			if ~opt
				color4MajorPSLs(ii).arr(jj) = 0;
major = jj				
			end
		end
	end
	
	for ii=1:numTarMediumPSLs
		iLgth = tarMediumPSLs(ii).length;
		color4MediumPSLs(ii).arr = ones(1, tarMediumPSLs(ii).length);
		for jj=1:iLgth
			iEle0 = tarMediumPSLs(ii).eleIndexList(jj);
			if 1==jj
				iEle1 = tarMediumPSLs(ii).eleIndexList(2);
				opt = ~isempty(intersect(eNodMat_(iEle0,:), eNodMat_(iEle1,:)));
			elseif iLgth==jj
				iEleMinus1 = tarMediumPSLs(ii).eleIndexList(end-1);
				opt = ~isempty(intersect(eNodMat_(iEleMinus1,:), eNodMat_(iEle0,:)));
			else
				iEleMinus1 = tarMediumPSLs(ii).eleIndexList(jj-1);
				iEle1 = tarMediumPSLs(ii).eleIndexList(jj+1);
				opt = ~isempty(intersect(eNodMat_(iEle0,:), eNodMat_(iEle1,:))) && ~isempty(intersect(eNodMat_(iEleMinus1,:), eNodMat_(iEle0,:)));
			end
			if ~opt
				color4MediumPSLs(ii).arr(jj) = 0;
medium = jj				
			end
		end
	end	
	
	for ii=1:numTarMinorPSLs
		iLgth = tarMinorPSLs(ii).length;
		color4MinorPSLs(ii).arr = ones(1, tarMinorPSLs(ii).length);
		for jj=1:iLgth
			iEle0 = tarMinorPSLs(ii).eleIndexList(jj);
			if 1==jj
				iEle1 = tarMinorPSLs(ii).eleIndexList(2);
				opt = ~isempty(intersect(eNodMat_(iEle0,:), eNodMat_(iEle1,:)));
			elseif iLgth==jj
				iEleMinus1 = tarMinorPSLs(ii).eleIndexList(end-1);
				opt = ~isempty(intersect(eNodMat_(iEleMinus1,:), eNodMat_(iEle0,:)));
			else
				iEleMinus1 = tarMinorPSLs(ii).eleIndexList(jj-1);
				iEle1 = tarMinorPSLs(ii).eleIndexList(jj+1);
				opt = ~isempty(intersect(eNodMat_(iEle0,:), eNodMat_(iEle1,:))) && ~isempty(intersect(eNodMat_(iEleMinus1,:), eNodMat_(iEle0,:)));
			end
			if ~opt
				color4MinorPSLs(ii).arr(jj) = 0;
minor = jj				
			end
		end
	end	
	
	%%Draw
	if 3==nargin 
		figure; axHandle_ = gca;
	else
		axHandle_ = varargin{1};  
	end
	handleSilhouette = DrawSilhouette(axHandle_); 
	
	handleMajorPSL = []; 
	[gridX, gridY, gridZ, gridC, ~] = ExpandPSLs2Tubes(tarMajorPSLs, color4MajorPSLs, lineWidthTube);
	if ~isempty(gridX)
		hold(axHandle_, 'on'); 
		handleMajorPSL = surf(axHandle_, gridX, gridY, gridZ, gridC);
		shading(axHandle_, 'interp');
	end
	
	handleMediumPSL = []; 
	[gridX, gridY, gridZ, gridC, ~] = ExpandPSLs2Tubes(tarMediumPSLs, color4MediumPSLs, lineWidthTube);
	if ~isempty(gridX)
		hold(axHandle_, 'on');
		handleMediumPSL = surf(axHandle_, gridX, gridY, gridZ, gridC);
		shading(axHandle_, 'interp');
	end
	
	handleMinorPSL = []; 
	[gridX, gridY, gridZ, gridC, ~] = ExpandPSLs2Tubes(tarMinorPSLs, color4MinorPSLs, lineWidthTube);
	if ~isempty(gridX)
		hold(axHandle_, 'on');
		handleMinorPSL = surf(axHandle_, gridX, gridY, gridZ, gridC);
		shading(axHandle_, 'interp');
	end
	
	set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', silhouetteOpacity_, 'EdgeColor', 'none');
	set(handleMajorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMediumPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMinorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	
	%%Colorbar
	colormap(axHandle_, [jet; flip(jet)]); 
	cb = colorbar(axHandle_, 'Location', 'east', 'AxisLocation','in');
	t=get(cb,'Limits'); 
	set(cb,'Ticks',[1]);
	L=cellfun(@(x)sprintf('%d',x),num2cell([1]),'Un',0); 
	set(cb,'xticklabel',L);		
	set(axHandle_, 'FontName', 'Times New Roman', 'FontSize', 20);
	
	% %%Lighting, Reflection
	lighting(axHandle_, 'gouraud');
	material(axHandle_, 'dull');
	camlight(axHandle_, 'headlight', 'infinite');	
end