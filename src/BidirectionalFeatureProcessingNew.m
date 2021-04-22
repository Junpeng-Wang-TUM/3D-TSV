function [targetDirection, terminationCond] = BidirectionalFeatureProcessingNew(originalVec, Vecs)
	global permittedMaxAdjacentTangentAngleDeviation_;
	angList = acos(Vecs*originalVec');
	[minAng, minAngPos] = min(angList);
	targetDirection = Vecs(minAngPos,:);
	if minAng < pi/permittedMaxAdjacentTangentAngleDeviation_
		terminationCond = 1;
	else
		terminationCond = 0;
	end
end