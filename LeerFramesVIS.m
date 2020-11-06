function frameOUT = LeerFramesIR(frameIN)
% %% Lectura de frames
% 
% newStr = split(directorio,'/');
% directorioSalida = fullfile(directorio,'..','..','..','frames_database',newStr{4});
% [status, msg] = mkdir(directorioSalida);
% listaFicheros = dir(directorio);
% 
% imagenesVIS = [];
% 
% contador = 1;
% for i=1:length(listaFicheros)
% 
%     rutaActual = listaFicheros(i).name;
%     rutaActual = fullfile(directorio, rutaActual);
    rutaActual = frameIN;
    % tomamos como referencia todos los frames de rojo para encontrar sus
    % correspondientes azul y verde
    if (contains(rutaActual, 'Frame_R'))
        rutaRojo = rutaActual;
        rutaVerde = strrep(rutaActual, 'Frame_R', 'Frame_G');
        rutaAzul = strrep(rutaActual, 'Frame_R', 'Frame_B');
    elseif (contains(rutaActual, 'Frame_G'))
        rutaVerde = rutaActual;
        rutaRojo = strrep(rutaActual, 'Frame_G', 'Frame_R');
        rutaAzul = strrep(rutaActual, 'Frame_G', 'Frame_B');
    elseif (contains(rutaActual, 'Frame_B'))
        rutaAzul = rutaActual;
        rutaRojo = strrep(rutaActual, 'Frame_B', 'Frame_R');
        rutaVerde = strrep(rutaActual, 'Frame_B', 'Frame_G');
    end
    
    rutas = {rutaRojo, rutaVerde, rutaAzul};
    for color = 1 : 3        
        % Obtenemos la extensión del fichero
        [~, ~, extension] = fileparts(rutas{color});

        if( strcmp(extension, '.bin'))
            fileID = fopen(rutas{color});
            imagenActual = fread(fileID,Inf,'uint16')';
            fclose(fileID);
        else
            imagenActual = dlmread(rutas{color});
        end
        
        resolucionHorizontal = imagenActual(2);
        
        imagenActual = imagenActual(3: end);
        imagenActual = reshape(imagenActual, resolucionHorizontal, []);
        imagen(:,:,color) = permute(imagenActual,[2 1]);            
    end
    
        frameOUT = imagen ./ 256;
    end
    
    % Guardado frame



   
    
%     sat = 0.6;
% A = imagenActual;
% A(A>sat) = sat;
% minimo = 0;
% maximo = max(A(:));
% B=(A-minimo)./(maximo - minimo);
% %imtool(B)
%     rutaFicheroGuardadoActual = fullfile(directorioSalida, [mat2str(contador), '.png']);
%     imwrite(B, rutaFicheroGuardadoActual);
%     
%     imagenesVIS = cat(4, imagenesVIS, imagenActual);
    
%     contador = contador + 1; 
% end
%    imtool(imagenesVIS)

% %% Ajuste saturacion (opcional)
% sat = 0.6;
% A = imagenActual;
% A(A>sat) = sat;
% minimo = 0;
% maximo = max(A(:));
% B=(A-minimo)./(maximo - minimo);
% %imtool(B)
% X = 1;
% end


