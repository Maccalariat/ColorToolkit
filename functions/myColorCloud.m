function colorPoints =  myColorCloud(inImage, colorspace, parent)
    % myColorCloud produce a color cloud plot
    %    output  = (not via return) scatter3
    %    input: inputImage - the input image array. Must be 3D RGB
    %           colorspace - the colorspace of inputImage
    %           parent - the parent of the scatter3 plot.

    inputImage = im2double(inImage);
    % Convert RGB data into specified colorspace
    if isicc(colorspace)
    	try
    		C1 = makecform("clut", colorspace,"AToB0");
    	catch
    	end
    	try
    		C1 = makecform("mattrc", colorspace, Direction="forward");
    	catch
    	end
    	colorData = applycform(inputImage,C1);
    	clear C1;
        switch colorspace.Header.ConnectionSpace
    		case "XYZ"
    			colorData = xyz2lab(colorData);
    		case "Lab"
    		otherwise
    			disp(["unknown pcs ... " pcs]);
        end
    end

    [m,n,~] = size(colorData);
    colorData = reshape(colorData,[m*n 3]);

	% get unique colors
	uniqueColors = unique(colorData,'rows');
	cm = lab2rgb(uniqueColors);
	[colorPoints,~] = size(uniqueColors);

    % Downsample to 2e6 points if image is large to keep number of points in
    % scatter plot manageable
    % targetNumPoints = 2e6;
    % numPixels = x;

    % if x*3 > 2e6
    %     sampleFactor = round(numPixels/targetNumPoints);
	% 	idx = false(x, 1);
    %     idx(1:sampleFactor:end) = true;
    %     uniqueColors = uniqueColors(idx,:);
    % end
    
    scatter3(parent,uniqueColors(:,2),uniqueColors(:,3),uniqueColors(:,1),6,cm,'.');
end

