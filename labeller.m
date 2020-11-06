function frameOUT = labeller(frameIN, ids)

    tags = xmlReader(ids);
    frameIN = frameIN(:,:,1);
    uniques = unique(frameIN);
    
    
%     indexSea = find(strcmp(tags, 'Mar'))-offset;
%     indexWater = find(strcmp(tags, 'water'))-offset;
%     indexBuildings = find(strcmp(tags, 'buildings'))-offset;
%     indexTerrain = find(strcmp(tags, 'terrain'))-offset;
%     indexVegetation = find(strcmp(tags,'vegetation'))-offset;
%     indexRoads = find(strcmp(tags, 'roads'))-offset;
    
    
    frameIN(frameIN==tags('Mar')) = 1;
    frameIN(frameIN==tags('water')) = 2;
    frameIN(frameIN==tags('roads')) = 3;
    frameIN(frameIN==tags('vegetation')) = 4;
    frameIN(frameIN==tags('buildings')) = 5;
    frameIN(frameIN==tags('terrain')) = 6;
    
    frameOUT = frameIN;
% 
%         labelledImage = labeloverlay(ones(1024,1280),frameIN,'Transparency', 0,'Colormap',map);
%         imwrite(labelledImage,frameOutput_Seg);



end