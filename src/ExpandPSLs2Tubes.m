function hd = ExpandPSLs2Tubes(PSLs, colorSrc, r)
	hd = []; if isempty(PSLs), return; end
	n = 8; ct=0.5*r;
	numLines = length(PSLs);
	gridXYZ = zeros(3,n+1,1);
	gridC = zeros(n+1,1);
	for ii=1:numLines		
		curve = PSLs(ii).phyCoordList';
		npoints = size(curve,2);
		%deltavecs: average for internal points. first strecth for endpoitns.		
		dv = curve(:,[2:end,end])-curve(:,[1,1:end-1]);		
		%make nvec not parallel to dv(:,1)
		nvec=zeros(3,1); [buf,idx]=min(abs(dv(:,1))); nvec(idx)=1;
		xyz=repmat([0],[3,n+1,npoints+2]);
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
		end;
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
	hd = surf(gridX,gridY,gridZ,gridC); shading('interp'); hold('on');
end