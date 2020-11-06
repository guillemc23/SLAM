function tags = xmlReader(sampleXMLfile)
    mlStruct = parseXML(sampleXMLfile);
    keySet = {};
    valueSet = [];
    for i= 2:2:numel(mlStruct.Children)
       valueSet(i/2) = str2num(mlStruct.Children(i).Children(2).Children(2).Children.Data);
       keySet{i/2} = mlStruct.Children(i).Children(4).Children(2).Children.Data;
    end
    tags = containers.Map(keySet,valueSet);
end