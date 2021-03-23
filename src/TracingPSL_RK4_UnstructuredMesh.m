function [phyCoordList, cartesianStressList, eleIndexList, paraCoordList, vonMisesStressList, principalStressList] = ...
			TracingPSL_RK4_UnstructuredMesh(startPoint, iniDir, elementIndex, typePSL, limiSteps)
	global eNodMat_;
	global nodeCoords_;
	global cartesianStressField_;
	global tracingStepWidth_;
	siE = 1.0e-06;
	phyCoordList = zeros(limiSteps,3);
	cartesianStressList = zeros(limiSteps,6);
	eleIndexList = zeros(limiSteps,1);
	paraCoordList = [];
	vonMisesStressList = zeros(limiSteps,1);
	principalStressList = zeros(limiSteps,12);

	%%initialize initial k1, k2, k3 and k4
	k1 = iniDir;
	midPot1 = startPoint + k1*tracingStepWidth_/2;
	index = 0;
	[elementIndex2, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot1);
	if bool1
		%%k2
		NIdx2 = eNodMat_(elementIndex2,:)';
		vtxStress2 = cartesianStressField_(NIdx2, :);
		vtxCoords2 = nodeCoords_(NIdx2,:); 		
		cartesianStressOnGivenPoint2 = ElementInterpolationInverseDistanceWeighting(vtxCoords2, vtxStress2, midPot1);
		principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
		[k2, ~] = BidirectionalFeatureProcessing(k1, principalStress2(typePSL));
		midPot2 = startPoint + tracingStepWidth_*k2/2;
		%%k3
		[elementIndex3, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex2, midPot2);
		if bool1
			NIdx3 = eNodMat_(elementIndex3,:)';
			vtxStress3 = cartesianStressField_(NIdx3, :);
			vtxCoords3 = nodeCoords_(NIdx3,:); 			
			cartesianStressOnGivenPoint3 = ElementInterpolationInverseDistanceWeighting(vtxCoords3, vtxStress3, midPot2);
			principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
			[k3, ~] = BidirectionalFeatureProcessing(k1, principalStress3(typePSL));
			midPot3 = startPoint + tracingStepWidth_*k3;
			%%k4
			[elementIndex4, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex3, midPot3);
			if bool1
				NIdx4 = eNodMat_(elementIndex4,:)';
				vtxStress4 = cartesianStressField_(NIdx4, :);
				vtxCoords4 = nodeCoords_(NIdx4,:);
				cartesianStressOnGivenPoint4 = ElementInterpolationInverseDistanceWeighting(vtxCoords4, vtxStress4, midPot3);
				principalStress4 = ComputePrincipalStress(cartesianStressOnGivenPoint4);
				[k4, ~] = BidirectionalFeatureProcessing(k1, principalStress4(typePSL));
				nextPoint = startPoint + tracingStepWidth_ * (k1 + 2*k2 + 2*k3 + k4)/6;
				[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint);
				while bool1
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
					midPot1 = nextPoint + tracingStepWidth_*k1/2;
					%%k2
					[elementIndex2, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, midPot1);
					if ~bool1, index = index-1; break; end
					NIdx2 = eNodMat_(elementIndex2,:)';
					vtxStress2 = cartesianStressField_(NIdx2, :);
					vtxCoords2 = nodeCoords_(NIdx2,:); 		
					cartesianStressOnGivenPoint2 = ElementInterpolationInverseDistanceWeighting(vtxCoords2, vtxStress2, midPot1);
					principalStress2 = ComputePrincipalStress(cartesianStressOnGivenPoint2);
					[k2, ~] = BidirectionalFeatureProcessing(iniDir, principalStress2(typePSL));
					midPot2 = nextPoint + tracingStepWidth_*k2/2;
					%%k3
					[elementIndex3, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex2, midPot2);
					if ~bool1, index = index-1; break; end
					NIdx3 = eNodMat_(elementIndex3,:)';
					vtxStress3 = cartesianStressField_(NIdx3, :);
					vtxCoords3 = nodeCoords_(NIdx3,:); 		
					cartesianStressOnGivenPoint3 = ElementInterpolationInverseDistanceWeighting(vtxCoords3, vtxStress3, midPot2);
					principalStress3 = ComputePrincipalStress(cartesianStressOnGivenPoint3);
					[k3, ~] = BidirectionalFeatureProcessing(iniDir, principalStress3(typePSL));
					midPot3 = nextPoint + tracingStepWidth_*k3;	
					%%k4
					[elementIndex4, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex3, midPot3);
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
					nextPoint = nextPoint + tracingStepWidth_ * (k1 + 2*k2 + 2*k3 + k4)/6;		
					[elementIndex, bool1] = SearchNextIntegratingPointOnUnstructuredMesh(elementIndex, nextPoint);						
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
