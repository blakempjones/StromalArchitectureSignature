function rSquared = ComputeRSquared(sample)

normalized = single(sample);

normalized(isnan(normalized)) = 0;

imageSize = size(normalized);

mins = min(normalized, [], 3);

normalized = normalized - mins;

maxs = max(normalized, [], 3);

normalized = normalized ./ maxs;

normalized = normalized - 0.5;

normalized = normalized .* 2;

param1 = 1;
param2 = 4;
x90 = 1:0.01:90;
param3Expected = param1 * sind(param2 * x90);
param3Expected = x90(find(param3Expected == max(param3Expected), 1));

% xSample = (1:5:90)';
xSample = linspace(1,90, imageSize(3));

param3 = zeros(imageSize(1), imageSize(2));

for i = 1 : imageSize(1)
    
    for j = 1 : imageSize(2)
        
        maxValX = xSample(find(normalized(i,j,:) == 1, 1));
        
        param3(i,j) = maxValX - param3Expected;
        
    end
    
end

xSampleReshaped = reshape(xSample, 1, 1, length(xSample));
expectedResults = repmat(xSampleReshaped,imageSize(1), imageSize(2));
% expectedResultsNoShift = expectedResults;
expectedResults = expectedResults - param3;

% expectedResults = exp(-expectedResultsNoShift/50) .* sind(param2 .* expectedResults);
expectedResults = sind(param2 .* expectedResults);

% maxs = max(expectedResults, [], 3);
% expectedResults = expectedResults ./ maxs;
% expectedResults = (expectedResults - 0.5)*2;


SStot = sum((expectedResults - mean(expectedResults, 3)).^2,3);

SSres = sum((normalized - expectedResults).^2,3);

rSquared = 1 - (SSres ./ SStot);

end






