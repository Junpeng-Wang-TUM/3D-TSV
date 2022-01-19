function val = ComputeVonMisesStress(cartesianStress)
	%% "cartesianStress" is in the order: Sigma_xx, Sigma_yy, Sigma_zz, Sigma_yz, Sigma_zx, Sigma_xy
	val = sqrt(0.5*((cartesianStress(1)-cartesianStress(2))^2 + (cartesianStress(2)-cartesianStress(3))^2 + (cartesianStress(3)...
		-cartesianStress(1))^2) + 3*(cartesianStress(6)^2 + cartesianStress(4)^2 + cartesianStress(5)^2));						
end