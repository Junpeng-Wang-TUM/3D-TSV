clc;
addpath('./src');

%% PSLs Generation
%% ======Syntax======
%% RunMission(fileName, minimumEpsilonCtrl, numLevels);
%% RunMission(fileName, minimumEpsilonCtrl, numLevels, seedStrategy, seedResCtrl, selectedPrincipalStressField, ...
%%	mergingOpt, snappingOpt, maxAngleDevi, traceAlgorithm);
tStart = tic;
%% Some Examples for Test
%% =======================================cantilever
% fileName = './data/Vis2021_cantilever3D.vtk'; 
% RunMission(fileName, 10, 3);
% RunMission(fileName, 10, 3, 'Volume', 2, ["MAJOR", "MINOR"], 1, 0, 20, 'Euler');
%% =======================================femur
fileName = './data/Vis2021_femur3D.vtk';
RunMission(fileName, 18, 1);
% RunMission(fileName, 18, 3, 'Volume', 4, ["MAJOR", "MEDIUM", "MINOR"], 1, 0, 6, 'RK2');
%% =======================================Bunny
% fileName = './data/Vis2021_bunny3D.vtk'; 
% RunMission(fileName, 26, 1); 
% RunMission(fileName, 26, 3, 'Volume', 4, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');
%% =======================================Bunny_HexMesh
% fileName = './data/vis2021_bunny3D_HexMesh.vtk'; 
% RunMission(fileName, 26, 1);
% RunMission(fileName, 26, 3, 'Volume', 2, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');
%% =======================================bridge
% fileName = './data/Vis2021_bridge3D.vtk'; 
% RunMission(fileName, 10, 3); 
% RunMission(fileName, 10, 3, 'Volume', 3, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');
%% =======================================bracket
% fileName = './data/Vis2021_bracket3D.vtk'; 
% RunMission(fileName, 18, 3); 
% RunMission(fileName, 18, 3, 'Volume', 4, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');
%% =======================================roof
% fileName = './data/Vis2021_roof3D.vtk';
% RunMission(fileName, 32, 3);
% RunMission(fileName, 32, 3, 'Volume', 2, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2'); 
%% =======================================kitten
% fileName = './data/Vis2021_kitten3D.vtk'; 
% RunMission(fileName, 15, 3);
% RunMission(fileName, 15, 1, 'Volume', 25, ["MAJOR", "MINOR", "MEDIUM"], 0, 0, 6, 'RK2'); %%fig.2 left
% RunMission(fileName, 15, 1, 'LoadingArea', 2, ["MAJOR", "MINOR", "MEDIUM"], 0, 0, 6, 'RK2'); %%fig.2 right
% RunMission(fileName, 15, 3, 'Volume', 5, ["MAJOR", "MINOR"], 1, 1, 6, 'RK2'); %%fig.X 
%% =======================================parts
% fileName = './data/Vis2021_parts3D.vtk';
% RunMission(fileName, 30, 3);
% RunMission(fileName, 30, 3, 'Volume', 5, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');

disp(['Done! It Costs: ' sprintf('%10.3g',toc(tStart)) 's']); 
%%Vis
% imOpt = ["Geo", "Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
% imVal = [1,0.5, 0.3]; %% PSLs with IM>=imVal shown
% pslGeo = ["TUBE", "TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
% stressComponentOpt = 'None'; %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
% lw = 2; %% tubeRadius = lw, ribbonWidth = 4*lw
% smoothingOpt = 1; %% smoothing ribbon or not (0)
% DrawSeedPoints();
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'Sigma', 0.5, 1, 20);