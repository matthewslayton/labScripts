
%define directories and mask files
maskdir='/Users/cortneyhoward/Desktop/Matt_Project/'; %%%ChangeTHIS%%%%%
betadir='/Users/cortneyhoward/Documents/RSA_Rotation/New_Stamp_Single_Trial/Analysis/Encoding/'; %%%ChangeTHIS%%%%%
outputdir='/Users/cortneyhoward/Desktop/Matt_Project/'; %%%ChangeTHIS%%%%%
cd (maskdir)
ROIfiles=dir('*.nii');
ROIlist = {ROIfiles.name}.';
sublist={'S002','S005'}; %%%ChangeTHIS%%%%%
%sub loop
for cursub = 1:length(sublist)
    sub=cell2mat(sublist(cursub));
    cd (strcat(betadir,sub,'/betas/')) 
    betafiles=dir('*.nii');
    betanames = {betafiles.name}.';
    %create empty vector for ROI by beta data for this subject
    ROImeans=zeros(length(betanames),length(ROIlist)+1);
    ROImeans(:,1)=repelem(str2double(extractAfter( sub, 'S' )),length(ROImeans));

%mask loop

for curROI = 1:length(ROIlist)
    %pull the mask
ROI=cell2mat(ROIlist(curROI));
curmask = load_untouch_nii(fullfile(maskdir,ROI));
%pull subject betas

for curbeta = 1:length(betanames)
    betafile=cell2mat(betanames(curbeta));
    beta= load_untouch_nii(betafile);
   

%Get the item ID
ROImeans(curbeta,2)=str2double(extractBetween( betafile, 'Item' , '_' ));
%get average activity across voxels in the current mask per beta
ROImeans(curbeta,curROI+2)=mean(beta.img(curmask.img==1));

end


if cursub==1
    tbl=ROImeans;
    %append sub table to group table
else
    tbl=[tbl;ROImeans];
end
%end sub loop
end
%converto to table and name variables for R
tbl=array2table(tbl);
tbl.Properties.VariableNames=[{'subjet'};{'item'};erase( ROIlist , '.nii')];
%write table
cd (outputdir)
writetable(tbl,'clustermeans.csv');

