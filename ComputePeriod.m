function periodImg = ComputePeriod(sample)

sample = single(sample);

sample(isnan(sample)) = 0;

maxs = max(sample, [], 3);

mins = min(sample, [], 3);

imgSize = size(sample);

periodImg = zeros(imgSize(1), imgSize(2));

for i = 1 : imgSize(1)
    
    for j = 1 : imgSize(2)
        maxInd = find(sample(i,j,:) ==  maxs(i,j), 1);
        minInd = find(sample(i,j,:) ==  mins(i,j), 1);
        periodImg(i,j) = maxInd - minInd;
    end
    
end
     
periodImg = abs(periodImg);

end