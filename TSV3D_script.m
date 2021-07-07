%% 3D-TSV
%% The 3D Trajectory-based Stress Visualizer (3D-TSV), a visual analysis tool for the exploration 
%% of the principal stress directions in 3D solids under load.
%% This repository was created for the paper "The 3D Trajectory-based Stress Visualizer" 
%% 	by Junpeng Wang, Christoph Neuhauser, Jun Wu, Xifeng Gao and Rüdiger Westermann, 
%% which was submitted to IEEE VIS 2021.

clc;
addpath('./src');
global MATLAB_GUI_opt_; MATLAB_GUI_opt_ = 0;
userInterface = InterfaceStruct();

%% Uncomment one of the experiments below to run the 3D-TSV, please be sure to relate the correct directory of data set

%% Some Examples used in the paper
%% =======================================cantilever=======================================
userInterface.fileName = './data/cantilever3D_stressField.vtk';
userInterface.lineDensCtrl = 5; 
userInterface.numLevels = 1;
userInterface.seedStrategy = 'Volume';
userInterface.seedDensCtrl = 5; 
userInterface.selectedPrincipalStressField = [1, 3];
userInterface.mergingOpt = 1;
userInterface.snappingOpt = 0;
userInterface.maxAngleDevi = 20;
userInterface.traceAlgorithm = 'Euler';


%% =======================================arched_bridge=======================================
%% ---------------------------------------Experiment 1: (fig. 5)
% userInterface.fileName = './data/arched_bridge3D_stressField.vtk';
% userInterface.lineDensCtrl = 6; 
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 2; 
% userInterface.selectedPrincipalStressField = [1, 2, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20; 
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 2: (new fig.6 and fig.9 )
% userInterface.fileName = './data/arched_bridge3D_stressField.vtk';
% userInterface.lineDensCtrl = 12; 
% userInterface.numLevels = 2;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 2; 
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20; 
% userInterface.traceAlgorithm = 'RK2';


%% =======================================chamfer=======================================
% userInterface.fileName = './data/chamfer_stressField.vtk';
% userInterface.lineDensCtrl = 8;
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 5;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================rod=======================================
% userInterface.fileName = './data/rod3D_stressField.vtk';
% userInterface.lineDensCtrl = 5;
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 3;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================femur=======================================
% userInterface.fileName = './data/femur3D_stressField.vtk';
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = [1, 2, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 10;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================Bunny_HexMesh=======================================
% userInterface.fileName = './data/bunny3D_HexMesh_stressField.vtk';
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 3;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================bracket=======================================
% userInterface.fileName = './data/bracket3D_stressField.vtk';
% userInterface.lineDensCtrl = 12;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================kitten_HexMesh=======================================
% userInterface.fileName = './data/kitten3D_HexMesh_stressField.vtk';
% userInterface.lineDensCtrl = 20;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 1;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================parts=======================================
% userInterface.fileName = './data/parts3D_stressField.vtk';
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 5;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';


RunMission(userInterface);
% RunMission_evenlySpacedSeeding(userInterface);
%%PSLs Visualization
%% ======Syntax======
% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, smoothingOpt, minLength);
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'None', 0.5, 1, 20);

%% Show if Necessary
% DrawSeedPoints(0.5);
% DrawPSLsIntersections(["Geo", "Geo", "Geo"], [0,0,0], 1);