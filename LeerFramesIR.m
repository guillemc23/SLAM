function imagenActual = LeerFramesIR(file)




% %% Lectura de frames
% 
% newStr = split(directorio,'/');
% 
% directorioSalida = fullfile(directorio,'..','..','..','frames_database',newStr{4});
% 
% [status, msg] = mkdir(directorioSalida);
% listaFicheros = dir(directorio);
% 
% imagenesIR = [];
% 
% contador = 1;
% for i=1:length(listaFicheros)

%     rutaActual = listaFicheros(i).name;
%     rutaActual = fullfile(directorio, rutaActual);
rutaActual = file;

    if(~isempty(strfind(rutaActual, 'Frame_')) ) %ImagenSalidaADCV imagen
        
        % Obtenemos la extensión del fichero
        [~, ~, extension] = fileparts(rutaActual);
        
        % En función de si es binario o .dat, leemos de una forma u otra
        if( strcmp(extension, '.bin'))
            fileID = fopen(rutaActual);
            imagenActual = fread(fileID,Inf,'uint16')';
            fclose(fileID);
        else
            imagenActual = dlmread(rutaActual);
        end
        
        % Resolucion de la imagen
        resolucionHorizontal = imagenActual(2);
        
        % Eliminamos los dos primeros valores, que contienen la dimensión
        % de la imagen
        imagenActual = imagenActual(3:end);
        
        % formato de matriz
        imagenActual = reshape(imagenActual, resolucionHorizontal, []);
        imagenActual = permute(imagenActual,[2 1]);

%         % Guardado de la imagen 
%         percentilEliminar = 0.5; 
%         max = prctile(imagenActual(:), percentilEliminar);
%         min = prctile(imagenActual(:), 100 - percentilEliminar);
%         
%         imagen = mat2gray(imagenActual, [max,min]); % Se aplican límites para el ploteado y la imagen pierde rango.
%         cmap = gray(256);
%         frame = ceil(imagen * size(cmap,1));
%         rutaFicheroGuardadoActual = fullfile(directorioSalida, [mat2str(contador), '.png']);
%         imwrite(frame, cmap, rutaFicheroGuardadoActual);
% 
%         imagenesIR = cat(3, imagenesIR, imagenActual);
%         
%         contador = contador + 1;              
%         
    end
end

% imtool(imagenesIR)
% fclose('all')
% X = 1;
% end



