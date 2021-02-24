clc;
addpath('./src');
fileName = 'D:/MyProjects/StressField3D-PSLs-Investigator/data/Vis2021_femur3D_HexMesh.vtk';

%% PSLs Generation
%% ======Syntax======
%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, maxAngleDevi, snappingOpt, minPSLength, volumeSeedingOpt);
tic
RunMission(fileName, 'Volume', 8, 3); %% "femur" test
% RunMission(fileName, 'Volume', 3, 4, 6, 0, 20, 5); %% "bunny_hex" test
% RunMission(fileName, 'Volume', 5, 3, 6, 0, 20, 3); %% "bridge" test
disp(['Done! It Costs: ' sprintf('%10.3g',toc) 's']); 

%%Vis
% imOpt = ["Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
% imVal = [1,0.5]; %% PSLs with IM>=imVal shown
% pslGeo = ["TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
% stressComponentOpt = 'None'; %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
% lw = 2; %% tubeRadius = lw, ribbonWidth = 4*lw
% smoothingOpt = 1; %% smoothing ribbon or not (0)
% DrawSeedPoints();
DrawPSLs(["Geo", "Geo"], [0,0], ["TUBE", "TUBE"], 'None', 1.0, 1);
