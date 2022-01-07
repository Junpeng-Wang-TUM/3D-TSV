function hd = DrawScalarStressField(stressComponentOpt, varargin)
	global eNodMat_;
	global nodeCoords_;
	global numEles_;
	global boundaryElements_;
	global nodState_;
	global cartesianStressField_;

	if 1==nargin, axHandle_ = gca; else, axHandle_ = varargin{1}; end
	patchIndices = eNodMat_(boundaryElements_, [4 3 2 1  5 6 7 8  1 2 6 5  8 7 3 4  5 8 4 1  2 3 7 6])';
	patchIndices = reshape(patchIndices(:), 4, 6*numel(boundaryElements_));
	tmp = nodState_(patchIndices); 
	tmp = sum(tmp,1);
	boundaryEleFaces = patchIndices(:,find(4==tmp))';
	
	cVal = zeros(size(nodState_));
	boundaryNodes = find(nodState_);
	boundaryCartesianStress = cartesianStressField_(boundaryNodes,:);
	numBoundaryNodes = numel(boundaryNodes);
	switch stressComponentOpt
		case 'Sigma_1' %%Major Principal Stress
			tmp = zeros(numBoundaryNodes,1);
			for ii=1:numBoundaryNodes
				iTmp = ComputePrincipalStress(boundaryCartesianStress(ii,:));
				tmp(ii) = iTmp(9);
			end
			cVal(boundaryNodes) = tmp;			
		case 'Sigma_2' %%Medium Principal Stress
			tmp = zeros(numBoundaryNodes,1);
			for ii=1:numBoundaryNodes
				iTmp = ComputePrincipalStress(boundaryCartesianStress(ii,:));
				tmp(ii) = iTmp(5);
			end
			cVal(boundaryNodes) = tmp;		
		case 'Sigma_3' %%Minor Principal Stress
			tmp = zeros(numBoundaryNodes,1);
			for ii=1:numBoundaryNodes
				iTmp = ComputePrincipalStress(boundaryCartesianStress(ii,:));
				tmp(ii) = iTmp(1);
			end
			cVal(boundaryNodes) = tmp;		
		case 'Sigma_vM' %%von Mises Stress
			tmp = zeros(numBoundaryNodes,1);
			for ii=1:numBoundaryNodes
				tmp(ii) = ComputeVonMisesStress(boundaryCartesianStress(ii,:));
			end
			cVal(boundaryNodes) = tmp;
		case 'Sigma_xx'
			cVal(boundaryNodes) = boundaryCartesianStress(:,1);
		case 'Sigma_yy'
			cVal(boundaryNodes) = boundaryCartesianStress(:,2);
		case 'Sigma_zz'
			cVal(boundaryNodes) = boundaryCartesianStress(:,3);
		case 'Sigma_yz'
			cVal(boundaryNodes) = boundaryCartesianStress(:,4);
		case 'Sigma_zx'
			cVal(boundaryNodes) = boundaryCartesianStress(:,5);
		case 'Sigma_xy'
			cVal(boundaryNodes) = boundaryCartesianStress(:,6);
		otherwise
			warning('Wrong Input!');
	end
	
	colormap(axHandle_, 'jet');
	hd = patch(axHandle_, 'Faces', boundaryEleFaces, 'Vertices', nodeCoords_, 'FaceVertexCData', cVal);
	set(hd, 'FaceColor', 'interp', 'FaceAlpha', 1.0, 'EdgeColor', 'none');
	 
	cb = colorbar(axHandle_, 'Location', 'east', 'AxisLocation','in');
	t=get(cb,'Limits'); 
	set(cb,'Ticks',linspace(t(1),t(2),5));
	L=cellfun(@(x)sprintf('%.2e',x),num2cell(linspace(t(1),t(2),5)),'Un',0); 
	set(cb,'xticklabel',L);		
	set(axHandle_, 'FontName', 'Times New Roman', 'FontSize', 20);
	
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