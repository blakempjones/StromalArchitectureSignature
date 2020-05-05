function ApplyFunctionToMultipleImages(rootFolder, iterateFolders, namesToExclude, ... 
passCurrName, fcnHandle, collateFcnHandle, varargin)
%
% Utility function to handle the iteration logic for batch processing. 
% 
% Input:
%   - rootFolder: Path to the folder containing the subfolders or files to
%       iterate through.
%   - iterateFolders: Boolean flag indicating whether the iteration should
%       expect a folder structure like:
%               - rootFolder     or    - rootFolder
%                     - folder1              - file1
%                     - folder2              - file2
%   - namesToExclude: a cell array of character vectors containing any
%       folders or files to skip in the iteration.
%   - passCurrName: Boolean flag to determine whether to pass the path of
%       the name of the current file or folder.
%   - fcnHandle: Function to be applied in each sub-folder or to each file.
%       Should contain any loading and saving required as all that will be
%       passed to it is the name of the current file or folder, and any
%       variables in varargin before the CollateVars flag. Can output an
%       unspecified number of variables that will then be handled by the
%       collate function. Be aware these variables are collated once at the
%       end of processing, so large data or images should be saved within
%       this function and not returned.
%   - collateFcnHandle: If fcnHandle returns output variables, the function
%       specified by collateFcnHandle can serve as an aggregate function,
%       grouping or saving as needed. The @save function can be passed directly
%       if simple saving is all that is required.

% Varargin variables
numFixedVars = 6;
vararginSize = nargin - numFixedVars;
collateKeyword = "CollateVars";
collateVarsStart = 0;
numLogicVars = vararginSize;

% Finding the start of the collate function inputs
for i = 1 : vararginSize
    if (isstring(varargin{i}))
        if (strncmp(collateKeyword, varargin{i}, 15))
            collateVarsStart = i+1;
            numLogicVars = i-1;
            break;
        end
    end
end

% Get list of folders or files in the rootFolder
roiFolders = dir(rootFolder);

if (iterateFolders)
    roiFolders = {roiFolders([roiFolders.isdir]).name};
    roiFolders = roiFolders(roiFolders ~= "." & roiFolders ~= "..");
else
    roiFolders = {roiFolders(~[roiFolders.isdir]).name};
end

if (~isempty(namesToExclude))
    roiFolders = setdiff(roiFolders, namesToExclude);
end
    
numROIs = length(roiFolders);

numOutputVars = nargout(fcnHandle);

outputVars = cell(numROIs, 1);

% For each folder
for k = 1 : numROIs
    
    clc; disp("Working on Image: " + num2str(k) + "/" + num2str(numROIs));
    
    tempCell = {};
    
    if (passCurrName)
        % Current folder path
        currFolderPath = rootFolder + roiFolders(k);
        
        % Add a slash to currFolderPath if iterating over folders and not
        % files.
        if (iterateFolders)
            currFolderPath = currFolderPath + "/";
        end
        
        if (numLogicVars == 0)
            [tempCell{1:numOutputVars}] = fcnHandle(currFolderPath);
        else
            [tempCell{1:numOutputVars}] = fcnHandle(currFolderPath, varargin{1:numLogicVars});          
        end       
    else
        if (numLogicVars == 0)
            [tempCell{1:numOutputVars}] = fcnHandle();      
        else 
            [tempCell{1:numOutputVars}] = fcnHandle(varargin{1:numLogicVars});
        end
    end
    
    if(numOutputVars > 0)
        outputVars{k} = tempCell;
    end
        
end % For each file

if (numOutputVars > 0 && ~isempty(collateFcnHandle))
    if (collateVarsStart == 0)
        collateFcnHandle(outputVars);
    elseif (isequal(collateFcnHandle, @save))
        collateFcnHandle(string(varargin(collateVarsStart)), 'outputVars');
    else
        collateFcnHandle(outputVars, varargin{collateVarsStart:end});
    end    
end

end % Function