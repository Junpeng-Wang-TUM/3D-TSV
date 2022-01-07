function hd = DrawBoundaryCondition(varargin)
	global boundingBox_;
	global nodeCoords_;
	global loadingCond_; 
	global fixingCond_;
	
	if 0==nargin, axHandle_ = gca; else, axHandle_ = varargin{1}; end
	hd = [];
	
	%%fixation
	if ~isempty(fixingCond_)
		hold(axHandle_, 'on'); 
		tarNodeCoord = nodeCoords_(fixingCond_(:,1),:);
		hd(end+1,1) = plot3(axHandle_, tarNodeCoord(:,1), tarNodeCoord(:,2), tarNodeCoord(:,3), 'xk', 'LineWidth', 3, 'MarkerSize', 15);
	end
	
	%%loading
	if ~isempty(loadingCond_)
		hold(axHandle_, 'on');
		lB = 0.2;
		uB = 1.0;
		amps = vecnorm(loadingCond_(:,2:end),2,2);
		maxAmp = max(amps);
		minAmp = min(amps);
		if abs(minAmp-maxAmp)/(minAmp+maxAmp)<0.1
			scalingFac = 1;
		else
			if minAmp/maxAmp>lB/uB, lB = minAmp/maxAmp; end
			scalingFac = lB + (uB-lB)*(amps-minAmp)/(maxAmp-minAmp);
		end   
		loadingDirVec = loadingCond_(:,2:end)./amps.*scalingFac;
		pos = nodeCoords_(loadingCond_(:,1),:);
		amps = mean(boundingBox_(2,:)-boundingBox_(1,:))/5 * loadingDirVec;
		hd(end+1,1) = quiver3(axHandle_, pos(:,1), pos(:,2), pos(:,3), amps(:,1), amps(:,2), amps(:,3), ...
			0, 'Color', [255 127 0.0]/255, 'LineWidth', 2, 'MaxHeadSize', 1, 'MaxHeadSize', 1); 	
	end
end