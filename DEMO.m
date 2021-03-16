clc;
addpath('./src');

%% Space-filling PSLs Generation
%% ======Syntax======
%% RunMission(fileName); %% Easy-to-Run
%% RunMission(fileName, minimumEpsilonCtrl, numLevels);
%% RunMission(fileName, minimumEpsilonCtrl, numLevels, seedStrategy, seedResCtrl, selectedPrincipalStressField, ...
%%	mergingOpt, snappingOpt, maxAngleDevi, traceAlgorithm);

%% Some Examples for PSLs Generation
%% =======================================cantilever
% fileName = './data/Vis2021_cantilever3D.vtk'; 
% RunMission(fileName, 10, 1);
% RunMission(fileName, 10, 3, 'Volume', 4, ["MAJOR", "MINOR"], 1, 0, 20, 'Euler');
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
% RunMission(fileName, 26, 3, 'Volume', 3, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');
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
% RunMission(fileName, 15, 20, 'Volume', 30, ["MAJOR", "MINOR", "MEDIUM"], 0, 0, 20, 'RK2'); %%fig.2 left
% RunMission(fileName, 15, 1, 'LoadingArea', 2, ["MAJOR", "MINOR", "MEDIUM"], 0, 0, 6, 'RK2'); %%fig.2 right
% RunMission(fileName, 15, 3, 'Volume', 5, ["MAJOR", "MINOR"], 1, 1, 6, 'RK2'); %%fig.X 
%% =======================================parts
% fileName = './data/Vis2021_parts3D.vtk';
% RunMission(fileName, 30, 3);
% RunMission(fileName, 30, 3, 'Volume', 5, ["MAJOR", "MINOR"], 1, 0, 6, 'RK2');

%%PSLs Visualization
%% ======Syntax======
% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, smoothingOpt, minLength);
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'Sigma', 0.5, 1, 10);

%%Show Seed Points if Necessary
% DrawSeedPoints();