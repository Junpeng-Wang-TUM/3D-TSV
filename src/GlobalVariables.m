%% This script declares some global variables for this program

%% 1. Dataset info.
global dataName_; 
global GPU_; GPU_ = 'OFF';
global meshType_; 
global vtxLowerBound_; global vtxUpperBound_; 
global nelx_; global nely_; global nelz_; 
global numNodes_;
global nodeCoords_; 
global numEles_; 
global eNodMat_;
global nodState_; 
global nodStruct_; %% Adjacent Elements for each Mesh Vertex (only for Unstructured Hex-mesh) 
global cartesianStressField_; 
global nodeLoadVec_; 
global fixedNodes_; 	
global eleSize_; %% Element Size for Cartesian Mesh, or an Assumed one for Unstructured Hex-mesh
global silhouetteStruct_; %% Patches for Draw Silhoutte of Stress Field
global originalValidNodeIndex_; %% Only for Cartesian Mesh

%% 2. Algorithm Control
%% 2.1 Integrating Step Size = element Size * tracingStepWidth_
global tracingStepWidth_; 
%% 2.2 %% Tracing PSL stops when the angle deviation between the neighboring tangents is larger than 180/interceptionThreshold_
global interceptionThreshold_; interceptionThreshold_ = 20; 
%% 2.3 Store the Original Seed Points
global seedPointsHistory_; seedPointsHistory_ = [];
%% 2.4 Control Seed Point Density under 'Volume' Seeding Strategy
global seedSpan4VolumeOptCartesianMesh_; seedSpan4VolumeOptCartesianMesh_ = [];
%% 2.5 Relaxing Merge Operation via Epsilon*relaxedFactor_
global relaxedFactor_; relaxedFactor_ = 1;
%% 2.6 Snapping PSLs or not when they are too close
global snappingOpt_; snappingOpt_ = 'OFF';
%% 2.7 Excluding PSLs with less than 'minLengthVisiblePSLs_' Integrating Steps
global minLengthVisiblePSLs_; minLengthVisiblePSLs_ = 20;

%% 3. Result
global majorPSLpool_; majorPSLpool_ = PrincipalStressLineStruct();;
global minorPSLpool_; minorPSLpool_ = PrincipalStressLineStruct();;
global majorCoordList_; majorCoordList_ = [];
global minorCoordList_; minorCoordList_ = [];
global majorHierarchy_; majorHierarchy_ = [];
global minorHierarchy_; minorHierarchy_ = [];	