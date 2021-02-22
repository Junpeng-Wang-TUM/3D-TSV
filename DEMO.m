clc;
addpath('./src');
fileName = 'D:/MyDataSets/StressFields4LLGP/Vis2021_femur3D.vtk';

seedStrategy = 'Volume'; %% 'Volume', 'Surface', 'LoadingArea', 'ApproxTopology'
minimumEpsilon = 8;
numLevels = 3;

tic
RunMission(fileName, seedStrategy, minimumEpsilon, numLevels);
disp(['Done! It costs: ' sprintf('%10.3g',toc) 's']);

%%Vis
% imOpt = ["Geo", "Geo"]; %% 'Geo', 'PS', 'vM', 'Length'
% imVal = [1,0.5]; %% PSLs with IM>=imVal shown
% pslGeo = ["TUBE", "TUBE"]; %% 'TUBE', 'RIBBON'
% stressComponentOpt = 'None'; %% 'None', 'Sigma', 'Sigma_xx', 'Sigma_yy', 'Sigma_zz', 'Sigma_yz', 'Sigma_zx', 'Sigma_xy', 'Sigma_vM'
% lw = 2; %% tubeRadius = lw, ribbonWidth = 4*lw
% smoothingOpt = 1; %% smoothing ribbon or not (0)
% DrawSeedPoints();
DrawPSLs(["Geo", "Geo"], [0,0], ["TUBE", "TUBE"], 'None', 1.5, 1);

% global majorHierarchy_; global minorHierarchy_;
% figure; 
% plot(majorHierarchy_(:,1), '-', 'LineWidth', 2); hold on
% plot(majorHierarchy_(:,2), '-r', 'LineWidth', 2); hold on
% plot(majorHierarchy_(:,3), '-g', 'LineWidth', 2); hold on
% plot(majorHierarchy_(:,4), '-k', 'LineWidth', 2); hold on
% xlabel('Major PSLs'); ylabel('Importance Metric');
% legend('Geo-based', 'PS-based', 'vM-based', 'Length-based');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);	

% figure; 
% plot(minorHierarchy_(:,1), '-', 'LineWidth', 2); hold on
% plot(minorHierarchy_(:,2), '-r', 'LineWidth', 2); hold on
% plot(minorHierarchy_(:,3), '-g', 'LineWidth', 2); hold on
% plot(minorHierarchy_(:,4), '-k', 'LineWidth', 2); hold on
% xlabel('Minor PSLs'); ylabel('Importance Metric');
% legend('Geo-based', 'PS-based', 'vM-based', 'Length-based');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);

% global majorHierarchy_; global minorHierarchy_;
% figure; 
% plot(majorHierarchy_(:,1), '-r', 'LineWidth', 2); hold on
% plot(minorHierarchy_(:,1), '--b', 'LineWidth', 2); hold on
% xlabel('PSLs'); ylabel('Geo-based Importance Metric');
% legend('Major PSLs', 'Minor PSLs');
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);