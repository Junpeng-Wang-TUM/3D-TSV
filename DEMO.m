clc;
addpath('./src');
% fileName = 'D:/MyDataSets/StressFields4LLGP/euroVis2020_case8_carGrid.vtk';

%% PSLs Generation
%% ======Syntax======
%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, maxAngleDevi, snappingOpt, minPSLength, volumeSeedingOpt);
tStart = tic;

%% Some Examples for Test
%% =======================================femur
fileName = './data/Vis2021_femur3D.vtk'; 
[opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 8, 3); 
%% =======================================Bunny_HexMesh
% fileName = './data/Vis2021_bunny3D_HexMesh.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 3, 4, 6, 0, 20, 5, 'Euler'); 
%% =======================================bridge
% fileName = './data/Vis2021_bridge3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 5, 3, 6, 0, 20, 3, 'Euler'); 

disp(['Done! It Costs: ' sprintf('%10.3g',toc(tStart)) 's']); 
%%Vis
% imOpt = ["Geo", "Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
% imVal = [1,0.5, 0.3]; %% PSLs with IM>=imVal shown
% pslGeo = ["TUBE", "TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
% stressComponentOpt = 'None'; %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
% lw = 2; %% tubeRadius = lw, ribbonWidth = 4*lw
% smoothingOpt = 1; %% smoothing ribbon or not (0)
% DrawSeedPoints();
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'Sigma', 1.0, 1);