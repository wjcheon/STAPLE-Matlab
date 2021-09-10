clc
clear
close all
% addpath('model2')
%%
mainPath = "\\172.20.202.87\Users\keem\staple\models\model2"
targetWeight = 0.2;
kidneyWeight =0.3;
savePath = sprintf("\\\\172.20.202.87\\Users\\keem\\staple\\test210909-1_staple_result_model2_target_%1.2f_kidney_%1.2f", targetWeight, kidneyWeight);

folderList = dir(mainPath);
folderList(1:2) = [];
patientNumber = 83;

for iter1= 1: patientNumber
    fprintf("%d th data was collected !!\n", iter1)
    fileNamePatient = sprintf('test%03d',iter1);
    eval(sprintf('test%03d={};',iter1));
    
    for iter2= 1: size(folderList , 1)
        perPatientPath = fullfile(mainPath, folderList(iter2).name, fileNamePatient);
        labelList = dir(fullfile(perPatientPath, '*.png'));
        szLabelList = size(labelList, 1);
        label3DPerPatient = [];
        for iter3= 1: szLabelList
            labelTemp = imread(fullfile(perPatientPath, labelList(iter3).name));
            label3DPerPatient(:,:,iter3) = labelTemp;
        end
        eval(sprintf('test%03d{iter2}=label3DPerPatient;',iter1));
    end
end


%%
kidneySum = []
tumorSum = []
for iter4=1:patientNumber
%     iter4=23
    fprintf("%d th data was generated !!\n", iter4)
    cellTemp = eval(sprintf('test%03d', iter4));
    label0 ={};
    label1 ={};
    label2 ={};
    for iter5= 1: size(cellTemp, 2)
        cellLabelTemp = cellTemp{iter5};
        label0Temp = double(cellLabelTemp==0);
        label1Temp = double(cellLabelTemp==1);
        label2Temp = double(cellLabelTemp==2);
        
        label0{iter5} = label0Temp;
        label1{iter5} = label1Temp;
        label2{iter5} = label2Temp;
    end
    
    strNumsV = [1:size(cellTemp,2)];
    
    % Label 0 
    %     [apparent3M_label0,staple3M_label0,reliability3M_label0] = calcConsensus_standardalone(strNumsV,label0);
    % Label 1 
    [apparent3M_label1,staple3M_label1,reliability3M_label1, iterF1] = calcConsensus_standardalone(strNumsV,label1);
    mask1= uint8(staple3M_label1 >= kidneyWeight);  % boolean to uint8
    iterSummary(iter4,1) = iterF1;
    kidneySum(iter4) = sum(mask1(:));
    clear iterF1 
    % Label 2 
    [apparent3M_label2,staple3M_label2,reliability3M_label2, iterF2] = calcConsensus_standardalone(strNumsV,label2);
    mask2= uint8((staple3M_label2 >= targetWeight).*2.0);  % boolean to uint8
    tumorSum(iter4) = sum(mask2(:));
    iterSummary(iter4,2) = iterF2;
    clear iterF2 
% %     Visualization
%         figure
%         for iter1 = 1:size(mask2,3)
%             tempImg= squeeze(mask2(:,:,iter1));  % boolean to uint8
%             imshow(tempImg, [])
%         end
    
    labelFinal = mask1+mask2;
    labelFinal(labelFinal>2)=2;
    
%     figure,
    patientIndex =sprintf('test%03d', iter4);
    savePathFinal = fullfile(savePath, patientIndex);
    mkdir(savePathFinal)
    for iter100 = 1: size(labelFinal , 3)
        tempImg = uint8(squeeze(labelFinal(:,:,iter100)));
        % Visualization
        %         imshow(tempImg, [])
        %         pause(0.1)
        savefileName = sprintf('%05d.png', iter100);
        imwrite(tempImg,fullfile(savePathFinal, savefileName))
    end
end
disp('DONE')