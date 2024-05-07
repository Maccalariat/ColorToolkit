function outputImage = iccTransformToPCS(iccProfile, inputImage)
	%ICCTRANSFORMTOPCS forward-transform an image to its PCS(Lab)
	%   with the supplied iccProfile and image create an icc profile to
	%   transform to the profiles pcs. if the pcs is Lab, ok. if the pcs id XYZ
	%   then convert to Lab.
	% apply the transform to the supplied image.
	% we prefer a clut forward transform based on the colloquial information
	% that clut is likely more accurate that matrrc. <shrugs/>
	% return both the transform and the transformed image.

	if ~isicc(iccProfile)
		disp("valid profile not supplied to iccTransformToPCS");
		return;
	end

	% create the appropriate transform to the pcs
	try
		% AToB3 device->PCS, Absolute Colorimetric
		transform = makecform("clut", iccProfile,"AToB3");
	catch
		try
			transform = makecform("mattrc", iccProfile, Direction="forward", RenderingIntent="AbsoluteColorimetric");
		catch
			disp("Problem creating the transform to PCS");
			return;
		end
	end

	% apply the transform to the image
	try
		outputImage = applycform(inputImage,transform);
	catch
		disp("problem performing the image -> PCS applycform");
		return;
	end
	
	% ensure the image is double for the possible xyz2lab
	outputImage = double(outputImage);
	% ensure the returned image is in Lab space
	switch iccProfile.Header.ConnectionSpace
		case "XYZ"
			outputImage = xyz2lab(outputImage);
		case "Lab"
			disp("Connection space = Lab for target, no conversion needed");
		otherwise
			disp(["unknown pcs ... " pcs]);
	end
end

