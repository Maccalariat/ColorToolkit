function colorPoints =  myColorCloud(inImage, colorspace, parent)
	% myColorCloud produce a color cloud plot
	%    output  = (not via return) scatter3
	%    input: inputImage - the input image array. Must be 3D RGB
	%           colorspace - the colorspace of inputImage
	%           parent - the parent of the scatter3 plot.

	inputImage = double(zeros(size(inImage)));

    [m,n,~] = size(colorData);
    gpuColorData = gpuArray(reshape(colorData,[m*n 3]));

	% get unique colors
	uniqueColors = gather(unique(gpuColorData,'rows'));
	cm = lab2rgb(uniqueColors);
    
	inputImage = im2double(inImage);

	% Convert RGB data into specified colorspace
	try
		C1 = makecform("clut", colorspace,"AToB0");
	catch
		try
			C1 = makecform("mattrc", colorspace, Direction="forward");
		catch
			return;
		end
	end
	colorData = applycform(inputImage,C1);
	switch colorspace.Header.ConnectionSpace
		case "XYZ"
			colorData = xyz2lab(colorData);
		case "Lab"
		otherwise
			disp(["unknown pcs ... " pcs]);
	end

	[m,n,~] = size(colorData);

	% get unique colors
	if gpuDeviceCount > 0
		UcolorData = reshape(gpuArray(colorData),[m*n 3]);
		uniqueColors = gather(unique(UcolorData,'rows'));
	else
		UcolorData = reshape(colorData,[m*n 3]);
		uniqueColors = unique(UcolorData,'rows');
	end
>>>>>>> da192bc4d25e509caae4321c6567c7a7b747b0eb
	[colorPoints,~] = size(uniqueColors);
	cm = lab2rgb(uniqueColors);
	scatter3(parent,uniqueColors(:,2),uniqueColors(:,3),uniqueColors(:,1),6,cm,'.');
end

