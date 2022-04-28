  function defects = findDefects(bw1, bw2)
    bw = bw1 & bw2;
    
    r=2;
    se=strel('disk',r,0);
    bw=imerode(imdilate(bw,se), se);
    [label, numLabel]=bwlabel(bw);
    prop=regionprops(bw, 'Centroid', 'Area');
    defects=[];
    if ~isempty(prop)
      for k=1:numel(prop)
        defects(end+1,1:3)=[prop(k).Centroid prop(k).Area];
      end
    end
  end
