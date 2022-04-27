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
    if 0
    overlaps=[];
    for i=1:numel(spots1.position(:,1))
      for j=1:numel(spots2.position(:,1))
        dist=hypot(spots1.position(i,1)-spots2.position(j,1), spots1.position(i,2)-spots2.position(j,2));
        if dist <= spots1.diameter(i)/2+spots2.diameter(j)/2
          overlaps(end+1,1:6) = [spots1.position(i,:) spots1.diameter(i), spots2.position(j,:) spots2.diameter(j)];
        end
      end
    end
   end
  end
