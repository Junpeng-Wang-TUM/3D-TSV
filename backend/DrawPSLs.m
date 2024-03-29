function DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, miniPSLength, varargin)
	%% Syntax:
	%% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw);
	%% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, minLength);
	%% =====================================================================
	%% imOpt: ["Geo", "Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
	%% imVal: [1,0.5, 0.3]; %% PSLs with IM>=imVal shown
	%% pslGeo: ["TUBE", "TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
	%% stressComponentOpt: %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
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
	global axHandle_;
	
	lineWidthTube = min([lw*minimumEpsilon_/5, min(boundingBox_(2,:)-boundingBox_(1,:))/10]);
	lineWidthRibbon = 3*lineWidthTube;

	%% Get Target PSLs to Draw
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
		if tarMajorPSLs(ii).length > miniPSLength, tarIndice(end+1,1) = ii; end
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
		if tarMediumPSLs(ii).length > miniPSLength, tarIndice(end+1,1) = ii; end
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
		if tarMinorPSLs(ii).length > miniPSLength, tarIndice(end+1,1) = ii; end
	end
	tarMinorPSLs = tarMinorPSLs(tarIndice);	
	numTarMinorPSLs = length(tarMinorPSLs);
	
	if 0==numTarMajorPSLs && 0==numTarMediumPSLs && 0==numTarMinorPSLs, return; end
	
	%% Initialize Stress Component for Coloring
	color4MajorPSLs = struct('arr', []); color4MajorPSLs = repmat(color4MajorPSLs, numTarMajorPSLs, 1);
	color4MediumPSLs = struct('arr', []); color4MediumPSLs = repmat(color4MediumPSLs, numTarMediumPSLs, 1);
	color4MinorPSLs = struct('arr', []); color4MinorPSLs = repmat(color4MinorPSLs, numTarMinorPSLs, 1);
	%%'None', 'Sigma', 'Sigma_3', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
	switch stressComponentOpt
		case 'None'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = ones(1, tarMajorPSLs(ii).length);
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = ones(1, tarMediumPSLs(ii).length);
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = ones(1, tarMinorPSLs(ii).length);
			end			
		case 'Sigma'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).principalStressList(:,9)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).principalStressList(:,5)';
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).principalStressList(:,1)';
			end
			if 0<numTarMajorPSLs && 0==numTarMediumPSLs && 0==numTarMinorPSLs
				m=100; r4Major = [1 m]; 
				cValOnMajor = [color4MajorPSLs.arr]; cmin = min(cValOnMajor); cmax = max(cValOnMajor);
				for ii=1:numTarMajorPSLs
					color4MajorPSLs(ii).arr = (r4Major(2)-r4Major(1))*(color4MajorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Major(1);
				end				
			elseif 0==numTarMajorPSLs && 0<numTarMediumPSLs && 0==numTarMinorPSLs
				m=100; r4Medium = [1 m];
				cValOnMedium = [color4MediumPSLs.arr]; cmin = min(cValOnMedium); cmax = max(cValOnMedium);
				for ii=1:numTarMediumPSLs
					color4MediumPSLs(ii).arr = (r4Medium(2)-r4Medium(1))*(color4MediumPSLs(ii).arr-cmin)/(cmax-cmin)+r4Medium(1);
				end				
			elseif 0==numTarMajorPSLs && 0==numTarMediumPSLs && 0<numTarMinorPSLs
				m=100; r4Minor = [1 m];
				cValOnMinor = [color4MinorPSLs.arr]; cmin = min(cValOnMinor); cmax = max(cValOnMinor);
				for ii=1:numTarMinorPSLs
					color4MinorPSLs(ii).arr = (r4Minor(2)-r4Minor(1))*(color4MinorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Minor(1);
				end				
			elseif 0<numTarMajorPSLs && 0<numTarMediumPSLs && 0==numTarMinorPSLs
				m=100; r4Medium = [1 m]; r4Major = m+r4Medium;
				cValOnMajor = [color4MajorPSLs.arr]; cmin = min(cValOnMajor); cmax = max(cValOnMajor);
				for ii=1:numTarMajorPSLs
					color4MajorPSLs(ii).arr = (r4Major(2)-r4Major(1))*(color4MajorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Major(1);
				end
				cValOnMedium = [color4MediumPSLs.arr]; cmin = min(cValOnMedium); cmax = max(cValOnMedium);
				for ii=1:numTarMediumPSLs
					color4MediumPSLs(ii).arr = (r4Medium(2)-r4Medium(1))*(color4MediumPSLs(ii).arr-cmin)/(cmax-cmin)+r4Medium(1);
				end				
			elseif 0<numTarMajorPSLs && 0==numTarMediumPSLs && 0<numTarMinorPSLs
				m=100; r4Minor = [1 m]; r4Major = m+r4Minor;
				cValOnMajor = [color4MajorPSLs.arr]; cmin = min(cValOnMajor); cmax = max(cValOnMajor);
				for ii=1:numTarMajorPSLs
					color4MajorPSLs(ii).arr = (r4Major(2)-r4Major(1))*(color4MajorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Major(1);
				end
				cValOnMinor = [color4MinorPSLs.arr]; cmin = min(cValOnMinor); cmax = max(cValOnMinor);
				for ii=1:numTarMinorPSLs
					color4MinorPSLs(ii).arr = (r4Minor(2)-r4Minor(1))*(color4MinorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Minor(1);
				end				
			elseif 0==numTarMajorPSLs && 0<numTarMediumPSLs && 0<numTarMinorPSLs
				m=100; r4Minor = [1 m]; r4Medium = m+r4Minor;
				cValOnMedium = [color4MediumPSLs.arr]; cmin = min(cValOnMedium); cmax = max(cValOnMedium);
				for ii=1:numTarMediumPSLs
					color4MediumPSLs(ii).arr = (r4Medium(2)-r4Medium(1))*(color4MediumPSLs(ii).arr-cmin)/(cmax-cmin)+r4Medium(1);
				end
				cValOnMinor = [color4MinorPSLs.arr]; cmin = min(cValOnMinor); cmax = max(cValOnMinor);
				for ii=1:numTarMinorPSLs
					color4MinorPSLs(ii).arr = (r4Minor(2)-r4Minor(1))*(color4MinorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Minor(1);
				end					
			else
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
			end			
		case 'Sigma_xx'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,1)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).cartesianStressList(:,1)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,1)';
			end		
		case 'Sigma_yy'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,2)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).cartesianStressList(:,2)';
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,2)';
			end		
		case 'Sigma_zz'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,3)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).cartesianStressList(:,3)';
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,3)';
			end		
		case 'Sigma_yz'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,4)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).cartesianStressList(:,4)';
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,4)';
			end		
		case 'Sigma_zx'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,5)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).cartesianStressList(:,5)';
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,5)';
			end		
		case 'Sigma_xy'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,6)';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).cartesianStressList(:,6)';
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,6)';
			end		
		case 'Sigma_vM'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).vonMisesStressList';
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = tarMediumPSLs(ii).vonMisesStressList';
			end				
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).vonMisesStressList';
			end
		otherwise
			error('Wrong Input!');			
	end
	
	%%Draw
	if 6==nargin 
		figure; axHandle_ = gca;
	else
		axHandle_ = varargin{1};  
	end
	handleSilhouette = DrawSilhouette(axHandle_); 
	
	handleMajorPSL = []; 
	switch pslGeo(1)
		case 'TUBE'
			[gridX, gridY, gridZ, gridC, ~] = ExpandPSLs2Tubes(tarMajorPSLs, color4MajorPSLs, lineWidthTube);
			if ~isempty(gridX)
				hold(axHandle_, 'on'); 
				handleMajorPSL = surf(axHandle_, gridX, gridY, gridZ, gridC);
				shading(axHandle_, 'interp');
			end		
		case 'RIBBON'
			[ribbonVertices, facePatches, faceColors, ~] = ...
				ExpandPSLs2Ribbons(tarMajorPSLs, lineWidthRibbon, [6 7 8; 2 3 4], color4MajorPSLs);
			if ~isempty(ribbonVertices)
				hold(axHandle_, 'on');
				handleMajorPSL = patch(axHandle_, 'Faces', facePatches, 'Vertices', ribbonVertices, ...
					'FaceVertexCData', faceColors, 'FaceColor', 'interp');			
			end	
	end
	handleMediumPSL = []; 
	switch pslGeo(2)
		case 'TUBE'
			[gridX, gridY, gridZ, gridC, ~] = ExpandPSLs2Tubes(tarMediumPSLs, color4MediumPSLs, lineWidthTube);
			if ~isempty(gridX)
				hold(axHandle_, 'on');
				handleMediumPSL = surf(axHandle_, gridX, gridY, gridZ, gridC);
				shading(axHandle_, 'interp');
			end				
		case 'RIBBON'
			psDir = [2 3 4; 10 11 12]; %% [2 3 4; 10 11 12] or [10 11 12; 2 3 4]
			[ribbonVertices, facePatches, faceColors, ~] = ...
				ExpandPSLs2Ribbons(tarMediumPSLs, lineWidthRibbon, psDir, color4MediumPSLs);
			if ~isempty(ribbonVertices)
				hold(axHandle_, 'on');
				handleMediumPSL = patch(axHandle_, 'Faces', facePatches, 'Vertices', ribbonVertices, ...
					'FaceVertexCData', faceColors, 'FaceColor', 'interp');						
			end				
	end
	handleMinorPSL = []; 
	switch pslGeo(3)
		case 'TUBE'
			[gridX, gridY, gridZ, gridC, ~] = ExpandPSLs2Tubes(tarMinorPSLs, color4MinorPSLs, lineWidthTube);
			if ~isempty(gridX)
				hold(axHandle_, 'on');
				handleMinorPSL = surf(axHandle_, gridX, gridY, gridZ, gridC);
				shading(axHandle_, 'interp');
			end				
		case 'RIBBON'
			[ribbonVertices, facePatches, faceColors, ~] = ...
				ExpandPSLs2Ribbons(tarMinorPSLs, lineWidthRibbon, [6 7 8; 10 11 12], color4MinorPSLs);			
			if ~isempty(ribbonVertices)
				hold(axHandle_, 'on');
				handleMinorPSL = patch(axHandle_, 'Faces', facePatches, 'Vertices', ribbonVertices, ...
					'FaceVertexCData', faceColors, 'FaceColor', 'interp');
			end					
	end
	set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', silhouetteOpacity_, 'EdgeColor', 'none');
	if strcmp(stressComponentOpt, "None")
		set(handleMajorPSL, 'FaceColor', [252 141 98]/255);
		set(handleMediumPSL, 'FaceColor', [141 160 203]/255);
		set(handleMinorPSL, 'FaceColor', [102 194 165]/255);	
	end
	set(handleMajorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMediumPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMinorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	
	%%Colorbar
	if 1
		if strcmp(stressComponentOpt, "None")
		elseif strcmp(stressComponentOpt, "Sigma")
			cb = colorbar(axHandle_, 'Location', 'east', 'AxisLocation','in');
			if 0<numTarMajorPSLs && 0==numTarMediumPSLs && 0==numTarMinorPSLs
				colormap(axHandle_, 'autumn');
				v5 = min(cValOnMajor); 
				v6 = max(cValOnMajor);
				set(cb,'Ticks',[0 25 50 75 100],'TickLabels', {linspace(v5, v6, 5)});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(v5, v6, 5)),'Un',0); 
				set(cb,'xticklabel',L);				
			elseif 0==numTarMajorPSLs && 0<numTarMediumPSLs && 0==numTarMinorPSLs
				colormap(axHandle_, 'copper');
				v3 = min(cValOnMedium); 
				v4 = max(cValOnMedium);
				set(cb,'Ticks',[0 25 50 75 99],'TickLabels', {linspace(v3, v4, 5)});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(v3, v4, 5)),'Un',0); 
				set(cb,'xticklabel',L);			
			elseif 0==numTarMajorPSLs && 0==numTarMediumPSLs && 0<numTarMinorPSLs
				colormap(axHandle_, 'winter');	
				v1 = min(cValOnMinor); 
				v2 = max(cValOnMinor);
				set(cb,'Ticks',[0 25 50 75 100],'TickLabels', {linspace(v1, v2, 5)});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(v1, v2, 5)),'Un',0); 
				set(cb,'xticklabel',L);				
			elseif 0<numTarMajorPSLs && 0<numTarMediumPSLs && 0==numTarMinorPSLs
				colormap(axHandle_, [pink; flip(autumn)]);
				v3 = min(cValOnMedium); 
				v4 = max(cValOnMedium);
				v5 = min(cValOnMajor); 
				v6 = max(cValOnMajor);				
				set(cb,'Ticks',[25 75 125 175],'TickLabels', {v3 v4 v5 v6});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell([v3 v4 v5 v6]),'Un',0); 
				set(cb,'xticklabel',L);				
			elseif 0<numTarMajorPSLs && 0==numTarMediumPSLs && 0<numTarMinorPSLs
				colormap(axHandle_, [winter; flip(autumn)]);
				v1 = min(cValOnMinor); 
				v2 = max(cValOnMinor);
				v5 = min(cValOnMajor); 
				v6 = max(cValOnMajor);				
				set(cb,'Ticks',[25 75 125 175],'TickLabels', {v1 v2 v5 v6});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell([v1 v2 v5 v6]),'Un',0); 
				set(cb,'xticklabel',L);			
			elseif 0==numTarMajorPSLs && 0<numTarMediumPSLs && 0<numTarMinorPSLs
				colormap(axHandle_, [winter; pink]);
				v1 = min(cValOnMinor); 
				v2 = max(cValOnMinor);
				v3 = min(cValOnMedium); 
				v4 = max(cValOnMedium);			
				set(cb,'Ticks',[25 75 125 175],'TickLabels', {v1 v2 v3 v4});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell([v1 v2 v3 v4]),'Un',0); 
				set(cb,'xticklabel',L);					
			else
				colormap(axHandle_, [winter; pink; flip(autumn)]);
				v1 = min(cValOnMinor); 
				v2 = max(cValOnMinor);
				v3 = min(cValOnMedium); 
				v4 = max(cValOnMedium);
				v5 = min(cValOnMajor); 
				v6 = max(cValOnMajor);				
				set(cb,'Ticks',[25 75 125 175 225 275],'TickLabels', {v1 v2 v3 v4 v5 v6});
				L=cellfun(@(x)sprintf('%.2e',x),num2cell([v1 v2 v3 v4 v5 v6]),'Un',0); 
				set(cb,'xticklabel',L);
			end
		else
			colormap(axHandle_, 'jet'); 
			cb = colorbar(axHandle_, 'Location', 'east', 'AxisLocation','in');
			t=get(cb,'Limits'); 
			set(cb,'Ticks',linspace(t(1),t(2),5));
			L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(t(1),t(2),5)),'Un',0); 
			set(cb,'xticklabel',L);	
		end
		set(axHandle_, 'FontName', 'Times New Roman', 'FontSize', 20);
	end
	
	% %%Lighting, Reflection
	lighting(axHandle_, 'gouraud');
	material(axHandle_, 'dull');
	camlight(axHandle_, 'headlight', 'infinite');	
end