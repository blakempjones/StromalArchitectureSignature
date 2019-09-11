function periodImg = ComputePeriod(sample)
%
% Computes the period of the intensity values for each pixel in a stack of
% PLM images, each offset by a constant degree from their predecessor. This
% function will find the difference between where the max and min intensity
% values occur for PLM data.
%
% --- Input ---
% sample: a 3D matrix representation of an image stack where the third
% dimension corresponds to respective images.
%
% --- Output ---
% periodImg: parametric image of periodic/frequency values.
%

imgSize = size(sample);

% Type and nan cleaning
sample = single(sample);
sample(isnan(sample)) = 0;

% Calculation of the max and min values for every pixel over the the stack
maxs = max(sample, [], 3);
mins = min(sample, [], 3);

% Holders for the index at which the max and min occur.
maxInd = zeros(imgSize(1), imgSize(2));
minInd = zeros(imgSize(1), imgSize(2));

for i = 1 : imgSize(1)
    
    for j = 1 : imgSize(2)
        % Finding the indces where the max and min occur. If multiple
        % values of the max or min are present the one with the lowest
        % value of the third dimension is used (i.e. closer to the top of
        % the image stack).
        maxInd(i,j) = find(sample(i,j,:) ==  maxs(i,j), 1);
        minInd(i,j) = find(sample(i,j,:) ==  mins(i,j), 1);
    end
    
end

% Calculation of the period 
periodImg(i,j) = maxInd - minInd;
periodImg = abs(periodImg);

end