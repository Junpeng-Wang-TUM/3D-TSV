function [lineFaceIntersection, nextEleIndex] = SearchNextIntegratingPointOnUnstructuredMesh_Classic(eleIndex, P0, dirVec)
	%% parametric equation to determine intersection between line and face: P(s) = P0 + s(P1-P0) = P0+s*dirVec;
	global eleStruct_;
	global nodeCoords_; 
	global eNodMat_;	
	lineFaceIntersection = []; nextEleIndex = 0; scalingFactor = 1.0e-1;
	eleFaces = [4 3 2 1; 5 6 7 8; 1 2 6 5; 8 7 3 4; 5 8 4 1; 2 3 7 6];
	srcEleVertices = nodeCoords_(eNodMat_(eleIndex,:),:);
	checkIfCoincideWithVertex = min(vecnorm(P0-srcEleVertices,2,2));
	if 0==checkIfCoincideWithVertex
		eleCentre = sum(srcEleVertices,1)/8;
		disturbanceFactor = scalingFactor*(eleCentre-P0);
		P0 = P0 + disturbanceFactor;
	end
	numElementFaces = 6;
	V0s = eleStruct_(eleIndex).faceCentres;
	normals = eleStruct_(eleIndex).faceNormals;
	%% Compute all potential intersections of vector 'dirVec' and element faces
	lineParameters = NaN(numElementFaces,1);
	for ii=1:numElementFaces
		iNormal = normals(ii,:);
		parallelCheck = iNormal*dirVec';
		% inPlaneCheck = iNormal*(P0-srcEleVertices(eleFaces(ii,1),:))';
		% if 0==inPlaneCheck, continue; end
		if parallelCheck
			lineParameters(ii) = iNormal * (V0s(ii,:)-P0)' / (parallelCheck);
		end
	end
	%% Remove the irelated "intersections", inc. on the opposite directions, parallel situations, etc.
	potentialElementFaces = find(lineParameters>0);
	if isempty(potentialElementFaces), return; end
		
	%% Identify real intersection, i.e., intersection causing 3rd or 2nd largest distance to P0	
	[sortedPotentialElementFacesDesceding, sortMap] = sort(lineParameters(potentialElementFaces), 'descend');
% sortedPotentialElementFacesDesceding
	numPotentialElementFacesDesceding = length(sortedPotentialElementFacesDesceding);
	if numPotentialElementFacesDesceding>2
		rightIntersection = 3;	
	elseif 2==numPotentialElementFacesDesceding
		rightIntersection = 2;
	else
		rightIntersection = 1; %% right on the element edge
	end
	targetLineParameter = sortedPotentialElementFacesDesceding(rightIntersection);
	lineFaceIntersection = P0 + targetLineParameter*dirVec;
	intersectedElementFace = potentialElementFaces(sortMap(rightIntersection));
	nextEleIndex = eleStruct_(eleIndex).elementsSharingThisElementFaces(intersectedElementFace);
% nextEleIndex	
	%%%%%%%%%%%%%%%%%%%%%%%%%%TEST
	if 1==numPotentialElementFacesDesceding
		figure
		patchXsrc = srcEleVertices(:,1); patchXsrc = patchXsrc(eleFaces);
		patchYsrc = srcEleVertices(:,2); patchYsrc = patchYsrc(eleFaces);
		patchZsrc = srcEleVertices(:,3); patchZsrc = patchZsrc(eleFaces);
		patchCsrc = zeros(size(patchZsrc));
		featureSize = sum(vecnorm(sum(srcEleVertices,1)/8 - srcEleVertices,2,2))/8*2;
		dirVecToDraw = dirVec/norm(dirVec) * featureSize;
		seg = [P0; lineFaceIntersection];
		hdP0 = plot3(seg(1,1), seg(1,2), seg(1,3), 'xk', 'LineWidth', 4, 'MarkerSize', 15); hold on;
		hdIntersection = plot3(seg(2,1), seg(2,2), seg(2,3), '+r', 'LineWidth', 4, 'MarkerSize', 15); hold on;
		hdDirVec = quiver3(P0(1),P0(2),P0(3),dirVecToDraw(:,1),dirVecToDraw(:,2),dirVecToDraw(:,3), 'LineWidth', 2, 'Color', 'b'); hold on;	
		hdEleSrc = patch(patchXsrc',patchYsrc',patchZsrc',patchCsrc'); hold on; 
		if nextEleIndex
			tarEleVertices = nodeCoords_(eNodMat_(nextEleIndex,:), :);
			patchXtar = tarEleVertices(:,1); patchXtar = patchXtar(eleFaces);
			patchYtar = tarEleVertices(:,2); patchYtar = patchYtar(eleFaces);
			patchZtar = tarEleVertices(:,3); patchZtar = patchZtar(eleFaces);
			patchCtar = zeros(size(patchZtar));			
			hdEleTar = patch(patchXtar',patchYtar',patchZtar',patchCtar'); hold on; 
			otherAdjacentElements = eleStruct_(eleIndex).elementsSharingThisElementFaces;
			otherAdjacentElements(0==otherAdjacentElements) = [];
			otherAdjacentElements = setdiff(otherAdjacentElements, nextEleIndex);
			numEles = length(otherAdjacentElements);
			faceIndex = zeros(6*numEles,4);
			for ii=1:numEles
				index = (ii-1)*6;
				iEleVtx = eNodMat_(otherAdjacentElements(ii),:)';
				faceIndex(index+1:index+6,:) = iEleVtx(eleFaces);
			end			
			patchXotherAdjacentElements = nodeCoords_(:,1); patchXotherAdjacentElements = patchXotherAdjacentElements(faceIndex);
			patchYotherAdjacentElements = nodeCoords_(:,2); patchYotherAdjacentElements = patchYotherAdjacentElements(faceIndex);
			patchZotherAdjacentElements = nodeCoords_(:,3); patchZotherAdjacentElements = patchZotherAdjacentElements(faceIndex);
			patchCotherAdjacentElements = zeros(size(patchZotherAdjacentElements));	
			hdEleotherAdjacentElements = patch(patchXotherAdjacentElements',patchYotherAdjacentElements', ...
				patchZotherAdjacentElements',patchCotherAdjacentElements'); hold on; 
			set(hdEleTar, 'faceColor', 'g', 'faceAlpha', 0.1)
		else
			otherAdjacentElements = eleStruct_(eleIndex).elementsSharingThisElementFaces;
			otherAdjacentElements(0==otherAdjacentElements) = [];
			numEles = length(otherAdjacentElements);
			faceIndex = zeros(6*numEles,4);
			for ii=1:numEles
				index = (ii-1)*6;
				iEleVtx = eNodMat_(otherAdjacentElements(ii),:)';
				faceIndex(index+1:index+6,:) = iEleVtx(eleFaces);
			end			
			patchXotherAdjacentElements = nodeCoords_(:,1); patchXotherAdjacentElements = patchXotherAdjacentElements(faceIndex);
			patchYotherAdjacentElements = nodeCoords_(:,2); patchYotherAdjacentElements = patchYotherAdjacentElements(faceIndex);
			patchZotherAdjacentElements = nodeCoords_(:,3); patchZotherAdjacentElements = patchZotherAdjacentElements(faceIndex);
			patchCotherAdjacentElements = zeros(size(patchZotherAdjacentElements));	
			hdEleotherAdjacentElements = patch(patchXotherAdjacentElements',patchYotherAdjacentElements', ...
				patchZotherAdjacentElements',patchCotherAdjacentElements'); hold on; 		
		end	
		set(hdEleSrc, 'faceColor', 'r', 'faceAlpha', 0.3);
		set(hdEleotherAdjacentElements, 'faceColor', 'y', 'faceAlpha', 0.5);
		axis equal; axis tight;	
		close	
	end
end