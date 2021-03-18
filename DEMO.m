clc;
addpath('./src');

%% Space-filling PSLs Generation
%% ======Syntax (Example)======
%% userInterface.fileName = './data/Vis2021_femur3D.vtk';
%% userInterface.lineDensCtrl = 18;
%% userInterface.numLevels = 3;
%% userInterface.seedStrategy = 'Volume';
%% userInterface.seedDensCtrl = 4;
%% userInterface.selectedPrincipalStressField = ["MAJOR", "MINOR"];
%% userInterface.mergingOpt = 1;
%% userInterface.snappingOpt = 0;
%% userInterface.maxAngleDevi = 6;
%% userInterface.traceAlgorithm = 'RK2';
%% RunMission(userInterface);

%% Some Examples used in the paper
userInterface = InterfaceStruct();

%% =======================================cantilever=======================================
%% ---------------------------------------Experiment 1
% userInterface.fileName = './data/Vis2021_cantilever3D.vtk';
% userInterface.lineDensCtrl = 12.5;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 3;
% userInterface.maxAngleDevi = 20;
% userInterface.traceAlgorithm = 'Euler';

%% =======================================femur=======================================
userInterface.fileName = './data/Vis2021_femur3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
userInterface.lineDensCtrl = 18;
userInterface.numLevels = 1;
userInterface.traceAlgorithm = 'Euler';
%% ---------------------------------------Experiment 3: %%Teaser 1st-row
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = ["MAJOR", "MEDIUM", "MINOR"];
%% ---------------------------------------Experiment 4
% userInterface.seedStrategy = 'LoadingArea';
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = "MINOR";
% userInterface.mergingOpt = 0;
%% ---------------------------------------Experiment 5: %%Teaser 2nd-row PlanB
% userInterface.multiMergingThresholds = [2 3 1];
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 1;
% userInterface.seedDensCtrl = 4;
% userInterface.selectedPrincipalStressField = ["MAJOR", "MEDIUM", "MINOR"];

%% =======================================Bunny=======================================
% userInterface.fileName = './data/Vis2021_bunny3D.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 4;

%% =======================================Bunny_HexMesh=======================================
% userInterface.fileName = './data/Vis2021_bunny3D_HexMesh.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 3;
%% ---------------------------------------Experiment 3: %%Teaser 2nd-row
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = ["MAJOR", "MEDIUM", "MINOR"];
%% ---------------------------------------Experiment 4: %%Teaser 2nd-row Plan  B
% userInterface.multiMergingThresholds = [1 3 2];
% userInterface.lineDensCtrl = 26;
% userInterface.numLevels = 1;
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = ["MAJOR", "MEDIUM", "MINOR"];

%% =======================================Armadillo_HexMesh=======================================
% userInterface.fileName = './data/Vis2021_armadillo3D_HexMesh.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 2;

%% =======================================bridge=======================================
% userInterface.fileName = './data/Vis2021_bridge3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 10;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 10;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 3;

%% =======================================bracket=======================================
% userInterface.fileName = './data/Vis2021_bracket3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 18;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 4;

%% =======================================roof=======================================
% userInterface.fileName = './data/Vis2021_roof3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 32;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 32;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 2;

%% =======================================kitten=======================================
% userInterface.fileName = './data/Vis2021_kitten3D.vtk';
%% ---------------------------------------Experiment 1
% userInterface.lineDensCtrl = 15;
% userInterface.numLevels = 3;
%% ---------------------------------------Experiment 2: %%fig.2 left
% userInterface.seedDensCtrl = 30;
% userInterface.selectedPrincipalStressField = ["MAJOR", "MINOR", "MEDIUM"];
% userInterface.mergingOpt = 0;
% userInterface.maxAngleDevi = 20;
%% ---------------------------------------Experiment 3: %%fig.2 right
% userInterface.seedStrategy = 'LoadingArea';
% userInterface.seedDensCtrl = 2;
% userInterface.selectedPrincipalStressField = ["MAJOR", "MINOR", "MEDIUM"];
% userInterface.mergingOpt = 0;
% userInterface.maxAngleDevi = 20;
%% ---------------------------------------Experiment 4: %%fig.xx
% userInterface.lineDensCtrl = 15;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 5;
% userInterface.snappingOpt = 1;

%% =======================================parts=======================================
% userInterface.fileName = './data/Vis2021_parts3D.vtk';
%% ---------------------------------------Experiment 1
%% ---------------------------------------Experiment 2
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 1;
%% ---------------------------------------Experiment 3
% userInterface.lineDensCtrl = 30;
% userInterface.numLevels = 3;
% userInterface.seedDensCtrl = 5;

RunMission(userInterface);
%%PSLs Visualization
%% ======Syntax======
% DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, smoothingOpt, minLength);
DrawPSLs(["Geo", "Geo", "Geo"], [0,0,0], ["TUBE", "TUBE", "TUBE"], 'Sigma', 0.5, 1, 20);

%% Show if Necessary
% DrawSeedPoints();
% DrawPSLsIntersections(1);