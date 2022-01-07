function DrawPSLsWithAssociateElements(PSList, psDir)
	global nodeCoords_;
	global numEles_;
	global eNodMat_;
	
	numPSLs = length(PSList(:));
	if numPSLs<1, return; end
	eleList = [];
	for ii=1:numPSLs
		iPSL = PSList(ii);
		eleList(end+1:end+iPSL.length,1) = iPSL.eleIndexList;
	end
	if isempty(eleList), return; end
	numEleToBeShown = length(eleList);
	patchIndices = eNodMat_(eleList, [4 3 2 1  5 6 7 8  1 2 6 5  8 7 3 4  5 8 4 1  2 3 7 6])';
	patchIndices = reshape(patchIndices(:), 4, 6*numEleToBeShown);
	xPatchs = nodeCoords_(:,1); xPatchs = xPatchs(patchIndices);
	yPatchs = nodeCoords_(:,2); yPatchs = yPatchs(patchIndices);
	zPatchs = nodeCoords_(:,3); zPatchs = zPatchs(patchIndices);
	cPatchs = zeros(size(xPatchs));
	
	% figure;
	hd = patch(xPatchs, yPatchs, zPatchs, cPatchs);
	switch psDir
		case 'MAJOR', icolor = [1 0 0];
		case 'MEDIUM', icolor = [0 1 0];
		case 'MINOR', icolor = [0 0 1];
	end	
	for ii=1:numPSLs
		iPSL = PSList(ii);
		hold('on');
		plot3(iPSL.phyCoordList(:,1), iPSL.phyCoordList(:,2), iPSL.phyCoordList(:,3), '-x', 'Color', icolor, 'LineWidth', 3, 'MarkerSize', 10);
	end
	xlabel('X'); ylabel('Y'); zlabel('Z');
	view(3);
	lighting('gouraud');
	camlight('headlight','infinite');
    material('dull'); %% dull, shiny, metal		
	set(hd, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5, 'EdgeColor', 'k');
	axis('equal'); axis('tight'); axis('on');
	set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);		
end