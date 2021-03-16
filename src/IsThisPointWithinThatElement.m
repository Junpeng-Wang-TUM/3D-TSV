function opt = IsThisPointWithinThatElement(tarEleIndex, iCoord)
	global eleStruct_;
	opt = 1; 
	iElefaceCentres = eleStruct_(tarEleIndex).faceCentres;
	%%compute direction vectors from iCoord to face centers as reference vectors
	refVec = iElefaceCentres - iCoord; %% dir vecs from volume center to face centers
	refVecNorm = vecnorm(refVec,2,2);
	if find(0==refVecNorm), return; end %% iCoord coincides with a vertex
	refVec = refVec ./ refVecNorm; 
	normVecs = eleStruct_(tarEleIndex).faceNormals;
	
	%%compute angle deviation
	angleDevs = zeros(6,1);
	for ii=1:6
		angleDevs(ii) = acos(refVec(ii,:)*normVecs(ii,:)')/pi*180;
	end
	%% iCoord is out of tarEleIndex, using the relaxed 91 instead of 90 for numerical instability
	maxAngle = max(angleDevs);
	if maxAngle > 91, opt = 0; end 

	%%===============================test	
	% global nodeCoords_; 
	% global eNodMat_;
	% angleDevs
	% eleFaces = [4 3 2 1; 5 6 7 8; 1 2 6 5; 8 7 3 4; 5 8 4 1; 2 3 7 6];
	% eleVertices = nodeCoords_(eNodMat_(tarEleIndex,:),:);	
	% patchX = eleVertices(:,1); patchX = patchX(eleFaces);
	% patchY = eleVertices(:,2); patchY = patchY(eleFaces);
	% patchZ = eleVertices(:,3); patchZ = patchZ(eleFaces);
	% patchC = zeros(size(patchZ));	
	% featureSize = sum(vecnorm(sum(eleVertices,1)/8 - eleVertices,2,2))/8*2;	
	% hdRefPot = plot3(iCoord(1), iCoord(2), iCoord(3), 'xm', 'LineWidth', 2, 'MarkerSize', 8); hold on;
	% hdEle = patch(patchX',patchY',patchZ',patchC'); hold on;
	% hdCentres = plot3(iElefaceCentres(:,1), iElefaceCentres(:,2), iElefaceCentres(:,3), '+k', 'LineWidth', 2, 'MarkerSize', 8); hold on;
	% normVecsToDraw = normVecs ./ vecnorm(normVecs,2,2) * featureSize;	
	% hdNormals = quiver3(iElefaceCentres(:,1),iElefaceCentres(:,2),iElefaceCentres(:,3),normVecsToDraw(:,1),normVecsToDraw(:,2),normVecsToDraw(:,3)); hold on;
	% refPos = repmat(iCoord,6,1);
	% refVecToDraw = refVec ./ vecnorm(refVec,2,2) * featureSize/2;	
	% hdNormals2 = quiver3(refPos(:,1),refPos(:,2),refPos(:,3),refVecToDraw(:,1),refVecToDraw(:,2),refVecToDraw(:,3)); hold on;
	% set(hdEle, 'faceColor', 'g', 'faceAlpha', 0.1);
	% set(hdNormals, 'LineWidth', 2, 'Color', 'r');
	% set(hdNormals2, 'LineWidth', 2, 'Color', 'b');
	% axis equal; axis tight;
end