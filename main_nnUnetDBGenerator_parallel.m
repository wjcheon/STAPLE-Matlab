clc
clear
close all
%%
pathTrainDicom = 'D:\brain\train\DICOM';
pathTrainLabel = "D:\brain\train\Label";
pathTestDicom = 'D:\brain\test\DICOM';
savePath = "D:\brainNNUNET-210820-11"
savePathImage = fullfile(savePath, 'imagesTr');
savePathLabel = fullfile(savePath, 'LabelsTr');
savePathImageTest = fullfile(savePath, 'imagesTs');
mkdir(savePath)
mkdir(savePathImage)
mkdir(savePathLabel)
mkdir(savePathImageTest)

dicomPathList = dir(pathTrainDicom );
dicomPathList(1:2)= [];
labelPathList = dir(pathTrainLabel);
labelPathList(1:2)= [];
dicomPathListTest = dir(pathTestDicom );
dicomPathListTest(1:2)= [];

% nnUNet json file.
fileID = fopen(fullfile(savePath, 'dataset.json'), 'w');
fprintf(fileID, '{\n');
fprintf(fileID,'"name": "BRAIN comp.", \n');
fprintf(fileID,'"description": "Custom dataset for nnUNet", \n');
fprintf(fileID,'"reference": "Wonjoong Cheon", \n');
fprintf(fileID,'"licence":"CC-BY-SA 4.0", \n');
fprintf(fileID,'"release":"1.0 17/08/2021", \n');
fprintf(fileID,'"tensorImageSize": "3D", \n');
fprintf(fileID,'"modality": { "0": "CT" }, \n');
fprintf(fileID,'"labels": { "0": "background", "1": "kidney", "2": "tumour" },  \n');
fprintf(fileID,'"numTraining": %d, \n', size(dicomPathList,1));
fprintf(fileID,'"numTest": %d, \n', size(dicomPathListTest, 1));
fprintf(fileID,'"training":[');

updateWaitbar = waitbarParfor(size(dicomPathList, 1), "Calculation in progress...");
parfor iterPatient = 1 : size(dicomPathList, 1)
    disp(iterPatient)
    tempPathDICOM = fullfile(pathTrainDicom, dicomPathList(iterPatient).name);
    tempPathLabel = fullfile(pathTrainLabel, labelPathList(iterPatient).name);
    tempDicomList = dir(fullfile(tempPathDICOM, '*.dcm'));
    tempLabelList = dir(fullfile(tempPathLabel, '*.png'));
    
    tempDicom = dicomread(fullfile(tempPathDICOM, tempDicomList(1).name));
    sizeTempDicom = size(tempDicom);
    patientDicomSetTemp = zeros(sizeTempDicom(1), sizeTempDicom(2), size(tempDicomList, 1));
    patientLabelSetTemp = zeros(sizeTempDicom(1), sizeTempDicom(2), size(tempDicomList, 1));
    for iter1 = 1: size(tempDicomList, 1)
        tempDicom = dicomread(fullfile(tempPathDICOM, tempDicomList(iter1).name));
        tempDicomInfo = dicominfo(fullfile(tempPathDICOM, tempDicomList(iter1).name));
        tempDicomHU = (tempDicom.*tempDicomInfo.RescaleSlope)+tempDicomInfo.RescaleIntercept;
        
        tempLabel = imread(fullfile(tempPathLabel, tempLabelList(iter1).name));
        % STACK
        patientDicomSetTemp(:,:,iter1) = tempDicomHU;
        patientLabelSetTemp(:,:,iter1) = tempLabel;
    end
    %patientDicomSetF = single(patientDicomSetTemp);
    scalingFactor = 2;
    sz_patientDicomSetTemp = size(patientDicomSetTemp);
    sz_patientLabelSetTemp = size(patientLabelSetTemp);
    patientDicomSetF = single(imresize3(patientDicomSetTemp, [sz_patientDicomSetTemp(1), sz_patientDicomSetTemp(2), sz_patientDicomSetTemp(3).*scalingFactor])); % up-scaling
    patientLabelSetF = uint8(imresize3(patientLabelSetTemp, [sz_patientLabelSetTemp(1), sz_patientLabelSetTemp(2), sz_patientLabelSetTemp(3).*scalingFactor], 'nearest')); % up-scaling
    
    singleFileName = [dicomPathList(iterPatient).name, '.nii'];
    nnUnetDicomFileName = fullfile(savePathImage, singleFileName);
    nnUnetLabelFileName = fullfile(savePathLabel, singleFileName);
    
    
    niftiwrite(patientDicomSetF,nnUnetDicomFileName, 'Compressed',true)
    niftiwrite(patientLabelSetF,nnUnetLabelFileName, 'Compressed',true)
    
    
    updateWaitbar(); %#ok<PFBNS>
end


f = waitbar(0,'Please wait... (TrainingSet:json)');
for iterPatient = 1 : size(dicomPathList, 1)
    % Writing nnUNet json
    singleFileName = [dicomPathList(iterPatient).name, '.nii'];
    fprintf(fileID,'{"image":"');
    fprintf(fileID,'./imagesTr/%s",', [singleFileName, '.gz']);
    % IF statement was wirtten for close the json file.
    if iterPatient == size(dicomPathList, 1)
        fprintf(fileID,'"label":"./labelsTr/%s"}], \n', [singleFileName, '.gz']);
    else
        fprintf(fileID,'"label":"./labelsTr/%s"},', [singleFileName, '.gz']);
    end
    
    waitbar(iterPatient/size(dicomPathList, 1),f,'Loading your data (Train)');
end
close(f)

%

updateWaitbar = waitbarParfor(size(dicomPathListTest, 1), "Calculation in progress...");
fprintf(fileID,'"test":[');
parfor iterPatient = 1 : size(dicomPathListTest, 1)
    disp(iterPatient)
    tempPathDICOM = fullfile(pathTestDicom, dicomPathListTest(iterPatient).name);
    tempDicomList = dir(fullfile(tempPathDICOM, '*.dcm'));
    
    tempDicom = dicomread(fullfile(tempPathDICOM, tempDicomList(1).name));
    sizeTempDicom = size(tempDicom);
    patientDicomSetTemp = zeros(sizeTempDicom(1), sizeTempDicom(2), size(tempDicomList, 1));
    
    for iter1 = 1: size(tempDicomList, 1)
        tempDicom = dicomread(fullfile(tempPathDICOM, tempDicomList(iter1).name));
        tempDicomInfo = dicominfo(fullfile(tempPathDICOM, tempDicomList(iter1).name));
        tempDicomHU = (tempDicom.*tempDicomInfo.RescaleSlope)+tempDicomInfo.RescaleIntercept;
        
        % STACK
        patientDicomSetTemp(:,:,iter1) = tempDicomHU;
    end
    
    % original
    patientDicomSetF = single(patientDicomSetTemp);
    
    % up-scaling 
%     scalingFactor = 2;
%     sz_patientDicomSetTemp = size(patientDicomSetTemp);
%     patientDicomSetF = single(imresize3(patientDicomSetTemp, [sz_patientDicomSetTemp(1), sz_patientDicomSetTemp(2), sz_patientDicomSetTemp(3).*scalingFactor])); % up-scaling
    
    singleFileName = [dicomPathListTest(iterPatient).name, '.nii'];
    nnUnetDicomFileName = fullfile(savePathImageTest, singleFileName);
    
    niftiwrite(patientDicomSetF,nnUnetDicomFileName, 'Compressed',true)
    
    updateWaitbar(); %#ok<PFBNS>
end


f = waitbar(0,'Please wait...(Test set:json)');
for iterPatient = 1 : size(dicomPathListTest, 1)
    % Writing nnUNet json
    % IF statement was wirtten for close the json file.
    %     fprintf(fileID,'"./imagesTs/%s",', [singleFileName, '.gz']);
    singleFileName = [dicomPathList(iterPatient).name, '.nii'];
    if iterPatient == size(dicomPathListTest, 1)
        fprintf(fileID,'"./imagesTs/%s"]\n', [singleFileName, '.gz']);
    else
        fprintf(fileID,'"./imagesTs/%s",', [singleFileName, '.gz']);
    end
    
    waitbar(iterPatient/size(dicomPathListTest, 1),f,'Loading your data (Test)');
end
close(f)
fprintf(fileID,'}');
fclose(fileID);

disp('Done!!')

%%
 nLoops = 100;
 
 updateWaitbar = waitbarParfor(nLoops, "Calculation in progress...");
 parfor loopCnt = 1:nLoops
     A = rand(5000);
     updateWaitbar(); %#ok<PFBNS>
 end
