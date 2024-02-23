function whitePointText = WhitePointToText(x,y,z, colorspace)
%WHITEBLACKPOINT With a supplied Lab tuple, return text if it is a known
%                white or black point
%   Input an L, a, b value set and return text string for the whitepoint

% Define standard whitepoints
whitepoints = {'a', 'c', 'e', 'd50', 'd55', 'd65', 'icc'};
min_distance = inf;
wp = '';
whitePointText = 'non standard';

if colorspace == "Lab"
    % convert the values to XYZ
    x; y; z = Lab2xyz(x, y, z);
end

% Iterate over each standard whitepoint
for i = 1:length(whitepoints)
    % Get the XYZ values for the current whitepoint
    wp_xyz = whitepoint(whitepoints{i});

    % Calculate the Euclidean distance to the input XYZ values
    distance = sqrt((x - wp_xyz(1))^2 + (y - wp_xyz(2))^2 + (z - wp_xyz(3))^2);

    % If this distance is smaller than the current minimum, update the minimum and set the whitepoint
    if distance < min_distance
        min_distance = distance;
        whitePointText = whitepoints{i};
    end
end
if whitePointText == "icc"
    whitePointText = "icc(PCS)";
end
