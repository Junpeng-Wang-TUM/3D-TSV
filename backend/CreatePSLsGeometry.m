function CreatePSLsGeometry(lw)
	global majorPSLs_tubeGeometry_gridX_;
	global majorPSLs_tubeGeometry_gridY_;
	global majorPSLs_tubeGeometry_gridZ_;
	global majorPSLs_tubeGeometry_indices_;
	global majorPSLs_ribbonGeometry_vertices_;
	global majorPSLs_ribbonGeometry_faces_;
	global majorPSLs_ribbonGeometry_indices_;
	
	global mediumPSLs_tubeGeometry_gridX_;
	global mediumPSLs_tubeGeometry_gridY_;
	global mediumPSLs_tubeGeometry_gridZ_;
	global mediumPSLs_tubeGeometry_indices_;
	global mediumPSLs_ribbonGeometry_vertices_;
	global mediumPSLs_ribbonGeometry_faces_;
	global mediumPSLs_ribbonGeometry_indices_;

	global minorPSLs_tubeGeometry_gridX_;
	global minorPSLs_tubeGeometry_gridY_;
	global minorPSLs_tubeGeometry_gridZ_;
	global minorPSLs_tubeGeometry_indices_;
	global minorPSLs_ribbonGeometry_vertices_;
	global minorPSLs_ribbonGeometry_faces_;
	global minorPSLs_ribbonGeometry_indices_;
	
	global majorPSLpool_; 
	global mediumPSLpool_; 
	global minorPSLpool_;
	
	global minimumEpsilon_;
	global boundingBox_;
	
	lineWidthTube = min([lw*minimumEpsilon_/5, min(boundingBox_(2,:)-boundingBox_(1,:))/10]);
	lineWidthRibbon = 3*lineWidthTube;	
	
	numMajorPSLs = length(majorPSLpool_);	
	if numMajorPSLs>0
		color4MajorPSLs = struct('arr', []); color4MajorPSLs = repmat(color4MajorPSLs, numMajorPSLs, 1);
		for ii=1:numMajorPSLs
			color4MajorPSLs(ii).arr = ones(1, majorPSLpool_(ii).length);
		end
		[majorPSLs_tubeGeometry_gridX_, majorPSLs_tubeGeometry_gridY_, majorPSLs_tubeGeometry_gridZ_, ~, ...
			majorPSLs_tubeGeometry_indices_] = ExpandPSLs2Tubes(majorPSLpool_, color4MajorPSLs, lineWidthTube);
		
		[majorPSLs_ribbonGeometry_vertices_, majorPSLs_ribbonGeometry_faces_, ~, majorPSLs_ribbonGeometry_indices_] = ...
			ExpandPSLs2Ribbons(majorPSLpool_, lineWidthRibbon, [6 7 8; 2 3 4], color4MajorPSLs);
	else
		majorPSLs_tubeGeometry_gridX_ = [];
		majorPSLs_tubeGeometry_gridY_ = [];
		majorPSLs_tubeGeometry_gridZ_ = [];
		majorPSLs_tubeGeometry_indices_ = [];
		majorPSLs_ribbonGeometry_vertices_ = [];
		majorPSLs_ribbonGeometry_faces_ = [];
		majorPSLs_ribbonGeometry_indices_ = [];	
	end	
			
	numMediumPSLs = length(mediumPSLpool_);
	if numMediumPSLs>0
		color4MediumPSLs = struct('arr', []); color4MediumPSLs = repmat(color4MediumPSLs, numMediumPSLs, 1);
		for ii=1:numMediumPSLs
			color4MediumPSLs(ii).arr = ones(1, mediumPSLpool_(ii).length);
		end
		[mediumPSLs_tubeGeometry_gridX_, mediumPSLs_tubeGeometry_gridY_, mediumPSLs_tubeGeometry_gridZ_, ~, ...
			mediumPSLs_tubeGeometry_indices_] = ExpandPSLs2Tubes(mediumPSLpool_, color4MediumPSLs, lineWidthTube);	
		
		psDir = [2 3 4; 10 11 12]; %% [2 3 4; 10 11 12] or [10 11 12; 2 3 4]
		[mediumPSLs_ribbonGeometry_vertices_, mediumPSLs_ribbonGeometry_faces_, ~, mediumPSLs_ribbonGeometry_indices_] = ...
			ExpandPSLs2Ribbons(mediumPSLpool_, lineWidthRibbon, psDir, color4MediumPSLs);	
	else
		mediumPSLs_tubeGeometry_gridX_ = [];
		mediumPSLs_tubeGeometry_gridY_ = [];
		mediumPSLs_tubeGeometry_gridZ_ = [];
		mediumPSLs_tubeGeometry_indices_ = [];
		mediumPSLs_ribbonGeometry_vertices_ = [];
		mediumPSLs_ribbonGeometry_faces_ = [];
		mediumPSLs_ribbonGeometry_indices_ = [];	
	end
	
	
	numMinorPSLs = length(minorPSLpool_);
	if numMinorPSLs>0
		color4MinorPSLs = struct('arr', []); color4MinorPSLs = repmat(color4MinorPSLs, numMinorPSLs, 1);
		for ii=1:numMinorPSLs
			color4MinorPSLs(ii).arr = ones(1, minorPSLpool_(ii).length);
		end
		[minorPSLs_tubeGeometry_gridX_, minorPSLs_tubeGeometry_gridY_, minorPSLs_tubeGeometry_gridZ_, ~, ...
			minorPSLs_tubeGeometry_indices_] = ExpandPSLs2Tubes(minorPSLpool_, color4MinorPSLs, lineWidthTube);
		
		[minorPSLs_ribbonGeometry_vertices_, minorPSLs_ribbonGeometry_faces_, ~, minorPSLs_ribbonGeometry_indices_] = ...
			ExpandPSLs2Ribbons(minorPSLpool_, lineWidthRibbon, [6 7 8; 10 11 12], color4MinorPSLs);	
	else
		minorPSLs_tubeGeometry_gridX_ = [];
		minorPSLs_tubeGeometry_gridY_ = [];
		minorPSLs_tubeGeometry_gridZ_ = [];
		minorPSLs_tubeGeometry_indices_ = [];
		minorPSLs_ribbonGeometry_vertices_ = [];
		minorPSLs_ribbonGeometry_faces_ = [];
		minorPSLs_ribbonGeometry_indices_ = [];	
	end
	
end