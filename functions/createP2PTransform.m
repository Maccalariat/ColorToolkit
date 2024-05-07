function [outputImage, returnToImage, transform] = createP2PTransform(iccProfileFrom, iccProfileTo, sourceRI, destRI, inputImage)
    %CREATEPCSTRANSFORM Create an icc transform to the destination profiles space
    % and returns a Lab version (if PCS is XYZ)
    %   with the supplied iccProfile and image create an icc profile to
    %   transform to the profiles pcs. if the pcs is Lab, ok. if the pcs id XYZ
    %   then convert to Lab.
    % apply the transform to the supplied image.
    % we prefer a clut forward transform based on the colloquial information
    % that clut is likely more accurate that matrrc. <shrugs/>
    % return both the transform and the transformed image.

    % create the PCS representation of the image in the iccProfileForm PCS
    returnToImage = createPCSTransform(iccProfileFrom, inputImage, sourceRI);

    % make a transform between iccProfileFrom and iccProfileTo using the
    % supplied renderingIntent
    transform = makecform("icc", iccProfileFrom, iccProfileTo, SourceRenderingIntent=sourceRI, DestRenderingIntent=destRI);

    transformedToImage = applycform(image,transform);
    
	% now re-render the image to the PCS/Lab colorspace
    outputImage = iccTransformToPCS(iccProfileTo, transformedToImage);

end

