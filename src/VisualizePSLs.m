function VisualizePSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt)
	global majorPSLpool_; global minorPSLpool_;
	global majorHierarchy_; global minorHierarchy_;
	global tracingStepWidth_;
	
	lineWidthTube = lw*tracingStepWidth_;
	lineWidthRibbon = 2*lineWidthTube;
	
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
	numTarMajorPSLs = length(tarMajorPSLs);
	
	%% Minor
	switch imOpt(2)
		case 'Geo'
			tarMinorPSLindex = find(minorHierarchy_(:,1)>=imVal(2));
		case 'PS'
			tarMinorPSLindex = find(minorHierarchy_(:,2)>=imVal(2));
		case 'vM'
			tarMinorPSLindex = find(minorHierarchy_(:,3)>=imVal(2));
		case 'Length'
			tarMinorPSLindex = find(minorHierarchy_(:,4)>=imVal(2));
		otherwise
			error('Wrong Input!');
	end
	tarMinorPSLs = minorPSLpool_(tarMinorPSLindex);
	numTarMinorPSLs = length(tarMinorPSLs);
	
	%% Initialize Stress Component for Coloring
	color4MajorPSLs = struct('arr', []); color4MajorPSLs = repmat(color4MajorPSLs, numTarMajorPSLs, 1);
	color4MinorPSLs = struct('arr', []); color4MinorPSLs = repmat(color4MinorPSLs, numTarMinorPSLs, 1);
	%%'None', 'Sigma', 'Sigma_3', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
	switch stressComponentOpt
		case 'None'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = zeros(1, tarMajorPSLs(ii).length);
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = zeros(1, tarMinorPSLs(ii).length);
			end			
		case 'Sigma'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).principalStressList(:,9)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).principalStressList(:,1)';
			end				
			m=100; r4Minor = [1 m]; r4Major = m+r4Minor;
			cValOnMajor = [color4MajorPSLs.arr]; cmin = min(cValOnMajor); cmax = max(cValOnMajor);
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = (r4Major(2)-r4Major(1))*(color4MajorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Major(1);
			end
			cValOnMinor = [color4MinorPSLs.arr]; cmin = min(cValOnMinor); cmax = max(cValOnMinor);
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = (r4Minor(2)-r4Minor(1))*(color4MinorPSLs(ii).arr-cmin)/(cmax-cmin)+r4Minor(1);
			end			
		case 'Sigma_xx'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,1)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,1)';
			end		
		case 'Sigma_yy'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,2)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,2)';
			end		
		case 'Sigma_zz'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,3)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,3)';
			end		
		case 'Sigma_yz'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,4)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,4)';
			end		
		case 'Sigma_zx'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,5)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,5)';
			end		
		case 'Sigma_xy'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).cartesianStressList(:,6)';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).cartesianStressList(:,6)';
			end		
		case 'Sigma_vM'
			for ii=1:numTarMajorPSLs
				color4MajorPSLs(ii).arr = tarMajorPSLs(ii).vonMisesStressList';
			end
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = tarMinorPSLs(ii).vonMisesStressList';
			end
		otherwise
			error('Wrong Input!');			
	end
	
	%%Draw
	figure; handleSilhouette = DrawSilhouette(); 
	if strcmp(stressComponentOpt, 'Sigma'), colormap([BlueRGB(); RedRGB()]); end
	switch pslGeo(1)
		case 'TUBE'
			handleMajorPSL = ExpandPSLs2Tubes(tarMajorPSLs, color4MajorPSLs, lineWidthTube);
		case 'RIBBON'
			[handleMajorPSL, handleRibbonOutlineMajorPSL] = ...
				ExpandPSLs2Ribbon(tarMajorPSLs, color4MajorPSLs, lineWidthRibbon, ribbonSmoothingOpt);
	end
	switch pslGeo(2)
		case 'TUBE'
			handleMinorPSL = ExpandPSLs2Tubes(tarMinorPSLs, color4MinorPSLs, lineWidthTube);
		case 'RIBBON'
			[handleMinorPSL, handleRibbonOutlineMinorPSL] = ...
				ExpandPSLs2Ribbon(tarMinorPSLs, color4MinorPSLs, lineWidthRibbon, ribbonSmoothingOpt);		
	end
	
	set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
	if exist('handleRibbonOutlineMajorPSL')
		set(handleRibbonOutlineMajorPSL, 'EdgeAlpha', 1, 'edgecol','k');
	end
	if exist('handleRibbonOutlineMinorPSL')
		set(handleRibbonOutlineMinorPSL, 'EdgeAlpha', 1, 'edgecol','k');
	end
	if strcmp(stressComponentOpt, "None")
		set(handleMajorPSL, 'FaceColor', [1 0 0]);
		set(handleMinorPSL, 'FaceColor', [0 0 1]);	
	end
	set(handleMajorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMinorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	
	%%Colorbar
	if 1
		if strcmp(stressComponentOpt, "None")
		elseif strcmp(stressComponentOpt, "Sigma")
			cb = colorbar('Location', 'east');
			v1 = min(cValOnMinor); v2 = max(cValOnMinor);
			v5 = min(cValOnMajor); v6 = max(cValOnMajor);				
			set(cb,'Ticks',[25 75 125 175],'TickLabels', {v1 v2 v5 v6}, 'AxisLocation','out');
			L=cellfun(@(x)sprintf('%.2e',x),num2cell([v1 v2 v5 v6]),'Un',0); set(cb,'xticklabel',L);	
		else
			colormap('jet'); cb = colorbar('Location', 'east');
			t=get(cb,'Limits'); set(cb,'Ticks',linspace(t(1),t(2),5),'AxisLocation','out');
			L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(t(1),t(2),5)),'Un',0); set(cb,'xticklabel',L);	
		end
		set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);
	end
	
	%%Lighting, Reflection
	if 1
		% view(-1.108713692790638e+00, 1.972962667454830e+01); %%femur
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

function hd = ExpandPSLs2Tubes(PSLs, colorSrc, r)
	global axHandle_; axHandle_ = gca;
	n = 8; ct=0.5*r;
	numLines = length(PSLs);
	gridXYZ = zeros(3,n+1,1);
	gridC = zeros(n+1,1);
	for ii=1:numLines		
		curve = PSLs(ii).phyCoordList';
		npoints = size(curve,2);
		%deltavecs: average for internal points. first strecth for endpoitns.		
		dv = curve(:,[2:end,end])-curve(:,[1,1:end-1]);		
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
			xyz(:,:,k+1)=repmat(curve(:,k),[1,n+1]) + cfact.*repmat(r*nvec,[1,n+1]) + sfact.*repmat(r*convec,[1,n+1]);
		end;
		%finally, cap the ends:
		xyz(:,:,1)=repmat(curve(:,1),[1,n+1]);
		xyz(:,:,end)=repmat(curve(:,end),[1,n+1]);
		gridXYZ(:,:,end+1:end+npoints+2) = xyz;	
		color = colorSrc(ii).arr;	
		c = [color(1) color color(end)];
		c = repmat(c, n+1, 1);
		gridC(:,end+1:end+npoints+2) = c;
	end
	gridX = squeeze(gridXYZ(1,:,:));
	gridY = squeeze(gridXYZ(2,:,:));
	gridZ = squeeze(gridXYZ(3,:,:));
	hd = surf(axHandle_, gridX,gridY,gridZ,gridC); shading(axHandle_, 'interp'); hold(axHandle_, 'on');
end

function [hdFace, hdOutline] = ExpandPSLs2Ribbon(PSLs, colorSrc, lw, smoothingOpt)
	%%1. initialize arguments
	global axHandle_; axHandle_ = gca;
	numPSLs = length(PSLs);
	if 0==numPSLs, hdFace = []; hdOutline = []; return; end
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
	quadMapFace = [];
	quadMapOutline = [];
	faceColorList = [];
	for ii=1:numPSLs
		%%2.1 ribbon boundary nodes
		iPSLength = PSLs(ii).length;
		iCoordList = zeros(2*iPSLength,3);
		iDirConsistencyMetric = zeros(iPSLength,3);
		midPots = PSLs(ii).phyCoordList;
		
		dirVecs = PSLs(ii).principalStressList(:,[6 7 8]);
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
		if smoothingOpt
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
		iFaceColorList = colorSrc(ii).arr;
		iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
		
		%%2.2 create quad patches
		numExistingNodes = size(coordList,1);
		numNewlyGeneratedNodes = 2*iPSLength;
		newGeneratedNodes = numExistingNodes + (1:1:numNewlyGeneratedNodes);
		newGeneratedNodes = reshape(newGeneratedNodes, 2, iPSLength);
		iQuadMapFace = [newGeneratedNodes(1,1:end-1); newGeneratedNodes(2,1:end-1); ...
			newGeneratedNodes(2,2:end); newGeneratedNodes(1,2:end)];
		iQuadMapOutline = [
			newGeneratedNodes(1,1:end-1) newGeneratedNodes(2,1:end-1) newGeneratedNodes(1,1) newGeneratedNodes(1,end)
			newGeneratedNodes(1,2:end)	 newGeneratedNodes(2,2:end)	  newGeneratedNodes(2,1) newGeneratedNodes(2,end)
			newGeneratedNodes(1,2:end)	 newGeneratedNodes(2,2:end)   newGeneratedNodes(2,1) newGeneratedNodes(2,end)
			newGeneratedNodes(1,1:end-1) newGeneratedNodes(2,1:end-1) newGeneratedNodes(1,1) newGeneratedNodes(1,end)
		];
			
		%%2.3 write into global ribbon info
		coordList(end+1:end+2*iPSLength,:) = iCoordList;
		quadMapFace(:,end+1:end+iPSLength-1) = iQuadMapFace;
		quadMapOutline(:,end+1:end+2*iPSLength) = iQuadMapOutline;
		faceColorList(end+1:end+2*iPSLength,:) = iFaceColorList;
	end

	%%draw ribbon
	xCoord = coordList(:,1); 
	yCoord = coordList(:,2); 
	zCoord = coordList(:,3);
	
	xPatchsFace = xCoord(quadMapFace);
	yPatchsFace = yCoord(quadMapFace);
	zPatchsFace = zCoord(quadMapFace);
	cPatchsFace = faceColorList(quadMapFace);
	hdFace = patch(axHandle_, xPatchsFace, yPatchsFace, zPatchsFace, cPatchsFace); 
	shading(axHandle_, 'interp'); hold(axHandle_, 'on');
	 
	xPatchsOutline = xCoord(quadMapOutline);
	yPatchsOutline = yCoord(quadMapOutline);
	zPatchsOutline = zCoord(quadMapOutline);
	cPatchsOutline = zeros(size(xPatchsOutline));
	hdOutline = patch(axHandle_, xPatchsOutline, yPatchsOutline, zPatchsOutline, cPatchsOutline); hold(axHandle_, 'on');
	set(hdOutline, 'facecol', 'None', 'linew', 3);
end

function val = RedRGB()
	val = [ 0.988235294117647	0.572549019607843	0.447058823529412
			0.980502310784314	0.558035395098039	0.432104890196079
			0.975931984313725	0.543502054901961	0.416605113725490
			0.973834951960784	0.528814832352941	0.400728219607843
			0.973591341176470	0.513866541176471	0.384627952941176
			0.974647671568628	0.498575367647059	0.368443627450980
			0.976513756862745	0.482883262745098	0.352300674509804
			0.978759606862745	0.466754334313726	0.336311192156863
			0.981012329411765	0.450173239215686	0.320574494117647
			0.982953032352941	0.433143575490196	0.305177658823530
			0.984313725490196	0.415686274509804	0.290196078431373
			0.984874222549020	0.397837993137255	0.275694007843137
			0.984459043137255	0.379649505882353	0.261725113725490
			0.982934314705882	0.361184097058824	0.248333023529412
			0.980204674509804	0.342515952941176	0.235551874509804
			0.976210171568627	0.323728553921569	0.223406862745098
			0.970923168627451	0.304913066666667	0.211914792156863
			0.964345244117647	0.286166736274510	0.201084623529412
			0.956504094117647	0.267591278431373	0.190918023529412
			0.947450434313726	0.249291271568627	0.181409913725490
			0.937254901960784	0.231372549019608	0.172549019607843
			0.926004957843137	0.213940591176471	0.164318419607843
			0.913801788235294	0.197098917647059	0.156696094117647
			0.900757206862745	0.180947479411765	0.149655474509804
			0.886990556862745	0.165581050980392	0.143165992156863
			0.872625612745098	0.151087622549020	0.137193627450980
			0.857787482352941	0.137546792156863	0.131701458823529
			0.842599508823530	0.125028157843137	0.126650211764706
			0.827180172549020	0.113589709803922	0.121998807843137
			0.811639993137255	0.103276222549020	0.117704913725490
			0.796078431372549	0.0941176470588235	0.113725490196078
			0.780580791176471	0.0861275029411765	0.110017341176471
			0.765215121568627	0.0793012705882353	0.106537662745098
			0.750029118627451	0.0736147833333333	0.103244592156863
			0.735047027450981	0.0690226196078431	0.100097756862745
			0.720266544117647	0.0654564950980392	0.0970588235294118
			0.705655717647059	0.0628236549019608	0.0940920470588235
			0.691149851960784	0.0610052656862745	0.0911648196078431
			0.676648407843137	0.0598548078431373	0.0882482196078432
			0.662011904901961	0.0591964676470588	0.0853175607843137
			0.647058823529412	0.0588235294117647	0.0823529411764706
			0.631562506862745	0.0584967676470588	0.0793397921568628
			0.615248062745098	0.0579428392156863	0.0762694274509804
			0.597789265686275	0.0568526754901961	0.0731395921568627
			0.578805458823530	0.0548798745098039	0.0699550117647059
			0.557858455882353	0.0516390931372549	0.0667279411764706
			0.534449443137255	0.0467044392156863	0.0634787137254902
			0.508015881372549	0.0396078637254902	0.0602362901960784
			0.477928407843137	0.0298375529411765	0.0570388078431373
			0.443487738235294	0.0168363205882352	0.0539341294117647
			0.403921568627451	0					0.0509803921568627];
end

function val = BlueRGB()
	val = [ 0.0313725490196078	0.188235294117647	0.419607843137255
			0.0227352401960785	0.203425561764706	0.445449917647059
			0.0165872941176470	0.217764643137255	0.469565992156863
			0.0126860147058823	0.231411704901961	0.492054988235294
			0.0108059607843138	0.244509364705883	0.513013709803922
			0.0107383578431373	0.257184436274510	0.532536764705882
			0.0122905098039216	0.269548674509804	0.550716486274510
			0.0152852107843137	0.281699520588235	0.567642854901961
			0.0195601568627451	0.293720847058824	0.583403419607843
			0.0249673578431373	0.305683702941176	0.598083219607843
			0.0313725490196078	0.317647058823529	0.611764705882353
			0.0386546029411764	0.329658551960784	0.624527662745098
			0.0467049411764706	0.341755231372549	0.636449129411765
			0.0554269460784314	0.353964302941176	0.647603321568627
			0.0647353725490197	0.366303874509804	0.658061552941177
			0.0745557598039216	0.378783700980392	0.667892156862745
			0.0848238431372549	0.391405929411765	0.677160407843137
			0.0954849656862745	0.404165844117647	0.685928443137255
			0.106493490196078	0.417052611764706	0.694255184313726
			0.117812210784314	0.430050026470588	0.702196258823530
			0.129411764705882	0.443137254901961	0.709803921568628
			0.141270044117647	0.456289581372549	0.717126976470588
			0.153371607843137	0.469479152941176	0.724210698039216
			0.165707093137255	0.482675724509804	0.731096752941177
			0.178272627450981	0.495847403921569	0.737823121568628
			0.191069240196078	0.508961397058824	0.744424019607843
			0.204102274509804	0.521984752941176	0.750929819607843
			0.217380799019608	0.534885108823529	0.757366972549020
			0.230917019607843	0.547631435294118	0.763757929411765
			0.244725691176471	0.560194781372549	0.770121062745098
			0.258823529411765	0.572549019607843	0.776470588235294
			0.273228622549020	0.584671591176471	0.782816486274510
			0.287959843137255	0.596544250980392	0.789164423529412
			0.303036259803922	0.608153812745098	0.795515674509804
			0.318476549019608	0.619492894117647	0.801867043137255
			0.334298406862745	0.630560661764706	0.808210784313726
			0.350517960784314	0.641363576470588	0.814534525490196
			0.367149181372549	0.651916138235294	0.820821188235294
			0.384203294117647	0.662241631372549	0.827048909803922
			0.401688191176471	0.672372869607843	0.833190964705882
			0.419607843137255	0.682352941176471	0.839215686274510
			0.437961710784314	0.692235953921569	0.845086388235294
			0.456744156862745	0.702087780392157	0.850761286274510
			0.475943857843137	0.711986802941176	0.856193419607843
			0.495543215686275	0.722024658823530	0.861330572549020
			0.515517769607843	0.732306985294118	0.866115196078431
			0.535835607843137	0.742954164705882	0.870484329411764
			0.556456779411765	0.754102069607843	0.874369521568628
			0.577332705882353	0.765902807843137	0.877696752941176
			0.598405593137255	0.778525467647059	0.880386356862745
			0.619607843137255	0.792156862745098	0.882352941176471];
end
