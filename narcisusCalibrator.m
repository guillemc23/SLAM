function frame_corregido = narcisusCalibrator(frame)

[~,~,z] = size(frame);

if z == 1
    if max(frame(:))<10000
        global Coef_NarcisusLWIR
        Coef_Narcisus = Coef_NarcisusLWIR;    
    else
        global Coef_NarcisusMWIR
        Coef_Narcisus = Coef_NarcisusMWIR;
    end
    frame_corregido = double(frame).*Coef_Narcisus;
    frame_corregido = uint16(round(frame_corregido));
    minIR = double(min(frame_corregido(:)));
    maxIR = double(max(frame_corregido(:)));
    frame_corregido = uint8(255*mat2gray(frame_corregido, [minIR, maxIR]));

elseif z == 3
    global Coef_NarcisusVIS
    Coef_Narcisus = Coef_NarcisusVIS;
    frame_corregido = double(frame).*Coef_Narcisus;
    frame_corregido = frame_corregido.*255;
    frame_corregido = uint8(round(frame_corregido));
end

end