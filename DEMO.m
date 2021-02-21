clc;
addpath('./src');
fileName = 'D:/MyDataSets/StressFields4LLGP/Vis2021_femur3D.vtk';

seedStrategy = 'Volume';
minimumEpsilon = 8;
numLevels = 3;

tic
RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
disp(['Done! It costs: ' sprintf('%10.3g',toc) 's']);

%%Vis
% imOpt = ["Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
% imVal = [1,0.5]; %% >=0 && <= 1
% pslGeo = ["TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
% stressComponentOpt = 'None'; %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
% lw = 2; %% tubeRadius = lw, ribbonWidth = 4*lw
% smoothingOpt = 1; %% smoothing ribbon or not (0)
VisualizePSLs(["Geo", "Geo"], [1,1], ["TUBE", "TUBE"], 'None', 1.5, 1);

