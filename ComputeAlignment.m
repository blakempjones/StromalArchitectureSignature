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

% Because of the periodic nature of the angle measurements (i.e. 90 = 0) we
% need to use a circular number space when computing the maximum
% difference. Otherwise the difference between 85 and 0 (5 degrees) will be
% over-represented.
adjustedImage = dirImage;
adjustedImage(adjustedImage <= 9) = adjustedImage(adjustedImage <= 9) + 18;
adjustedImage = adjustedImage - 9;

alignmentMatrix = zeros(imgSize);

for i = 1:imgSize(1)
    
    for j = 1:imgSize(2)
        % Find the max difference in the neighbourhood with the original
        % scaling (i.e. difference between 0 and 85 degrees will be 85).
        roi = dirImage(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        % Find the max difference in the neighbourhood with the recentered
        % scaling (difference betwen 0 and 85 is now 5 but the
        % discontinuity still exists).
        roi2 = adjustedImage(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        % Take the min of the 2 roi variables, correctly representing the
        % differences.
        alignmentMatrix(i,j) = min(std(roi, 0, 'all'), min(std(roi2, 0, 'all')));
    end
    
end

% Rescale the alignmentMatrix such that the higher the numerical value of
% the alignment metric, the more aligned a region is.
alignmentMatrix(alignmentMatrix == 0) = max(alignmentMatrix, [], 'all') + 1;
alignmentMatrix = -1 * alignmentMatrix;

end