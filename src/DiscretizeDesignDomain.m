function DiscretizeDesignDomain()	
	global domainType_;
	global nelx_; global nely_; global nelz_; 
	global voxelizedVolume_;
	global vtxLowerBound_; global vtxUpperBound_;
	global numEles_; global numNodes_; global eleSize_;
	global nodeCoords_; global eNodMat_; 
	global originalValidNodeIndex_; global validElements_;
	global meshState_; global eleMapBack_;
	global nodeLoadVec_; global fixedNodes_;
	switch domainType_
		case '2D'
			%    __ x
			%   / 
			%  -y         
			%		4--------3
			%	    |		 |		
			%		|		 |
			%		1--------2
			%	rectangular element		
			eleSize_ = min((vtxUpperBound_(1)-vtxLowerBound_(1))/nelx_, (vtxUpperBound_(2)-vtxLowerBound_(2))/nely_);
			validElements_ = find(1==voxelizedVolume_);
			validElements_ = int32(validElements_);			
			numEles_ = length(validElements_);
			meshState_ = zeros(nelx_*nely_,1,'int32');	
			meshState_(validElements_) = 1;	
			eleMapBack_ = zeros(nelx_*nely_,1,'int32');	
			eleMapBack_(validElements_) = (1:numEles_)';
			nodenrs = reshape(1:(nelx_+1)*(nely_+1), 1+nely_, 1+nelx_); nodenrs = int32(nodenrs);
			eNodVec = reshape(nodenrs(1:end-1,1:end-1)+1, nelx_*nely_, 1);
			eNodMat_ = repmat(eNodVec(validElements_),1,4);
			tmp = [0 nely_+[1 0] -1]; tmp = int32(tmp);
			for ii=1:4
				eNodMat_(:,ii) = eNodMat_(:,ii) + repmat(tmp(ii), numEles_,1);
			end
			originalValidNodeIndex_ = unique(eNodMat_);
			numNodes_ = length(originalValidNodeIndex_);
			nodeMap4CutBasedModel_ = zeros((nelx_+1)*(nely_+1),1,'int32');
			nodeMap4CutBasedModel_(originalValidNodeIndex_) = (1:numNodes_)';	
			for ii=1:4
				eNodMat_(:,ii) = nodeMap4CutBasedModel_(eNodMat_(:,ii));
			end
			nodeCoords_ = zeros((nelx_+1)*(nely_+1),2);
			[nodeCoords_(:,1), nodeCoords_(:,2)] = NodalizeDesignDomain([nelx_ nely_], [vtxLowerBound_; vtxUpperBound_]);		
			nodeCoords_ = nodeCoords_(originalValidNodeIndex_,:);
		case '3D'
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
	end
	nodeLoadVec_(:,1,1) = nodeMap4CutBasedModel_(nodeLoadVec_(:,1));
	fixedNodes_(:,1) = double(nodeMap4CutBasedModel_(fixedNodes_));
end
