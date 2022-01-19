function val = ElementInterpolationInverseDistanceWeighting(coords, vtxEntity, ips)
	%% Inverse Distance Weighting
	%% coords --> element vertex coordinates, Matrix: [N-by-3] 
	%% vtxEntity --> entities on element vertics, Matrix: [N-by-M], e.g., M = 6 for 3D stress tensor
	%% ips --> to-be interpolated coordinate, Vector: [1-by-3]
	
	e = -2;
	D = vecnorm(ips-coords,2,2);
	[sortedD, sortedMapVec] = sort(D);
    if 0==sortedD(1)
        val = vtxEntity(sortedMapVec(1),:); return;
    end
	sortedVtxVals = vtxEntity(sortedMapVec,:);
	wV = sortedD.^e;
	V = sortedVtxVals.*wV;	
	val = sum(V) / sum(wV);
end