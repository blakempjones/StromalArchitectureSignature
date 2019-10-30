function ApplyFunctionToMultipleImages(rootFolder, iterateFolders, namesToExclude, passCurrName, fcnHandle, varargin)

% namesToExclude must be a cell array of character arrays.

% Get list of folders or files in the rootFolder
roiFolders = dir(rootFolder);

if (iterateFolders)
    roiFolders = {roiFolders([roiFolders.isdir]).name};
    roiFolders = roiFolders(roiFolders ~= "." & roiFolders ~= "..");
else
    roiFolders = {roiFolders(~[roiFolders.isdir]).name};
end

if (isempty(namesToExclude))
    roiFolders = setdiff(roiFolders, namesToExclude);
end
    
numROIs = length(roiFolders);

% For each folder
for k = 1 : numROIs
    
    clc; disp("Working on Image: " + num2str(k) + "/" + num2str(numROIs));
    
    if (passCurrName)
        % Current folder path
        currFolderPath = rootFolder + roiFolders(k) + "/";
        fcnHandle(currFolderPath, varargin{:})
    else
        fcnHandle(varargin{:});      
    end
        
end % For each file

end % Function