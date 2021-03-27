function GenerateSeedPoints(seedStrategy, seedDensCtrl)
	global meshType_;
	global nodeCoords_;
	global nodState_;
	global nodeLoadVec_;
	global fixedNodes_;
	global seedPointsHistory_;
	global originalValidNodeIndex_;
	global nelx_; global nely_; global nelz_;
	global nodStruct_;
	global eNodMat_;
	global numNodes_;
	if 0>=seedDensCtrl, seedDensCtrl = 4; end %% in case 0>=minimumEpsilon and volumeSeedingOpt is not defined
	switch seedStrategy
		case 'Volume'
			if strcmp(meshType_, 'CARTESIAN_GRID')
				if seedDensCtrl > min([nelx_ nely_ nelz_])/3, seedDensCtrl = 4; end %% in case seedDensCtrl is wrongly selected
				validNodesVolume = zeros((nelx_+1)*(nely_+1)*(nelz_+1),1);
				validNodesVolume(originalValidNodeIndex_) = (1:length(originalValidNodeIndex_))';
				validNodesVolume = reshape(validNodesVolume, nely_+1, nelx_+1, nelz_+1);
				sampledNodes = validNodesVolume(seedDensCtrl+1:seedDensCtrl:nely_+1-seedDensCtrl, ...
					seedDensCtrl+1:seedDensCtrl:nelx_+1-seedDensCtrl, seedDensCtrl+1:seedDensCtrl:nelz_+1-seedDensCtrl);	
				sampledNodes = reshape(sampledNodes, numel(sampledNodes), 1);
				sampledNodes(0==sampledNodes) = [];
				nodesOnBoundary = find(1==nodState_);
				sampledNodes = setdiff(sampledNodes, nodesOnBoundary);
				seedPointsHistory_ = nodeCoords_(sampledNodes,:);
				
			else
				allNodes = (1:numNodes_)';		
				if 0
					%%for testing
					dis2Boundary = 2;
					boundaryNods = find(1==nodState_);
					tmp0 = boundaryNods;
					index = 2;
					while index <=dis2Boundary %%Pealing away elements layer by layer
						tmp = [];
						for ii=1:length(tmp0)
							iEles = nodStruct_(tmp0(ii)).adjacentEles;
							nEles = length(iEles);
							tmp(end+1:end+nEles) = iEles;
						end
						tmp0 = unique(tmp);
						tmp0 = eNodMat_(tmp0,:);
						tmp0 = reshape(tmp0, numel(tmp0), 1);
						tmp0 = unique(tmp0);
						index = index + 1;
					end
					passiveNodes = tmp0;
					sampledNodes = setdiff(allNodes, passiveNodes);
					seedPointsHistory_ = nodeCoords_(sampledNodes(1:seedDensCtrl:end),:);
				else
					seedPointsHistory_ = nodeCoords_(0==nodState_,:); %%exclude the boundary nodes
					seedPointsHistory_ = seedPointsHistory_(1:seedDensCtrl:end,:);
				end
			end
		case 'Surface'
			seedPointsHistory_ = nodeCoords_(1==nodState_,:);
			seedPointsHistory_ = seedPointsHistory_(1:seedDensCtrl:end,:);
		case 'LoadingArea'			
			seedPointsHistory_ = nodeCoords_(nodeLoadVec_(1:seedDensCtrl:end,1),:);
		case 'FixedArea' 
			seedPointsHistory_ = nodeCoords_(fixedNodes_(1:seedDensCtrl:end,1),:);
	end
end