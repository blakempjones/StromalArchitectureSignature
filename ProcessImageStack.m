function ProcessImageStack(rootFolder, saveFolder, blankExposureTime, crossExposureTime, numAngles, blankWLAv, saveStack)

% Calculate constant used for birefringence calculation normalization
crossMultiple = crossExposureTime / blankExposureTime;

% Names of Things
suffix = ".czi";
blankPrefix = "blank";
wlBlankPrefix = "HH_blank";
wlPrefix = "HH";
savePrefix = "_stitch_save.mat";
stitchedSuffix = "_Stitched";

% Name of the save file
imageName = split(rootFolder,{'/', '\'});
imageName = imageName(end - 1) + stitchedSuffix;

% Empirically found for 5 micron thick FFPE slides
WL_thresh = 0.86;

% Image registration configuration
[optimizer, metric] = imregconfig('multimodal');
optimizer.InitialRadius = 0.003;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

variablesToSave = {'HH_norm','aligned','sample_std','dirImage','rSquared', ...
    'lin_reta','biref','WL_thresh'};

if (saveStack)
    variablesToSave{end+1} = 'crossStack';
end

if (isempty(blankWLAv))
    
    blankFolder = split(rootFolder,{'/', '\'});
    blankFolder = join(blankFolder(1:end-2), '/') + "/";
    
    % Load in and find averages of crossed polarizer blanks
    regBlank = bfopen(char(blankFolder+blankPrefix+suffix));
    for i = 1:numAngles
        blankAv(i) = mean(double(regBlank{1, 1}{i,1}), "all");
    end
    
    % Load and compute the average of the whitelight blanks
    regWLBlank = bfopen(char(blankFolder+wlBlankPrefix+suffix));
    blankWLAv = mean(mean(regWLBlank{1,1}{1,1}));
    
end

% Open the raw PLM stack
regCross = bfopen(char(rootFolder+imageName+suffix));

% Get the size of a single PLM stack image
sizeRef = size(regCross{1,1}{1,1});

% PLM stack holder
crossStack = zeros(sizeRef(1), sizeRef(2), numAngles);

% Load the PLM stack
for i = 1:numAngles
    crossStack(:,:,i) = double(regCross{1,1}{i,1});
end

% Region to use for the image registration
regWindowSize = 250;
co_row_start = floor(sizeRef(1)/2) - regWindowSize;
co_row_stop = floor(sizeRef(1)/2) + regWindowSize;
co_col_start = floor(sizeRef(2)/2) - regWindowSize;
co_col_stop = floor(sizeRef(2)/2) + regWindowSize;

% Define the reference image used for the image registration
refNumber = floor(numAngles/2.0);
ref = crossStack(:,:,refNumber);

% Align each image in the stack in case of any shifting
for i = 1:numAngles
    
    disp(i)
    
    temp_target = squeeze(crossStack(:,:,i));
    
    % Compute the registration transform using the middle image as
    % the reference.
    try
        tform(i) = imregtform(temp_target(co_row_start:co_row_stop,co_col_start:co_col_stop), ref(co_row_start:co_row_stop,co_col_start:co_col_stop), 'translation', optimizer, metric);
    catch ex
        size(temp_target)
        size(ref)
        imageName
        rootFolder
        isfile(char(rootFolder+imageName+suffix))
        %error(ex.message)
        return;
    end
    % Align the image
    crossStack(:,:,i) = imwarp(squeeze(crossStack(:,:,i)),tform(i),'OutputView',imref2d(sizeRef));
    
    % Why is this commented out?
    %crossStack(:,:,i) = crossStack(:,:,i) - blankAv(i);
end

% Open the whitelight image of the slide
regWL = bfopen(char(rootFolder+wlPrefix+suffix));
HH_norm =regWL{1,1}{1,1};

% Align the whitelight with the middle PLLM image
tformHH = imregtform(HH_norm(co_row_start:co_row_stop,co_col_start:co_col_stop), ref(co_row_start:co_row_stop,co_col_start:co_col_stop), 'translation', optimizer, metric);
HH_norm = imwarp(HH_norm,tformHH,'OutputView',imref2d(sizeRef));

% Normalize the whitelight by the whitelight average intensity
HH_norm = double(HH_norm)./blankWLAv;

%Standard Deviation Image
clc; disp("      Calculating Standard Deviation Image");
sample_std = std(crossStack, 0, 3);

%Direction
clc; disp("      Calculating Direction Image");
[~, dirImage] = max(crossStack, [], 3);

%Alignment Image
clc; disp("      Calculating Alignment Image");
aligned = ComputeAlignment(dirImage, size(crossStack, 3), 2);

%R2 Image
clc; disp("      Calculating R2 Image");
rSquared = ComputeRSquared(crossStack, 5, 90, 5);

% Period Image
%clc; disp("      Calculating Period Image");
%period = ComputePeriod(crossStack);

% Retardance Image
clc; disp("      Calculating Retardance/Birefringence Image");

wavelength = 633; %nm
thickness = 5000; %nm

lin_reta = real(2*asind(sqrt(max(double(crossStack),[],3)./(blankWLAv*crossMultiple))));
biref = real(wavelength*asin(sqrt(max(double(crossStack),[],3)./(blankWLAv*crossMultiple))))/(pi*thickness);

%Save
clc; 
disp("      Saving");
save(saveFolder + imageName + savePrefix, variablesToSave{:}, '-v7.3', '-nocompression')

end
