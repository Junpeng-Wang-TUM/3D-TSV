classdef TSV3D_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        LineDensityCtrlEditFieldLabel   matlab.ui.control.Label
        LineDensityCtrlEditField        matlab.ui.control.EditField
        NumLevelsEditFieldLabel         matlab.ui.control.Label
        NumLevelsEditField              matlab.ui.control.EditField
        SubmitButton                    matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        SettingsTab                     matlab.ui.container.Tab
        SnappingCheckBox                matlab.ui.control.CheckBox
        MergingCheckBox                 matlab.ui.control.CheckBox
        MinorCheckBox                   matlab.ui.control.CheckBox
        MediumCheckBox                  matlab.ui.control.CheckBox
        MajorCheckBox                   matlab.ui.control.CheckBox
        SeedingStrategyDropDown         matlab.ui.control.DropDown
        SeedingStrategyDropDownLabel    matlab.ui.control.Label
        SeedDensityCtrlEditField        matlab.ui.control.EditField
        SeedDensityCtrlLabel            matlab.ui.control.Label
        PermittedMaxTangentDeviEditFieldLabel  matlab.ui.control.Label
        PermittedMaxTangentDeviEditField  matlab.ui.control.NumericEditField
        IntegratingSchemeDropDownLabel  matlab.ui.control.Label
        IntegratingSchemeDropDown       matlab.ui.control.DropDown
        MergingThresholdScalingFacMajorEditFieldLabel  matlab.ui.control.Label
        MergingThresholdScalingFacMajorEditField  matlab.ui.control.NumericEditField
        MergingThresholdScalingFacMediumEditFieldLabel  matlab.ui.control.Label
        MergingThresholdScalingFacMediumEditField  matlab.ui.control.NumericEditField
        MergingThresholdScalingFacMinorEditFieldLabel  matlab.ui.control.Label
        MergingThresholdScalingFacMinorEditField  matlab.ui.control.NumericEditField
        PSLGeometryScalingFacEditFieldLabel  matlab.ui.control.Label
        PSLGeometryScalingFacEditField  matlab.ui.control.NumericEditField
        PermittedMinLengthofVisiblePSLEditFieldLabel  matlab.ui.control.Label
        PermittedMinLengthofVisiblePSLEditField  matlab.ui.control.NumericEditField
        InteractionsTab                 matlab.ui.container.Tab
        MajorLoDsDropDownLabel          matlab.ui.control.Label
        MajorLoDsDropDown               matlab.ui.control.DropDown
        MajorPSLGeometryDropDownLabel   matlab.ui.control.Label
        MajorPSLGeometryDropDown        matlab.ui.control.DropDown
        MajorResCtrlSliderLabel         matlab.ui.control.Label
        MajorResCtrlSlider              matlab.ui.control.Slider
        MediumResCtrlSliderLabel        matlab.ui.control.Label
        MediumResCtrlSlider             matlab.ui.control.Slider
        MediumLoDsDropDownLabel         matlab.ui.control.Label
        MediumLoDsDropDown              matlab.ui.control.DropDown
        MediumPSLGeometryDropDownLabel  matlab.ui.control.Label
        MediumPSLGeometryDropDown       matlab.ui.control.DropDown
        MinorResCtrlSliderLabel         matlab.ui.control.Label
        MinorResCtrlSlider              matlab.ui.control.Slider
        MinorLoDsDropDownLabel          matlab.ui.control.Label
        MinorLoDsDropDown               matlab.ui.control.DropDown
        MinorPSLGeometryDropDownLabel   matlab.ui.control.Label
        MinorPSLGeometryDropDown        matlab.ui.control.DropDown
        ColoringDropDownLabel           matlab.ui.control.Label
        ColoringDropDown                matlab.ui.control.DropDown
        LightingDropDownLabel           matlab.ui.control.Label
        LightingDropDown                matlab.ui.control.DropDown
        SmoothingRibbonCheckBox         matlab.ui.control.CheckBox
        RightPanel                      matlab.ui.container.Panel
        UIAxes                          matlab.ui.control.UIAxes
        FilesMenu                       matlab.ui.container.Menu
        ImportStressFieldvtkMenu        matlab.ui.container.Menu
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: ImportStressFieldvtkMenu
        function ImportStressFieldvtkMenuSelected(app, event)
            addpath('./src');
            global MATLAB_GUI_opt_; MATLAB_GUI_opt_ = 1;
            global axHandle_; axHandle_ = app.UIAxes;
            global userInterface_;
            [fileName, dataPath] = uigetfile('.vtk', 'Select a Stress Field File to Open');
            if isnumeric(fileName) || isnumeric(dataPath), return; end
            userInterface_ = InterfaceStruct();
            userInterface_.fileName = strcat(dataPath,fileName);
        end

        % Button pushed function: SubmitButton
        function SubmitButtonPushed(app, event)
            global userInterface_;
            global handleSilhoutte_;
            global handleGraphicPSLsPrimitives_;
            global handleLights_; handleLights_ = [];
            if ~strcmp(app.LineDensityCtrlEditField.Value, 'Default')
                userInterface_.lineDensCtrl = str2double(app.LineDensityCtrlEditField.Value);
            end
            if ~strcmp(app.NumLevelsEditField.Value, 'Default')
                userInterface_.numLevels = str2double(app.NumLevelsEditField.Value);
            end
            userInterface_.seedStrategy = app.SeedingStrategyDropDown.Value;
            if ~strcmp(app.SeedDensityCtrlEditField.Value, 'Default')
                userInterface_.seedDensCtrl = str2double(app.SeedDensityCtrlEditField.Value);
            end
            userInterface_.selectedPrincipalStressField = [];
            if app.MajorCheckBox.Value
                userInterface_.selectedPrincipalStressField(1,end+1) = 1;
            end
            if app.MediumCheckBox.Value
                userInterface_.selectedPrincipalStressField(1,end+1) = 2;
            end            
            if app.MinorCheckBox.Value
                userInterface_.selectedPrincipalStressField(1,end+1) = 3;
            end
            if isempty(userInterface_.selectedPrincipalStressField)
                error('There is no Principal Stress Field Selected!');
            end
            userInterface_.mergingOpt = app.MergingCheckBox.Value;
            userInterface_.snappingOpt = app.SnappingCheckBox.Value;
            userInterface_.maxAngleDevi = app.PermittedMaxTangentDeviEditField.Value;
            userInterface_.multiMergingThresholds(1) = [app.MergingThresholdScalingFacMajorEditField.Value];
            userInterface_.multiMergingThresholds(2) = [app.MergingThresholdScalingFacMediumEditField.Value];
            userInterface_.multiMergingThresholds(3) = [app.MergingThresholdScalingFacMinorEditField.Value];
            switch app.IntegratingSchemeDropDown.Value
                case 'Euler'
                    userInterface_.traceAlgorithm = 'Euler';
                case 'Runge-Kutta (2)'
                    userInterface_.traceAlgorithm = 'RK2';
                case 'Runge-Kutta (4)'
                    userInterface_.traceAlgorithm = 'RK4';
            end
            RunMission(userInterface_);
            handleGraphicPSLsPrimitives_ = [];
            cla(app.UIAxes);
            colorbar(app.UIAxes, 'off');
            handleSilhoutte_ = DrawSilhouette(app.UIAxes);
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);
            LightingDropDownValueChanged(app, event);
        end

        % Value changed function: LightingDropDown
        function LightingDropDownValueChanged(app, event)
            global handleLights_;
            value = app.LightingDropDown.Value;          
            if ~isempty(handleLights_)
                set(handleLights_, 'visible', 'off'); handleLights_ = [];
            end
            switch value
                case 'Left'
                    handleLights_ = camlight(app.UIAxes, 'left','infinite');	
                case 'Right'
                    handleLights_ = camlight(app.UIAxes, 'right','infinite');
                case 'Top'
                    handleLights_ = camlight(app.UIAxes, 'headlight','infinite');
                case 'All'
                    handleLights_(1) = camlight(app.UIAxes, 'left','infinite');
                    handleLights_(2) = camlight(app.UIAxes, 'right','infinite');
                    handleLights_(3) = camlight(app.UIAxes, 'headlight','infinite');
            end
        end

        % Value changed function: MajorLoDsDropDown
        function MajorLoDsDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);          
        end

        % Value changed function: MajorPSLGeometryDropDown
        function MajorPSLGeometryDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);               
        end

        % Value changed function: MajorResCtrlSlider
        function MajorResCtrlSliderValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);
            LightingDropDownValueChanged(app, event);              
        end

        % Value changed function: MediumLoDsDropDown
        function MediumLoDsDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);             
        end

        % Value changed function: MediumPSLGeometryDropDown
        function MediumPSLGeometryDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);             
        end

        % Value changed function: MediumResCtrlSlider
        function MediumResCtrlSliderValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);               
        end

        % Value changed function: MinorLoDsDropDown
        function MinorLoDsDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);            
        end

        % Value changed function: MinorPSLGeometryDropDown
        function MinorPSLGeometryDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);                
        end

        % Value changed function: MinorResCtrlSlider
        function MinorResCtrlSliderValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);               
        end

        % Value changed function: ColoringDropDown
        function ColoringDropDownValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            if strcmp(stressComponentOpt, 'None'), colorbar(app.UIAxes, 'off'); end
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);               
        end

        % Value changed function: SmoothingRibbonCheckBox
        function SmoothingRibbonCheckBoxValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);              
        end

        % Value changed function: PSLGeometryScalingFacEditField
        function PSLGeometryScalingFacEditFieldValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);            
        end

        % Value changed function: 
        % PermittedMinLengthofVisiblePSLEditField
        function PermittedMinLengthofVisiblePSLEditFieldValueChanged(app, event)
            global handleGraphicPSLsPrimitives_;
            [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(app);
            handleGraphicPSLsPrimitives_ = DrawPSLs(imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength, app.UIAxes);           
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {738, 738};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {332, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1148 738];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {332, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create LineDensityCtrlEditFieldLabel
            app.LineDensityCtrlEditFieldLabel = uilabel(app.LeftPanel);
            app.LineDensityCtrlEditFieldLabel.HorizontalAlignment = 'right';
            app.LineDensityCtrlEditFieldLabel.Position = [12 690 97 22];
            app.LineDensityCtrlEditFieldLabel.Text = 'Line Density Ctrl.';

            % Create LineDensityCtrlEditField
            app.LineDensityCtrlEditField = uieditfield(app.LeftPanel, 'text');
            app.LineDensityCtrlEditField.Position = [124 690 100 22];
            app.LineDensityCtrlEditField.Value = 'Default';

            % Create NumLevelsEditFieldLabel
            app.NumLevelsEditFieldLabel = uilabel(app.LeftPanel);
            app.NumLevelsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumLevelsEditFieldLabel.Position = [37 649 72 22];
            app.NumLevelsEditFieldLabel.Text = 'Num. Levels';

            % Create NumLevelsEditField
            app.NumLevelsEditField = uieditfield(app.LeftPanel, 'text');
            app.NumLevelsEditField.Position = [124 649 100 22];
            app.NumLevelsEditField.Value = 'Default';

            % Create SubmitButton
            app.SubmitButton = uibutton(app.LeftPanel, 'push');
            app.SubmitButton.ButtonPushedFcn = createCallbackFcn(app, @SubmitButtonPushed, true);
            app.SubmitButton.Position = [124 606 100 22];
            app.SubmitButton.Text = 'Submit';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LeftPanel);
            app.TabGroup.Position = [6 7 320 576];

            % Create SettingsTab
            app.SettingsTab = uitab(app.TabGroup);
            app.SettingsTab.Title = 'Settings';

            % Create SnappingCheckBox
            app.SnappingCheckBox = uicheckbox(app.SettingsTab);
            app.SnappingCheckBox.Text = 'Snapping';
            app.SnappingCheckBox.Position = [224 387 73 22];

            % Create MergingCheckBox
            app.MergingCheckBox = uicheckbox(app.SettingsTab);
            app.MergingCheckBox.Text = 'Merging';
            app.MergingCheckBox.Position = [27 387 65 22];
            app.MergingCheckBox.Value = true;

            % Create MinorCheckBox
            app.MinorCheckBox = uicheckbox(app.SettingsTab);
            app.MinorCheckBox.Text = 'Minor';
            app.MinorCheckBox.Position = [254 516 52 22];
            app.MinorCheckBox.Value = true;

            % Create MediumCheckBox
            app.MediumCheckBox = uicheckbox(app.SettingsTab);
            app.MediumCheckBox.Text = 'Medium';
            app.MediumCheckBox.Position = [132 516 65 22];

            % Create MajorCheckBox
            app.MajorCheckBox = uicheckbox(app.SettingsTab);
            app.MajorCheckBox.Text = 'Major';
            app.MajorCheckBox.Position = [23 516 52 22];
            app.MajorCheckBox.Value = true;

            % Create SeedingStrategyDropDown
            app.SeedingStrategyDropDown = uidropdown(app.SettingsTab);
            app.SeedingStrategyDropDown.Items = {'Volume', 'Surface', 'Loading Area', 'Fixed Area'};
            app.SeedingStrategyDropDown.Position = [157 474 134 22];
            app.SeedingStrategyDropDown.Value = 'Volume';

            % Create SeedingStrategyDropDownLabel
            app.SeedingStrategyDropDownLabel = uilabel(app.SettingsTab);
            app.SeedingStrategyDropDownLabel.HorizontalAlignment = 'right';
            app.SeedingStrategyDropDownLabel.Position = [44 474 98 22];
            app.SeedingStrategyDropDownLabel.Text = 'Seeding Strategy';

            % Create SeedDensityCtrlEditField
            app.SeedDensityCtrlEditField = uieditfield(app.SettingsTab, 'text');
            app.SeedDensityCtrlEditField.Position = [191 429 100 22];
            app.SeedDensityCtrlEditField.Value = 'Default';

            % Create SeedDensityCtrlLabel
            app.SeedDensityCtrlLabel = uilabel(app.SettingsTab);
            app.SeedDensityCtrlLabel.HorizontalAlignment = 'right';
            app.SeedDensityCtrlLabel.Position = [74 429 102 22];
            app.SeedDensityCtrlLabel.Text = 'Seed Density Ctrl.';

            % Create PermittedMaxTangentDeviEditFieldLabel
            app.PermittedMaxTangentDeviEditFieldLabel = uilabel(app.SettingsTab);
            app.PermittedMaxTangentDeviEditFieldLabel.HorizontalAlignment = 'right';
            app.PermittedMaxTangentDeviEditFieldLabel.Position = [87 297 163 22];
            app.PermittedMaxTangentDeviEditFieldLabel.Text = 'Permitted Max. Tangent Devi.';

            % Create PermittedMaxTangentDeviEditField
            app.PermittedMaxTangentDeviEditField = uieditfield(app.SettingsTab, 'numeric');
            app.PermittedMaxTangentDeviEditField.Position = [262 297 40 22];
            app.PermittedMaxTangentDeviEditField.Value = 6;

            % Create IntegratingSchemeDropDownLabel
            app.IntegratingSchemeDropDownLabel = uilabel(app.SettingsTab);
            app.IntegratingSchemeDropDownLabel.HorizontalAlignment = 'right';
            app.IntegratingSchemeDropDownLabel.Position = [12 347 110 22];
            app.IntegratingSchemeDropDownLabel.Text = 'Integrating Scheme';

            % Create IntegratingSchemeDropDown
            app.IntegratingSchemeDropDown = uidropdown(app.SettingsTab);
            app.IntegratingSchemeDropDown.Items = {'Euler', 'Runge-Kutta (2)', 'Runge-Kutta (4)'};
            app.IntegratingSchemeDropDown.Position = [137 347 158 22];
            app.IntegratingSchemeDropDown.Value = 'Runge-Kutta (2)';

            % Create MergingThresholdScalingFacMajorEditFieldLabel
            app.MergingThresholdScalingFacMajorEditFieldLabel = uilabel(app.SettingsTab);
            app.MergingThresholdScalingFacMajorEditFieldLabel.HorizontalAlignment = 'right';
            app.MergingThresholdScalingFacMajorEditFieldLabel.Position = [26 257 225 22];
            app.MergingThresholdScalingFacMajorEditFieldLabel.Text = 'Merging Threshold Scaling. Fac. (Major) ';

            % Create MergingThresholdScalingFacMajorEditField
            app.MergingThresholdScalingFacMajorEditField = uieditfield(app.SettingsTab, 'numeric');
            app.MergingThresholdScalingFacMajorEditField.Position = [263 257 40 22];
            app.MergingThresholdScalingFacMajorEditField.Value = 1;

            % Create MergingThresholdScalingFacMediumEditFieldLabel
            app.MergingThresholdScalingFacMediumEditFieldLabel = uilabel(app.SettingsTab);
            app.MergingThresholdScalingFacMediumEditFieldLabel.HorizontalAlignment = 'right';
            app.MergingThresholdScalingFacMediumEditFieldLabel.Position = [12 215 238 22];
            app.MergingThresholdScalingFacMediumEditFieldLabel.Text = 'Merging Threshold Scaling. Fac. (Medium) ';

            % Create MergingThresholdScalingFacMediumEditField
            app.MergingThresholdScalingFacMediumEditField = uieditfield(app.SettingsTab, 'numeric');
            app.MergingThresholdScalingFacMediumEditField.Position = [262 215 40 22];
            app.MergingThresholdScalingFacMediumEditField.Value = 1;

            % Create MergingThresholdScalingFacMinorEditFieldLabel
            app.MergingThresholdScalingFacMinorEditFieldLabel = uilabel(app.SettingsTab);
            app.MergingThresholdScalingFacMinorEditFieldLabel.HorizontalAlignment = 'right';
            app.MergingThresholdScalingFacMinorEditFieldLabel.Position = [26 174 225 22];
            app.MergingThresholdScalingFacMinorEditFieldLabel.Text = 'Merging Threshold Scaling. Fac. (Minor) ';

            % Create MergingThresholdScalingFacMinorEditField
            app.MergingThresholdScalingFacMinorEditField = uieditfield(app.SettingsTab, 'numeric');
            app.MergingThresholdScalingFacMinorEditField.Position = [263 174 40 22];
            app.MergingThresholdScalingFacMinorEditField.Value = 1;

            % Create PSLGeometryScalingFacEditFieldLabel
            app.PSLGeometryScalingFacEditFieldLabel = uilabel(app.SettingsTab);
            app.PSLGeometryScalingFacEditFieldLabel.HorizontalAlignment = 'right';
            app.PSLGeometryScalingFacEditFieldLabel.Position = [95 133 157 22];
            app.PSLGeometryScalingFacEditFieldLabel.Text = 'PSL Geometry Scaling. Fac.';

            % Create PSLGeometryScalingFacEditField
            app.PSLGeometryScalingFacEditField = uieditfield(app.SettingsTab, 'numeric');
            app.PSLGeometryScalingFacEditField.ValueChangedFcn = createCallbackFcn(app, @PSLGeometryScalingFacEditFieldValueChanged, true);
            app.PSLGeometryScalingFacEditField.Position = [264 133 40 22];
            app.PSLGeometryScalingFacEditField.Value = 0.5;

            % Create PermittedMinLengthofVisiblePSLEditFieldLabel
            app.PermittedMinLengthofVisiblePSLEditFieldLabel = uilabel(app.SettingsTab);
            app.PermittedMinLengthofVisiblePSLEditFieldLabel.HorizontalAlignment = 'right';
            app.PermittedMinLengthofVisiblePSLEditFieldLabel.Position = [48 92 202 22];
            app.PermittedMinLengthofVisiblePSLEditFieldLabel.Text = 'Permitted Min. Length of Visible PSL';

            % Create PermittedMinLengthofVisiblePSLEditField
            app.PermittedMinLengthofVisiblePSLEditField = uieditfield(app.SettingsTab, 'numeric');
            app.PermittedMinLengthofVisiblePSLEditField.ValueChangedFcn = createCallbackFcn(app, @PermittedMinLengthofVisiblePSLEditFieldValueChanged, true);
            app.PermittedMinLengthofVisiblePSLEditField.Position = [262 92 40 22];
            app.PermittedMinLengthofVisiblePSLEditField.Value = 20;

            % Create InteractionsTab
            app.InteractionsTab = uitab(app.TabGroup);
            app.InteractionsTab.Title = 'Interactions';

            % Create MajorLoDsDropDownLabel
            app.MajorLoDsDropDownLabel = uilabel(app.InteractionsTab);
            app.MajorLoDsDropDownLabel.HorizontalAlignment = 'right';
            app.MajorLoDsDropDownLabel.Position = [92 516 67 22];
            app.MajorLoDsDropDownLabel.Text = 'Major LoDs';

            % Create MajorLoDsDropDown
            app.MajorLoDsDropDown = uidropdown(app.InteractionsTab);
            app.MajorLoDsDropDown.Items = {'Geo', 'PS', 'vM', 'Length'};
            app.MajorLoDsDropDown.ValueChangedFcn = createCallbackFcn(app, @MajorLoDsDropDownValueChanged, true);
            app.MajorLoDsDropDown.Position = [174 516 115 22];
            app.MajorLoDsDropDown.Value = 'Geo';

            % Create MajorPSLGeometryDropDownLabel
            app.MajorPSLGeometryDropDownLabel = uilabel(app.InteractionsTab);
            app.MajorPSLGeometryDropDownLabel.HorizontalAlignment = 'right';
            app.MajorPSLGeometryDropDownLabel.Position = [91 482 118 22];
            app.MajorPSLGeometryDropDownLabel.Text = 'Major PSL Geometry';

            % Create MajorPSLGeometryDropDown
            app.MajorPSLGeometryDropDown = uidropdown(app.InteractionsTab);
            app.MajorPSLGeometryDropDown.Items = {'TUBE', 'RIBBON'};
            app.MajorPSLGeometryDropDown.ValueChangedFcn = createCallbackFcn(app, @MajorPSLGeometryDropDownValueChanged, true);
            app.MajorPSLGeometryDropDown.Position = [224 482 65 22];
            app.MajorPSLGeometryDropDown.Value = 'TUBE';

            % Create MajorResCtrlSliderLabel
            app.MajorResCtrlSliderLabel = uilabel(app.InteractionsTab);
            app.MajorResCtrlSliderLabel.HorizontalAlignment = 'right';
            app.MajorResCtrlSliderLabel.Position = [18 449 86 22];
            app.MajorResCtrlSliderLabel.Text = 'Major Res. Ctrl';

            % Create MajorResCtrlSlider
            app.MajorResCtrlSlider = uislider(app.InteractionsTab);
            app.MajorResCtrlSlider.Limits = [0 1.2];
            app.MajorResCtrlSlider.ValueChangedFcn = createCallbackFcn(app, @MajorResCtrlSliderValueChanged, true);
            app.MajorResCtrlSlider.Position = [125 458 158 3];

            % Create MediumResCtrlSliderLabel
            app.MediumResCtrlSliderLabel = uilabel(app.InteractionsTab);
            app.MediumResCtrlSliderLabel.HorizontalAlignment = 'right';
            app.MediumResCtrlSliderLabel.Position = [7 308 98 22];
            app.MediumResCtrlSliderLabel.Text = 'Medium Res. Ctrl';

            % Create MediumResCtrlSlider
            app.MediumResCtrlSlider = uislider(app.InteractionsTab);
            app.MediumResCtrlSlider.Limits = [0 1.2];
            app.MediumResCtrlSlider.ValueChangedFcn = createCallbackFcn(app, @MediumResCtrlSliderValueChanged, true);
            app.MediumResCtrlSlider.Position = [126 317 157 3];

            % Create MediumLoDsDropDownLabel
            app.MediumLoDsDropDownLabel = uilabel(app.InteractionsTab);
            app.MediumLoDsDropDownLabel.HorizontalAlignment = 'right';
            app.MediumLoDsDropDownLabel.Position = [79 377 80 22];
            app.MediumLoDsDropDownLabel.Text = 'Medium LoDs';

            % Create MediumLoDsDropDown
            app.MediumLoDsDropDown = uidropdown(app.InteractionsTab);
            app.MediumLoDsDropDown.Items = {'Geo', 'PS', 'vM', 'Length'};
            app.MediumLoDsDropDown.ValueChangedFcn = createCallbackFcn(app, @MediumLoDsDropDownValueChanged, true);
            app.MediumLoDsDropDown.Position = [174 377 115 22];
            app.MediumLoDsDropDown.Value = 'Geo';

            % Create MediumPSLGeometryDropDownLabel
            app.MediumPSLGeometryDropDownLabel = uilabel(app.InteractionsTab);
            app.MediumPSLGeometryDropDownLabel.HorizontalAlignment = 'right';
            app.MediumPSLGeometryDropDownLabel.Position = [78 338 130 22];
            app.MediumPSLGeometryDropDownLabel.Text = 'Medium PSL Geometry';

            % Create MediumPSLGeometryDropDown
            app.MediumPSLGeometryDropDown = uidropdown(app.InteractionsTab);
            app.MediumPSLGeometryDropDown.Items = {'TUBE', 'RIBBON'};
            app.MediumPSLGeometryDropDown.ValueChangedFcn = createCallbackFcn(app, @MediumPSLGeometryDropDownValueChanged, true);
            app.MediumPSLGeometryDropDown.Position = [223 338 65 22];
            app.MediumPSLGeometryDropDown.Value = 'TUBE';

            % Create MinorResCtrlSliderLabel
            app.MinorResCtrlSliderLabel = uilabel(app.InteractionsTab);
            app.MinorResCtrlSliderLabel.HorizontalAlignment = 'right';
            app.MinorResCtrlSliderLabel.Position = [17 163 86 22];
            app.MinorResCtrlSliderLabel.Text = 'Minor Res. Ctrl';

            % Create MinorResCtrlSlider
            app.MinorResCtrlSlider = uislider(app.InteractionsTab);
            app.MinorResCtrlSlider.Limits = [0 1.2];
            app.MinorResCtrlSlider.ValueChangedFcn = createCallbackFcn(app, @MinorResCtrlSliderValueChanged, true);
            app.MinorResCtrlSlider.Position = [124 172 158 3];

            % Create MinorLoDsDropDownLabel
            app.MinorLoDsDropDownLabel = uilabel(app.InteractionsTab);
            app.MinorLoDsDropDownLabel.HorizontalAlignment = 'right';
            app.MinorLoDsDropDownLabel.Position = [87 236 67 22];
            app.MinorLoDsDropDownLabel.Text = 'Minor LoDs';

            % Create MinorLoDsDropDown
            app.MinorLoDsDropDown = uidropdown(app.InteractionsTab);
            app.MinorLoDsDropDown.Items = {'Geo', 'PS', 'vM', 'Length'};
            app.MinorLoDsDropDown.ValueChangedFcn = createCallbackFcn(app, @MinorLoDsDropDownValueChanged, true);
            app.MinorLoDsDropDown.Position = [169 236 115 22];
            app.MinorLoDsDropDown.Value = 'Geo';

            % Create MinorPSLGeometryDropDownLabel
            app.MinorPSLGeometryDropDownLabel = uilabel(app.InteractionsTab);
            app.MinorPSLGeometryDropDownLabel.HorizontalAlignment = 'right';
            app.MinorPSLGeometryDropDownLabel.Position = [85 195 118 22];
            app.MinorPSLGeometryDropDownLabel.Text = 'Minor PSL Geometry';

            % Create MinorPSLGeometryDropDown
            app.MinorPSLGeometryDropDown = uidropdown(app.InteractionsTab);
            app.MinorPSLGeometryDropDown.Items = {'TUBE', 'RIBBON'};
            app.MinorPSLGeometryDropDown.ValueChangedFcn = createCallbackFcn(app, @MinorPSLGeometryDropDownValueChanged, true);
            app.MinorPSLGeometryDropDown.Position = [218 195 65 22];
            app.MinorPSLGeometryDropDown.Value = 'TUBE';

            % Create ColoringDropDownLabel
            app.ColoringDropDownLabel = uilabel(app.InteractionsTab);
            app.ColoringDropDownLabel.HorizontalAlignment = 'right';
            app.ColoringDropDownLabel.Position = [74 92 50 22];
            app.ColoringDropDownLabel.Text = 'Coloring';

            % Create ColoringDropDown
            app.ColoringDropDown = uidropdown(app.InteractionsTab);
            app.ColoringDropDown.Items = {'None', 'Principal Stress', 'Mises Stress', 'Normal Stress (xx)', 'Normal Stress (yy)', 'Normal Stress (zz)', 'Shear Stress (yz)', 'Shear Stress (zx)', 'Shear Stress (xy)'};
            app.ColoringDropDown.ValueChangedFcn = createCallbackFcn(app, @ColoringDropDownValueChanged, true);
            app.ColoringDropDown.Position = [139 92 152 22];
            app.ColoringDropDown.Value = 'None';

            % Create LightingDropDownLabel
            app.LightingDropDownLabel = uilabel(app.InteractionsTab);
            app.LightingDropDownLabel.HorizontalAlignment = 'right';
            app.LightingDropDownLabel.Position = [127 52 48 22];
            app.LightingDropDownLabel.Text = 'Lighting';

            % Create LightingDropDown
            app.LightingDropDown = uidropdown(app.InteractionsTab);
            app.LightingDropDown.Items = {'None', 'Left', 'Right', 'Top', 'All'};
            app.LightingDropDown.ValueChangedFcn = createCallbackFcn(app, @LightingDropDownValueChanged, true);
            app.LightingDropDown.Position = [190 52 100 22];
            app.LightingDropDown.Value = 'Top';

            % Create SmoothingRibbonCheckBox
            app.SmoothingRibbonCheckBox = uicheckbox(app.InteractionsTab);
            app.SmoothingRibbonCheckBox.ValueChangedFcn = createCallbackFcn(app, @SmoothingRibbonCheckBoxValueChanged, true);
            app.SmoothingRibbonCheckBox.Text = 'Smoothing Ribbon';
            app.SmoothingRibbonCheckBox.Position = [167 16 121 22];
            app.SmoothingRibbonCheckBox.Value = true;

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.View = [-37.5 30];
            app.UIAxes.Projection = 'perspective';
            app.UIAxes.FontName = 'Times New Roman';
            app.UIAxes.FontSize = 20;
            app.UIAxes.Position = [7 14 785 685];

            % Create FilesMenu
            app.FilesMenu = uimenu(app.UIFigure);
            app.FilesMenu.Text = 'Files';

            % Create ImportStressFieldvtkMenu
            app.ImportStressFieldvtkMenu = uimenu(app.FilesMenu);
            app.ImportStressFieldvtkMenu.MenuSelectedFcn = createCallbackFcn(app, @ImportStressFieldvtkMenuSelected, true);
            app.ImportStressFieldvtkMenu.Text = 'Import Stress Field (.vtk)';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = TSV3D_GUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end