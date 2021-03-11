clc;
addpath('./src');

%% PSLs Generation
%% ======Syntax======
%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
%% RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, maxAngleDevi, snappingOpt, minPSLength, volumeSeedingOpt, tracingAlg);
tStart = tic;

%% Some Examples for Test
%% =======================================cantilever
% fileName = './data/Vis2021_cantilever3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 4, 3, 20, 0, 5, 2, 'RK2');
% DrawPSLs(["Geo", "Geo"], [1,1], ["RIBBON", "RIBBON"], 'Sigma', 0.75, 1); colorbar off; 
%% view(4.94e+01,2.31e+01); view(-7.65e+01, 1.08e+01);
%% =======================================femur
fileName = './data/Vis2021_femur3D.vtk'; 
[opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 5, 3, 6, 0, 20, 3, 'RK2'); 
%% =======================================Bunny
% fileName = './data/Vis2021_bunny3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 6, 3, 6, 0, 30, 4, 'RK2'); 
%% =======================================Bunny_HexMesh
% fileName = './data/Vis2021_bunny3D_HexMesh.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 3, 3, 6, 0, 20, 5, 'RK2'); 
%% =======================================bridge
% fileName = './data/Vis2021_bridge3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 4, 3, 6, 0, 20, 3, 'RK2'); 
%% =======================================bracket
% fileName = './data/Vis2021_bracket3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 4, 3, 6, 0, 20, 4, 'RK2');
%% =======================================roof
% fileName = './data/Vis2021_roof3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 2, 3, 6, 0, 10, 2, 'RK2');
% % DrawPSLs(["vM", "vM"], [0.1,0.1], ["TUBE", "TUBE"], 'Sigma', 0.5, 1); colorbar off;
%% =======================================kitten
% fileName = './data/Vis2021_kitten3D.vtk'; 
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 5, 3, 6, 0, 20, 4, 'RK2');
% DrawPSLs(["Geo", "Geo"], [0.5,0], ["RIBBON", "TUBE"], 'Sigma', 0.75, 1); colorbar off;
% view(-5.32e+00,3.77e+00);
%% =======================================parts
% fileName = './data/Vis2021_parts3D.vtk';
% [opt, pslDataNameOutput] = RunMission(fileName, 'Volume', 6, 3, 10, 0, 20, 5, 'RK2');

disp(['Done! It Costs: ' sprintf('%10.3g',toc(tStart)) 's']); 
%%Vis
% imOpt = ["Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
% imVal = [1,0.5]; %% PSLs with IM>=imVal shown
% pslGeo = ["TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
% stressComponentOpt = 'None'; %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
% lw = 2; %% tubeRadius = lw, ribbonWidth = 4*lw
% smoothingOpt = 1; %% smoothing ribbon or not (0)
% DrawSeedPoints();
DrawPSLs(["Geo", "Geo"], [0,0], ["TUBE", "TUBE"], 'Sigma', 0.5, 1); colorbar off;