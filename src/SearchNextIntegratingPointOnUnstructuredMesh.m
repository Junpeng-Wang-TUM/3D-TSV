function [lineFaceIntersection, nextEleIndex] = SearchNextIntegratingPointOnUnstructuredMesh(eleIndex, P0, dirVec)
	global eleStruct_;
	%% parametric equation: P(s) = P0 + s(P1-P0) = P0+s*dirVec;
	%% eleStruct_ = struct('faceCentres', [], 'faceNormals', [], 'elementsSharingThisElementFaces', []);
	numElementFaces = size(eleStruct_(eleIndex).faceNormals,1);
	V0s = eleStruct_(eleIndex).faceCentres;
	normals = eleStruct_(eleIndex).faceNormals;
	%% Compute all potential intersections of vector 'dirVec' and element faces
	lineParameters = NaN(numElementFaces,1);
	for ii=1:numElementFaces
		iNormal = normals(ii,:);
		parallelCheck = iNormal*dirVec';
		if parallelCheck
			lineParameters(ii) = iNormal * (V0s(ii,:)-P0)' / (parallelCheck);
		end
	end
	%% Remove the irelated "intersections", inc. on the opposite directions, parallel situations, etc.
	potentialElementFaces = find(lineParameters>0);
	%% Identify real intersection, i.e., closest intersection to P0
	[targetLineParameter, minValPos0] = min(lineParameters(potentialElementFaces));
	lineFaceIntersection = P0 + targetLineParameter*dirVec;
	intersectedElementFace = potentialElementFaces(minValPos0);
	nextEleIndex = eleStruct_(eleIndex).elementsSharingThisElementFaces(intersectedElementFace);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%TEST
	% global nodeCoords_; 
	% global eNodMat_;
	% tarEleVertices = nodeCoords_(eNodMat_(eleIndex,:), :);
	% eleFaces = [4 3 2 1; 5 6 7 8; 1 2 6 5; 8 7 3 4; 5 8 4 1; 2 3 7 6];
	% patchX = tarEleVertices(:,1); patchX = patchX(eleFaces);
	% patchY = tarEleVertices(:,2); patchY = patchY(eleFaces);
	% patchZ = tarEleVertices(:,3); patchZ = patchZ(eleFaces);
	% patchC = zeros(size(patchZ));	
	% featureSize = sum(vecnorm(sum(tarEleVertices,1)/8 - tarEleVertices,2,2))/8*2;
	% dirVecToDraw = dirVec/norm(dirVec) * featureSize;
	% hdEle = patch(patchX',patchY',patchZ',patchC', 'faceColor', 'g', 'faceAlpha', 0.1); hold on; 
	% seg = [P0; lineFaceIntersection];
	% hdP0 = plot3(seg(1,1), seg(1,2), seg(1,3), 'xk', 'LineWidth', 4, 'MarkerSize', 15); hold on;
	% hdIntersection = plot3(seg(2,1), seg(2,2), seg(2,3), '+r', 'LineWidth', 4, 'MarkerSize', 15); hold on;
	% hdDirVec = quiver3(P0(1),P0(2),P0(3),dirVecToDraw(:,1),dirVecToDraw(:,2),dirVecToDraw(:,3)); hold on;
	% set(hdDirVec, 'LineWidth', 2, 'Color', 'b');
	% axis equal; axis tight;
end