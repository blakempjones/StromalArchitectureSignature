function ProcessPolImagesWithStitchedTiling(rootFolder, crossMultiple)



% Get list of folders in the rootFolder


roiFolders = dir(rootFolder);

roiFolders = {roiFolders([roiFolders.isdir]).name};

roiFolders = roiFolders(roiFolders ~= "." & roiFolders ~= "..");

numROIs = length(roiFolders);


% Make Folder to hold save files

saveFolder = rootFolder + "SaveFiles";
mkdir(saveFolder);


%Names of Things

stitchSuffix = "_stitch.czi";
suffix = ".czi";
crossSuffix = "_Stitched.czi";
blankPrefix = "blank";

wlBlankPrefix = "HH_blank";

wlPrefix = "HH";


%Universal Numbers

numAngles = 18;

[optimizer, metric] = imregconfig('multimodal');

optimizer.InitialRadius = 0.003;

optimizer.Epsilon = 1.5e-4;

optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

WL_thresh = 0.86;



%Load in and find averages of blanks 
regBlank = bfopen(char(rootFolder+blankPrefix+suffix));


%Blanks

for i = 1:numAngles

temp_blank = regBlank{1, 1}{i,1};

blankAv(i) = mean(mean(double(temp_blank)));

end


regWLBlank = bfopen(char(rootFolder+wlBlankPrefix+suffix));

blankWLAv = mean(mean(regWLBlank{1,1}{1,1}));


% For each folder

for k = 1 : numROIs

        
clc; disp("Working on Image: " + num2str(k) + "/" + num2str(numROIs));disp("      Loading & Registering Files");

clear crossStack;
clear dirImage; 
clear HH_norm; 
clear sample_std; 
clear rSquared; 
clear period; 
clear aligned; 
clear biref; 
clear lin_reta;      
        
% Current folder path
        
currFolderPath = rootFolder + roiFolders(k) + "/";

if(~isfile(saveFolder + "/" + roiFolders(k)+"_stitch_save.mat"))
  
         regCross = bfopen(char(currFolderPath+roiFolders(k)+suffix));
            
            
for i = 1:numAngles
                
crossStack(:,:,i) = regCross{1,1}{i,1};
            
end
            
            

co_col_start = 750;
            
co_col_stop = 1250;
            
co_row_start = 750;
            
co_row_stop = 1250;
            
sizeRef = imref2d(size(crossStack(:,:,1)));
            
crossStack = double(crossStack);
            
ref = crossStack(:,:,9);
            
for i = 1:numAngles
            
disp(i)
            
temp_target = squeeze(crossStack(:,:,i));
            
tform(i) = imregtform(temp_target(co_row_start:co_row_stop,co_col_start:co_col_stop), ref(co_row_start:co_row_stop,co_col_start:co_col_stop), 'translation', optimizer, metric);

crossStack(:,:,i) = imwarp(squeeze(crossStack(:,:,i)),tform(i),'OutputView',sizeRef);
            
%crossStack(:,:,i) = crossStack(:,:,i) - blankAv(i);
            
end
            
            

regWL = bfopen(char(currFolderPath+wlPrefix+suffix));
            
HH_norm =regWL{1,1}{1,1};
 
tformHH = imregtform(HH_norm(co_row_start:co_row_stop,co_col_start:co_col_stop), ref(co_row_start:co_row_stop,co_col_start:co_col_stop), 'translation', optimizer, metric);      
            
HH_norm = imwarp(HH_norm,tformHH,'OutputView',sizeRef);
      
HH_norm = double(HH_norm)./blankWLAv;

%Standard Deviation Image
            
clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));disp("      Calculating Standard Deviation Image");
            
sample_std = zeros(size(crossStack,1),size(crossStack,2));
            
sample_std = std(crossStack,[],3);
for i = 1:size(crossStack,1)
                
for j = 1:size(crossStack,2)
                    
sample_std(i,j) = std(squeeze(crossStack(i,j,:)));
                
end
            
end
            
            

%Direction
            
clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));disp("      Calculating Direction Image");

dirImage = zeros(size(crossStack,1),size(crossStack,2));
            
[~,dirImage2] = max(crossStack,[],3);
            
for i = 1:size(crossStack,1)
                
for j = 1:size(crossStack,2)
                    
[a,b] = max(squeeze(crossStack(i,j,:)));
                    
dirImage(i,j) = b;
                
end
            
end
         
            
%Alignment Image
            
clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));disp("      Calculating Alignment Image");

aligned = ComputeAlignment(dirImage,2);

%R2 Image
            
clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));disp("      Calculating R2 Image");
            
rSquared = ComputeRSquared(crossStack);
            
           

 % Period Image
            
clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));disp("      Calculating Period Image");
            
%period = ComputePeriod(crossStack);
            
            

% Retardance Image
            
clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));disp("      Calculating Retardance/Birefringence Image");
            
lin_reta = real(2*asind(sqrt(max(double(crossStack),[],3)./(blankWLAv*crossMultiple)))); %look into this
            
biref = real(633*asin(sqrt(max(double(crossStack),[],3)./(blankWLAv*crossMultiple))))/(pi*5000); %look into this
            
             

%Save
            clc; disp("Working on ROI: " + num2str(k) + "/" + num2str(numROIs));
            disp("      Saving");
            
%save(saveFolder + "\" + roiFolders(k)+"_save.mat",'HH_norm','crossStack', ...
            
%    'sample_std','dirImage', 'aligned','rSquared','period','lin_reta','biref','WL_thresh')
            
%save(saveFolder + "\" + roiFolders(k)+"_simple_save.mat",  'HH_norm',...
            
%    'sample_std','dirImage','aligned','rSquared','period','lin_reta','biref','WL_thresh')

 	    
save(saveFolder + "/" + roiFolders(k)+"_stitch_save.mat",  'HH_norm','aligned',...
                'sample_std','dirImage','rSquared','lin_reta','biref','WL_thresh')
            
        

else
            
disp(roiFolders(k)+"was already processed ")
        
end

end