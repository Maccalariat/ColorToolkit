function CompareTwoGamuts_old
    % COMPARETWOGAMUTS compare two gamuts
    %
    % Rread in two icc profiles and able compare them in 3D renders.

    gDim = 64;
    gExt = gDim -1;

    %% Reference Gamut
    % The reference gamut is a square x, y, 3 HSL array where:
    % L is 0 <= y <= 256
    % S is 1
    % H is 0 <= x <= 256
    %
    % This is input to all the color conversions.

    % reference_target is a temporary array for calculating arrays to be moved to prtarg for printing.
    % Maximum S, varying H and L.  (S1 region)
    hsl_reference_target = zeros(gDim,gDim, 3);
    hsl_reference_target(:,1:gDim,1) = ones(1,gDim)'*(0:1/gExt:1);  % H
    hsl_reference_target(:,1:gDim,2) = ones(gDim,gDim);             % S
    hsl_reference_target(:,1:gDim,3) = (1:-1/gExt:0)'*ones(1,gDim); % L

    rgb_reference_target = hsl2rgb(hsl_reference_target);

    % redo saturation to 0.5 for the colormaps
    hsl_reference_target(:,1:gDim,2) = ones(gDim,gDim)/2;            % S
    rgb_p5_reference_target = hsl2rgb(hsl_reference_target);
    clear hsl_reference_target;

    % Get the La*b* profile from the local store
    ROMMProfile = iccread('profiles/ISO22028-2_ROMM-RGB.icc');

    % Get the two required targets from the user.
    [fn1, pn1] = uigetfile({'*.icc'; '*.icm'},'Select first profile (wireframe).', iccroot);
    if isequal(fn1,0)
        return;
    end
    profile1Path = [pn1 fn1];
    profile1 = iccread(profile1Path);
    [fn1, pn1] = uigetfile({'*.icc'; '*.icm'},'Select second profile (solid).', iccroot);
    if isequal(fn1,0)
        return;
    end
    profile2Path = [pn1 fn1];
    profile2 = iccread(profile2Path);

    % this applies the profile1 target to Lab.
    C = makecform("icc", profile1, ROMMProfile, DestRenderingIntent="AbsoluteColorimetric");
    display_target1 = applycform(rgb_reference_target, C);
    display_target1 = rgb2lab(display_target1, ColorSpace='srgb', WhitePoint='d65');

    C = makecform("icc", profile2, ROMMProfile, 'DestRenderingIntent','AbsoluteColorimetric');
    display_target2 = applycform(rgb_reference_target, C);
    display_target2 = rgb2lab(display_target2, ColorSpace='srgb', WhitePoint='d65');

    figure(Name='Gamut Comparemeter', NumberTitle='off');

    surf(display_target1(:,:,2), display_target1(:,:,3), display_target1(:,:,1), FaceColor='none', EdgeColor='#606060');

    hold on;

    surf(display_target2(:,:,2), display_target2(:,:,3), display_target2(:,:,1), rgb_p5_reference_target, ...
        FaceColor='flat', EdgeColor='flat', FaceLighting='gouraud', FaceAlpha=0.5);

    set(gca,'Color',[.9 .9 .9]);
    rotate3d on;
    axis tight;
    axis vis3d;
    % axis("square");
    pbaspect([2,2,1]);
    xlabel('a*');  ylabel('b*');  zlabel('L');
    title([profile1.Description.String, ' (wire)'], [profile2.Description.String, ' (solid)']);
    xlim([-110 110]);
    ylim([-110 110]);
    view(-110,32);
    set(gcf, 'Position', [100, 100, 700, 700]);

    % [minA, maxA] = bounds(display_target2(:,:,2));
    % disp(['min a* ', minA, ' max a* ', maxA]);
    return;
end