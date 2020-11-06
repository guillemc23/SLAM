%% MASTER
clc;
%% Verificar componentes necesarios
% fList -> funciones necesarias
% pList -> toolboxes necesarias
[fList,pList] = matlab.codetools.requiredFilesAndProducts('master.m');

disp({pList.Name});

% for i= 1:length(fList)
%     t = strsplit(fList{i},pwd) ;
%     disp(t{2})
% end

%pause

%%

addpath('f')

G_classNames = [ "sea","water","roads","vegetation","buildings","terrain",]; 
sensors = ["LWIR", "MWIR", "VIS"];
global res map;
res = [1024 1280];
frameRawFolder = './frames_raw/Dubai';
frameFolderOutput = './frames/';
databaseFolder = './frames_database/';
cmapIR = gray(256);
map = [0 0 0.5          % SEA
    0.012 0.161 1.0     % WATER
    0.021 0.021 0.021   % ROADS
    0 0.7 0             % VEGETATION
    1 0.03 0            % BUILDINGS
    0.5 0.4 0           % TERRAIN
    ];

%foldersList = dir(frameRawFolder);

%% Generar base de datos
createDatabase = true;

global cameraParams
run('narcisus')
run('calibrator')

%dataPacker(frameRawFolder, frameFolderOutput, databaseFolder)

if createDatabase
    n = dataPacker(0,frameRawFolder,databaseFolder,frameFolderOutput);
%     run('frameparty')
end

%% Entrenamiento
train = true;
if train
    run('params')
    run('opts04')
    run('trainer')
else
    load('multispectralUnet-29-07-2020-16-40-13-Epoch-20.mat')
end

%% Test

tic;
frameRawTestFolder = './frames_raw/Kremlin';
foldersList = dir(frameRawTestFolder);
databaseFolder = './testframes_database/';

% de entrada necesita database folder y frameRawTestFolder y frameFolderOutput
    for i = 1:1
    ficheroIdentificador = fullfile(frameRawTestFolder,foldersList(i).name,'IdentificadoresBlancosEscenario.xml');
    %tags = xmlReader(ficheroIdentificador);
    framesLWIR = fullfile(frameRawTestFolder,foldersList(i).name, 'LWIR');
    framesMWIR = fullfile(frameRawTestFolder,foldersList(i).name, 'MWIR');
    framesVIS  = fullfile(frameRawTestFolder,foldersList(i).name, 'VIS');
    framesSeg = fullfile(frameRawTestFolder,foldersList(i).name, 'ids');
    
    listaFicheros_LWIR = fileSorter(framesLWIR);
    listaFicheros_MWIR = fileSorter(framesMWIR);
    listaFicheros_VIS = fileSorter(framesVIS);
    listaFicheros_Seg = fileSorter(framesSeg);
    
    tags = xmlReader(ficheroIdentificador);
    
    for j = 1:1
        frame  = zeros(res(1),res(2),5);
        gtruth = zeros(res(1),res(2),1);
        frameName = sprintf('%03d.png',j);
        frameFile = fullfile(listaFicheros_LWIR(j).folder,listaFicheros_LWIR(j).name);
        frameOutput_LWIR = fullfile(frameFolderOutput,foldersList(i).name, 'LWIR');
        [~, ~] = mkdir(frameOutput_LWIR);
        frameOutput_LWIR = fullfile(frameOutput_LWIR, frameName);
        frameLWIR = LeerFramesIR(frameFile);
        frameLWIR = narcisusCalibrator(frameLWIR);
        frameLWIR = undistortImage(frameLWIR,cameraParams);
%         imwrite(frameLWIR,cmapIR,frameOutput_LWIR);

        frameFile = fullfile(listaFicheros_MWIR(j).folder,listaFicheros_MWIR(j).name);
        frameOutput_MWIR = fullfile(frameFolderOutput,foldersList(i).name, 'MWIR');
        [~, ~] = mkdir(frameOutput_MWIR);
        frameOutput_MWIR = fullfile(frameOutput_MWIR, frameName);
        frameMWIR = LeerFramesIR(frameFile);
        frameMWIR = narcisusCalibrator(frameMWIR); 
        frameMWIR = undistortImage(frameMWIR,cameraParams);
%         imwrite(frameMWIR,cmapIR,frameOutput_MWIR);

        frameFile = fullfile(listaFicheros_VIS(3*j).folder,listaFicheros_VIS(3*j).name);
        frameOutput_VIS = fullfile(frameFolderOutput,foldersList(i).name, 'VIS');
        [~, ~] = mkdir(frameOutput_VIS);
        frameOutput_VIS = fullfile(frameOutput_VIS, frameName);
        frameVIS = LeerFramesVIS(frameFile);
        frameVIS = narcisusCalibrator(frameVIS);
        frameVIS = undistortImage(frameVIS,cameraParams);
%         imwrite(frameVIS,frameOutput_VIS);

        frameFile = fullfile(listaFicheros_Seg(j).folder,listaFicheros_Seg(j).name);
        frameOutput_Seg = fullfile(frameFolderOutput,foldersList(i).name, 'Seg');
        [~, ~] = mkdir(frameOutput_Seg);
        frameOutput_Seg = fullfile(frameOutput_Seg, frameName);
        frameSeg = LeerFramesIDs(frameFile);
        frameSeg = labeller(frameSeg, ficheroIdentificador);
        labelledImage = labeloverlay(ones(res),frameSeg,'Transparency', 0,'Colormap',map);
        labelledImage = undistortImage(labelledImage,cameraParams);
%         imwrite(labelledImage,frameOutput_Seg);
        
        frame(:,:,1)   = frameMWIR;
        frame(:,:,2)   = frameLWIR;
        frame(:,:,3:5) = frameVIS;
        gtruth(:,:,1) = frameSeg;
        frame = uint16(frame);
        gtruth = uint8(gtruth);
        
        name = strsplit(framesSeg, '/');
        [~,~] = mkdir(fullfile(databaseFolder, 'frames'));
        [~,~] = mkdir(fullfile(databaseFolder, 'gtruth'));
        frameNameMAT = fullfile(databaseFolder, 'frames', sprintf('%s_%03d.mat',name{3},j));
        gtruthNameMAT = fullfile(databaseFolder, 'gtruth', sprintf('%s_%03d.mat',name{3},j));
        save(frameNameMAT, 'frame');
        imwrite(gtruth,fullfile(databaseFolder, 'gtruth', sprintf('%s_%03d.png',name{3},j)));
        save(gtruthNameMAT, 'gtruth');
                
    end   
    end
fprintf('Test image(s) done\n');
toc;
%% sick testing skills
predictPatchSize = [1024 1280];
frame(:,:,6) = ones(res);
segmentedImage = segmentImage(frame,net,predictPatchSize);

gtruth = imread('./testframes_database/gtruth/Kremlin_002.png');

figure
imshow(segmentedImage,[])
title('Segmented Image')
%B = medfilt2(segmentedImage, [5,5]);
%B = ordfilt2(segmentImage,5,ones(5,5));
imshow(segmentedImage,[]);
title('Segmented Image  with Noise Removed')

sea_truth = gtruth == 1;
water_truth = gtruth == 2;
roads_truth = gtruth == 3;
vegetation_truth = gtruth == 4;
buildings_truth = gtruth == 5;
terrain_truth = gtruth == 6;

sea = segmentedImage == 1;
water = segmentedImage == 2;
roads = segmentedImage == 3;
vegetation = segmentedImage == 4;
buildings = segmentedImage == 5;
terrain = segmentedImage == 6;

B = labeloverlay(frame(:,:,3:5),segmentedImage,'Transparency',0,'Colormap',map);
% imwrite(B,'');
figure
imshow(B)
N = numel(G_classNames);
ticks = 1/(N*2):1/N:1;
title('Labeled Validation Image')
colorbar('TickLabels',cellstr(G_classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');
colormap(map)

imwrite(segmentedImage,'raw_results.png');
imwrite(gtruth,'gtruth.png');
imwrite(B,'getmapped.png');

pxdsResults = pixelLabelDatastore('raw_results.png',G_classNames,1:6);
pxdsTruth = pixelLabelDatastore('gtruth.png',G_classNames,1:6);

ssm = evaluateSemanticSegmentation(pxdsResults,pxdsTruth);%,'Metrics','global-accuracy');

figure;
for i=58:numel(net.Layers)
fprintf('%d - %s\n',i,net.Layers(i).Name);
title(sprintf('%d - %s',i,net.Layers(i).Name))
act1= activations(net, frame(:,:,1:5), net.Layers(i).Name);
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [floor(sqrt(sz(3))) ceil(sqrt(sz(3)))]);
imshow(I)
end

save 'david.mat' sea water roads vegetation buildings...
    terrain segmentedImage B gtruth frame I
%% Activations
act1= activations(net, frame, 'Encoder-Section-1-Conv-1');
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [8 8]);
imshow(I)

act1= activations(net, frame, 'Encoder-Section-1-ReLU-1');
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [8 8]);
imshow(I)

act1= activations(net, frame, 'Encoder-Section-1-Conv-2');
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [8 8]);
imshow(I)

act1= activations(net, frame, 'Encoder-Section-1-ReLU-2');
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [8 8]);
imshow(I)

act1= activations(net, frame, 'Encoder-Section-1-MaxPool');
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [8 8]);
imshow(I)

%% auto activations
figure;
for i=1:numel(net.Layers)
fprintf('%d - %s\n',i,net.Layers(i).Name);
title(sprintf('%d - %s',i,net.Layers(i).Name))
act1= activations(net, frame, net.Layers(i).Name);
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize', [floor(sqrt(sz(3))) ceil(sqrt(sz(3)))]);
imshow(I)
end