clc;
addpath('./src');

%% Space-filling PSLs Generation
%% ======Syntax (Example)======
%% userInterface.fileName = './data/Vis2021_femur3D.vtk';
%% userInterface.lineDensCtrl = 18;
%% userInterface.numLevels = 3;
%% userInterface.seedStrategy = 'Volume';
%% userInterface.seedDensCtrl = 4;
%% userInterface.selectedPrincipalStressField = [1, 3];
%% userInterface.mergingOpt = 1;
%% userInterface.snappingOpt = 0;
%% userInterface.maxAngleDevi = 6;
%% userInterface.traceAlgorithm = 'RK2';
%% RunMission(userInterface);

%% Some Examples used in the paper
userInterface = InterfaceStruct();

%% =======================================cantilever=======================================
userInterface.fileName = './data/Vis2021_cantilever3D.vtk';
%% ---------------------------------------Experiment 1
userInterface.lineDensCtrl = 4;
userInterface.numLevels = 1;
userInterface.seedStrategy = 'Volume';
userInterface.seedDensCtrl = 8;
userInterface.selectedPrincipalStressField = [1, 3];
userInterface.mergingOpt = 1;
userInterface.snappingOpt = 0;
userInterface.maxAngleDevi = 20;
userInterface.traceAlgorithm = 'Euler';

%% =======================================femur=======================================
% userInterface.fileName = './data/Vis2021_femur3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 1;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3: %%Teaser
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = [1, 2, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 4
% userInterface.seedStrategy = 'LoadingArea';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = 3;
% userInterface.mergingOpt = 0;

%% =======================================Bunny=======================================
% userInterface.fileName = './data/Vis2021_bunny3D.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 2 (fig. x)
% userInterface.lineDensCtrl = 20;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 5;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';

%% =======================================Bunny_HexMesh=======================================
% userInterface.fileName = './data/Vis2021_bunny3D_HexMesh.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 3;
%% ---------------------------------------Experiment 3:
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 3;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 4: 
% userInterface.multiMergingThresholds = [1 3 2];
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 1;
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = [1, 2, 3];

%% =======================================bridge=======================================
% userInterface.fileName = './data/Vis2021_bridge3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 8;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 3;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 10;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 3;

%% =======================================bracket=======================================
% userInterface.fileName = './data/Vis2021_bracket3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2 (fig. x)
% userInterface.lineDensCtrl = 12;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 4;

%% =======================================roof=======================================
% userInterface.fileName = './data/Vis2021_roof3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 32;
% userInterface.numLevels = 2;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 6;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 32;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 2;

%% =======================================kitten=======================================
% userInterface.fileName = './data/Vis2021_kitten3D.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 15;
% userInterface.numLevels = 3;
%% ---------------------------------------Experiment 2: (fig.2 left)
% userInterface.lineDensCtrl = 10; %%has nothing to do with result, can be anything
% userInterface.numLevels = 1; %%has nothing to do with result, can be anything
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 30;
% userInterface.selectedPrincipalStressField = [1, 2, 3];
% userInterface.mergingOpt = 0;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3: (fig.2 right)
% userInterface.lineDensCtrl = 10; %%has nothing to do with result, can be anything
% userInterface.numLevels = 1; %%has nothing to do with result, can be anything
% userInterface.seedStrategy = 'LoadingArea';
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = [1, 2, 3];
% userInterface.mergingOpt = 0;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 4 (fig. 6)
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 5: %%fig.xx
% userInterface.lineDensCtrl = 15;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 5;
% userInterface.snappingOpt = 1;

%% =======================================kitten_HexMesh=======================================
% userInterface.fileName = './data/Vis2021_kitten3D_HexMesh.vtk';
%% ---------------------------------------Experiment 1
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
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 1;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 5;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 5;

%% =======================================femurPorousInfill=======================================
% userInterface.fileName = './data/Vis2021_femurPorousInfill3D.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 20;
% userInterface.numLevels = 3;
% userInterface.seedStrategy = 'Volume';
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = [1, 3];
% userInterface.mergingOpt = 1;
% userInterface.snappingOpt = 0;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'RK2';

RunMission(userInterface);
%%PSLs Visualization
%% ======Syntax======
% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, smoothingOpt, minLength);
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'Sigma', 0.5, 1, 20);

%% Show if Necessary
% DrawSeedPoints(0.5);
% DrawPSLsIntersections(["Geo", "Geo", "Geo"], [0,0,0], 1);