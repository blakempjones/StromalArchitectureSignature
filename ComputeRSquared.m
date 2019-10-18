function rSquared = ComputeRSquared(sample, startAngle, endAngle, stepSize)
%
% Computes the correlation with the sinusoidal pattern expected from
% polarization theory for a stack of PLM images, each offset by a constant 
% degree from their predecessor.
%
% --- Input ---
% sample: a 3D matrix representation of an image stack where the third
% dimension corresponds to respective images.
% startAngle: Tau angle at which imaging began. For this code the choice of
% angles can be arbitrary so 5 should typically be used.
% endAngle: Tau angle at which imaging ended. 90 is the typical value.
% stepSize: Incremental difference used in the calculation of the
% theoretical curve.
%
% --- Output ---
% rSquared: parametric image of R squared values.
%

imageSize = size(sample);

% Type and nan cleaning
normalized = single(sample);
normalized(isnan(normalized)) = 0;

% Normalization of the sample to be between 1 and 0
mins = min(normalized, [], 3);
normalized = normalized - mins;
maxs = max(normalized, [], 3);
normalized = normalized ./ maxs;

% Frequency parameter, known from theory.
param2 = 2;

% Values to compute expected sine curve
x90 = startAngle : stepSize : endAngle;

% Horizontal translation parameter of the expected curve
param3Expected = sind(param2 * x90).^2;
param3Expected = x90(find(param3Expected == max(param3Expected), 1));

% Values at which the PLM was sampled (i.e. imaged)
xSample = linspace(startAngle, endAngle, imageSize(3));

% Second round of nan cleaning to handle pixel stacks that are entirely 
% zero (only occurs when the image has been adjusted for tiling).
normalized(isnan(normalized)) = 0;

% Calculate the horizontal translation via comparison of where the
% max value occured
[~,maxValX] = max(normalized, [], 3);

% Scale such that maxValX represents an angle and not a position
maxValX = startAngle + (maxValX - 1) * stepSize;

% Calculate the horzontal shift (observed - expected)
param3 = maxValX - param3Expected;

% Create a matrix the same size as the input and store, along the 3rd
% dimension the expected results (this time calculated using the correct
% horizontal translation.
xSampleReshaped = reshape(xSample, 1, 1, length(xSample));
expectedResults = repmat(xSampleReshaped,imageSize(1), imageSize(2));
expectedResults = expectedResults - param3;
expectedResults = sind(param2 .* expectedResults).^2;

% Compute the residuals and final rSquared value.
SStot = sum((expectedResults - mean(expectedResults, 3)).^2,3);
SSres = sum((normalized - expectedResults).^2,3);
rSquared = 1 - (SSres ./ SStot);

end






