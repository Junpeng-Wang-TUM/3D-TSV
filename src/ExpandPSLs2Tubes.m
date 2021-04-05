function varargout = ExpandPSLs2Tubes(varargin)
	%%Syntax
	%% hd = ExpandPSLs2Tubes(PSLs, colorSrc, r)
	%% [gridX,gridY,gridZ,gridC,gridIndices] = ExpandPSLs2Tubes(PSLs, psDir, r);
	global axHandle_;
	PSLs = varargin{1};
	r = varargin{3};
	n = 8; ct=0.5*r;
	numLines = length(PSLs);
	gridXYZ = zeros(3,n+1,1);
	if 5==nargout
		if isempty(PSLs)
			varargout{1} = []; varargout{2} = []; varargout{3} = []; varargout{4} = []; varargout{5} = [];
			return; 
		end
		psDir = varargin{2};
		gridC = zeros(n+1,1,9);	
		gridIndices = struct('arr', []); gridIndices = repmat(gridIndices, numLines, 1);
		for ii=1:numLines		
			curve = PSLs(ii).phyCoordList';
			npoints = size(curve,2);
			%deltavecs: average for internal points. first strecth for endpoitns.		
			dv = curve(:,[2:end,end])-curve(:,[1,1:end-1]);		
			%make nvec not parallel to dv(:,1)
			nvec=zeros(3,1); [~,idx]=min(abs(dv(:,1))); nvec(idx)=1;
			%precalculate cos and sing factors:
			cfact=repmat(cos(linspace(0,2*pi,n+1)),[3,1]);
			sfact=repmat(sin(linspace(0,2*pi,n+1)),[3,1]);
			%Main loop: propagate the normal (nvec) along the tube
			xyz = zeros(3,n+1,npoints+2);
			for k=1:npoints
				convec=cross(nvec,dv(:,k));
				convec=convec./norm(convec);
				nvec=cross(dv(:,k),convec);
				nvec=nvec./norm(nvec);
				%update xyz:
				xyz(:,:,k+1)=repmat(curve(:,k),[1,n+1]) + cfact.*repmat(r*nvec,[1,n+1]) + sfact.*repmat(r*convec,[1,n+1]);
            end
			%finally, cap the ends:
			xyz(:,:,1)=repmat(curve(:,1),[1,n+1]);
			xyz(:,:,end)=repmat(curve(:,end),[1,n+1]);
			tmp = size(gridXYZ,3)+1 : size(gridXYZ,3)+size(xyz,3);	
			
			gridIndices(ii).arr = tmp;	
			gridXYZ(:,:,tmp) = xyz;	
			gridC(:,tmp,:) = zeros(n+1, npoints+2, 9);
			
			iColor = PSLs(ii).principalStressList(:,psDir)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 2) = c;
			
			iColor = PSLs(ii).vonMisesStressList';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 3) = c;
			
			iColor = PSLs(ii).cartesianStressList(:,1)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 4) = c;
			
			iColor = PSLs(ii).cartesianStressList(:,2)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 5) = c;
			
			iColor = PSLs(ii).cartesianStressList(:,3)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 6) = c;
			
			iColor = PSLs(ii).cartesianStressList(:,4)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 7) = c;
			
			iColor = PSLs(ii).cartesianStressList(:,5)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 8) = c;
			
			iColor = PSLs(ii).cartesianStressList(:,6)';
			c = [iColor(1) iColor iColor(end)]; c = repmat(c, n+1, 1);
			gridC(:,tmp, 9) = c;
		end			
		gridX = squeeze(gridXYZ(1,:,:));
		gridY = squeeze(gridXYZ(2,:,:));
		gridZ = squeeze(gridXYZ(3,:,:));
		varargout{1} = gridX;
		varargout{2} = gridY;
		varargout{3} = gridZ;
		varargout{4} = gridC;
		varargout{5} = gridIndices;
	else
		if isempty(PSLs)
			varargout{1} = []; 
			return; 
		end
		colorSrc = varargin{2};
		gridC = zeros(n+1,1);
		for ii=1:numLines		
			curve = PSLs(ii).phyCoordList';
			npoints = size(curve,2);
			%deltavecs: average for internal points. first strecth for endpoitns.		
			dv = curve(:,[2:end,end])-curve(:,[1,1:end-1]);		
			%make nvec not parallel to dv(:,1)
			nvec=zeros(3,1); [~,idx]=min(abs(dv(:,1))); nvec(idx)=1;
			%precalculate cos and sing factors:
			cfact=repmat(cos(linspace(0,2*pi,n+1)),[3,1]);
			sfact=repmat(sin(linspace(0,2*pi,n+1)),[3,1]);
			%Main loop: propagate the normal (nvec) along the tube
			xyz = zeros(3,n+1,npoints+2);
			for k=1:npoints
				convec=cross(nvec,dv(:,k));
				convec=convec./norm(convec);
				nvec=cross(dv(:,k),convec);
				nvec=nvec./norm(nvec);
				%update xyz:
				xyz(:,:,k+1)=repmat(curve(:,k),[1,n+1]) + cfact.*repmat(r*nvec,[1,n+1]) + sfact.*repmat(r*convec,[1,n+1]);
            end
			%finally, cap the ends:
			xyz(:,:,1)=repmat(curve(:,1),[1,n+1]);
			xyz(:,:,end)=repmat(curve(:,end),[1,n+1]);
			gridXYZ(:,:,end+1:end+npoints+2) = xyz;	
			color = colorSrc(ii).arr;	
			c = [color(1) color color(end)];
			c = repmat(c, n+1, 1);
			gridC(:,end+1:end+npoints+2) = c;
		end		
		gridX = squeeze(gridXYZ(1,:,:));
		gridY = squeeze(gridXYZ(2,:,:));
		gridZ = squeeze(gridXYZ(3,:,:));		
		hd = surf(axHandle_,gridX,gridY,gridZ,gridC); shading(axHandle_,'interp'); hold(axHandle_,'on');
		varargout{1} = hd;
	end
end
