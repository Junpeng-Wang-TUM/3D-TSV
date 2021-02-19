classdef Main_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        LeftPanel          matlab.ui.container.Panel
        TabGroup           matlab.ui.container.TabGroup
        ControlPanelTab    matlab.ui.container.Tab
        MethodPanel        matlab.ui.container.Panel
        SettingsPanel      matlab.ui.container.Panel
        InvestigationTab   matlab.ui.container.Tab
        InteractionPanel   matlab.ui.container.Panel
        PreferencePanel    matlab.ui.container.Panel
        RightPanel         matlab.ui.container.Panel
        UIAxes             matlab.ui.control.UIAxes
        FilesMenu          matlab.ui.container.Menu
        ImportDatavtkMenu  matlab.ui.container.Menu
        ExportDataMenu     matlab.ui.container.Menu
        ResetMenu          matlab.ui.container.Menu
        ClearAllMenu       matlab.ui.container.Menu
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {670, 670};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {290, '1x'};
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
            app.UIFigure.Position = [100 100 1047 670];
            app.UIFigure.Name = 'StressField3D-PSLs-Investigator v1.0';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {290, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LeftPanel);
            app.TabGroup.Position = [1 6 284 663];

            % Create ControlPanelTab
            app.ControlPanelTab = uitab(app.TabGroup);
            app.ControlPanelTab.Title = 'Control Panel';

            % Create MethodPanel
            app.MethodPanel = uipanel(app.ControlPanelTab);
            app.MethodPanel.Title = 'Method';
            app.MethodPanel.Position = [3 406 281 221];

            % Create SettingsPanel
            app.SettingsPanel = uipanel(app.ControlPanelTab);
            app.SettingsPanel.Title = 'Settings';
            app.SettingsPanel.Position = [5 173 279 221];

            % Create InvestigationTab
            app.InvestigationTab = uitab(app.TabGroup);
            app.InvestigationTab.Title = 'Investigation';

            % Create InteractionPanel
            app.InteractionPanel = uipanel(app.InvestigationTab);
            app.InteractionPanel.Title = 'Interaction';
            app.InteractionPanel.Position = [3 406 281 221];

            % Create PreferencePanel
            app.PreferencePanel = uipanel(app.InvestigationTab);
            app.PreferencePanel.Title = 'Preference';
            app.PreferencePanel.Position = [5 173 279 221];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontName = 'Times New Roman';
            app.UIAxes.FontSize = 20;
            app.UIAxes.Position = [25 6 715 647];

            % Create FilesMenu
            app.FilesMenu = uimenu(app.UIFigure);
            app.FilesMenu.Text = 'Files';

            % Create ImportDatavtkMenu
            app.ImportDatavtkMenu = uimenu(app.FilesMenu);
            app.ImportDatavtkMenu.Text = 'Import Data (.vtk)';

            % Create ExportDataMenu
            app.ExportDataMenu = uimenu(app.FilesMenu);
            app.ExportDataMenu.Text = 'Export Data';

            % Create ResetMenu
            app.ResetMenu = uimenu(app.FilesMenu);
            app.ResetMenu.Text = 'Reset';

            % Create ClearAllMenu
            app.ClearAllMenu = uimenu(app.FilesMenu);
            app.ClearAllMenu.Text = 'Clear All';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Main_exported

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