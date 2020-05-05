function CalculateComboPicture(fileName, saveFolder, nhoodSize)

saveSuffix = "_SAS.mat";

load(fileName);

sampleName = GetSectionFromPath(fileName, "end", [], 2, '_'); % Change 2 back to 1
sampleName = sampleName{1};
%sample_std(HH_norm > WL_thresh) = 0;
%aligned(HH_norm > WL_thresh) = 10;
%rSquared(HH_norm > WL_thresh) = 0;

imgSize = size(sample_std);

sasImage = zeros(imgSize);
if (isfile(saveFolder + sampleName + saveSuffix))
    return
end

for i = 1:imgSize(1)
    
    if(mod(i,100) == 0)
        disp(num2str(i)+"/"+imgSize(1));
    end
    
    for j = 1:imgSize(2)  
        
        roi_std = sample_std(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        roi_al = aligned(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        roi_r2 = rSquared(max(1, i - nhoodSize): min(imgSize(1), i + nhoodSize), max(1, j - nhoodSize): min(imgSize(2), j + nhoodSize));
        
        med_std = median(roi_std,'all');
        med_al = median(roi_al,'all');
        roi_r2(roi_r2 < 0.75) = 0;
        above75 = sum(logical(roi_r2),'all')/numel(roi_r2);
        sasImage(i,j) = med_std/med_al*above75;
        
    end
    
end

save(saveFolder + sampleName + saveSuffix, 'sasImage');

end