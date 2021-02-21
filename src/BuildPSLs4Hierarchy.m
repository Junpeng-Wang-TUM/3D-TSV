function BuildPSLs4Hierarchy()
	global majorPSLpool_; global minorPSLpool_;
	global majorPSLindexList_; global minorPSLindexList_;
	global majorHierarchy_; global minorHierarchy_;
	global numLevels_;
		
	%% IM: 'Pure PSLs Density Ctrl, 1' (Geo), 'Principal Stress, 2' (PS), 'von Mises Stress, 3' (vM), 'PSLs Length, 4' (Length)
	numItems = 4;
	numMajorPSLs = length(majorPSLpool_);
	majorHierarchy_ = zeros(numMajorPSLs,numItems);
	numMinorPSLs = length(minorPSLpool_);
	minorHierarchy_ = zeros(numMinorPSLs,numItems);
	numLevels = length(majorPSLindexList_);
	
	%% #Major
	for jj=1:numLevels
		if 1==jj
			iPSLs = majorPSLindexList_(jj).arr;
		else
			iPSLs = setdiff(majorPSLindexList_(jj).arr, majorPSLindexList_(jj-1).arr);
		end
		majorHierarchy_(iPSLs(:),1) = (numLevels-jj+1)/numLevels;
	end	
	for jj=1:numMajorPSLs
		if majorPSLpool_(jj).length > 0		
			majorHierarchy_(jj,2) = max(abs(majorPSLpool_(jj).principalStressList(:,9)));
			majorHierarchy_(jj,3) = max(majorPSLpool_(jj).vonMisesStressList);
			majorHierarchy_(jj,4) = majorPSLpool_(jj).length;
		end
	end
	majorHierarchy_(:,2) = majorHierarchy_(:,2) / max(majorHierarchy_(:,2));		
	majorHierarchy_(:,3) = majorHierarchy_(:,3) / max(majorHierarchy_(:,3));
	majorHierarchy_(:,4) = majorHierarchy_(:,4) / max(majorHierarchy_(:,4));
	
	%% #Minor
	for jj=1:numLevels
		if 1==jj
			iPSLs = minorPSLindexList_(jj).arr;
		else
			iPSLs = setdiff(minorPSLindexList_(jj).arr, minorPSLindexList_(jj-1).arr);
		end
		minorHierarchy_(iPSLs(:),1) = (numLevels-jj+1)/numLevels;		
	end
	for jj=1:numMinorPSLs
		if minorPSLpool_(jj).length > 0		
			minorHierarchy_(jj,2) = max(abs(minorPSLpool_(jj).principalStressList(:,1)));
			minorHierarchy_(jj,3) = max(minorPSLpool_(jj).vonMisesStressList);
			minorHierarchy_(jj,4) = minorPSLpool_(jj).length;
		end
	end		
	minorHierarchy_(:,2) = minorHierarchy_(:,2) / max(minorHierarchy_(:,2));	
	minorHierarchy_(:,3) = minorHierarchy_(:,3) / max(minorHierarchy_(:,3));
	minorHierarchy_(:,4) = minorHierarchy_(:,4) / max(minorHierarchy_(:,4));
end
