function hd = DrawSilhouette(varargin)
	global silhouetteStruct_;
	global silhouetteOpacity_;
	if 0==nargin, axHandle_ = gca; else, axHandle_ = varargin{1}; end
	hd = patch(axHandle_, silhouetteStruct_); hold(axHandle_, 'on');
	set(hd, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', silhouetteOpacity_, 'EdgeColor', 'None');
	view(axHandle_, 3);
	camproj(axHandle_, 'perspective');
	axis(axHandle_, 'equal'); 
	axis(axHandle_, 'tight');
	axis(axHandle_, 'off');
end