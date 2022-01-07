function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK2_UnstructuredMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	global sPoint_;
	siE = 1.0e-06;
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);	
	
	index = 0;
	k1 = iniDir;
	%%re-scale stepsize if necessary
	stepsize = tracingStepWidth_(elementIndex);
	testPot = startPoint + k1*tracingStepWidth_(elementIndex);
	[~, testPot1, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, testPot, startPoint, 1);
	if bool1
		stepsize = norm(testPot1-startPoint)/norm(testPot-startPoint) * stepsize;
		%%initialize initial k1 and k2
		midPot = startPoint + k1*stepsize/2;
		[elementIndex2, ~, bool2] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot, startPoint, 0);
		if bool2 %%just in case
			NIdx = eNodMat_(elementIndex2,:)';
			vtxStress = cartesianStressField_(NIdx, :);
			vtxCoords = nodeCoords_(NIdx,:);
			cartesianStressOnGivenPoint = ElementInterpolationInverseDistanceWeighting(vtxCoords, vtxStress, midPot);
			principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
			[k2, ~] = BidirectionalFeatureProcessing(k1, principalStress(typePSL));
			nextPoint = startPoint + stepsize*k2;
			[elementIndex, ~, bool3] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint, startPoint, 0);
			while bool3
				index = index + 1; if index > limiSteps, index = index-1; break; end
				NIdx = eNodMat_(elementIndex,:)';
				vtxStress = cartesianStressField_(NIdx, :);
				vtxCoords = nodeCoords_(NIdx,:); 
				cartesianStressOnGivenPoint = ElementInterpolationInverseDistanceWeighting(vtxCoords, vtxStress, nextPoint); 
				vonMisesStress = ComputeVonMisesStress(cartesianStressOnGivenPoint);
				principalStress = ComputePrincipalStress(cartesianStressOnGivenPoint);
				evs = principalStress([1 5 9]);
				if min([abs((evs(1)-evs(2))/2/(evs(1)+evs(2))) abs((evs(3)-evs(2))/2/(evs(3)+evs(2)))])<siE, index = index-1; break; end %%degenerate point	
				%%k1
				[k1, terminationCond] = BidirectionalFeatureProcessing(iniDir, principalStress(typePSL));	
				if ~terminationCond, index = index-1; break; end
				%%k2
				%%re-scale stepsize if necessary
				stepsize = tracingStepWidth_(elementIndex);
				testPot = nextPoint + k1*stepsize;
				[~, testPot1, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, testPot, nextPoint, 1);			
				if ~bool1, index = index-1; break; end
				stepsize = norm(testPot1-nextPoint)/norm(testPot-nextPoint) * stepsize;
				midPot = nextPoint + k1*stepsize/2;
				[elementIndex2, ~, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot, nextPoint, 0);					
				if ~bool1, index = index-1; break; end	
				NIdx2 = eNodMat_(elementIndex2,:)';	
				vtxStress2 = cartesianStressField_(NIdx2,:);
				vtxCoords2 = nodeCoords_(NIdx2,:);
				cartesianStressOnGivenPoint2 = ElementInterpolationInverseDistanceWeighting(vtxCoords2, vtxStress2, midPot);
				principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
				[k2, ~] = BidirectionalFeatureProcessing(k1, principalStress2(typePSL));					
				%%store	
				iniDir = k1;
				phyCoordList(index,:) = nextPoint;
				cartesianStressList(index,:) = cartesianStressOnGivenPoint;
				eleIndexList(index,:) = elementIndex;
				vonMisesStressList(index,:) = vonMisesStress;
				principalStressList(index,:) = principalStress;
				%%next point
				nextPoint0 = nextPoint + stepsize*k2;
				if norm(sPoint_-nextPoint0)<stepsize, break; end
				[elementIndex, ~, bool3] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint0, nextPoint, 0);			
				nextPoint = nextPoint0;				
			end
		end
	end
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end