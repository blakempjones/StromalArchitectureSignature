function alignmentMatrix = ComputeAlignment(dirImage, nhoodSize)
%
% Computes the maximum difference in the diretion of the optical axis for
% the neighbourhood around each pixel. Used in the alignment score outlined
% in: "Novel methodology to image stromal tissue and assess its
% morphological features with polarized light: towards a tumour
% microenvironment prognostic signature," Biomed. Opt. Express 10, 3963-3973 (2019)
%
% --- Input ---
% dirImage: A 2D matrix where each pixel corresponds to the optical axis
% directional at that pixel.
% nhoodSize: The number of pixels to use in the neighbourhood around a
% pixel. For instance, a value of 2 would result in a 5x5 neighbourhood (2
% + 2 + center Pixel = 5).
%
% --- Output ---
% alignmentMatrix: A 2D matrix of the same size as dirImage whose values
% correspond to the maximum angular difference found in the neighbourhood
% of each pixel.
%

imgSize = size(dirImage);
dirImage(isnan(dirImage)) = 0;
alignmentMatrix = zeros(imgSize);

for i = 1:imgSize(1)
    
    distMatrix = [];
    distMatrix2 = [];
    
    for j = 1:imgSize(2)
        % Region of interest
        roi = dirImage(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        
        % Calculate the pariwise distances between values in the roi
        differences = pdist(roi(:));
        
        % Find the max difference in the neighbourhood with the original
        % scaling (i.e. difference between 0 and 85 degrees will be 85).
        dist = mod(differences, dirRange);
        
        % Find the max difference in the neighbourhood with the recentered
        % scaling (difference betwen 0 and 85 is now 5 but the
        % discontinuity still exists).
        dist2 = mod(-1*differences, dirRange);
        
        % Take the min of the 2 roi variables, correctly representing the
        % differences and set the value in the alignment output to be the 
        % mean difference for pixel (i,j)
        alignmentMatrix(i,j) = mean(min(dist, dist2));
        
    end
    
end

end