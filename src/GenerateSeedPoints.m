function GenerateSeedPoints(seedStrategy)
	global meshType_;
	global nodeCoords_;
	global nodState_;
	global nodeLoadVec_;
	global seedPointsHistory_;
	
	switch seedStrategy
		case 'Volume'
			if strcmp(meshType_, 'CARTESIAN_GRID')
				global originalValidNodeIndex_;
				global nelx_; global nely_; global nelz_;
				global seedSpan4VolumeOptCartesianMesh_;
				step = seedSpan4VolumeOptCartesianMesh_;
				validNodesVolume = zeros((nelx_+1)*(nely_+1)*(nelz_+1),1);
				validNodesVolume(originalValidNodeIndex_) = (1:length(originalValidNodeIndex_))';
				validNodesVolume = reshape(validNodesVolume, nely_+1, nelx_+1, nelz_+1);
				sampledNodes = validNodesVolume(step+1:step:nely_+1-step, step+1:step:nelx_+1-step, step+1:step:nelz_+1-step);	
				sampledNodes = reshape(sampledNodes, numel(sampledNodes), 1);
				sampledNodes(0==sampledNodes) = [];
				seedPointsHistory_ = nodeCoords_(sampledNodes,:);
			else
				global nodStruct_;
				global eNodMat_;
				global numNodes_;
				allNodes = (1:numNodes_)';
				dis2Boundary = 2;
				if dis2Boundary <= 0
					seedPointsHistory_ = nodeCoords_(1:3:end,:);
				else
					boundaryNods = find(1==nodState_);
					tmp0 = boundaryNods;
					index = 2;
					while index <=dis2Boundary
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
					seedPointsHistory_ = nodeCoords_(sampledNodes(1:dis2Boundary:end),:);
				end			
			end
		case 'Surface'
			seedPointsHistory_ = nodeCoords_(1==nodState_,:);
		case 'LoadingArea'			
			seedPointsHistory_ = nodeCoords_(nodeLoadVec_(:,1),:);			
		case 'ApproxTopology' %% only Work Cartesian Mesh
			if strcmp(meshType_, 'CARTESIAN_GRID')
				seedPointsHistory_ = GetDegenerateElements();
			else
				warning('This Seed Strategy only Works with Cartesian Mesh, back to all Mesh Vertices Seeding!');
				seedPointsHistory_ = nodeCoords_(1:2:end,:);;
			end
	end
end

function degenerateElementCenters = GetDegenerateElements()
	global eleCentroidList_;
	global numEles_;
	global eNodMat_;	
	global cartesianStressField_;
	global potentialDegenerateElements;
	potentialDegenerateElements = [];
	for ii=1:numEles_
		eleStress = cartesianStressField_(eNodMat_(ii,:)',:);
		opt = DegenrationMeasure(eleStress);
		if 1==opt, potentialDegenerateElements(end+1,1) = ii; end			
	end	
	degenerateElementCenters = eleCentroidList_(potentialDegenerateElements,:);	
end

function opt = DegenrationMeasure(tar)	
	discriminants = DiscriminantConstraintFuncs(tar);
	
	fx = discriminants(:,1);
	fy1 = discriminants(:,2);
	fy2 = discriminants(:,3);
	fy3 = discriminants(:,4);
	fz1 = discriminants(:,5);
	fz2 = discriminants(:,6);
	fz3 = discriminants(:,7);
	
	bool1_1 = fx(1)>0 && fx(2)>0 && fx(3)>0 && fx(4)>0 && fx(5)>0 && fx(6)>0 && fx(7)>0 && fx(8)>0;
	bool1_2 = fx(1)<0 && fx(2)<0 && fx(3)<0 && fx(4)<0 && fx(5)<0 && fx(6)<0 && fx(7)<0 && fx(8)<0;
	bool1 = bool1_1 || bool1_2;
	
	bool2_1 = fy1(1)>0 && fy1(2)>0 && fy1(3)>0 && fy1(4)>0 && fy1(5)>0 && fy1(6)>0 && fy1(7)>0 && fy1(8)>0;
	bool2_2 = fy1(1)<0 && fy1(2)<0 && fy1(3)<0 && fy1(4)<0 && fy1(5)<0 && fy1(6)<0 && fy1(7)<0 && fy1(8)<0;
	bool2 = bool2_1 || bool2_2;
	
	bool3_1 = fy2(1)>0 && fy2(2)>0 && fy2(3)>0 && fy2(4)>0 && fy2(5)>0 && fy2(6)>0 && fy2(7)>0 && fy2(8)>0;
	bool3_2 = fy2(1)<0 && fy2(2)<0 && fy2(3)<0 && fy2(4)<0 && fy2(5)<0 && fy2(6)<0 && fy2(7)<0 && fy2(8)<0;
	bool3 = bool3_1 || bool3_2;

	bool4_1 = fy3(1)>0 && fy3(2)>0 && fy3(3)>0 && fy3(4)>0 && fy3(5)>0 && fy3(6)>0 && fy3(7)>0 && fy3(8)>0;
	bool4_2 = fy3(1)<0 && fy3(2)<0 && fy3(3)<0 && fy3(4)<0 && fy3(5)<0 && fy3(6)<0 && fy3(7)<0 && fy3(8)<0;
	bool4 = bool4_1 || bool4_2;

	bool5_1 = fz1(1)>0 && fz1(2)>0 && fz1(3)>0 && fz1(4)>0 && fz1(5)>0 && fz1(6)>0 && fz1(7)>0 && fz1(8)>0;
	bool5_2 = fz1(1)<0 && fz1(2)<0 && fz1(3)<0 && fz1(4)<0 && fz1(5)<0 && fz1(6)<0 && fz1(7)<0 && fz1(8)<0;
	bool5 = bool5_1 || bool5_2;

	bool6_1 = fz2(1)>0 && fz2(2)>0 && fz2(3)>0 && fz2(4)>0 && fz2(5)>0 && fz2(6)>0 && fz2(7)>0 && fz2(8)>0;
	bool6_2 = fz2(1)<0 && fz2(2)<0 && fz2(3)<0 && fz2(4)<0 && fz2(5)<0 && fz2(6)<0 && fz2(7)<0 && fz2(8)<0;
	bool6 = bool6_1 || bool6_2;

	bool7_1 = fz3(1)>0 && fz3(2)>0 && fz3(3)>0 && fz3(4)>0 && fz3(5)>0 && fz3(6)>0 && fz3(7)>0 && fz3(8)>0;
	bool7_2 = fz3(1)<0 && fz3(2)<0 && fz3(3)<0 && fz3(4)<0 && fz3(5)<0 && fz3(6)<0 && fz3(7)<0 && fz3(8)<0;
	bool7 = bool7_1 || bool7_2;
	
	if bool1 || bool2 || bool3 || bool4 || bool5 || bool6 || bool7
		opt = 0;
	else
		opt = 1;	
	end
end

function discriminants = DiscriminantConstraintFuncs(eleStress)
	T00 = eleStress(:,1); T11 = eleStress(:,2); T22 = eleStress(:,3);
	T12 = eleStress(:,4); T02 = eleStress(:,5); T01 = eleStress(:,6);	
	T00T00 = T00.^2;		%sigma_xx.^2
	T11T11 = T11.^2;		%sigma_yy.^2
	T22T22 = T22.^2;		%sigma_zz.^2
	T12T12 = T12.^2;		%tadis_yz.^2
	T02T02 = T02.^2;		%tadis_zx.^2
	T01T01 = T01.^2;		%tadis_xy.^2
	T00T11 = T00.*T11; 	%sigma_xx .* sigma_yy
	T11T22 = T11.*T22; 	%sigma_yy .* sigma_zz
	T22T00 = T22.*T00; 	%sigma_zz .* sigma_xx
	T01T02 = T01.*T02; 	%tadis_xy .* tadis_zx
	T12T01 = T12.*T01; 	%tadis_yz .* tadis_xy
	T02T12 = T02.*T12; 	%tadis_zx .* tadis_yz	
	
	fx = T00.*(T11T11-T22T22 + T01T01-T02T02) + T11.*(T22T22-T00T00 + ...
		T12T12-T01T01) + T22.*(T00T00-T11T11 + T02T02-T12T12);
	
	fy1 = T12.*(2*(T12T12-T00T00) - (T02T02+T01T01) + 2*(T00T11 + T22T00 - T11T22)) + ...
		T01T02.*(2*T00-T22-T11);		
	fy2 = T02.*(2*(T02T02-T11T11) - (T01T01+T12T12) + 2*(T11T22 + T00T11 - T22T00)) + ...
		T12T01.*(2*T11-T00-T22);		
	fy3 = T01.*(2*(T01T01-T22T22) - (T12T12+T02T02) + 2*(T22T00 + T11T22 - T00T11)) + ...	
		T02T12.*(2*T22-T11-T00);		

	fz1 = T12.*(T02T02-T01T01) + T01T02.*(T11-T22);
	fz2 = T02.*(T01T01-T12T12) + T12T01.*(T22-T00);
	fz3 = T01.*(T12T12-T02T02) + T02T12.*(T00-T11);		
	
	discriminants = [fx fy1 fy2 fy3 fz1 fz2 fz3];
end