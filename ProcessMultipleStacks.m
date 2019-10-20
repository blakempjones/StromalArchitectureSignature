function ProcessMultipleStacks(rootFolder, blankExposureTime, crossExposureTime, numAngles)

% Get list of folders in the rootFolder
roiFolders = dir(rootFolder);
roiFolders = {roiFolders([roiFolders.isdir]).name};
roiFolders = roiFolders(roiFolders ~= "." & roiFolders ~= "..");

numROIs = length(roiFolders);

% Make Folder to hold save files
saveFolder = rootFolder + "SaveFiles/";
mkdir(saveFolder);

% Names of Things
suffix = ".czi";
blankPrefix = "blank";
wlBlankPrefix = "HH_blank";

% Load in and find averages of crossed polarizer blanks
regBlank = bfopen(char(rootFolder+blankPrefix+suffix));
for i = 1:numAngles
    blankAv(i) = mean(double(regBlank{1, 1}{i,1}), "all"); % Decide when needed
end

% Load and compute the average of the whitelight blanks
regWLBlank = bfopen(char(rootFolder+wlBlankPrefix+suffix));
blankWLAv = mean(mean(regWLBlank{1,1}{1,1}));

% For each folder
for k = 1 : numROIs
    
    clc; disp("Working on Image: " + num2str(k) + "/" + num2str(numROIs));disp("      Loading & Registering Files");
    
    % Current folder path
    currFolderPath = rootFolder + roiFolders(k) + "/";
    
    ProcessImageStack(currFolderPath, saveFolder, blankExposureTime, crossExposureTime, numAngles, blankWLAv);
    
end % For each file

end % Function