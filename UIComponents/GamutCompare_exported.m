classdef GamutCompare_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        GamutCompareUIFigure          matlab.ui.Figure
        Switch                        matlab.ui.control.Switch
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout17                  matlab.ui.container.GridLayout
        Profile2Volume                matlab.ui.control.Label
        Profile2VolumeLabel           matlab.ui.control.Label
        Profile1Volume                matlab.ui.control.Label
        Profile1VolumeLabel           matlab.ui.control.Label
        GridLayout16                  matlab.ui.container.GridLayout
        RenderButton                  matlab.ui.control.Button
        ExitButton                    matlab.ui.control.Button
        Profile1GridLayout            matlab.ui.container.GridLayout
        GridLayout13                  matlab.ui.container.GridLayout
        profile1InfoButton            matlab.ui.control.Button
        ResetProfile1Button           matlab.ui.control.Button
        profile1Button                matlab.ui.control.Button
        Profile1WhiteBlackPointsGridLayout  matlab.ui.container.GridLayout
        GridLayout20                  matlab.ui.container.GridLayout
        Profile1BlackPointLabel       matlab.ui.control.Label
        GridLayout18                  matlab.ui.container.GridLayout
        Profile1WhitePointLabel       matlab.ui.control.Label
        GridLayout9                   matlab.ui.container.GridLayout
        Profile1BlackPointLstar       matlab.ui.control.Label
        Profile1BlackPointastar       matlab.ui.control.Label
        Profile1BlackPointbstar       matlab.ui.control.Label
        GridLayout14                  matlab.ui.container.GridLayout
        Profile1WhitePointLstar       matlab.ui.control.Label
        Profile1WhitePointastar       matlab.ui.control.Label
        Profile1WhitePointbstar       matlab.ui.control.Label
        MonitorProfileGridLayout      matlab.ui.container.GridLayout
        GridLayout23                  matlab.ui.container.GridLayout
        monitorProfileInfoButton      matlab.ui.control.Button
        GridLayout22                  matlab.ui.container.GridLayout
        MonitorProfileButton          matlab.ui.control.Button
        ViewManagementGridLayout      matlab.ui.container.GridLayout
        aStarRightButton              matlab.ui.control.Button
        aStarLeftButton               matlab.ui.control.Button
        bStarLeftButton               matlab.ui.control.Button
        bStarRightButton              matlab.ui.control.Button
        viewBottomUpButton            matlab.ui.control.Button
        ProfileViewButtonGroup        matlab.ui.container.ButtonGroup
        Profile2Button                matlab.ui.control.RadioButton
        Profile1Button                matlab.ui.control.RadioButton
        Profile2monitorButton         matlab.ui.control.RadioButton
        Profile1monitorButton         matlab.ui.control.RadioButton
        viewOrthogonalButton          matlab.ui.control.Button
        viewTopDownButton             matlab.ui.control.Button
        wiresatLabel                  matlab.ui.control.Label
        SaturationSlider              matlab.ui.control.Slider
        referenceImageDisplay         matlab.ui.control.Image
        BPCDropDown                   matlab.ui.control.DropDown
        BPCDropDownLabel              matlab.ui.control.Label
        Profile2GridLayout            matlab.ui.container.GridLayout
        GridLayout11                  matlab.ui.container.GridLayout
        profile2InfoButton            matlab.ui.control.Button
        ResetProfile2Button           matlab.ui.control.Button
        profile2Button                matlab.ui.control.Button
        GridLayout10                  matlab.ui.container.GridLayout
        GridLayout21                  matlab.ui.container.GridLayout
        Profile2BlackPointLabel       matlab.ui.control.Label
        GridLayout19                  matlab.ui.container.GridLayout
        Profile2WhitePointLabel       matlab.ui.control.Label
        Profile2BlackPointGridLayout  matlab.ui.container.GridLayout
        Profile2BlackPointLstar       matlab.ui.control.Label
        Profile2BlackPointastar       matlab.ui.control.Label
        Profile2BlackPointbstar       matlab.ui.control.Label
        Profile2WhitePointGridLayout  matlab.ui.container.GridLayout
        Profile2WhitePointLstar       matlab.ui.control.Label
        Profile2WhitePointastar       matlab.ui.control.Label
        Profile2WhitePointbstar       matlab.ui.control.Label
        UIAxes                        matlab.ui.control.UIAxes
    end

    properties (Access = private)
        graphicsRoot    % handle to the graphics root: information about this machine
        monitorProfilePath  % ICC Monitor profile path
        monitorProfile  % The monitor profile
        monitorProfileFlag % flag for the existence of the monitor profile. This is a hack
        profile1Path    % ICC Profile 1 path
        profile2Path    % ICC Profile 2 path
        profile1        % ICC Profile 1 struct
        profile2        % ICC Profile 2 struct
        profile1WhitePoint
        profile2WhitePoint
        referenceTarget    % the synthetic HSL image for input to gamut displays
        referenceTargetDimension = 64;
        referenceTargetSaturation = 1.0;
        profile1Surface    % the surface plot for profile 1
        profile2Surface    % the surface plot for profile 2
        rotateFigure = false       % flag for figure rotation
        renderingIntents = ["AbsoluteColorimetric"
            "Perceptual"
            "RelativeColorimetric"
            "Saturation"]
        MonitorWhitePoint % White Point of the monitor
        profile1BlackPoint % Description
        profile2BlackPoint
        monitorBlackPoint
        LmaxP1 = 0;
        amaxP1 = 0;
        bmaxP1 = 0;
        LmaxP2 = 0;
        amaxP2 = 0;
        bmaxP2 = 0;
    end
    methods (Access = private)

        function keepFocus(app)
            figure(app.GamutCompareUIFigure);    % matlab keeps loosing focus - this is the fix.
        end


        function [blackPoint, whitePoint] = getMediaBlackandWhitePoints(~, profile)
            %getMediaBlackandWhitePoints: returns the black and white
            %points of a supplied profile. Will default to (0,0,0) and
            %(100,100,100) if any errors.
            try profile.MediaWhitePoint
                whitePoint = xyz2lab(profile.MediaWhitePoint);
            catch
                whitePoint = [100,100,100];    % default
            end
            try profile.MediaBlackPoint
                blackPoint = xyz2lab(profile.MediaBlackPoint);
            catch
                blackPoint = [0,0,0];    % default. MediaBlackPoint not required in V2 or reported to be unreliable
            end
        end

        function vol = calculateVolume(~, target)
            [~, V] = convhull(target(:,:,1), target(:,:,2), target(:,:,3));
            vol = V;
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            clc;
            app.graphicsRoot = groot;
            movegui(app.GamutCompareUIFigure, "center");
            app.referenceTarget = generateReferenceGamut(app.referenceTargetDimension, app.referenceTargetSaturation);
            app.referenceImageDisplay.ImageSource = gather(app.referenceTarget);
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
            app.delete();
        end

        % Button pushed function: profile1Button
        function profile1ButtonPushed(app, event)
            [fn, pn] = uigetfile({'*.icc;*.icm'},'Select first profile (wireframe).', iccroot);
            if isequal(fn,0)
                app.ResetProfile1Button.Enable = "off";
            else
                app.profile1Path = [pn fn];
                try
                    app.profile1 = iccread(app.profile1Path);
                    if app.profile1.Header.ColorSpace ~= "RGB"
                        % we only handle RGB images no CMYB
                        msgbox("Cannot handle CMYG profiles.");
                        app.ResetProfile1Button;
                        app.keepFocus;
                        return;
                    end
                    app.profile1Button.Text = strcat(app.profile1.Description.String, " (wire)");
                    app.keepFocus;
                    % adjust ui elements to reflect that we now have a profile1
                    app.profile1InfoButton.Enable = "on";
                    app.ResetProfile1Button.Enable = "on";

                    % populate the media white/black point information
                    app.Profile1WhitePointLstar.Text = num2str(app.profile1.MediaWhitePoint(1));
                    app.Profile1WhitePointastar.Text = num2str(app.profile1.MediaWhitePoint(2));
                    app.Profile1WhitePointbstar.Text = num2str(app.profile1.MediaWhitePoint(3));
                    app.Profile1WhitePointLabel.Text =  "WP " + WhitePointToText(app.profile1.MediaWhitePoint(1), app.profile1.MediaWhitePoint(2), app.profile1.MediaWhitePoint(3), "XYZ");

                    % blackpoints are not guaranteed to be present so check and
                    % markup label if not present.
                    if isfield(app.profile1, 'MediaBlackPoint')
                        app.Profile1BlackPointLstar.Text = num2str(app.profile1.MediaBlackPoint(1));
                        app.Profile1BlackPointastar.Text = num2str(app.profile1.MediaBlackPoint(2));
                        app.Profile1BlackPointbstar.Text = num2str(app.profile1.MediaBlackPoint(3));
                        app.Profile1BlackPointLabel.Text = "BP";
                    else
                        app.Profile1BlackPointLabel.Text = "BP absent";
                    end
                catch ME
                    disp(["error reading profile: ", ME.message]);
                end

            end
        end

        % Button pushed function: profile2Button
        function profile2ButtonPushed(app, event)
            [fn, pn] = uigetfile({'*.icc;*.icm'},'Select second profile (solid).', iccroot);
            if isequal(fn,0)
                app.ResetProfile2Button.Enable = "off";
            else
                app.profile2Path = [pn fn];
                try
                    app.profile2 = iccread(app.profile2Path);
                    if app.profile2.Header.ColorSpace ~= "RGB"
                        % we only handle RGB images no CMYB
                        msgbox("Cannot handle CMYG profiles.");
                        app.ResetProfile1Button;
                        app.keepFocus;
                        return;
                    end
                    app.profile2Button.Text = strcat(app.profile2.Description.String, " (solid)");
                    app.keepFocus;
                    % adjust ui elements to reflect that we now have a profile1
                    app.profile2InfoButton.Enable = "on";
                    app.ResetProfile2Button.Enable = "on";
                    % populate the media white/black point information
                    app.Profile2WhitePointLstar.Text = num2str(app.profile2.MediaWhitePoint(1));
                    app.Profile2WhitePointastar.Text = num2str(app.profile2.MediaWhitePoint(2));
                    app.Profile2WhitePointbstar.Text = num2str(app.profile2.MediaWhitePoint(3));
                    app.Profile2WhitePointLabel.Text =  "WP " + WhitePointToText(app.profile2.MediaWhitePoint(1), app.profile2.MediaWhitePoint(2), app.profile1.MediaWhitePoint(3), "XYZ");

                    % blackpoints are not guaranteed to be present so check and
                    % markup label if not present.
                    if isfield(app.profile1, 'MediaBlackPoint')
                        app.Profile2BlackPointLstar.Text = num2str(app.profile2.MediaBlackPoint(1));
                        app.Profile2BlackPointastar.Text = num2str(app.profile2.MediaBlackPoint(2));
                        app.Profile2BlackPointbstar.Text = num2str(app.profile2.MediaBlackPoint(3));
                        app.Profile2BlackPointLabel.Text = "BP";
                    else
                        app.Profile1BlackPointLabel.Text = "BP absent";
                    end

                catch ME
                    disp(["error reading profile: ", ME.message]);
                end

            end
        end

        % Button pushed function: MonitorProfileButton
        function MonitorProfileButtonPushed(app, event)
            % Get the monitor profile.
            % I would like this to be automatic.
            [fn, pn] = uigetfile({'*.icc;*.icm'},'Select the monitor profile.', iccroot);
            if isequal(fn,0)
                app.monitorProfileFlag = false;
            else
                app.monitorProfilePath = [pn fn];
                try
                    app.monitorProfile = iccread(app.monitorProfilePath);
                    if app.monitorProfile.Header.DeviceClass ~= "display"
                        % monitor profile needs to be a display - duh.
                        waitfor(msgbox("Monitor profile needs to be of display class."));
                        % app.keepFocus;
                        return;
                    end
                    app.monitorProfileFlag = true;
                    app.MonitorProfileButton.Text = app.monitorProfile.Description.String;
                    app.keepFocus;
                    app.monitorProfileInfoButton.Enable = 'on';
                catch ME
                    disp(["error reading profile: ", ME.message]);
                end
            end
        end

        % Button pushed function: RenderButton
        function RenderButtonPushed(app, event)
            cla(app.UIAxes, "reset");

            if ~isicc(app.profile1) && ~isicc(app.profile2)
                % we don't have any profiles, so just sit there (return).
                % we will render if there is one.
                return;
            end

            % profile 1
            if isicc(app.profile1)
                is_clut = false;
                is_mattrc = false;
                try
                    % AToB3 device->PCS, Absolute Colorimetric
                    C1 = makecform("clut", app.profile1,"AToB3");
                catch
                end
                try
                    C1 = makecform("mattrc", app.profile1, Direction="forward", RenderingIntent="AbsoluteColorimetric");
                catch
                end

                target1 = applycform(app.referenceTarget,C1);
                clear C1;
                switch app.profile1.Header.ConnectionSpace
                    case "XYZ"
                        target1 = xyz2lab(target1);
                    case "Lab"
                    otherwise
                        disp(["unknown pcs ... " pcs]);
                end
                % get max and min for grid extents
                app.LmaxP1 = max(max(target1(:,:,1)));
                app.amaxP1 = max(max(target1(:,:,2)));
                app.bmaxP1 = max(max(target1(:,:,3)));

                app.profile1Surface = surf(app.UIAxes, target1(:,:,2), target1(:,:,3), target1(:,:,1), ...
                    app.referenceTarget, FaceColor='none', EdgeColor='flat', EdgeAlpha=0.5);
                hold(app.UIAxes, "on");
                app.Profile1Volume.Text = num2str(app.calculateVolume(target1));
            end
            % profile 2
            if isicc(app.profile2)
                try
                     % AToB3 device->PCS, Absolute Colorimetric
                    C2 = makecform("clut", app.profile2,"AToB3");
                catch
                end
                try
                    C2 = makecform("mattrc", app.profile2, Direction="forward", RenderingIntent="AbsoluteColorimetric");
                catch
                end
                target2 = applycform(app.referenceTarget,C2);
                switch app.profile2.Header.ConnectionSpace
                    case "XYZ"
                        target2 = xyz2lab(target2);
                    case "Lab"
                    otherwise
                        disp(["unknown pcs ... " pcs]);
                end
                % get max and min for grid extents
                app.LmaxP2 = max(max(target2(:,:,1)));
                app.amaxP2 = max(max(target2(:,:,2)));
                app.bmaxP2 = max(max(target2(:,:,3)));

                app.profile2Surface = surf(app.UIAxes, target2(:,:,2), target2(:,:,3), target2(:,:,1), ...
                    app.referenceTarget, ...
                    FaceColor='flat', EdgeColor='none', FaceLighting='gouraud', FaceAlpha=0.5);
                clear C2;
                app.Profile2Volume.Text = num2str(app.calculateVolume(target2));
            end

            % just to be clear mapping Lab to XYZL (I keep forgetting)
            %    a = X axes
            %    L = Y axes
            %    b = Z axes
            app.UIAxes.Color = [0.8,0.8,0.8];
            xlabel(app.UIAxes, "a*");
            ylabel(app.UIAxes, "b*");
            zlabel(app.UIAxes, "L*");
            rotate3d(app.UIAxes, 'on');
            axis(app.UIAxes, "vis3d");
            grid(app.UIAxes, "on");

            % add 20% to the boundary for some 'comfort' in the view
            abMax = max([app.amaxP1, app.amaxP2, app.bmaxP1, app.bmaxP2])*1.2;
            Lm = max(app.LmaxP1, app.LmaxP2)*1.1;
            % if Lm < 100
            % 	Lm = 100;
            % end
            % app.UIAxes.XLim = [-abMax, abMax];
            % app.UIAxes.ZLim = [0, Lm];
            % app.UIAxes.YLim = [-abMax, abMax];
            app.UIAxes.Clipping = "off";
        end

        % Button pushed function: ResetProfile1Button
        function ResetProfile1ButtonPushed(app, event)
            app.profile1 = [];    % clear does not seem to work
            app.profile1Button.Text = "profile 1 (wireframe)";
            app.ResetProfile1Button.Enable = "off";
            app.profile1InfoButton.Enable = "off";
            app.Profile1Volume.Text = "0.0";
            delete(app.profile1Surface);
        end

        % Button pushed function: ResetProfile2Button
        function ResetProfile2ButtonPushed(app, event)
            app.profile2 = [];    % clear does not seem to work
            app.profile2Button.Text = "profile 2 (solid)";
            app.ResetProfile2Button.Enable = "off";
            app.profile2InfoButton.Enable = "off";
            app.Profile2Volume.Text = "0.0";
            delete(app.profile2Surface);
        end

        % Value changed function: SaturationSlider
        function SaturationSliderValueChanged(app, event)
            app.referenceTargetSaturation = app.SaturationSlider.Value;
            app.referenceTarget = generateReferenceGamut(app.referenceTargetDimension, app.referenceTargetSaturation);
            app.referenceImageDisplay.ImageSource = app.referenceTarget;
        end

        % Button pushed function: viewTopDownButton
        function viewTopDownButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, 2);
            rotate3d(app.UIAxes, 'on');
        end

        % Button pushed function: viewOrthogonalButton
        function viewOrthogonalButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, 3);
            rotate3d(app.UIAxes, 'on');
        end

        % Button pushed function: viewBottomUpButton
        function viewBottomUpButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, [0,-90]);
            rotate3d(app.UIAxes, 'on');
        end

        % Button pushed function: profile1InfoButton
        function profile1InfoButtonPushed(app, event)
            ProfileInformation(app.profile1, app.profile1Path);
        end

        % Button pushed function: profile2InfoButton
        function profile2InfoButtonPushed(app, event)
            ProfileInformation(app.profile2, app.profile2Path);
        end

        % Button pushed function: monitorProfileInfoButton
        function monitorProfileInfoButtonPushed(app, event)
            ProfileInformation(app.monitorProfile, app.monitorProfilePath);
        end

        % Button pushed function: aStarLeftButton
        function aStarLeftButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, [0,0]);
            rotate3d(app.UIAxes, 'on');
        end

        % Button pushed function: bStarLeftButton
        function bStarLeftButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, [90 ,0]);
            rotate3d(app.UIAxes, 'on');
        end

        % Button pushed function: aStarRightButton
        function aStarRightButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, [180,0]);
            rotate3d(app.UIAxes, 'on');
        end

        % Button pushed function: bStarRightButton
        function bStarRightButtonPushed(app, event)
            rotate3d(app.UIAxes, 'off');
            view(app.UIAxes, [-90 ,0]);
            rotate3d(app.UIAxes, 'on');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create GamutCompareUIFigure and hide until all components are created
            app.GamutCompareUIFigure = uifigure('Visible', 'off');
            app.GamutCompareUIFigure.Position = [500 500 950 832];
            app.GamutCompareUIFigure.Name = 'GamutCompare';
            app.GamutCompareUIFigure.Icon = '3dGamut.gif';
            app.GamutCompareUIFigure.Tag = 'ColorToolboxTag';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.GamutCompareUIFigure);
            app.GridLayout.ColumnWidth = {'2x', 'fit'};
            app.GridLayout.RowHeight = {'2x', '0.3x', '0.3x', '0.3x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Compare Two Profiles')
            app.UIAxes.XLim = [0 1];
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create Profile2GridLayout
            app.Profile2GridLayout = uigridlayout(app.GridLayout);
            app.Profile2GridLayout.ColumnWidth = {'2x'};
            app.Profile2GridLayout.RowSpacing = 1;
            app.Profile2GridLayout.Padding = [1 1 1 1];
            app.Profile2GridLayout.Layout.Row = 3;
            app.Profile2GridLayout.Layout.Column = 1;

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.Profile2GridLayout);
            app.GridLayout10.ColumnWidth = {'fit', '1x', 'fit', '1x'};
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.Padding = [1 1 1 1];
            app.GridLayout10.Layout.Row = 2;
            app.GridLayout10.Layout.Column = 1;

            % Create Profile2WhitePointGridLayout
            app.Profile2WhitePointGridLayout = uigridlayout(app.GridLayout10);
            app.Profile2WhitePointGridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.Profile2WhitePointGridLayout.RowHeight = {'fit'};
            app.Profile2WhitePointGridLayout.Layout.Row = 1;
            app.Profile2WhitePointGridLayout.Layout.Column = 2;

            % Create Profile2WhitePointbstar
            app.Profile2WhitePointbstar = uilabel(app.Profile2WhitePointGridLayout);
            app.Profile2WhitePointbstar.Layout.Row = 1;
            app.Profile2WhitePointbstar.Layout.Column = 1;
            app.Profile2WhitePointbstar.Text = 'L';

            % Create Profile2WhitePointastar
            app.Profile2WhitePointastar = uilabel(app.Profile2WhitePointGridLayout);
            app.Profile2WhitePointastar.Layout.Row = 1;
            app.Profile2WhitePointastar.Layout.Column = 2;
            app.Profile2WhitePointastar.Text = 'a';

            % Create Profile2WhitePointLstar
            app.Profile2WhitePointLstar = uilabel(app.Profile2WhitePointGridLayout);
            app.Profile2WhitePointLstar.Layout.Row = 1;
            app.Profile2WhitePointLstar.Layout.Column = 3;
            app.Profile2WhitePointLstar.Text = 'b';

            % Create Profile2BlackPointGridLayout
            app.Profile2BlackPointGridLayout = uigridlayout(app.GridLayout10);
            app.Profile2BlackPointGridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.Profile2BlackPointGridLayout.RowHeight = {'fit'};
            app.Profile2BlackPointGridLayout.Layout.Row = 1;
            app.Profile2BlackPointGridLayout.Layout.Column = 4;

            % Create Profile2BlackPointbstar
            app.Profile2BlackPointbstar = uilabel(app.Profile2BlackPointGridLayout);
            app.Profile2BlackPointbstar.Layout.Row = 1;
            app.Profile2BlackPointbstar.Layout.Column = 3;
            app.Profile2BlackPointbstar.Text = 'b';

            % Create Profile2BlackPointastar
            app.Profile2BlackPointastar = uilabel(app.Profile2BlackPointGridLayout);
            app.Profile2BlackPointastar.Layout.Row = 1;
            app.Profile2BlackPointastar.Layout.Column = 2;
            app.Profile2BlackPointastar.Text = 'a';

            % Create Profile2BlackPointLstar
            app.Profile2BlackPointLstar = uilabel(app.Profile2BlackPointGridLayout);
            app.Profile2BlackPointLstar.Layout.Row = 1;
            app.Profile2BlackPointLstar.Layout.Column = 1;
            app.Profile2BlackPointLstar.Text = 'L';

            % Create GridLayout19
            app.GridLayout19 = uigridlayout(app.GridLayout10);
            app.GridLayout19.ColumnWidth = {'1x'};
            app.GridLayout19.RowHeight = {'1x'};
            app.GridLayout19.Layout.Row = 1;
            app.GridLayout19.Layout.Column = 1;

            % Create Profile2WhitePointLabel
            app.Profile2WhitePointLabel = uilabel(app.GridLayout19);
            app.Profile2WhitePointLabel.BackgroundColor = [1 1 1];
            app.Profile2WhitePointLabel.Layout.Row = 1;
            app.Profile2WhitePointLabel.Layout.Column = 1;
            app.Profile2WhitePointLabel.Text = 'White Point';

            % Create GridLayout21
            app.GridLayout21 = uigridlayout(app.GridLayout10);
            app.GridLayout21.ColumnWidth = {'1x'};
            app.GridLayout21.RowHeight = {'1x'};
            app.GridLayout21.Layout.Row = 1;
            app.GridLayout21.Layout.Column = 3;

            % Create Profile2BlackPointLabel
            app.Profile2BlackPointLabel = uilabel(app.GridLayout21);
            app.Profile2BlackPointLabel.BackgroundColor = [0 0 0];
            app.Profile2BlackPointLabel.FontColor = [1 1 1];
            app.Profile2BlackPointLabel.Layout.Row = 1;
            app.Profile2BlackPointLabel.Layout.Column = 1;
            app.Profile2BlackPointLabel.Text = 'Black Point';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.Profile2GridLayout);
            app.GridLayout11.ColumnWidth = {'1x', 'fit', 'fit'};
            app.GridLayout11.RowHeight = {'1x'};
            app.GridLayout11.RowSpacing = 1;
            app.GridLayout11.Layout.Row = 1;
            app.GridLayout11.Layout.Column = 1;

            % Create profile2Button
            app.profile2Button = uibutton(app.GridLayout11, 'push');
            app.profile2Button.ButtonPushedFcn = createCallbackFcn(app, @profile2ButtonPushed, true);
            app.profile2Button.Layout.Row = 1;
            app.profile2Button.Layout.Column = 1;
            app.profile2Button.Text = 'profile 2 (solid)';

            % Create ResetProfile2Button
            app.ResetProfile2Button = uibutton(app.GridLayout11, 'push');
            app.ResetProfile2Button.ButtonPushedFcn = createCallbackFcn(app, @ResetProfile2ButtonPushed, true);
            app.ResetProfile2Button.Enable = 'off';
            app.ResetProfile2Button.Tooltip = {'remove profile 2'};
            app.ResetProfile2Button.Layout.Row = 1;
            app.ResetProfile2Button.Layout.Column = 2;
            app.ResetProfile2Button.Text = 'clear';

            % Create profile2InfoButton
            app.profile2InfoButton = uibutton(app.GridLayout11, 'push');
            app.profile2InfoButton.ButtonPushedFcn = createCallbackFcn(app, @profile2InfoButtonPushed, true);
            app.profile2InfoButton.Icon = 'info-icon-23815.png';
            app.profile2InfoButton.Enable = 'off';
            app.profile2InfoButton.Tooltip = {'information panel for profile 2'};
            app.profile2InfoButton.Layout.Row = 1;
            app.profile2InfoButton.Layout.Column = 3;
            app.profile2InfoButton.Text = '';

            % Create ViewManagementGridLayout
            app.ViewManagementGridLayout = uigridlayout(app.GridLayout);
            app.ViewManagementGridLayout.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.ViewManagementGridLayout.RowHeight = {'1x', '1x', 'fit', 'fit', 'fit', 'fit'};
            app.ViewManagementGridLayout.Layout.Row = 1;
            app.ViewManagementGridLayout.Layout.Column = 2;

            % Create BPCDropDownLabel
            app.BPCDropDownLabel = uilabel(app.ViewManagementGridLayout);
            app.BPCDropDownLabel.HorizontalAlignment = 'right';
            app.BPCDropDownLabel.Enable = 'off';
            app.BPCDropDownLabel.Tooltip = {'Black Point Compensation'};
            app.BPCDropDownLabel.Layout.Row = 4;
            app.BPCDropDownLabel.Layout.Column = 2;
            app.BPCDropDownLabel.Text = 'BPC';

            % Create BPCDropDown
            app.BPCDropDown = uidropdown(app.ViewManagementGridLayout);
            app.BPCDropDown.Items = {'On', 'Off'};
            app.BPCDropDown.Enable = 'off';
            app.BPCDropDown.Layout.Row = 4;
            app.BPCDropDown.Layout.Column = 4;
            app.BPCDropDown.Value = 'On';

            % Create referenceImageDisplay
            app.referenceImageDisplay = uiimage(app.ViewManagementGridLayout);
            app.referenceImageDisplay.Layout.Row = 1;
            app.referenceImageDisplay.Layout.Column = [1 4];

            % Create SaturationSlider
            app.SaturationSlider = uislider(app.ViewManagementGridLayout);
            app.SaturationSlider.Limits = [0.1 1];
            app.SaturationSlider.MajorTicks = [0.1 0.25 0.5 0.75 1];
            app.SaturationSlider.MajorTickLabels = {'0.1', '0.25', '0.5', '0.75', '1'};
            app.SaturationSlider.ValueChangedFcn = createCallbackFcn(app, @SaturationSliderValueChanged, true);
            app.SaturationSlider.MinorTicks = [];
            app.SaturationSlider.FontSize = 9;
            app.SaturationSlider.Layout.Row = 3;
            app.SaturationSlider.Layout.Column = [2 4];
            app.SaturationSlider.Value = 1;

            % Create wiresatLabel
            app.wiresatLabel = uilabel(app.ViewManagementGridLayout);
            app.wiresatLabel.HorizontalAlignment = 'center';
            app.wiresatLabel.VerticalAlignment = 'top';
            app.wiresatLabel.Layout.Row = [3 4];
            app.wiresatLabel.Layout.Column = 1;
            app.wiresatLabel.Text = {'wire'; 'sat.'};

            % Create viewTopDownButton
            app.viewTopDownButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.viewTopDownButton.ButtonPushedFcn = createCallbackFcn(app, @viewTopDownButtonPushed, true);
            app.viewTopDownButton.Icon = 'down-arrow.png';
            app.viewTopDownButton.Tooltip = {'top-down view'};
            app.viewTopDownButton.Layout.Row = 5;
            app.viewTopDownButton.Layout.Column = 4;
            app.viewTopDownButton.Text = '';

            % Create viewOrthogonalButton
            app.viewOrthogonalButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.viewOrthogonalButton.ButtonPushedFcn = createCallbackFcn(app, @viewOrthogonalButtonPushed, true);
            app.viewOrthogonalButton.Icon = 'orthographic-arrow.png';
            app.viewOrthogonalButton.Tooltip = {'Orthogonal view'};
            app.viewOrthogonalButton.Layout.Row = 5;
            app.viewOrthogonalButton.Layout.Column = 1;
            app.viewOrthogonalButton.Text = '';

            % Create ProfileViewButtonGroup
            app.ProfileViewButtonGroup = uibuttongroup(app.ViewManagementGridLayout);
            app.ProfileViewButtonGroup.Title = 'Profile View';
            app.ProfileViewButtonGroup.Layout.Row = 2;
            app.ProfileViewButtonGroup.Layout.Column = [1 4];

            % Create Profile1monitorButton
            app.Profile1monitorButton = uiradiobutton(app.ProfileViewButtonGroup);
            app.Profile1monitorButton.Text = 'Profile 1 -> monitor';
            app.Profile1monitorButton.Position = [11 122 124 22];
            app.Profile1monitorButton.Value = true;

            % Create Profile2monitorButton
            app.Profile2monitorButton = uiradiobutton(app.ProfileViewButtonGroup);
            app.Profile2monitorButton.Text = 'Profile 2 -> monitor';
            app.Profile2monitorButton.Position = [11 101 124 22];

            % Create Profile1Button
            app.Profile1Button = uiradiobutton(app.ProfileViewButtonGroup);
            app.Profile1Button.Text = 'Profile 1';
            app.Profile1Button.Position = [11 80 66 22];

            % Create Profile2Button
            app.Profile2Button = uiradiobutton(app.ProfileViewButtonGroup);
            app.Profile2Button.Text = 'Profile 2';
            app.Profile2Button.Position = [11 59 66 22];

            % Create viewBottomUpButton
            app.viewBottomUpButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.viewBottomUpButton.ButtonPushedFcn = createCallbackFcn(app, @viewBottomUpButtonPushed, true);
            app.viewBottomUpButton.Icon = 'up-arrow.png';
            app.viewBottomUpButton.Tooltip = {'bottom-up view'};
            app.viewBottomUpButton.Layout.Row = 6;
            app.viewBottomUpButton.Layout.Column = 4;
            app.viewBottomUpButton.Text = '';

            % Create bStarRightButton
            app.bStarRightButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.bStarRightButton.ButtonPushedFcn = createCallbackFcn(app, @bStarRightButtonPushed, true);
            app.bStarRightButton.Icon = 'arrow-right-icon.png';
            app.bStarRightButton.Layout.Row = 6;
            app.bStarRightButton.Layout.Column = 3;
            app.bStarRightButton.Text = '-b*';

            % Create bStarLeftButton
            app.bStarLeftButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.bStarLeftButton.ButtonPushedFcn = createCallbackFcn(app, @bStarLeftButtonPushed, true);
            app.bStarLeftButton.Icon = 'arrow-left-icon.png';
            app.bStarLeftButton.Layout.Row = 5;
            app.bStarLeftButton.Layout.Column = 3;
            app.bStarLeftButton.Text = '-b*';

            % Create aStarLeftButton
            app.aStarLeftButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.aStarLeftButton.ButtonPushedFcn = createCallbackFcn(app, @aStarLeftButtonPushed, true);
            app.aStarLeftButton.Icon = 'arrow-left-icon.png';
            app.aStarLeftButton.Layout.Row = 5;
            app.aStarLeftButton.Layout.Column = 2;
            app.aStarLeftButton.Text = '-a*';

            % Create aStarRightButton
            app.aStarRightButton = uibutton(app.ViewManagementGridLayout, 'push');
            app.aStarRightButton.ButtonPushedFcn = createCallbackFcn(app, @aStarRightButtonPushed, true);
            app.aStarRightButton.Icon = 'arrow-right-icon.png';
            app.aStarRightButton.Layout.Row = 6;
            app.aStarRightButton.Layout.Column = 2;
            app.aStarRightButton.Text = '-a*';

            % Create MonitorProfileGridLayout
            app.MonitorProfileGridLayout = uigridlayout(app.GridLayout);
            app.MonitorProfileGridLayout.ColumnWidth = {'1x', 'fit'};
            app.MonitorProfileGridLayout.RowHeight = {'fit'};
            app.MonitorProfileGridLayout.Layout.Row = 4;
            app.MonitorProfileGridLayout.Layout.Column = 1;

            % Create GridLayout22
            app.GridLayout22 = uigridlayout(app.MonitorProfileGridLayout);
            app.GridLayout22.ColumnWidth = {'1x'};
            app.GridLayout22.RowHeight = {'1x'};
            app.GridLayout22.Layout.Row = 1;
            app.GridLayout22.Layout.Column = 1;

            % Create MonitorProfileButton
            app.MonitorProfileButton = uibutton(app.GridLayout22, 'push');
            app.MonitorProfileButton.ButtonPushedFcn = createCallbackFcn(app, @MonitorProfileButtonPushed, true);
            app.MonitorProfileButton.Layout.Row = 1;
            app.MonitorProfileButton.Layout.Column = 1;
            app.MonitorProfileButton.Text = 'Monitor Profile';

            % Create GridLayout23
            app.GridLayout23 = uigridlayout(app.MonitorProfileGridLayout);
            app.GridLayout23.ColumnWidth = {'1x'};
            app.GridLayout23.RowHeight = {'1x'};
            app.GridLayout23.Layout.Row = 1;
            app.GridLayout23.Layout.Column = 2;

            % Create monitorProfileInfoButton
            app.monitorProfileInfoButton = uibutton(app.GridLayout23, 'push');
            app.monitorProfileInfoButton.ButtonPushedFcn = createCallbackFcn(app, @monitorProfileInfoButtonPushed, true);
            app.monitorProfileInfoButton.Icon = 'info-icon-23815.png';
            app.monitorProfileInfoButton.Enable = 'off';
            app.monitorProfileInfoButton.Tooltip = {'information panel for monitor profile'};
            app.monitorProfileInfoButton.Layout.Row = 1;
            app.monitorProfileInfoButton.Layout.Column = 1;
            app.monitorProfileInfoButton.Text = '';

            % Create Profile1GridLayout
            app.Profile1GridLayout = uigridlayout(app.GridLayout);
            app.Profile1GridLayout.ColumnWidth = {'1x'};
            app.Profile1GridLayout.RowSpacing = 1;
            app.Profile1GridLayout.Padding = [1 1 1 1];
            app.Profile1GridLayout.Layout.Row = 2;
            app.Profile1GridLayout.Layout.Column = 1;

            % Create Profile1WhiteBlackPointsGridLayout
            app.Profile1WhiteBlackPointsGridLayout = uigridlayout(app.Profile1GridLayout);
            app.Profile1WhiteBlackPointsGridLayout.ColumnWidth = {'fit', '1x', 'fit', '1x'};
            app.Profile1WhiteBlackPointsGridLayout.RowHeight = {'fit'};
            app.Profile1WhiteBlackPointsGridLayout.RowSpacing = 1;
            app.Profile1WhiteBlackPointsGridLayout.Padding = [1 1 1 1];
            app.Profile1WhiteBlackPointsGridLayout.Layout.Row = 2;
            app.Profile1WhiteBlackPointsGridLayout.Layout.Column = 1;

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.Profile1WhiteBlackPointsGridLayout);
            app.GridLayout14.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout14.RowHeight = {'1x'};
            app.GridLayout14.Layout.Row = 1;
            app.GridLayout14.Layout.Column = 2;

            % Create Profile1WhitePointbstar
            app.Profile1WhitePointbstar = uilabel(app.GridLayout14);
            app.Profile1WhitePointbstar.Layout.Row = 1;
            app.Profile1WhitePointbstar.Layout.Column = 1;
            app.Profile1WhitePointbstar.Text = 'L';

            % Create Profile1WhitePointastar
            app.Profile1WhitePointastar = uilabel(app.GridLayout14);
            app.Profile1WhitePointastar.Layout.Row = 1;
            app.Profile1WhitePointastar.Layout.Column = 2;
            app.Profile1WhitePointastar.Text = 'a';

            % Create Profile1WhitePointLstar
            app.Profile1WhitePointLstar = uilabel(app.GridLayout14);
            app.Profile1WhitePointLstar.Layout.Row = 1;
            app.Profile1WhitePointLstar.Layout.Column = 3;
            app.Profile1WhitePointLstar.Text = 'b';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.Profile1WhiteBlackPointsGridLayout);
            app.GridLayout9.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.Layout.Row = 1;
            app.GridLayout9.Layout.Column = 4;

            % Create Profile1BlackPointbstar
            app.Profile1BlackPointbstar = uilabel(app.GridLayout9);
            app.Profile1BlackPointbstar.Layout.Row = 1;
            app.Profile1BlackPointbstar.Layout.Column = 3;
            app.Profile1BlackPointbstar.Text = 'b';

            % Create Profile1BlackPointastar
            app.Profile1BlackPointastar = uilabel(app.GridLayout9);
            app.Profile1BlackPointastar.Layout.Row = 1;
            app.Profile1BlackPointastar.Layout.Column = 2;
            app.Profile1BlackPointastar.Text = 'a';

            % Create Profile1BlackPointLstar
            app.Profile1BlackPointLstar = uilabel(app.GridLayout9);
            app.Profile1BlackPointLstar.Layout.Row = 1;
            app.Profile1BlackPointLstar.Layout.Column = 1;
            app.Profile1BlackPointLstar.Text = 'L';

            % Create GridLayout18
            app.GridLayout18 = uigridlayout(app.Profile1WhiteBlackPointsGridLayout);
            app.GridLayout18.ColumnWidth = {'1x'};
            app.GridLayout18.RowHeight = {'1x'};
            app.GridLayout18.Layout.Row = 1;
            app.GridLayout18.Layout.Column = 1;

            % Create Profile1WhitePointLabel
            app.Profile1WhitePointLabel = uilabel(app.GridLayout18);
            app.Profile1WhitePointLabel.BackgroundColor = [1 1 1];
            app.Profile1WhitePointLabel.Layout.Row = 1;
            app.Profile1WhitePointLabel.Layout.Column = 1;
            app.Profile1WhitePointLabel.Text = 'White Point';

            % Create GridLayout20
            app.GridLayout20 = uigridlayout(app.Profile1WhiteBlackPointsGridLayout);
            app.GridLayout20.ColumnWidth = {'1x'};
            app.GridLayout20.RowHeight = {'1x'};
            app.GridLayout20.Layout.Row = 1;
            app.GridLayout20.Layout.Column = 3;

            % Create Profile1BlackPointLabel
            app.Profile1BlackPointLabel = uilabel(app.GridLayout20);
            app.Profile1BlackPointLabel.BackgroundColor = [0 0 0];
            app.Profile1BlackPointLabel.FontColor = [1 1 1];
            app.Profile1BlackPointLabel.Layout.Row = 1;
            app.Profile1BlackPointLabel.Layout.Column = 1;
            app.Profile1BlackPointLabel.Text = 'Black Point';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.Profile1GridLayout);
            app.GridLayout13.ColumnWidth = {'1x', 'fit', 'fit'};
            app.GridLayout13.RowHeight = {'fit'};
            app.GridLayout13.RowSpacing = 1;
            app.GridLayout13.Layout.Row = 1;
            app.GridLayout13.Layout.Column = 1;

            % Create profile1Button
            app.profile1Button = uibutton(app.GridLayout13, 'push');
            app.profile1Button.ButtonPushedFcn = createCallbackFcn(app, @profile1ButtonPushed, true);
            app.profile1Button.Layout.Row = 1;
            app.profile1Button.Layout.Column = 1;
            app.profile1Button.Text = 'profile 1 (wireframe)';

            % Create ResetProfile1Button
            app.ResetProfile1Button = uibutton(app.GridLayout13, 'push');
            app.ResetProfile1Button.ButtonPushedFcn = createCallbackFcn(app, @ResetProfile1ButtonPushed, true);
            app.ResetProfile1Button.Enable = 'off';
            app.ResetProfile1Button.Tooltip = {'remove profile 1'};
            app.ResetProfile1Button.Layout.Row = 1;
            app.ResetProfile1Button.Layout.Column = 2;
            app.ResetProfile1Button.Text = 'clear';

            % Create profile1InfoButton
            app.profile1InfoButton = uibutton(app.GridLayout13, 'push');
            app.profile1InfoButton.ButtonPushedFcn = createCallbackFcn(app, @profile1InfoButtonPushed, true);
            app.profile1InfoButton.Icon = 'info-icon-23815.png';
            app.profile1InfoButton.Enable = 'off';
            app.profile1InfoButton.Tooltip = {'information panel for profile 1'};
            app.profile1InfoButton.Layout.Row = 1;
            app.profile1InfoButton.Layout.Column = 3;
            app.profile1InfoButton.Text = '';

            % Create GridLayout16
            app.GridLayout16 = uigridlayout(app.GridLayout);
            app.GridLayout16.Layout.Row = 4;
            app.GridLayout16.Layout.Column = 2;

            % Create ExitButton
            app.ExitButton = uibutton(app.GridLayout16, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.Layout.Row = 2;
            app.ExitButton.Layout.Column = 2;
            app.ExitButton.Text = 'Exit';

            % Create RenderButton
            app.RenderButton = uibutton(app.GridLayout16, 'push');
            app.RenderButton.ButtonPushedFcn = createCallbackFcn(app, @RenderButtonPushed, true);
            app.RenderButton.Layout.Row = 1;
            app.RenderButton.Layout.Column = 2;
            app.RenderButton.Text = 'Render';

            % Create GridLayout17
            app.GridLayout17 = uigridlayout(app.GridLayout);
            app.GridLayout17.RowHeight = {'fit', 'fit'};
            app.GridLayout17.Layout.Row = 2;
            app.GridLayout17.Layout.Column = 2;

            % Create Profile1VolumeLabel
            app.Profile1VolumeLabel = uilabel(app.GridLayout17);
            app.Profile1VolumeLabel.Layout.Row = 1;
            app.Profile1VolumeLabel.Layout.Column = 1;
            app.Profile1VolumeLabel.Text = 'Profile 1 Volume:';

            % Create Profile1Volume
            app.Profile1Volume = uilabel(app.GridLayout17);
            app.Profile1Volume.Layout.Row = 1;
            app.Profile1Volume.Layout.Column = 2;
            app.Profile1Volume.Text = '0.0';

            % Create Profile2VolumeLabel
            app.Profile2VolumeLabel = uilabel(app.GridLayout17);
            app.Profile2VolumeLabel.Layout.Row = 2;
            app.Profile2VolumeLabel.Layout.Column = 1;
            app.Profile2VolumeLabel.Text = 'Profile 2 Volume:';

            % Create Profile2Volume
            app.Profile2Volume = uilabel(app.GridLayout17);
            app.Profile2Volume.Layout.Row = 2;
            app.Profile2Volume.Layout.Column = 2;
            app.Profile2Volume.Text = '0.0';

            % Create Switch
            app.Switch = uiswitch(app.GamutCompareUIFigure, 'slider');
            app.Switch.Items = {'-a*', '-a*'};
            app.Switch.Orientation = 'vertical';
            app.Switch.Position = [-283 -5 20 45];
            app.Switch.Value = '-a*';

            % Show the figure after all components are created
            app.GamutCompareUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GamutCompare_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.GamutCompareUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.GamutCompareUIFigure)
        end
    end
end