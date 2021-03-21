function hd = DrawSilhouette(varargin)
	global silhouetteStruct_;
	global meshType_;
	if 0==nargin, axHandle_ = gca;
	else, axHandle_ = varargin{1}; end
	
	if strcmp(meshType_, 'CARTESIAN_GRID')
		for ii=1:length(silhouetteStruct_)
			hd(ii) = patch(axHandle_, silhouetteStruct_(ii)); hold(axHandle_, 'on');
		end				
	else
		hd = patch(axHandle_, silhouetteStruct_.xPatchs, silhouetteStruct_.yPatchs, ...
			silhouetteStruct_.zPatchs, silhouetteStruct_.cPatchs); hold(axHandle_, 'on');
	end
	set(hd, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.1, 'EdgeColor', 'None');
	view(axHandle_, 3);
	camproj(axHandle_, 'perspective');
	axis(axHandle_, 'equal'); 
	axis(axHandle_, 'tight');
	axis(axHandle_, 'off');
	%set(axHandle_, 'FontName', 'Times New Roman', 'FontSize', 20);
end