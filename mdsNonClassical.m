 %Create MDS plot values then export for use in matlab 

cd('/Users/mariamhovhannisyan/Box Sync/ElectricDino/Projects/Object_Memorability/Mariam_AMT/Visual/VGG16_RSMs');

layer2 = load("layer_2_corr_matrix_nan.mat");
layer12 = load("layer_12_corr_matrix_nan.mat");
layer22 = load("layer_22_corr_matrix_nan.mat");
layer31 = load("layer_31_corr_matrix_nan.mat");



X1 = 1-layer2.R; 
X2 = 1-layer12.R;
X3 = 1-layer22.R;
X4 = 1-layer31.R;

X1(isnan(X1))=0;
X2(isnan(X2))=0;
X3(isnan(X3))=0;
X4(isnan(X4))=0;

Y_2 = mdscale(X1,2);
Y_12 = mdscale(X2,2);
Y_22 = mdscale(X3,2); 
Y_31 = mdscale(X4,2);

%write MDS matrices for DNN layers to to excel
csvwrite('MDS_layer2_VGG.csv', Y_2 );
csvwrite('MDS_layer12_VGG.csv', Y_12);
csvwrite('MDS_layer22_VGG.csv', Y_22);
csvwrite('MDS_layer31_VGG.csv', Y_31);

layers = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24' '25' '26' '27' '28' '29' '30' '31' '32' '33' '34' '35' '36' '37' '38' '39'};

for i = 1:size(layers,2)
    rsm_files = sprintf('layer_%s_corr_matrix_nan.mat', layers{i});
    rsm = load(rsm_files);
                                             
end 

%%%%%%% MD plots for STAMP - Taxonomic  %%%%%%%%%
cd('/Users/mariamhovhannisyan/Box Sync/ElectricDino/Projects/Object_Memorability/STAMP');


stamp_vgg2 = cell2mat(table2cell(readtable("stamp_rdmVGG_L02.csv")));
stamp_vgg12 = cell2mat(table2cell(readtable("stamp_rdmVGG_L12.csv")));
stamp_vgg22 = cell2mat(table2cell(readtable("stamp_rdmVGG_L22.csv")));

X1 = 1-stamp_vgg2;
X2 = 1-stamp_vgg12;
X3 = 1-stamp_vgg22;

layer2 = mdscale(X1,2);
layer2b= mdscale(X1,2,'criterion', 'sstress'); %same organization as layer2 mds
layer12 = mdscale(X2,2);
layer22 = mdscale(X3,2);

csvwrite('STAMP_MDS_layer2_coords.csv', layer2);
csvwrite('STAMP_MDS_layer12_coords.csv', layer12);
csvwrite('STAMP_MDS_layer22_coords.csv', layer22);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% trying taxonomic for STAMP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stamp_taxRDM = cell2mat(table2cell(readtable("stamp_rdm4Tax_copy.csv")));

%locations for NaNs (concepts) that will need to be removed 
col_locs = find(all(isnan(stamp_taxRDM),2));
row_locs = find(all(isnan(stamp_taxRDM),1));

k = randperm(size(stamp_taxRDM, 1));
X4b = stamp_taxRDM;
X4b(k(1:240),:) = NaN; X4b(:,k(1:240)) = NaN;

out = X4b(:,any(~isnan(X4b))); % for nan - columns
out2 = out(any(~isnan(out),2),:);  % for nan - rows
X4 = 1-out2;

%locations for NaNs (concepts) that will need to be removed 
col_locs = find(all(isnan(stamp_taxRDM),2));
row_locs = find(all(isnan(stamp_taxRDM),1));

tax = mdscale(X4,2,'criterion','sstress');
plot(tax(:,1),tax(:,2),'o')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% trying visual features for STAMP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stamp_visRDM = cell2mat(table2cell(readtable("stamp_rdm1Vis.csv")));

%locations for NaNs (concepts) that will need to be removed 
col_locs = find(all(isnan(stamp_visRDM),2));
row_locs = find(all(isnan(stamp_visRDM),1));

k = randperm(size(stamp_visRDM, 1));
X4b = stamp_visRDM;
X4b(k(1:240),:) = NaN; X4b(:,k(1:240)) = NaN;

out = X4b(:,any(~isnan(X4b))); % for nan - columns
out2 = out(any(~isnan(out),2),:);  % for nan - rows
X4 = 1-out2;

%locations for NaNs (concepts) that will need to be removed 
col_locs = find(all(isnan(stamp_taxRDM),2));
row_locs = find(all(isnan(stamp_taxRDM),1));

viz = mdscale(X4,2,'criterion','sstress');
plot(viz(:,1),viz(:,2),'o')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% trying encyclopaedic features for STAMP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stamp_visRDM = cell2mat(table2cell(readtable("stamp_rdm3Enc.csv")));

%locations for NaNs (concepts) that will need to be removed 
col_locs = find(all(isnan(stamp_visRDM),2));
row_locs = find(all(isnan(stamp_visRDM),1));

k = randperm(size(stamp_visRDM, 1));
X4b = stamp_visRDM;
X4b(k(1:240),:) = NaN; X4b(:,k(1:240)) = NaN;

out = X4b(:,any(~isnan(X4b))); % for nan - columns
out2 = out(any(~isnan(out),2),:);  % for nan - rows
X4 = 1-out2;

%locations for NaNs (concepts) that will need to be removed 
col_locs = find(all(isnan(stamp_taxRDM),2));
row_locs = find(all(isnan(stamp_taxRDM),1));

enc = mdscale(X4,2,'criterion','sstress');
plot(enc(:,1), enc(:,2), 'o')


