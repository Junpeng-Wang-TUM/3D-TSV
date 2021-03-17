function varargout = ExpandPSLs2Ribbon(varargin)
	%%Syntax:
	%% [hdFace, hdOutline] = ExpandPSLs2Ribbon(PSLs, colorSrc, lw, smoothingOpt);
	%% coordList = ExpandPSLs2Ribbon(PSLs, lw, smoothingOpt); Just Exporting Ribbon Vertices
	%%1. initialize arguments
	if 5==nargin
		PSLs = varargin{1}; numPSLs = length(PSLs);
		widthDir = varargin{2};
		colorSrc = varargin{3};
		lw = varargin{4};
		smoothingOpt = varargin{5};	
		nargout = 2;
		if 0==numPSLs, varargout{1} = []; varargout{2} = []; return; end
	elseif 4==nargin
		PSLs = varargin{1}; numPSLs = length(PSLs);
		widthDir = varargin{2};
		lw = varargin{3};
		smoothingOpt = varargin{4};
		nargout = 1;
		if 0==numPSLs, varargout{1} = []; return; end
	else
		error('Wrong Input!');
	end
	
	
	%%2. Expand PSL to ribbon
	%%			RIBBON
	%%	===========================
	%%		   dir2 |	
	%%				 ---dir1
	%%			   / dir3
	%%	===========================
	%%
	twistThreshold = 4/180*pi;

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
		
		dirVecs = PSLs(ii).principalStressList(:,widthDir);
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
			
		if 5==nargin
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
		end
		coordList(end+1:end+2*iPSLength,:) = iCoordList;
	end
	if 5==nargin
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
		varargout{1} = coordList;
	end
end
