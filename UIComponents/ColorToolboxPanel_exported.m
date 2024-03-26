classdef ColorToolboxPanel_exported < matlab.apps.AppBase

	% Properties that correspond to app components
	properties (Access = public)
		ColorToolboxUIFigure           matlab.ui.Figure
		ProfileInfomationButton        matlab.ui.control.Button
		ImagePointCloudButton          matlab.ui.control.Button
		CompareTwoTRCgraphButton       matlab.ui.control.Button
		ImageDeltaEVisualizationimageButton  matlab.ui.control.Button
		InputOutputProfilemap3DButton  matlab.ui.control.Button
		ExitButton                     matlab.ui.control.Button
		CompareTwoProfiles3DButton     matlab.ui.control.Button
	end


	properties (Access = private)
		CompareTwoGamutsApp % Description
	end


	% Callbacks that handle component events
	methods (Access = private)

		% Code that executes after component creation
		function startupFcn(app)
			%% configureGPU;
		end

		% Button pushed function: ExitButton
		function ExitButtonPushed(app, event)
			% process all handles of type "Figure" and where the figure
			% Tag = "ColorToolboxTag". This is my 'magic' tag to identify
			% figures that this app has created.

			handles = findall(groot, 'type', 'Figure');
			for i = 1:length(handles)
				if((get(handles(i), 'Tag') == "ColorToolboxTag"))
					delete(handles(i));
				end
			end

			app.delete();
		end

		% Button pushed function: CompareTwoProfiles3DButton
		function CompareTwoProfiles3DButtonPushed(app, event)
			GamutCompare;
		end

		% Button pushed function: ImagePointCloudButton
		function ImagePointCloudButtonPushed(app, event)
			ImagePointCloud;
		end

		% Button pushed function: ImageDeltaEVisualizationimageButton
		function ImageDeltaEVisualizationimageButtonPushed(app, event)
			ImageDeltaE;
		end

		% Button pushed function: ProfileInfomationButton
		function ProfileInfomationButtonPushed(app, event)
			ProfileInformation(" ");
		end
	end

	% Component initialization
	methods (Access = private)

		% Create UIFigure and components
		function createComponents(app)

			% Create ColorToolboxUIFigure and hide until all components are created
			app.ColorToolboxUIFigure = uifigure('Visible', 'off');
			app.ColorToolboxUIFigure.Position = [100 100 474 299];
			app.ColorToolboxUIFigure.Name = 'ColorToolbox';

			% Create CompareTwoProfiles3DButton
			app.CompareTwoProfiles3DButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.CompareTwoProfiles3DButton.ButtonPushedFcn = createCallbackFcn(app, @CompareTwoProfiles3DButtonPushed, true);
			app.CompareTwoProfiles3DButton.Tooltip = {'Plot the gamut boundary for two selected profiles in L*a*b* 3D space'};
			app.CompareTwoProfiles3DButton.Position = [49 243 254 23];
			app.CompareTwoProfiles3DButton.Text = 'Compare Two Profiles (3D)';

			% Create ExitButton
			app.ExitButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
			app.ExitButton.Position = [327 85 100 23];
			app.ExitButton.Text = 'Exit';

			% Create InputOutputProfilemap3DButton
			app.InputOutputProfilemap3DButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.InputOutputProfilemap3DButton.Enable = 'off';
			app.InputOutputProfilemap3DButton.Position = [52 63 254 23];
			app.InputOutputProfilemap3DButton.Text = 'Input -> Output Profile map (3D)';

			% Create ImageDeltaEVisualizationimageButton
			app.ImageDeltaEVisualizationimageButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.ImageDeltaEVisualizationimageButton.ButtonPushedFcn = createCallbackFcn(app, @ImageDeltaEVisualizationimageButtonPushed, true);
			app.ImageDeltaEVisualizationimageButton.Tooltip = {'Display an image with the DeltaE2000 colormap against a target profile'};
			app.ImageDeltaEVisualizationimageButton.Position = [49 209 254 23];
			app.ImageDeltaEVisualizationimageButton.Text = 'Image DeltaE Visualization (image)';

			% Create CompareTwoTRCgraphButton
			app.CompareTwoTRCgraphButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.CompareTwoTRCgraphButton.Enable = 'off';
			app.CompareTwoTRCgraphButton.Position = [51 33 254 23];
			app.CompareTwoTRCgraphButton.Text = 'Compare Two TRC (graph)';

			% Create ImagePointCloudButton
			app.ImagePointCloudButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.ImagePointCloudButton.ButtonPushedFcn = createCallbackFcn(app, @ImagePointCloudButtonPushed, true);
			app.ImagePointCloudButton.Tooltip = {'Image color point cloud against a target profile gamut volume in L*a*b* 3D space'};
			app.ImagePointCloudButton.Position = [49 178 254 23];
			app.ImagePointCloudButton.Text = 'Image Point Cloud';

			% Create ProfileInfomationButton
			app.ProfileInfomationButton = uibutton(app.ColorToolboxUIFigure, 'push');
			app.ProfileInfomationButton.ButtonPushedFcn = createCallbackFcn(app, @ProfileInfomationButtonPushed, true);
			app.ProfileInfomationButton.Position = [50 150 253 23];
			app.ProfileInfomationButton.Text = 'Profile Infomation';

			% Show the figure after all components are created
			app.ColorToolboxUIFigure.Visible = 'on';
		end
	end

	% App creation and deletion
	methods (Access = public)

		% Construct app
		function app = ColorToolboxPanel_exported

			runningApp = getRunningApp(app);

			% Check for running singleton app
			if isempty(runningApp)

				% Create UIFigure and components
				createComponents(app)

				% Register the app with App Designer
				registerApp(app, app.ColorToolboxUIFigure)

				% Execute the startup function
				runStartupFcn(app, @startupFcn)
			else

				% Focus the running singleton app
				figure(runningApp.ColorToolboxUIFigure)

				app = runningApp;
			end

			if nargout == 0
				clear app
			end
		end

		% Code that executes before app deletion
		function delete(app)

			% Delete UIFigure when app is deleted
			delete(app.ColorToolboxUIFigure)
		end
	end
end