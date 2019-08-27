sample = double(sample);
sampleSize = size(sample);
rsquaredVals = zeros(sampleSize(1),sampleSize(2));
x = 1:18;

parfor i = 1:2048
    i
    for j = 1:2048
        
        [~,gof] = fit(x',squeeze(sample(i,j,:)), 'sin1');
        rsquaredVals(i,j) = gof.rsquare;
    end
end