% Create a figure
f = figure;

% Create the main axes
main_axes = axes(f, 'Position', [0.1 0.1 0.8 0.8]);

% Create a 3D plot in the main axes
[X,Y,Z] = peaks;
surf(main_axes, X, Y, Z);

% Create the gizmo axes in the corner of the figure
gizmo_axes = axes(f, 'Position', [0.8 0.8 0.1 0.1]);

% Draw the 3D axes lines in the gizmo axes
line(gizmo_axes, [0 1], [0 0], [0 0], 'Color', 'r'); % x-axis
line(gizmo_axes, [0 0], [0 1], [0 0], 'Color', 'g'); % y-axis
line(gizmo_axes, [0 0], [0 0], [0 1], 'Color', 'b'); % z-axis

% Set the view angle of the gizmo axes to match the main axes
view(gizmo_axes, view(main_axes))

% Update the gizmo axes whenever the main axes is rotated
addlistener(main_axes, 'View', 'PostSet', @(src, event) view(gizmo_axes, view(main_axes)));