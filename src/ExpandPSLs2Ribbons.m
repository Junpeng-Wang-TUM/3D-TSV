function varargout = ExpandPSLs2Ribbons(varargin)
	%%Syntax:
	%% coordList = ExpandPSLs2Ribbons(PSLs, lw, psDir, smoothingOpt); Exporting Ribbon Vertices of a single PSL
	%% [hdFace, hdOutline] = ExpandPSLs2Ribbons(PSLs, lw, psDir colorSrc, smoothingOpt);
	%% [xPatchsFace,yPatchsFace,zPatchsFace,cPatchsFace,xPatchsOutline,yPatchsOutline,zPatchsOutline,patchIndices] = ...
	%%	ExpandPSLs2Ribbons(PSLs, lw, psDir, psAmpt, smoothingOpt); Exporting Ribbon Patches
	%%			RIBBON
	%%	===========================
	%%		   dir2 |	
	%%				 ---dir1
	%%			   / dir3
	%%	===========================
	%%
	twistThreshold = 3.5/180*pi;
	PSLs = varargin{1};
	lw = varargin{2};
	psDir = varargin{3};
	if isempty(PSLs) 
		if 1==nargout
			varargout{1} = [];
		elseif 2==nargout
			varargout{1} = []; varargout{2} = [];
		else
			varargout{1} = []; varargout{2} = []; varargout{3} = []; varargout{4} = [];
			varargout{5} = []; varargout{6} = []; varargout{7} = []; varargout{8} = [];
		end
		return; 
	end
	numPSLs = length(PSLs);
	
	if 1==nargout
		smoothingOpt = varargin{4};
		
		iPSLength = PSLs(1).length;
		iCoordList = zeros(2*iPSLength,3);
		iDirConsistencyMetric = zeros(iPSLength,3);
		midPots = PSLs(1).phyCoordList;
		
		dirVecs = PSLs(1).principalStressList(:,psDir);
		angList = zeros(iPSLength-1,1);
		for jj=2:iPSLength
			vec0 = dirVecs(jj-1,:);
			vec1 = dirVecs(jj,:); vec2 = -vec1;
			ang1 = acos(vec0 * vec1'); ang2 = acos(vec0 * vec2');
			angList(jj-1) = ang1;
			if ang2<ang1
				angList(jj-1) = ang2;
				dirVecs(jj,:) = vec2;
			end
		end
		if smoothingOpt
			angDeviationMetric = sum(angList)/(iPSLength-1);	
			if angDeviationMetric>twistThreshold
				effectingRadius = 3; wgts = ((effectingRadius:-1:1)').^(-2);
				for jj=effectingRadius:iPSLength
					if 1==jj, continue; end
					vec0 = dirVecs(jj-1,:);
					vec1 = dirVecs(jj,:);
					ang1 = acos(vec0 * vec1');
					if ang1>angDeviationMetric			
						if jj<=effectingRadius
							iSlider = 1:jj-1; iwgts = wgts(effectingRadius-length(iSlider)+1:end);
							tmp = sum(dirVecs(iSlider,:).*iwgts, 1);							
						else
							iSlider = jj-effectingRadius:jj-1;
							tmp = sum(dirVecs(iSlider,:).*wgts, 1);	
						end
						dirVecs(jj,:) = tmp/norm(tmp);
					end						
				end				
			end			
		end				
		dirVecs = dirVecs * lw;		
		
		coords1 = midPots + dirVecs;
		coords2 = midPots - dirVecs;
		iCoordList(1:2:end,:) = coords1;
		iCoordList(2:2:end,:) = coords2;
		
		varargout{1} = iCoordList;
	elseif 2==nargout		
		colorSrc = varargin{4};
		smoothingOpt = varargin{5};
		
		coordList = [];
		quadMapFace = [];
		quadMapOutline = [];
		faceColorList = [];			
		for ii=1:numPSLs
			%%2.1 ribbon boundary nodes
			iPSLength = PSLs(ii).length;
			iCoordList = zeros(2*iPSLength,3);
			iDirConsistencyMetric = zeros(iPSLength,3);
			midPots = PSLs(ii).phyCoordList;
			
			dirVecs = PSLs(ii).principalStressList(:,psDir);
			angList = zeros(iPSLength-1,1);
			for jj=2:iPSLength
				vec0 = dirVecs(jj-1,:);
				vec1 = dirVecs(jj,:); vec2 = -vec1;
				ang1 = acos(vec0 * vec1'); ang2 = acos(vec0 * vec2');
				angList(jj-1) = ang1;
				if ang2<ang1
					angList(jj-1) = ang2;
					dirVecs(jj,:) = vec2;
				end
			end
			if smoothingOpt
				angDeviationMetric = sum(angList)/(iPSLength-1);	
				if angDeviationMetric>twistThreshold
					for jj=2:iPSLength
						vec0 = dirVecs(jj-1,:);
						vec1 = dirVecs(jj,:);
						ang1 = acos(vec0 * vec1');
						if ang1>angDeviationMetric
							dirVecs(jj,:) = vec0;
						end
					end
				end
			end				
			dirVecs = dirVecs * lw;
			
			coords1 = midPots + dirVecs;
			coords2 = midPots - dirVecs;
			iCoordList(1:2:end,:) = coords1;
			iCoordList(2:2:end,:) = coords2;
				
			%%2.2 create quad patches
			numExistingNodes = size(coordList,1);
			numNewlyGeneratedNodes = 2*iPSLength;
			newGeneratedNodes = numExistingNodes + (1:numNewlyGeneratedNodes);
			newGeneratedNodes = reshape(newGeneratedNodes, 2, iPSLength);
			iQuadMapFace = [newGeneratedNodes(1,1:end-1); newGeneratedNodes(2,1:end-1); ...
				newGeneratedNodes(2,2:end); newGeneratedNodes(1,2:end)];
				
			%%2.3 write into global ribbon info
			iFaceColorList = colorSrc(ii).arr;
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);	
			iQuadMapOutline = [
				newGeneratedNodes(1,1:end-1) newGeneratedNodes(2,1:end-1) newGeneratedNodes(1,1) newGeneratedNodes(1,end)
				newGeneratedNodes(1,2:end)	 newGeneratedNodes(2,2:end)	  newGeneratedNodes(2,1) newGeneratedNodes(2,end)
				newGeneratedNodes(1,2:end)	 newGeneratedNodes(2,2:end)   newGeneratedNodes(2,1) newGeneratedNodes(2,end)
				newGeneratedNodes(1,1:end-1) newGeneratedNodes(2,1:end-1) newGeneratedNodes(1,1) newGeneratedNodes(1,end)
			];		
			faceColorList(end+1:end+2*iPSLength,:) = iFaceColorList;
			quadMapOutline(:,end+1:end+2*iPSLength) = iQuadMapOutline;
			quadMapFace(:,end+1:end+iPSLength-1) = iQuadMapFace;
			
			coordList(end+1:end+2*iPSLength,:) = iCoordList;
		end		
		
		%%draw ribbon
		xCoord = coordList(:,1); 
		yCoord = coordList(:,2); 
		zCoord = coordList(:,3);
		
		xPatchsFace = xCoord(quadMapFace);
		yPatchsFace = yCoord(quadMapFace);
		zPatchsFace = zCoord(quadMapFace);
		cPatchsFace = faceColorList(quadMapFace);
		hdFace = patch(xPatchsFace, yPatchsFace, zPatchsFace, cPatchsFace); 
		shading('interp'); hold('on');
		
		xPatchsOutline = xCoord(quadMapOutline);
		yPatchsOutline = yCoord(quadMapOutline);
		zPatchsOutline = zCoord(quadMapOutline);
		cPatchsOutline = zeros(size(xPatchsOutline));
		hdOutline = patch(xPatchsOutline, yPatchsOutline, zPatchsOutline, cPatchsOutline); hold('on');
		set(hdOutline, 'facecol', 'None', 'linew', 3);
		varargout{1} = hdFace; varargout{2} = hdOutline;		
	else
		psAmpt = varargin{4};
		smoothingOpt = varargin{5};
		patchIndices = struct('arrFace', [], 'arrOutline', []);
		patchIndices = repmat(patchIndices, numPSLs, 1);
		coordList = [];
		quadMapFace = [];
		quadMapOutline = [];
		faceColorList = [];	
		for ii=1:numPSLs
			%%2.1 ribbon boundary nodes
			iPSLength = PSLs(ii).length;
			iCoordList = zeros(2*iPSLength,3);
			iDirConsistencyMetric = zeros(iPSLength,3);
			midPots = PSLs(ii).phyCoordList;
			
			dirVecs = PSLs(ii).principalStressList(:,psDir);
			angList = zeros(iPSLength-1,1);
			for jj=2:iPSLength
				vec0 = dirVecs(jj-1,:);
				vec1 = dirVecs(jj,:); vec2 = -vec1;
				ang1 = acos(vec0 * vec1'); ang2 = acos(vec0 * vec2');
				angList(jj-1) = ang1;
				if ang2<ang1
					angList(jj-1) = ang2;
					dirVecs(jj,:) = vec2;
				end
			end
			if smoothingOpt
				angDeviationMetric = sum(angList)/(iPSLength-1);	
				if angDeviationMetric>twistThreshold
					for jj=2:iPSLength
						vec0 = dirVecs(jj-1,:);
						vec1 = dirVecs(jj,:);
						ang1 = acos(vec0 * vec1');
						if ang1>angDeviationMetric
							dirVecs(jj,:) = vec0;
						end
					end
				end
			end				
			dirVecs = dirVecs * lw;
			
			coords1 = midPots + dirVecs;
			coords2 = midPots - dirVecs;
			iCoordList(1:2:end,:) = coords1;
			iCoordList(2:2:end,:) = coords2;
				
			%%2.2 create quad patches
			numExistingNodes = size(coordList,1);
			numNewlyGeneratedNodes = 2*iPSLength;
			newGeneratedNodes = numExistingNodes + (1:numNewlyGeneratedNodes);
			newGeneratedNodes = reshape(newGeneratedNodes, 2, iPSLength);
			iQuadMapFace = [newGeneratedNodes(1,1:end-1); newGeneratedNodes(2,1:end-1); ...
				newGeneratedNodes(2,2:end); newGeneratedNodes(1,2:end)];
				
			%%2.3 write into global ribbon info
			iQuadMapOutline = [
				newGeneratedNodes(1,1:end-1) newGeneratedNodes(2,1:end-1) newGeneratedNodes(1,1) newGeneratedNodes(1,end)
				newGeneratedNodes(1,2:end)	 newGeneratedNodes(2,2:end)	  newGeneratedNodes(2,1) newGeneratedNodes(2,end)
				newGeneratedNodes(1,2:end)	 newGeneratedNodes(2,2:end)   newGeneratedNodes(2,1) newGeneratedNodes(2,end)
				newGeneratedNodes(1,1:end-1) newGeneratedNodes(2,1:end-1) newGeneratedNodes(1,1) newGeneratedNodes(1,end)
			];		
			tmpFace = size(quadMapFace,2)+1 : size(quadMapFace,2)+iPSLength-1;
			tmpOutline = size(quadMapOutline,2)+1 : size(quadMapOutline,2)+2*iPSLength;
			quadMapOutline(:,tmpOutline) = iQuadMapOutline;
			quadMapFace(:,tmpFace) = iQuadMapFace;
			coordList(tmpOutline,:) = iCoordList;
			
			faceColorList(tmpOutline,:) = zeros(2*iPSLength,9);
			
			iFaceColorList = PSLs(ii).principalStressList(:,psAmpt)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,2) = iFaceColorList;
			
			iFaceColorList = PSLs(ii).vonMisesStressList';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,3) = iFaceColorList;			
			
			iFaceColorList = PSLs(ii).cartesianStressList(:,1)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,4) = iFaceColorList;
			
			iFaceColorList = PSLs(ii).cartesianStressList(:,2)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,5) = iFaceColorList;
			
			iFaceColorList = PSLs(ii).cartesianStressList(:,3)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,6) = iFaceColorList;
			
			iFaceColorList = PSLs(ii).cartesianStressList(:,4)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,7) = iFaceColorList;
			
			iFaceColorList = PSLs(ii).cartesianStressList(:,5)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,8) = iFaceColorList;
			
			iFaceColorList = PSLs(ii).cartesianStressList(:,6)';
			iFaceColorList = reshape(repmat(iFaceColorList, 2, 1), 2*iPSLength, 1);
			faceColorList(tmpOutline,9) = iFaceColorList;
			
			patchIndices(ii).arrFace = tmpFace;
			patchIndices(ii).arrOutline = tmpOutline;
		end

		%%draw ribbon
		xCoord = coordList(:,1); 
		yCoord = coordList(:,2); 
		zCoord = coordList(:,3);
		xPatchsFace = xCoord(quadMapFace);
		yPatchsFace = yCoord(quadMapFace);
		zPatchsFace = zCoord(quadMapFace);
		cPatchsFace = zeros(4, size(quadMapFace,2), 9);
		for ii=2:9
			tmp = faceColorList(:,ii);
			cPatchsFace(:,:,ii) = tmp(quadMapFace);
		end
		xPatchsOutline = xCoord(quadMapOutline);
		yPatchsOutline = yCoord(quadMapOutline);
		zPatchsOutline = zCoord(quadMapOutline);
		
		
		varargout{1} = xPatchsFace;
		varargout{2} = yPatchsFace;
		varargout{3} = zPatchsFace;
		varargout{4} = cPatchsFace;
		varargout{5} = xPatchsOutline;
		varargout{6} = yPatchsOutline;
		varargout{7} = zPatchsOutline;
		varargout{8} = patchIndices;			
	end
end
