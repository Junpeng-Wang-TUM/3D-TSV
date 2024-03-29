function [targetDirection, terminationCond] = BidirectionalFeatureProcessing(originalVec, Vec)
	global permittedMaxAdjacentTangentAngleDeviation_;
	terminationCond = 1;
	angle1 = acos(originalVec*Vec');
	angle2 = acos(-originalVec*Vec');	
	if angle1 < angle2
		targetDirection = Vec;
		if angle1 > pi/permittedMaxAdjacentTangentAngleDeviation_, terminationCond = 0; end
	else
		targetDirection = -Vec;
		if angle2 > pi/permittedMaxAdjacentTangentAngleDeviation_, terminationCond = 0; end
	end
end