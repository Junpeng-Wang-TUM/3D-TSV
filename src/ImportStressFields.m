function ImportStressFields(fileName)
	global vtxLowerBound_; global vtxUpperBound_;
	global numNodes_;
	global nodeCoords_;
	global numEles_;
	global eNodMat_;
	global eleState_;
	global nodState_;	
	global numStressFields_;
	global cartesianStressField_;
	global nodeLoadVec_; global fixedNodes_;	
	global eleCentroidList_;
	global silhouetteStruct_;
	global meshType_;
	global surfaceQuadMeshNodeCoords_;
	global surfaceQuadMeshElements_;	
	
	%%read mesh and cartesian stress field
	fid = fopen(fileName, 'r');
	fgetl(fid); fgetl(fid); fgetl(fid); 
	tmp = fscanf(fid, '%s', 1);	
	meshType_ = fscanf(fid, '%s', 1);
	if strcmp(meshType_, 'CARTESIAN_GRID')
		global nelx_;
		global nely_;
		global nelz_;
		global originalValidNodeIndex_;
		global voxelizedVolume_;
		tmp = fscanf(fid, '%s', 1);
		tmp = fscanf(fid, '%d %d %d', [1 3]);
		nelx_ = tmp(1); nely_ = tmp(2); nelz_ = tmp(3);
		tmp = fscanf(fid, '%s', 1);
		vtxLowerBound_ = fscanf(fid, '%f %f %f', [1 3]);
		tmp = fscanf(fid, '%s', 1);
		vtxUpperBound_ = fscanf(fid, '%f %f %f', [1 3]);		
		tmp = fscanf(fid, '%s', 1); 
		numValidEles = fscanf(fid, '%d', 1);
		tmp = fscanf(fid, '%s', 1);
		validElements = fscanf(fid, '%d', [1, numValidEles])';
		validElements = validElements + 1;
			
		%%read cartesian stress field
		tmp = fscanf(fid, '%s %s %s %s %d', 5);
		tmp = fscanf(fid, '%s %s', 2); numLoadedNodes = fscanf(fid, '%d', 1);
		if numLoadedNodes>0
			tmp = fscanf(fid, '%d %f %f %f', [4, numLoadedNodes]); 
			tmp(1,:) = tmp(1,:)+1; 
			nodeLoadVec_ = tmp';
		end
		tmp = fscanf(fid, '%s %s', 2); numFixedNodes = fscanf(fid, '%d', 1);
		if numFixedNodes>0
			tmp = fscanf(fid, '%d', [1, numFixedNodes]); 
			fixedNodes_ = tmp'+1;
		end
		tmp = fscanf(fid, '%s %s', 2); numValidNods = fscanf(fid, '%d', 1);
		tmp = fscanf(fid, '%f %f %f %f %f %f', [6, numValidNods]);
		cartesianStressField_ = tmp';		
		fclose(fid);
		
		%%recover cartesian mesh
		voxelizedVolume_ = zeros(nelx_*nely_*nelz_,1);
		voxelizedVolume_(validElements) = 1;
		voxelizedVolume_ = reshape(voxelizedVolume_, nely_, nelx_, nelz_);				
		RecoverCartesianMesh();
		numNod2ElesVec = zeros(numNodes_,1);
		for ii=1:numEles_
			for jj=1:8
				numNod2ElesVec(eNodMat_(ii,jj)) = numNod2ElesVec(eNodMat_(ii,jj))+1;
			end
		end
		nodesOutline = find(numNod2ElesVec<8);	
		nodState_ = zeros(numNodes_,1); nodState_(nodesOutline) = 1;
		eleState_ = 12*ones(1, numEles_);
		
		%% element centroids
		eleNodCoordListX = nodeCoords_(:,1); eleNodCoordListX = eleNodCoordListX(eNodMat_);
		eleNodCoordListY = nodeCoords_(:,2); eleNodCoordListY = eleNodCoordListY(eNodMat_);
		eleNodCoordListZ = nodeCoords_(:,3); eleNodCoordListZ = eleNodCoordListZ(eNodMat_);
		eleCentroidList_ = [sum(eleNodCoordListX,2) sum(eleNodCoordListY,2) sum(eleNodCoordListZ,2)]/8;
			
		%%extract and Re-organize silhouette into quad-mesh for exporting
		[nodPosX nodPosY nodPosZ] = NodalizeDesignDomain([nelx_ nely_ nelz_], ...
			[vtxLowerBound_; vtxUpperBound_], 'inGrid');	
		valForExtctBoundary = zeros((nelx_+1)*(nely_+1)*(nelz_+1),1);
		valForExtctBoundary(originalValidNodeIndex_) = 1;
		valForExtctBoundary = reshape(valForExtctBoundary, nely_+1, nelx_+1, nelz_+1);
		fv = isosurface(nodPosX, nodPosY, nodPosZ, valForExtctBoundary, 0);		
		fv.facevertexcdata = zeros(size(fv.vertices));
		fvc = isocaps(nodPosX, nodPosY, nodPosZ, valForExtctBoundary, 0);
		silhouetteStruct_ = fv;
		silhouetteStruct_(2) = fvc;	
		
		faceIndex = zeros(4,6*numEles_);
		mapEle2patch = [4 3 2 1; 5 6 7 8; 1 2 6 5; 8 7 3 4; 5 8 4 1; 2 3 7 6]';
		for ii=1:numEles_
			index = (ii-1)*6;
			iEleVtx = eNodMat_(ii,:)';
			faceIndex(:,index+1:index+6) = iEleVtx(mapEle2patch);
		end
		tmp = nodState_(faceIndex'); tmp = sum(tmp,2);
		BoundaryEleFace = faceIndex(:,find(4==tmp)');		
		boundaryNode = find(1==nodState_);
		surfaceQuadMeshNodeCoords_ = nodeCoords_(boundaryNode,:);
		tmp = zeros(numNodes_,1); tmp(boundaryNode) = (1:length(boundaryNode))';
		surfaceQuadMeshElements_ = tmp(BoundaryEleFace');		
	else
		tmp = fscanf(fid, '%s', 1); 
		numNodes_ = fscanf(fid, '%d', 1);
		tmp = fscanf(fid, '%s', 1);
		
		%%read mesh 
		nodeCoords_ = fscanf(fid, '%f %f %f', [3, numNodes_]); 
		nodeCoords_ = nodeCoords_';	
		tmp = fscanf(fid, '%s', 1);
		numEles_ = fscanf(fid, '%d', 1);
		tmp = fscanf(fid, '%d', 1);
		eNodMat_ = fscanf(fid, '%d %d %d %d %d %d %d %d %d', [9, numEles_]); 
		eNodMat_ = eNodMat_'; eNodMat_(:,1) = []; eNodMat_ = eNodMat_ + 1;
		tmp = fscanf(fid, '%s', 1);
		tmp = fscanf(fid, '%d', 1);
		eleState_ = fscanf(fid, '%d', [1 numEles_])';
		tmp = fscanf(fid, '%s %s', 2);
		tmp = fscanf(fid, '%s %s %s', 3);
		tmp = fscanf(fid, '%s %s', 2);
		nodState_ = fscanf(fid, '%d', [1 numNodes_])';
		
		%%read cartesian stress field
		tmp = fscanf(fid, '%s %s %s %s %d', 5);
		tmp = fscanf(fid, '%s %s', 2); numLoadedNodes = fscanf(fid, '%d', 1);
		if numLoadedNodes>0
			tmp = fscanf(fid, '%d %f %f %f', [4, numLoadedNodes]); 
			tmp(1,:) = tmp(1,:)+1; 
			nodeLoadVec_ = tmp';		
		end
		tmp = fscanf(fid, '%s %s', 2); numFixedNodes = fscanf(fid, '%d', 1);
		if numFixedNodes>0
			tmp = fscanf(fid, '%d', [1, numFixedNodes]); 
			fixedNodes_ = tmp'+1;		
		end
		tmp = fscanf(fid, '%s %s', 2); numValidNods = fscanf(fid, '%d', 1);
		tmp = fscanf(fid, '%f %f %f %f %f %f', [6, numValidNods]);
		cartesianStressField_ = tmp';
		fclose(fid);
		
		%% element centroids and size	
		eleNodCoordListX = nodeCoords_(:,1); eleNodCoordListX = eleNodCoordListX(eNodMat_);
		eleNodCoordListY = nodeCoords_(:,2); eleNodCoordListY = eleNodCoordListY(eNodMat_);
		eleNodCoordListZ = nodeCoords_(:,3); eleNodCoordListZ = eleNodCoordListZ(eNodMat_);
		eleCentroidList_ = [sum(eleNodCoordListX,2) sum(eleNodCoordListY,2) sum(eleNodCoordListZ,2)]/8;
		
		vtxLowerBound_ = [min(nodeCoords_(:,1)) min(nodeCoords_(:,2)) min(nodeCoords_(:,3))];
		vtxUpperBound_ = [max(nodeCoords_(:,1)) max(nodeCoords_(:,2)) max(nodeCoords_(:,3))];
		global eleSize_; eleSize_ = max(vtxUpperBound_-vtxLowerBound_)/100;
		%%extract and Re-organize silhouette into quad-mesh for exporting
		faceIndex = eNodMat_(:, [4 3 2 1  5 6 7 8  1 2 6 5  8 7 3 4  5 8 4 1  2 3 7 6])';
		faceIndex = reshape(faceIndex(:), 4, 6*numEles_);		
		
		tmp = nodState_(faceIndex');
		tmp = sum(tmp,2);
		BoundaryEleFace = faceIndex(:,find(4==tmp)');
		boundaryNode = find(1==nodState_);
		surfaceQuadMeshNodeCoords_ = nodeCoords_(boundaryNode,:);
		tmp = zeros(numNodes_,1); tmp(boundaryNode) = (1:length(boundaryNode))';
		surfaceQuadMeshElements_ = tmp(BoundaryEleFace');
		silhouetteStruct_ = struct('xPatchs', [], 'yPatchs', [], 'zPatchs', [], 'cPatchs',[]);
		xPatchs = surfaceQuadMeshNodeCoords_(:,1); silhouetteStruct_.xPatchs = xPatchs(surfaceQuadMeshElements_');
		yPatchs = surfaceQuadMeshNodeCoords_(:,2); silhouetteStruct_.yPatchs = yPatchs(surfaceQuadMeshElements_');
		zPatchs = surfaceQuadMeshNodeCoords_(:,3); silhouetteStruct_.zPatchs = zPatchs(surfaceQuadMeshElements_');
		silhouetteStruct_.cPatchs = zeros(size(silhouetteStruct_.zPatchs));		
		
		%% build element three
		global nodStruct_; global eleStruct_; global boundaryElements_; 
		iNodStruct = struct('adjacentEles', []); 
		nodStruct_ = repmat(iNodStruct, numNodes_, 1);
		for ii=1:numEles_
			for jj=1:8
				nodStruct_(eNodMat_(ii,jj)).adjacentEles(1,end+1) = ii;
			end
		end		
		boundaryElements_ = unique([nodStruct_(boundaryNode).adjacentEles]);
		eleFaces = [4 3 2 1; 5 6 7 8; 1 2 6 5; 8 7 3 4; 5 8 4 1; 2 3 7 6];
		iEleStruct = struct('faceCentres', [], 'faceNormals', []); %%pure-Hex
		eleStruct_ = repmat(iEleStruct, numEles_, 1);
		for ii=1:numEles_
			iNodes = eNodMat_(ii,:);
			iEleVertices = nodeCoords_(iNodes, :);
			iEleFacesX = iEleVertices(:,1); iEleFacesX = iEleFacesX(eleFaces);
			iEleFacesY = iEleVertices(:,2); iEleFacesY = iEleFacesY(eleFaces);
			iEleFacesZ = iEleVertices(:,3); iEleFacesZ = iEleFacesZ(eleFaces);				
			ACs = [iEleFacesX(:,1)-iEleFacesX(:,3) iEleFacesY(:,1)-iEleFacesY(:,3) iEleFacesZ(:,1)-iEleFacesZ(:,3)];
			BDs = [iEleFacesX(:,2)-iEleFacesX(:,4) iEleFacesY(:,2)-iEleFacesY(:,4) iEleFacesZ(:,2)-iEleFacesZ(:,4)];
			iACxBD = cross(ACs,BDs); 
			aveNormal = iACxBD ./ vecnorm(iACxBD,2,2);			
			tmp = iEleStruct;			
			%% tmp.faceNormals = aveNormal;
			%% in case the node orderings on each element face are not constant
			tmp.faceCentres = [sum(iEleFacesX,2) sum(iEleFacesY,2) sum(iEleFacesZ,2)]/4;
			iEleCt = eleCentroidList_(ii,:);
			refVecs = iEleCt - tmp.faceCentres; refVecs = refVecs ./ vecnorm(refVecs,2,2);
			dirEval = acos(sum(refVecs .* aveNormal, 2));
			dirDes = ones(6,1); dirDes(dirEval<pi/2) = -1;
			faceNormals = dirDes .* aveNormal;
			tmp.faceNormals = faceNormals;
			eleStruct_(ii) = tmp;
		end
	end

end

function RecoverCartesianMesh()	
	global nelx_; global nely_; global nelz_; 
	global voxelizedVolume_;
	global vtxLowerBound_; global vtxUpperBound_;
	global numEles_; global numNodes_; global eleSize_;
	global nodeCoords_; global eNodMat_; 
	global originalValidNodeIndex_; global validElements_;
	global meshState_; global eleMapBack_;
	global nodeLoadVec_; global fixedNodes_;
	%    z
	%    |__ x
	%   / 
	%  -y                            
	%            8--------------7      	
	%			/ |			   /|	
	%          5-------------6	|
	%          |  |          |  |
	%          |  |          |  |	
	%          |  |          |  |   
	%          |  4----------|--3  
	%     	   | /           | /
	%          1-------------2             
	%			Hexahedral element
	eleSize_ = min([(vtxUpperBound_(1)-vtxLowerBound_(1))/nelx_, (vtxUpperBound_(2)-...
		vtxLowerBound_(2))/nely_, (vtxUpperBound_(3)-vtxLowerBound_(3))/nelz_]);
	validElements_ = find(1==voxelizedVolume_);
	validElements_ = int32(validElements_);			
	numEles_ = length(validElements_);		
	meshState_ = zeros(nelx_*nely_*nelz_,1,'int32');	
	meshState_(validElements_) = 1;	
	eleMapBack_ = zeros(nelx_*nely_*nelz_,1,'int32');	
	eleMapBack_(validElements_) = (1:numEles_)';	
	nodenrs = reshape(1:(nelx_+1)*(nely_+1)*(nelz_+1), 1+nely_, 1+nelx_, 1+nelz_); nodenrs = int32(nodenrs);
	eNodVec = reshape(nodenrs(1:end-1,1:end-1,1:end-1)+1, nelx_*nely_*nelz_, 1);
	eNodMat_ = repmat(eNodVec(validElements_),1,8);
	tmp = [0 nely_+[1 0] -1 (nely_+1)*(nelx_+1)+[0 nely_+[1 0] -1]]; tmp = int32(tmp);
	for ii=1:8
		eNodMat_(:,ii) = eNodMat_(:,ii) + repmat(tmp(ii), numEles_,1);
	end
	originalValidNodeIndex_ = unique(eNodMat_);
	numNodes_ = length(originalValidNodeIndex_);
	nodeMap4CutBasedModel_ = zeros((nelx_+1)*(nely_+1)*(nelz_+1),1,'int32');
	nodeMap4CutBasedModel_(originalValidNodeIndex_) = (1:numNodes_)';		
	for ii=1:8
		eNodMat_(:,ii) = nodeMap4CutBasedModel_(eNodMat_(:,ii));
	end
	nodeCoords_ = zeros((nelx_+1)*(nely_+1)*(nelz_+1),3);
	[nodeCoords_(:,1), nodeCoords_(:,2), nodeCoords_(:,3)] = ...
		NodalizeDesignDomain([nelx_ nely_ nelz_], [vtxLowerBound_; vtxUpperBound_]);		
	nodeCoords_ = nodeCoords_(originalValidNodeIndex_,:);
	if size(nodeLoadVec_,1)>0
		nodeLoadVec_(:,1) = nodeMap4CutBasedModel_(nodeLoadVec_(:,1));
	end
	if length(fixedNodes_)>0
		fixedNodes_ = double(nodeMap4CutBasedModel_(fixedNodes_));
	end
end

function varargout = NodalizeDesignDomain(varargin)
	numSeed = varargin{1};
	nx = numSeed(1); ny = numSeed(2); nz = numSeed(3);
	dd = varargin{2};		
	xSeed = dd(1,1):(dd(2,1)-dd(1,1))/nx:dd(2,1);
	ySeed = dd(2,2):(dd(1,2)-dd(2,2))/ny:dd(1,2);
	zSeed = dd(1,3):(dd(2,3)-dd(1,3))/nz:dd(2,3);		
	varargout{1} = repmat(xSeed, ny+1, 1);
	varargout{1} = reshape(varargout{1}, (nx+1)*(ny+1), 1);
	varargout{1} = repmat(varargout{1}, (nz+1), 1);
	varargout{2} = repmat(ySeed, 1, nx+1 )';
	varargout{2} = repmat(varargout{2}, (nz+1), 1);
	varargout{3} = repmat(zSeed, (nx+1)*(ny+1), 1);
	varargout{3} = reshape(varargout{3}, (nx+1)*(ny+1)*(nz+1), 1);
	if 3==nargin & strcmp(varargin{3}, 'inGrid')
		varargout{1} = reshape(varargout{1}, ny+1, nx+1, nz+1);
		varargout{2} = reshape(varargout{2}, ny+1, nx+1, nz+1);
		varargout{3} = reshape(varargout{3}, ny+1, nx+1, nz+1);			
	end	
end
