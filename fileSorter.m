function listaFicheros = fileSorter(directorio)
% FILESORTER(directorio) devuelve de forma ordenada por fecha la lista de
% archivos en una carpeta

listaFicheros = dir(directorio);
listaFicheros = listaFicheros(~[listaFicheros.isdir]);
[~,idx] = sort([listaFicheros.datenum]);
listaFicheros = listaFicheros(idx);

end