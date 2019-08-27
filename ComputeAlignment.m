function alignmentMatrix = ComputeAlignment(dirImage, nhoodSize)

dirImage(isnan(dirImage)) = 0;

imgSize = size(dirImage);

changeMatrix = 10*ones(imgSize);

adjustedImage = dirImage;
adjustedImage(adjustedImage <= 9) = adjustedImage(adjustedImage <= 9) + 18;
adjustedImage = adjustedImage - 9;

alignmentMatrix = zeros(imgSize);

for i = 1:imgSize(1)
    
    for j = 1:imgSize(2)
        
        roi = dirImage(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        roi2 = adjustedImage(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        alignmentMatrix(i,j) = min(std(roi, 0, 'all'), min(std(roi2, 0, 'all')));
        
    end
    
end

alignmentMatrix(alignmentMatrix == 0) = max(alignmentMatrix, [], 'all') + 1;

alignmentMatrix = -1 * alignmentMatrix;

end