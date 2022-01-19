function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK4_UnstructuredMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
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
		%%initialize initial k1, k2, k3 and k4
		midPot1 = startPoint + k1*stepsize/2;	
		[elementIndex2, ~, bool2] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot1, startPoint, 0);
		if bool2
			%%k2
			NIdx2 = eNodMat_(elementIndex2,:)';
			vtxStress2 = cartesianStressField_(NIdx2, :);
			vtxCoords2 = nodeCoords_(NIdx2,:); 		
			cartesianStressOnGivenPoint2 = ElementInterpolationInverseDistanceWeighting(vtxCoords2, vtxStress2, midPot1);
			principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
			[k2, ~] = BidirectionalFeatureProcessing(k1, principalStress2(typePSL));
			midPot2 = startPoint + stepsize*k2/2;
			%%k3
			[elementIndex3, ~, bool3] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot2, startPoint, 0);
			if bool3
				NIdx3 = eNodMat_(elementIndex3,:)';
				vtxStress3 = cartesianStressField_(NIdx3, :);
				vtxCoords3 = nodeCoords_(NIdx3,:); 			
				cartesianStressOnGivenPoint3 = ElementInterpolationInverseDistanceWeighting(vtxCoords3, vtxStress3, midPot2);
				principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
				[k3, ~] = BidirectionalFeatureProcessing(k1, principalStress3(typePSL));
				midPot3 = startPoint + stepsize*k3;			
				%%k4
				[elementIndex4, ~, bool4] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot3, startPoint, 0);
				if bool4
					NIdx4 = eNodMat_(elementIndex4,:)';
					vtxStress4 = cartesianStressField_(NIdx4, :);
					vtxCoords4 = nodeCoords_(NIdx4,:);
					cartesianStressOnGivenPoint4 = ElementInterpolationInverseDistanceWeighting(vtxCoords4, vtxStress4, midPot3);
					principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
					[k4, ~] = BidirectionalFeatureProcessing(k1, principalStress4(typePSL));
					nextPoint = startPoint + stepsize * (k1 + 2*k2 + 2*k3 + k4)/6;				
					[elementIndex, ~, bool5] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint, startPoint, 0);
					while bool5
						index = index + 1; if index > limiSteps, index = index-1; break; end
						NIdx = eNodMat_(elementIndex,:)';
						vtxStress = cartesianStressField_(NIdx, :);
						vtxCoords = nodeCoords_(NIdx,:); 		
						cartesianStressOnGivenPoint = ElementInterpolationInverseDistanceWeighting(vtxCoords, vtxStress, midPot1);
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
						midPot1 = nextPoint + stepsize*k1/2;						
						[elementIndex2, ~, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot1, nextPoint, 0);
						if ~bool1, index = index-1; break; end												
						NIdx2 = eNodMat_(elementIndex2,:)';
						vtxStress2 = cartesianStressField_(NIdx2, :);
						vtxCoords2 = nodeCoords_(NIdx2,:); 		
						cartesianStressOnGivenPoint2 = ElementInterpolationInverseDistanceWeighting(vtxCoords2, vtxStress2, midPot1);
						principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
						[k2, ~] = BidirectionalFeatureProcessing(iniDir, principalStress2(typePSL));
						midPot2 = nextPoint + stepsize*k2/2;							
						%%k3
						[elementIndex3, ~, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot2, nextPoint, 0);
						if ~bool1, index = index-1; break; end								
						NIdx3 = eNodMat_(elementIndex3,:)';
						vtxStress3 = cartesianStressField_(NIdx3, :);
						vtxCoords3 = nodeCoords_(NIdx3,:); 		
						cartesianStressOnGivenPoint3 = ElementInterpolationInverseDistanceWeighting(vtxCoords3, vtxStress3, midPot2);
						principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
						[k3, ~] = BidirectionalFeatureProcessing(iniDir, principalStress3(typePSL));
						midPot3 = nextPoint + stepsize*k3;
						%%k4	
						[elementIndex4, ~, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot3, nextPoint, 0);
						if ~bool1, index = index-1; break; end													
						NIdx4 = eNodMat_(elementIndex4,:)';
						vtxStress4 = cartesianStressField_(NIdx4, :);
						vtxCoords4 = nodeCoords_(NIdx4,:); 		
						cartesianStressOnGivenPoint4 = ElementInterpolationInverseDistanceWeighting(vtxCoords4, vtxStress4, midPot3);
						principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
						[k4, ~] = BidirectionalFeatureProcessing(iniDir, principalStress4(typePSL));
						%%store	
						iniDir = k1;
						phyCoordList(index,:) = nextPoint;
						cartesianStressList(index,:) = cartesianStressOnGivenPoint;
						eleIndexList(index,:) = elementIndex;			
						vonMisesStressList(index,:) = vonMisesStress;
						principalStressList(index,:) = principalStress;
						%%next point
						nextPoint0 = nextPoint + stepsize * (k1 + 2*k2 + 2*k3 + k4)/6;
						if norm(sPoint_-nextPoint0)<stepsize, break; end
						[elementIndex, ~, bool5] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint0, nextPoint, 0);
						nextPoint = nextPoint0;					
					end
				end
			end
		end
	end
	
	phyCoordList = phyCoordList(1:index,:);
	cartesianStressList = cartesianStressList(1:index,:);
	eleIndexList = eleIndexList(1:index,:);
	vonMisesStressList = vonMisesStressList(1:index,:);
	principalStressList = principalStressList(1:index,:);	
end