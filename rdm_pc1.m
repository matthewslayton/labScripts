% my x values will be the items' PC1 scores, and so will my y values

% itemListArray is the original order, which is alphabetical
% x_pc1 is the PC coefficients in the original word order.
load 'x_pc1.mat' % x_pc1 is a variable in mds_practice.m

store_distances = zeros(length(x_pc1),length(x_pc1)); 
for value = 1:length(x_pc1)
    for value2 = 1:length(x_pc1)
        store_distances(value,value2) = pdist([x_pc1(value);x_pc1(value2)],'euclidean');
    end
end

save('x_pc1_rdm.mat','store_distances') 

% could also do x_pc1_sorted which is in numerical order and
% itemList_array_sorted

load 'x_pc1_sorted.mat'

store_distances_sorted = zeros(length(x_pc1_sorted),length(x_pc1_sorted)); 
for value = 1:length(x_pc1_sorted)
    for value2 = 1:length(x_pc1_sorted)
        store_distances_sorted(value,value2) = pdist([x_pc1_sorted(value);x_pc1_sorted(value2)],'euclidean');
    end
end

save('x_pc1_sorted_rdm.mat','store_distances_sorted') 

load 'x_pc1_coeff.mat'

store_distances_coeff = zeros(length(x_pc1_coeff),length(x_pc1_coeff)); 
for value = 1:length(x_pc1_coeff)
    for value2 = 1:length(x_pc1_coeff)
        store_distances_coeff(value,value2) = pdist([x_pc1_coeff(value);x_pc1_coeff(value2)],'euclidean');
    end
end

save('x_pc1_coeff_rdm.mat','store_distances_coeff') 