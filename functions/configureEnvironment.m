function [IPT, PCT] = configureEnvironment()
	%CONFIGUREENVIRONMENT get and set the required matlab environment
	%   Check to see if the Image Processing Toolbox is installed. It is
	%   required.
	%   Check to see if the Parallel Processing Toolbox is installed and if so,
	%   select the GPU.
	toolboxes = ver;
	
	if any(strcmp('Image Processing Toolbox', {toolboxes.Name}))
		% the image processing toolbox is found.
		IPT = true;
	else
		% this app won't function without it
		IPT = false;
	end
	if any(strcmp('Parallel Computing Toolbox', {toolboxes.Name}))
		PCT = pickGPU();
	else
		"Parallel Computing Toolbox not found.";
	end

		
end

function gpu = pickGPU()
	gpuTable = gpuDeviceTable;
	if height(gpuTable) == 0
		% no GPU available (!)
		gpu = "";
		return;
	end
	if height(gpuTable) == 1
		gpuDevice(1);
		gpu = gpuTable.Name{1};
		return;
	end

	% we have the luxury of multiple GPUs. Let the User choose.
	[selectedGPU, ok] = listdlg('PromptString', 'Select a GPU:', 'SelectionMode', 'single',...
			'ListString', gpuTable.Name);
	if ok
		gpuDevice(selectedGPU);
		gpu = gpuTable{selectedGPU};
	end
	gpuDevice(gpuTable.index(seletedGPU));
end

