function DrawTracingSchematic(tarEle, piecePSL)
	global nodeCoords_;
	global eNodMat_;
	global nodStruct_;
	
	tarNodes = eNodMat_(tarEle,:); 
	adjacentEles = setdiff(unique([nodStruct_(tarNodes(:)).adjacentEles]), tarEle);
	
	patchIndicesTar = eNodMat_(tarEle, [4 3 2 1  5 6 7 8  1 2 6 5  8 7 3 4  5 8 4 1  2 3 7 6])';
	patchIndicesTar = reshape(patchIndicesTar(:), 4, 6);
	xPatchsTar = nodeCoords_(:,1); xPatchsTar = xPatchsTar(patchIndicesTar);
	yPatchsTar = nodeCoords_(:,2); yPatchsTar = yPatchsTar(patchIndicesTar);
	zPatchsTar = nodeCoords_(:,3); zPatchsTar = zPatchsTar(patchIndicesTar);
	cPatchsTar = zeros(size(xPatchsTar));	
	
	patchIndicesAdj = eNodMat_(adjacentEles, [4 3 2 1  5 6 7 8  1 2 6 5  8 7 3 4  5 8 4 1  2 3 7 6])';
	patchIndicesAdj = reshape(patchIndicesAdj(:), 4, 6*numel(adjacentEles));
	xPatchsAdj = nodeCoords_(:,1); xPatchsAdj = xPatchsAdj(patchIndicesAdj);
	yPatchsAdj = nodeCoords_(:,2); yPatchsAdj = yPatchsAdj(patchIndicesAdj);
	zPatchsAdj = nodeCoords_(:,3); zPatchsAdj = zPatchsAdj(patchIndicesAdj);
	cPatchsAdj = zeros(size(xPatchsAdj));	
	
	figure;
	hdTar = patch(xPatchsTar, yPatchsTar, zPatchsTar, cPatchsTar);
	hold('on');
	hdAdj = patch(xPatchsAdj, yPatchsAdj, zPatchsAdj, cPatchsAdj);
	hold('on');
	plot3(piecePSL(:,1), piecePSL(:,2), piecePSL(:,3), '-*k', 'LineWidth', 3, 'MarkerSize', 15);
	hold('on');
	plot3(piecePSL(2,1), piecePSL(2,2), piecePSL(2,3), '*r', 'LineWidth', 3, 'MarkerSize', 15);
	
	xlabel('X'); ylabel('Y'); zlabel('Z');
	view(3);
	lighting('gouraud');
	camlight('headlight','infinite');
    material('dull'); %% dull, shiny, metal		
	set(hdTar, 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5, 'EdgeColor', 'k');
	set(hdAdj, 'FaceColor', 'c', 'FaceAlpha', 0.1, 'EdgeColor', 'k');
	axis('equal'); axis('tight'); axis('on');
	set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);		
end