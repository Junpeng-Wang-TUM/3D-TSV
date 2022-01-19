function hd = DrawMesh(varargin)
	global eNodMat_;
	global nodeCoords_;
	global numEles_;
	global boundaryElements_;
	global nodState_;

	if 0==nargin, axHandle_ = gca; else, axHandle_ = varargin{1}; end
	patchIndices = eNodMat_(boundaryElements_, [4 3 2 1  5 6 7 8  1 2 6 5  8 7 3 4  5 8 4 1  2 3 7 6])';
	patchIndices = reshape(patchIndices(:), 4, 6*numel(boundaryElements_));
	tmp = nodState_(patchIndices); 
	tmp = sum(tmp,1);
	boundaryEleFaces = patchIndices(:,find(4==tmp))';

	FV.vertices = nodeCoords_;
	FV.faces = boundaryEleFaces;
	hd = patch(axHandle_, FV); 
	hold(axHandle_, 'on');
	set(hd, 'FaceColor', [65 174 118]/255, 'FaceAlpha', 1.0, 'EdgeColor', 'k');
	
	view(axHandle_, 3);
	camproj(axHandle_, 'perspective');
	axis(axHandle_, 'equal'); 
	axis(axHandle_, 'tight');
	axis(axHandle_, 'off');
	
	%%Lighting, Reflection
	lighting(axHandle_, 'gouraud');
	material(axHandle_, 'dull');
	camlight(axHandle_, 'headlight', 'infinite');
end