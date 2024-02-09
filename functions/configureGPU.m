function configureGPU
	% Get the GPU table
	gpuTable = gpuDeviceTable;

	% Extract the names of the GPUs
	gpuNames = gpuTable.Name;

	% Create a dialog box for GPU selection
	[selectedGPU, ok] = listdlg('PromptString', 'Select a GPU:',...
		'SelectionMode', 'single',...
		'ListString', gpuNames);

	% If a GPU is selected, set it as the current GPU
	if ok
		%reset(selectedGPU);
		gpuDevice(selectedGPU);
		% disp(['Selected GPU: ' gpuNames{selectedGPU}]);
	else
		disp('No GPU selected.');
	end
end