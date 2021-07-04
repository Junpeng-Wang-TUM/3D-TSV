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
%% ---------------------------------------Experiment 1: (fig.2 bottom new)
userInterface.fileName = './data/Vis2021_cantilever3D.vtk';
userInterface.lineDensCtrl = 5; %% or 5
userInterface.numLevels = 1;
userInterface.seedStrategy = 'Volume';
userInterface.seedDensCtrl = 5; %% or 5
userInterface.selectedPrincipalStressField = [1, 3];
userInterface.mergingOpt = 1;
userInterface.snappingOpt = 0;
userInterface.maxAngleDevi = 20;
userInterface.traceAlgorithm = 'Euler';


%% Some Examples used in the paper
%% =======================================cantilever=======================================
% userInterface.fileName = './data/Vis2021_cantilever3D.vtk';
% userInterface.lineDensCtrl = 4; %% or 5
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 8; %% or 5
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'Euler';


%% =======================================arched_bridge=======================================
%% ---------------------------------------Experiment 1: (fig.2 bottom new)
% userInterface.fileName = './data/new_arched_bridge_R256.vtk';
% userInterface.lineDensCtrl = 6; %% or 4 or 6
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'LoadingArea';
% userInterface.seedDensCtrl = 8; %%or 2 or 2
% userInterface.selectedPrincipalStressField = [3];
% userInterface.mergingOpt = 0;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20; %% or 30
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 2: (fig.2 top new and fig. 5)
% userInterface.fileName = './data/new_arched_bridge_R256.vtk';
% userInterface.lineDensCtrl = 6; %% or 4 or 6
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 2; %%or 2 or 2
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20; %% or 30
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3: (fig.6 new and fig.9)
% userInterface.fileName = './data/new_arched_bridge_R256.vtk';
% userInterface.lineDensCtrl = 13; %% or 4 or 6
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 2; %%or 2 or 2
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6; %% or 30
% userInterface.traceAlgorithm = 'RK2';


%% =======================================Chamfer=======================================
% userInterface.fileName = './data/new_Chamfer_L0.vtk';
% userInterface.lineDensCtrl = 8;
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 5;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';


%% =======================================asm001=======================================
% userInterface.fileName = './data/new_asm001.vtk';
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
% userInterface.fileName = './data/Vis2021_femur3D.vtk';
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
% userInterface.fileName = './data/Vis2021_bunny3D_HexMesh.vtk';
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
% userInterface.fileName = './data/Vis2021_bracket3D.vtk';
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
% userInterface.fileName = './data/Vis2021_kitten3D_HexMesh.vtk';
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
% userInterface.fileName = './data/Vis2021_parts3D.vtk';
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
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'None', 0.5, 1, 10);

%% Show if Necessary
% DrawSeedPoints(0.5);
% DrawPSLsIntersections(["Geo", "Geo", "Geo"], [0,0,0], 1);