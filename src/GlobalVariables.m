%% This script declares some global variables for this program

global GPU_; GPU_ = 'OFF';
global meshType_; meshType_ = [];
global vtxLowerBound_; vtxLowerBound_ = []; 
global vtxUpperBound_; vtxUpperBound_ = [];
global nelx_; nelx_ = 0;
global nely_; nely_ = 0;
global nelz_; nelz_ = 0;
global numNodes_; numNodes_ = []; 
global nodeCoords_; nodeCoords_ = [];
global numEles_; numEles_ = []; 
global eNodMat_; eNodMat_ = [];
global eleState_; eleState_ = [];
global nodState_; nodState_ = [];
global nodStruct_; nodStruct_ = [];
global cartesianStressField_; cartesianStressField_ = [];
global nodeLoadVec_; nodeLoadVec_ = [];
global fixedNodes_; fixedNodes_ = [];	
global eleSize_; eleSize_ = [];
global silhouetteStruct_; silhouetteStruct_ = [];
global originalValidNodeIndex_; originalValidNodeIndex_ = [];
global solidElements_; solidElements_ = [];

global interceptionThreshold_; interceptionThreshold_ = 20;
global majorPSLpool_; majorPSLpool_ = [];
global minorPSLpool_; minorPSLpool_ = [];
global majorCoordList_; majorCoordList_ = [];
global minorCoordList_; minorCoordList_ = [];

global tracingStepWidth_; tracingStepWidth_ = [];
global minimumEpsilon_; minimumEpsilon_ = 0;
global numLevels_; numLevels_ = 1;
global seedPointsHistory_; seedPointsHistory_ = [];
global seedPoints_; seedPoints_ = [];
global samplingSpan_; samplingSpan_ = 0;
global mergeTrigger_; mergeTrigger_ = 0;
global relaxedFactor_; relaxedFactor_ = 1;
global snappingOpt_; snappingOpt_ = 'OFF';
global Line3Dgeometry_; 
global colorCodingOpt_; colorCodingOpt_ = 'PS'; %% 'None', 'vM', 'PS'
global FocusContextOpt_; FocusContextOpt_ = 'OFF';
global maxMergeThreshold_; maxMergeThreshold_ = 2;
global seedPointsValence_; seedPointsValence_ = [];
global minLengthVisiblePSLs_; minLengthVisiblePSLs_ = 18;

global majorHierarchy_; majorHierarchy_ = [];
global minorHierarchy_; minorHierarchy_ = [];

global handleSilhoutte_; handleSilhoutte_ = [];
global handleMajorPSLs_; handleMajorPSLs_ = [];
global handleMinorPSLs_; handleMinorPSLs_ = [];
global handleForMajorPSLedge_; handleForMajorPSLedge_ = [];
global handleForMinorPSLedge_; handleForMinorPSLedge_ = [];
global handleSeedPoints_; handleSeedPoints_ = [];
global handleLight_; handleLight_ = [];
global axHandle_; axHandle_ = [];