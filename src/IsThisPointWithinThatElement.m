function opt = IsThisPointWithinThatElement(tarEleIndex, iCoord)
	global nodeCoords_; 
	global eNodMat_;
	opt = 1;
	%%data preparation
	tarEleVertices = nodeCoords_(eNodMat_(tarEleIndex,:), :);
	eleFaces = [4 3 2 1; 5 6 7 8; 1 2 6 5; 8 7 3 4; 5 8 4 1; 2 3 7 6];
	patchX = tarEleVertices(:,1); patchX = patchX(eleFaces);
	patchY = tarEleVertices(:,2); patchY = patchY(eleFaces);
	patchZ = tarEleVertices(:,3); patchZ = patchZ(eleFaces);
	patchC = zeros(size(patchZ));
	normVecs = zeros(6,3);
	faceCentres = [sum(patchX,2) sum(patchY,2) sum(patchZ,2)]/4;
	%%compute direction vectors from iCoord to face centers as reference vectors
	refVec = faceCentres - iCoord; %% dir vecs from volume center to face centers
	refVecNorm = vecnorm(refVec,2,2);
	if find(0==refVecNorm), disp('I am Here!!!!!!!!!!!!!!!!!!!!!!!!!!'); return; end %% iCoord coincides with a vertex
	refVec = refVec ./ refVecNorm; 
	
	%%compute face normals
	ABs = [patchX(:,1)-patchX(:,2) patchY(:,1)-patchY(:,2) patchZ(:,1)-patchZ(:,2)];
	ACs = [patchX(:,1)-patchX(:,4) patchY(:,1)-patchY(:,4) patchZ(:,1)-patchZ(:,4)];
	for ii=1:6
		iABxAC = cross(ABs(ii,:),ACs(ii,:));
		normVecs(ii,:) = iABxAC / norm(iABxAC);
	end
	
	%%compute angle deviation
	angleDevs = zeros(6,1);
	for ii=1:6
		angleDevs(ii) = acos(refVec(ii,:)*normVecs(ii,:)');
	end
	if max(angleDevs) > 90, opt = 0; end %% iCoord is out of  tarEleIndex
	
	%%test
	% hdRefPot = plot3(iCoord(1), iCoord(2), iCoord(3), 'xm', 'LineWidth', 2, 'MarkerSize', 8); hold on;
	% hdEle = patch(patchX',patchY',patchZ',patchC'); hold on;
	% hdCentres = plot3(faceCentres(:,1), faceCentres(:,2), faceCentres(:,3), '+k', 'LineWidth', 2, 'MarkerSize', 8); hold on;
	% hdNormals = quiver3(faceCentres(:,1),faceCentres(:,2),faceCentres(:,3),normVecs(:,1),normVecs(:,2),normVecs(:,3)); hold on;
	% refPos = repmat(iCoord,6,1);
	% hdNormals2 = quiver3(refPos(:,1),refPos(:,2),refPos(:,3),refVec(:,1),refVec(:,2),refVec(:,3)); hold on;
	% set(hdEle, 'faceColor', 'g', 'faceAlpha', 0.1);
	% set(hdNormals, 'autoScale', 'on', 'LineWidth', 2, 'Color', 'r');
	% set(hdNormals2, 'autoScale', 'on', 'AutoScaleFactor', 0.01, 'LineWidth', 2, 'Color', 'b');
	% axis equal; axis tight;
end