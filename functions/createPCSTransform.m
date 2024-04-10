function [returnImage, transform] = createPCSTransform(iccProfile, image)
    %CREATEPCSTRANSFORM Create an icc transform to the profiles PCS and return a
    % Lab version (if PCS is XYZ)
    %   with the supplied iccProfile and image create an icc profile to
    %   transform to the profiles pcs. if the pcs is Lab, ok. if the pcs id XYZ
    %   then convert to Lab.
    % apply the transform to the supplied image.
    % we prefer a clut forward transform based on the colloquial information
    % that clut is likely more accurate that matrrc. <shrugs/>
    % return both the transform and the transformed image.

    if ~isicc(iccProfile)
        return;
    end

    try
        % AToB3 device->PCS, Absolute Colorimetric
        transform = makecform("clut", iccProfile,"AToB3");
    catch
        try
            transform = makecform("mattrc", iccProfile, Direction="forward", RenderingIntent="AbsoluteColorimetric");
        catch
        end
    end
    returnImage = applycform(image,transform);
    switch iccProfile.Header.ConnectionSpace
        case "XYZ"
            returnImage = xyz2lab(returnImage);
        case "Lab"
        otherwise
            disp(["unknown pcs ... " pcs]);
    end
end

