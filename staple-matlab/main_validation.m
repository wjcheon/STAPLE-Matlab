clc
clear
close all
%%
% originalPath = "\\172.20.202.87\Users\keem\staple\original2_staple_result_model2_target_0.20_kidney_0.65"
originalPath = "\\172.20.202.87\Users\keem\staple\test210909_staple_result_model2_target_0.20_kidney_0.30"
folderList_original = dir(originalPath)
folderList_original(1:2,:) = []
originalPaitentSet = {}
for iter1 = 1: size(folderList_original, 1)
   originalSet = zeros(512,512,1);
   disp(iter1)
   folderTemp = fullfile(originalPath, folderList_original(iter1).name);
   fileList = dir(fullfile(folderTemp, '*.png'));
   
   for iter2 = 1: size(fileList, 1)
       tempImg = imread(fullfile(folderTemp, fileList(iter2).name));
       originalSet(:,:,iter2) = tempImg;
   end
   originalPaitentSet{iter1} = originalSet;
   
end

%%
rePath = "\\172.20.202.87\Users\keem\staple\Final_staple_result_model2_target_0.20_kidney_0.35"
rePath = "\\172.20.202.87\Users\keem\staple\Final_staple_result_model2_target_0.20_kidney_0.30"
folderList_re = dir(rePath)
folderList_re(1:2,:) = []
rePaitentSet = {}
for iter1 = 1: size(folderList_re, 1)
   disp(iter1)
   reSet = zeros(512,512,1);
   folderTemp = fullfile(rePath, folderList_re(iter1).name);
   fileList = dir(fullfile(folderTemp, '*.png'));
   
   for iter2 = 1: size(fileList, 1)
       tempImg = imread(fullfile(folderTemp, fileList(iter2).name));
       reSet(:,:,iter2) = tempImg;
   end
   rePaitentSet{iter1} = reSet;
   
end

%%
szPatient = size(originalPaitentSet, 2);
for iter3 = 1: szPatient
    originalTemp = originalPaitentSet{iter3};
    reTemp = rePaitentSet{iter3};
    
    disp(sum(originalTemp(:)))
    disp(sum(reTemp(:)))
    
    
    aa(iter3) = sum(originalTemp(:)-reTemp(:));
    
end
%%
nn = 23 
originalTemp = originalPaitentSet{nn};
reTemp = rePaitentSet{nn};

figure
iter22= 13
for iter22= 1:size(reTemp, 3)
   img1 =  squeeze(originalTemp(:,:,iter22));
   img2 =  squeeze(reTemp(:,:,iter22));
   imgDiff = img1-img2;
   disp(unique(imgDiff))
   tempDiff(iter22) = sum(img1(:)-img2(:));
   subplot(1,3,1), imshow(img1, [])
   subplot(1,3,2), imshow(img2, [])
   subplot(1,3,3), imshow(img1-img2, [])
   title(iter22)
   drawnow
    
end
% disp(sum(originalTemp(:)-reTemp(:)))
%%

