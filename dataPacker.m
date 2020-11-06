function n = dataPacker(modo, frameRawFolder, databaseFolder, frameFolderOutput)
% n = DATAPACKER(modo, crudos, database, pngFolder)
% Lee los frames de una carpeta y en funci�n del modo seleccionado, los 
% empaqueta para la red, los genera en png o ambas.
%   modo = 0: empaqueta y png
%   modo = 1: empaqueta
%   modo = 2: png
%
% Es necesario introducir como variables la carpeta en la que se encuentran
% los frames en crudo, la carpeta donde guardar los frames empaquetados y
% la carpeta donde guardar los frames en png. Como output devuelve el
% n�mero de frames que han sido procesados.

tic;
global res
global cameraParams
global map

name = strsplit(frameRawFolder,'/');
name = char(name(numel(name)));

cmapIR = gray(256);
wb = waitbar(0,'Cargando rutas...','Name','Packing data...');

ficheroIdentificador = fullfile(frameRawFolder,'IdentificadoresBlancosEscenario.xml');
framesLWIR = fullfile(frameRawFolder,'LWIR');
framesMWIR = fullfile(frameRawFolder,'MWIR');
framesVIS  = fullfile(frameRawFolder,'VIS');
framesSeg = fullfile(frameRawFolder,'ids');

listaFicheros_LWIR = fileSorter(framesLWIR);
listaFicheros_MWIR = fileSorter(framesMWIR);
listaFicheros_VIS = fileSorter(framesVIS);
listaFicheros_Seg = fileSorter(framesSeg);

n = length(listaFicheros_LWIR);
for j = 1:n
    waitbar(j/length(listaFicheros_LWIR),wb,sprintf('Frame %d/%d',j,length(listaFicheros_LWIR)));
    frame  = zeros(res(1),res(2),5);
    gtruth = zeros(res(1),res(2),1);
    
    frameName = sprintf('%03d.png',j);
    
    frameFile = fullfile(listaFicheros_LWIR(j).folder,listaFicheros_LWIR(j).name);
    frameLWIR = LeerFramesIR(frameFile);
    frameLWIR = narcisusCalibrator(frameLWIR);
    frameLWIR = undistortImage(frameLWIR,cameraParams);

    frameFile = fullfile(listaFicheros_MWIR(j).folder,listaFicheros_MWIR(j).name);
    frameMWIR = LeerFramesIR(frameFile);
    frameMWIR = narcisusCalibrator(frameMWIR); 
    frameMWIR = undistortImage(frameMWIR,cameraParams);

    frameFile = fullfile(listaFicheros_VIS(3*j).folder,listaFicheros_VIS(3*j).name);
    frameVIS = LeerFramesVIS(frameFile);
    frameVIS = narcisusCalibrator(frameVIS);
    frameVIS = undistortImage(frameVIS,cameraParams);

    frameFile = fullfile(listaFicheros_Seg(j).folder,listaFicheros_Seg(j).name);
    frameSeg = LeerFramesIDs(frameFile);
    frameSeg = labeller(frameSeg, ficheroIdentificador);
    labelledImage = labeloverlay(ones(res),frameSeg,'Transparency', 0,'Colormap',map);
    labelledImage = undistortImage(labelledImage,cameraParams);
    
    if rand > 0.8
        databaseOutputFolder = fullfile(databaseFolder,'validation');
    else
        databaseOutputFolder = fullfile(databaseFolder,'training');
    end
    
    if modo == 0 || modo == 1
        frame(:,:,1)   = frameMWIR;
        frame(:,:,2)   = frameLWIR;
        frame(:,:,3:5) = frameVIS;
        gtruth(:,:,1) = frameSeg;
        frame = uint16(frame);
        gtruth = uint8(gtruth);

        [~,~] = mkdir(fullfile(databaseOutputFolder, 'frames'));
        [~,~] = mkdir(fullfile(databaseOutputFolder, 'gtruth'));
        frameNameMAT = fullfile(databaseOutputFolder, 'frames', sprintf('%s_%03d.mat',name,j));
        gtruthNameMAT = fullfile(databaseOutputFolder, 'gtruth', sprintf('%s_%03d.mat',name,j));
        save(frameNameMAT, 'frame');
        imwrite(gtruth,fullfile(databaseOutputFolder, 'gtruth', sprintf('%s_%03d.png',name,j)));
        save(gtruthNameMAT, 'gtruth');
    end

    if modo == 0 || modo == 2
        frameOutput_LWIR = fullfile(frameFolderOutput, name, 'LWIR');
        [~, ~] = mkdir(frameOutput_LWIR);
        frameOutput_LWIR = fullfile(frameOutput_LWIR, frameName);
        imwrite(frameLWIR,cmapIR,frameOutput_LWIR);

        frameOutput_MWIR = fullfile(frameFolderOutput, name, 'MWIR');
        [~, ~] = mkdir(frameOutput_MWIR);
        frameOutput_MWIR = fullfile(frameOutput_MWIR, frameName);
        imwrite(frameMWIR,cmapIR,frameOutput_MWIR);

        frameOutput_VIS = fullfile(frameFolderOutput, name, 'VIS');
        [~, ~] = mkdir(frameOutput_VIS);
        frameOutput_VIS = fullfile(frameOutput_VIS, frameName);
        imwrite(frameVIS,frameOutput_VIS);

        frameOutput_Seg = fullfile(frameFolderOutput, name, 'Seg');
        [~, ~] = mkdir(frameOutput_Seg);
        frameOutput_Seg = fullfile(frameOutput_Seg, frameName);
        imwrite(labelledImage,frameOutput_Seg);
    end

%         img1 = imread(frameOutput_LWIR);
%         img2 = imread(frameOutput_MWIR);
%         img3 = imread(frameOutput_VIS);
%         img4 = imread(frameOutput_Seg);
%         osmell = montage({img1, img2, img3, img4});
%         montage_IM=osmell.CData;
%         [~, ~] = mkdir(fullfile(frameFolderOutput,foldersList(i).name, 'Montage'));
%         
%         imwrite(montage_IM,fullfile(frameFolderOutput,foldersList(i).name,...
%             'Montage', strcat(num2str(j),'.png')));


end   
close(wb);
fprintf('%d frames packed\n',n);
toc;
end