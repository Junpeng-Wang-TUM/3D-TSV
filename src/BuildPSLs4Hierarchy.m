function BuildPSLs4Hierarchy(importanceMetricItems)
	global majorPSLpool_; global minorPSLpool_;
	global majorPSLindexList_; global minorPSLindexList_;
	global majorHierarchy_; global minorHierarchy_;
	global numLevels_;
	
	numItems = length(importanceMetricItems);
	numMajorPSLs = length(majorPSLpool_);
	if numMajorPSLs>0, majorHierarchy_ = zeros(numMajorPSLs,numItems); end
	numMinorPSLs = length(minorPSLpool_);
	if numMinorPSLs>0, minorHierarchy_ = zeros(numMinorPSLs,numItems); end
	
	for ii=1:numItems
		iItem = importanceMetricItems{ii};
		switch iItem
			case 'Pure PSLs Density Ctrl'
				if numMajorPSLs>0
					for jj=1:numLevels_
						if 1==jj
							iPSLs = majorPSLindexList_(ii).arr;
						else
							iPSLs = setdiff(majorPSLindexList_(jj).arr, majorPSLindexList_(jj-1).arr);
						end
						majorHierarchy_(iPSLs(:),ii) = (numLevels_-jj+1)/numLevels;
					end				
				end
				if numMinorPSLs>0
					for jj=1:numLevels_
						if 1==jj
							iPSLs = minorPSLindexList_(ii).arr;
						else
							iPSLs = setdiff(minorPSLindexList_(jj).arr, minorPSLindexList_(jj-1).arr);
						end
						minorHierarchy_(iPSLs(:),ii) = (numLevels_-jj+1)/numLevels;
					end				
				end				
			case 'Principal Stress (PS)'
				if numMajorPSLs>0
					for jj=1:numMajorPSLs
						if majorPSLpool_(jj).length > 0		
							majorHierarchy_(jj,ii) = max(abs(majorPSLpool_(jj).principalStressList(:,9)));
						end
					end
					majorHierarchy_(:,ii) = majorHierarchy_(:,ii) / max(majorHierarchy_(:,ii));
				end
				if numMinorPSLs>0
					for jj=1:numMinorPSLs
						if minorPSLpool_(jj).length > 0		
							minorHierarchy_(jj,ii) = max(abs(minorPSLpool_(jj).principalStressList(:,1)));
						end
					end		
					minorHierarchy_(:,ii) = minorHierarchy_(:,ii) / max(minorHierarchy_(:,ii));
				end								
			case 'von Mises Stress (vM)'
				if numMajorPSLs>0
					for jj=1:numMajorPSLs
						if majorPSLpool_(jj).length > 0		
							majorHierarchy_(jj,ii) = max(majorPSLpool_(jj).vonMisesStressList);
						end
					end
					majorHierarchy_(:,ii) = majorHierarchy_(:,ii) / max(majorHierarchy_(:,ii));
				end
				if numMinorPSLs>0
					for jj=1:numMinorPSLs
						if minorPSLpool_(jj).length > 0		
							minorHierarchy_(jj,ii) = max(minorPSLpool_(jj).vonMisesStressList);
						end
					end
					minorHierarchy_(:,ii) = minorHierarchy_(:,ii) / max(minorHierarchy_(:,ii));
				end		
			case 'PSLs Length'
				if numMajorPSLs>0
					for jj=1:numMajorPSLs
						if majorPSLpool_(jj).length > 0		
							majorHierarchy_(jj,ii) = majorPSLpool_(jj).length;
						end
					end
					majorHierarchy_(:,ii) = majorHierarchy_(:,ii) / max(majorHierarchy_(:,ii));
				end
				if numMinorPSLs>0
					for jj=1:numMinorPSLs
						if minorPSLpool_(jj).length > 0		
							minorHierarchy_(jj,ii) = minorPSLpool_(jj).length;
						end
					end
					minorHierarchy_(:,ii) = minorHierarchy_(:,ii) / max(minorHierarchy_(:,ii));
				end		
			case 'Open to 3rd Party'
				if numMajorPSLs>0, majorHierarchy_(:,ii) = 1; end
				if numMinorPSLs>0, minorHierarchy_(:,ii) = 1; end					
		end
	end
end
