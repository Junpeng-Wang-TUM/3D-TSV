function DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, varargin)
	%% Syntax:
	%% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, smoothingOpt);
	%% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, smoothingOpt, minLength);
	%% =====================================================================
	%% imOpt: ["Geo", "Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
	%% imVal: [1,0.5, 0.3]; %% PSLs with IM>=imVal shown
	%% pslGeo: ["TUBE", "TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
	%% stressComponentOpt: %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
	%% lw: %% tubeRadius = lw*minimumEpsilon_/5, ribbonWidth = 3*tubeRadius
	%% smoothingOpt: %% smoothing ribbon or not (0)
	%% minLength: minLengthVisiblePSLs_ or varargin{1} if exists, only PSLs with length larger than minLength can be shown
	global majorPSLpool_; global mediumPSLpool_; global minorPSLpool_;
	global majorHierarchy_; global mediumHierarchy_; global minorHierarchy_;
	global minimumEpsilon_;
	global minLengthVisiblePSLs_;
	miniPSLength = minLengthVisiblePSLs_;
	if 7==nargin, miniPSLength = varargin{1}; end
	lineWidthTube = lw*minimumEpsilon_/5;
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
				color4MajorPSLs(ii).arr = zeros(1, tarMajorPSLs(ii).length);
			end
			for ii=1:numTarMediumPSLs
				color4MediumPSLs(ii).arr = zeros(1, tarMediumPSLs(ii).length);
			end			
			for ii=1:numTarMinorPSLs
				color4MinorPSLs(ii).arr = zeros(1, tarMinorPSLs(ii).length);
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
	figure; handleSilhouette = DrawSilhouette(); 
	switch pslGeo(1)
		case 'TUBE'
			handleMajorPSL = ExpandPSLs2Tubes(tarMajorPSLs, color4MajorPSLs, lineWidthTube);
		case 'RIBBON'
			[handleMajorPSL, handleRibbonOutlineMajorPSL] = ...
				ExpandPSLs2Ribbon(tarMajorPSLs, [6 7 8], color4MajorPSLs, lineWidthRibbon, ribbonSmoothingOpt);
	end
	switch pslGeo(2)
		case 'TUBE'
			handleMediumPSL = ExpandPSLs2Tubes(tarMediumPSLs, color4MediumPSLs, lineWidthTube);
		case 'RIBBON'
			[handleMediumPSL, handleRibbonOutlineMediumPSL] = ...
				ExpandPSLs2Ribbon(tarMediumPSLs, [2 3 4],  color4MediumPSLs, lineWidthRibbon, ribbonSmoothingOpt);
	end	
	switch pslGeo(3)
		case 'TUBE'
			handleMinorPSL = ExpandPSLs2Tubes(tarMinorPSLs, color4MinorPSLs, lineWidthTube);
		case 'RIBBON'
			[handleMinorPSL, handleRibbonOutlineMinorPSL] = ...
				ExpandPSLs2Ribbon(tarMinorPSLs, [6 7 8],  color4MinorPSLs, lineWidthRibbon, ribbonSmoothingOpt);		
	end
	
	set(handleSilhouette, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
	if exist('handleRibbonOutlineMajorPSL')
		set(handleRibbonOutlineMajorPSL, 'EdgeAlpha', 1, 'edgecol','k');
	end
	if exist('handleRibbonOutlineMediumPSL')
		set(handleRibbonOutlineMediumPSL, 'EdgeAlpha', 1, 'edgecol','k');
	end
	if exist('handleRibbonOutlineMinorPSL')
		set(handleRibbonOutlineMinorPSL, 'EdgeAlpha', 1, 'edgecol','k');
	end
	if strcmp(stressComponentOpt, "None")
		set(handleMajorPSL, 'FaceColor', [1 0 0]);
		set(handleMediumPSL, 'FaceColor', [0 1 0]);
		set(handleMinorPSL, 'FaceColor', [0 0 1]);	
	end
	set(handleMajorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMediumPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	set(handleMinorPSL, 'FaceAlpha', 1, 'EdgeAlpha', 0);
	
	%%Colorbar
	if 1
		if strcmp(stressComponentOpt, "None")
		elseif strcmp(stressComponentOpt, "Sigma")
			cb = colorbar('Location', 'east');
			v1 = min(cValOnMinor); v2 = max(cValOnMinor);
			v3 = min(cValOnMedium); v4 = max(cValOnMedium);
			v5 = min(cValOnMajor); v6 = max(cValOnMajor);
			if 0<numTarMajorPSLs && 0==numTarMediumPSLs && 0==numTarMinorPSLs
				%colormap([RedRGB()]);
				colormap('autumn');
			elseif 0==numTarMajorPSLs && 0<numTarMediumPSLs && 0==numTarMinorPSLs
				%colormap([GreenRGB();]);
				colormap('copper');
			elseif 0==numTarMajorPSLs && 0==numTarMediumPSLs && 0<numTarMinorPSLs
				%colormap([BlueRGB();]);
				colormap('winter');
			elseif 0<numTarMajorPSLs && 0<numTarMediumPSLs && 0==numTarMinorPSLs
				% colormap([GreenRGB(); RedRGB()]);
				colormap([pink; flip(autumn)]);
			elseif 0<numTarMajorPSLs && 0==numTarMediumPSLs && 0<numTarMinorPSLs
				% colormap([BlueRGB(); RedRGB()]);
				colormap([winter; pink; flip(autumn)]);
			elseif 0==numTarMajorPSLs && 0<numTarMediumPSLs && 0<numTarMinorPSLs
				% colormap([BlueRGB(); GreenRGB();]);
				colormap([winter; pink]);
			else
				%colormap([BlueRGB(); GreenRGB(); RedRGB()]);
				colormap([winter; pink; flip(autumn)]);
			end
			colorbar off
		else
			colormap('pink'); cb = colorbar('Location', 'east');
			t=get(cb,'Limits'); set(cb,'Ticks',linspace(t(1),t(2),5),'AxisLocation','out');
			L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(t(1),t(2),5)),'Un',0); set(cb,'xticklabel',L);	
		end
		set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);
	end
	
	%%Lighting, Reflection
	if 1
		% view(6.43e+01, 1.61e+01); %%cantilever - 1
		% view(-1.11e+00, 1.97e+01); %%femur 
		% view(7.07e+01, 1.24e+00); %%femur 
		% view(0, 0); %% bracket
		% view(-1.96e+02, 1.31e+01); %%bunny
		% view(-5.32e+00,3.77e+00); %%kitten
		% view(-2.05e+02,1.69e+01) %%parts
		% view(-2.44e+01, 1.24e+01); %%bridge
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

function val = GreenRGB()
	val = [ 0.631372549019608	0.850980392156863	0.607843137254902
			0.629617669607843	0.839994433333334	0.589383415686275
			0.621943466666667	0.830214023529412	0.572002635294118
			0.609418910784314	0.821368868627451	0.555621482352941
			0.593008188235294	0.813217380392157	0.540162760784314
			0.573575367647059	0.805545343137255	0.525551470588235
			0.551889066666667	0.798164580392157	0.511714886274510
			0.528627118627451	0.790911621568628	0.498582635294118
			0.504381239215686	0.783646368627451	0.486086776470588
			0.479661693137255	0.776250762745098	0.474161878431373
			0.454901960784314	0.768627450980392	0.462745098039216
			0.430463404901961	0.760698452941177	0.451776258823529
			0.406639937254902	0.752403827450980	0.441197929411765
			0.383662685294118	0.743700339215686	0.430955501960784
			0.361704658823529	0.734560125490196	0.420997270588235
			0.340885416666667	0.724969362745098	0.411274509803922
			0.321275733333333	0.714926933333333	0.401741552941176
			0.302902265686274	0.704443092156863	0.392355870588235
			0.285752219607843	0.693538133333333	0.383078149019608
			0.269778016666667	0.682241056862745	0.373872368627451
			0.254901960784314	0.670588235294118	0.364705882352941
			0.241020904901961	0.658622080392157	0.355549494117647
			0.228010917647059	0.646389709803922	0.346377537254902
			0.215731950000000	0.633941613725490	0.337167952941176
			0.204032501960784	0.621330321568627	0.327902368627451
			0.192754289215686	0.608609068627451	0.318566176470588
			0.181736909803922	0.595830462745098	0.309148611764706
			0.170822510784314	0.583045150980392	0.299642831372549
			0.159860454901961	0.570300486274510	0.290045992156863
			0.148711987254902	0.557639194117647	0.280359329411765
			0.137254901960784	0.545098039215686	0.270588235294118
			0.125388208823529	0.532706492156863	0.260742337254902
			0.113036800000000	0.520485396078431	0.250835576470588
			0.100156116666667	0.508445633333333	0.240886286274510
			0.0867368156862745	0.496586792156863	0.230917270588235
			0.0728094362745098	0.484895833333333	0.220955882352941
			0.0584490666666668	0.473345756862745	0.211034101960784
			0.0437800107843137	0.461894268627451	0.201188615686275
			0.0289804549019608	0.450482447058824	0.191460894117647
			0.0142871343137254	0.439033409803921	0.181897270588235
			0					0.427450980392157	0.172549019607843
			0					0.415618354901961	0.163472435294118
			0					0.403396768627451	0.154728909803922
			0					0.390624162745098	0.146385011764706
			0					0.377113850980392	0.138512564705882
			0					0.362653186274510	0.131188725490196
			0					0.347002227450981	0.124496062745098
			0					0.329892405882353	0.118522635294118
			0					0.311025192156863	0.113362070588235
			0					0.290070762745098	0.109113643137255
			0					0.266666666666667	0.105882352941176 ];
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
