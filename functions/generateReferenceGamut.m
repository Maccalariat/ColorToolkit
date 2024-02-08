function referenceTarget = generateReferenceGamut(dim, TargetSaturation)
    %generateReferenceGamut Generates a synthetic HSL Gamut
    %   Generate a synthetic image in HSL. This is used as input to the test
    %   gamut displays.
    %   the gamut is generated to the limits of the supplied Luminance(L)
    %   and Saturation(S)
    %   NOTE: the Linearity of L and S are in the Lab domain, so may not
    %   translate <i>exactly</i> to HSL

    % Hue
    t(:, 1:dim, 1) = ones(1, dim)'*linspace(0, 1, dim);
    % Saturation
    t(:, 1:dim, 2) = TargetSaturation;
    % Lightness
    t(:,1:dim, 3) = linspace(1,0, dim)'*ones(1, dim);
    referenceTarget = hsl2rgb(t);
end