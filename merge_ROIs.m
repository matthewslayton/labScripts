clear
clc
cd('Y:\Christina\ROI\brainnetome')

% fusiform gyrus 103-108
counter = 0;
for roi = 103:108
    mask_file = dir(sprintf('ROI_masks_43_51_35/BNA_%d_*.nii', roi));
    mask = spm_read_vols(spm_vol([mask_file.folder '/' mask_file.name]));
    switch counter
        case 0; mask_merged = mask;
        otherwise; mask_merged = mask_merged + mask;
    end
    counter = counter + 1;
%     sum(mask, 'all')
end
% sum(mask_merged, 'all')

% template functional file to get correct fields
nii_property = spm_vol([mask_file.folder '/' mask_file.name]);

% write nifti
nii_property.fname = 'new_fus_ROI_mask.nii';
nii_property.private.dat.fname = nii_property.fname;
nii_property.descrip = 'merged fus ROIs 103-108';
spm_write_vol(nii_property, mask_merged);

