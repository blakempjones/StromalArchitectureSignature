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
% angles can be arbitrary so 1 should typically be used.
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

% Normalization of the sample to be between 1 and -1
mins = min(normalized, [], 3);
normalized = normalized - mins;
maxs = max(normalized, [], 3);
normalized = normalized ./ maxs;
normalized = normalized - 0.5;
normalized = normalized .* 2;

% Frequency parameter, known from theory.
param2 = 2;

% Values to compute expected sine curve
x90 = startAngle : stepSize : endAngle;

% Horizontal translation parameter of the expected curve
param3Expected = sind(param2 * x90).^2;
param3Expected = x90(find(param3Expected == max(param3Expected), 1));

% Values at which the PLM was sampled (i.e. imaged)
xSample = linspace(startAngle, endAngle, imageSize(3));

% Holder for the horizontal translation parameter of the data
param3 = zeros(imageSize(1), imageSize(2));

for i = 1 : imageSize(1)
    
    for j = 1 : imageSize(2)
        
        % Calculate the horizontal translation via comparison of where the
        % max value occured
        maxValX = xSample(find(normalized(i,j,:) == 1, 1));
        param3(i,j) = maxValX - param3Expected;
        
    end
    
end

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






