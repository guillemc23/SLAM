function frameOUT = LeerFramesIDs(frameIN)
%% Lectura de frames

% newStr = split(directorio,'/');
% directorioSalida = fullfile(directorio,'..','..','..','frames_database',newStr{4});
% [status, msg] = mkdir(directorioSalida);
% listaFicheros = dir(directorio);
% fclose('all');
 %id = xmlReader(id);
% map = [0 0 0.5
%     1 0 0
%     0.05 0.05 0.05
%     0.5 0.4 0
%     0 0.7 0
%     0 0 1.0];
% 
% listaFicheros = fileSorter(directorio);
% for i=1:length(listaFicheros)

%     rutaActual = listaFicheros(i).name;
%     rutaActual = fullfile(directorio, rutaActual);
rutaActual = frameIN;

%    if(contains(rutaActual, 'IdsBlancosPorPixel_') ) % se abren los archivos cuyo nombre contiene el substring "IdsBlancosPorPixel_"
    
        % Obtenemos la extensión del fichero
        [~, ~, extension] = fileparts(rutaActual);
%         listaFicheros(i).name;
        % Leemos de forma diferente en función de si es .bin o .dat
        
        if( strcmp(extension, '.bin'))            
            fileID = fopen(rutaActual);
            imagenActual = fread(fileID, Inf, 'uint16')';
            fclose(fileID);

            resolucionHorizontal = imagenActual(2);
            dimensionBuffer = imagenActual(3);
            imagenActual = imagenActual(4:end);
            imagenActual(imagenActual == 65535) = -1; % en el .dat, la forma de codificar los espacios en los que no hay blancos es con -1, en el .bin se usó el 65535 por no poder representar negativos

        else % .dat              
            % Leemos las dimensiones de la imagen y del buffer en la cabecera
            fid = fopen(rutaActual);
            resolucionVertical = strsplit(fgetl(fid), ':');
            resolucionVertical = str2double(resolucionVertical{2});
            resolucionHorizontal = strsplit(fgetl(fid), ':');
            resolucionHorizontal = str2double(resolucionHorizontal{2});
            dimensionBuffer = strsplit(fgetl(fid), ':');
            dimensionBuffer = str2double(dimensionBuffer{2});
            fclose(fid);

            % cargamos el fichero
            imagenActual = dlmread(rutaActual,'',4,0);
        end

        % Ordenamos la matriz
%         try
        imagenActual = reshape(imagenActual, dimensionBuffer, resolucionHorizontal, []);
        imagenActual = permute(imagenActual,[3 2 1]); 
        frameOUT = rot90(imagenActual, 2);
        
end

        

%     S = imagenActual(:,:,1);
%     uniques = unique(S);
%     S(S==3) = 1;
%     S(S==1000) = 2;
%     S(S==1001) = 3;
%     S(S==1002) = 4;
%     S(S==1003) = 5;
%     S(S==1004) = 6;
%     
%     labelledImage = labeloverlay(ones(1024,1280),S,'Transparency', 0,'Colormap',map);
%     imwrite(labelledImage,fullfile(directorioSalida,strcat(num2str(i),'.png')));

% X = 1;
% end
