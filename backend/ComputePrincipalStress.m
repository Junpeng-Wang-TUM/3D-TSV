function principalStress = ComputePrincipalStress(cartesianStress)
	%% "cartesianStress" is in the order: Sigma_xx, Sigma_yy, Sigma_zz, Sigma_yz, Sigma_zx, Sigma_xy
	principalStress = zeros(1, 12);
	A = cartesianStress([1 6 5; 6 2 4; 5 4 3]);
	[eigenVec, eigenVal] = eig(A);
	principalStress([1 5 9]) = diag(eigenVal);
	principalStress([2 3 4 6 7 8 10 11 12]) = reshape(eigenVec,1,9);
end