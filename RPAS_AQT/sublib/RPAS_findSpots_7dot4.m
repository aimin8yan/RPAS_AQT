  function [spots, bw]=findSpots(img, pix, minArea, maxArea)
  
    %first determine threshold
    img= double(img);
    
    T = boundValue(img);
    
    
    %bw image
    bw = img<T;
    bw = imfill(bw,'holes');
    
    
    [label, numLabel]=bwlabel(bw); % labeling the blobs
    %region properties
    prop=regionprops(label, img, 'Area', 'Centroid', 'Eccentricity');

    %minimum area in pixel numbers 
    nArea=minArea/pix^2;
    mArea=maxArea/pix^2;
    areas=[];
    Eccentricity=[];
    center=[];
    for k=1:numLabel
      if prop(k).Area<nArea | prop(k).Eccentricity>0.9 | prop(k).Area>mArea | std(img(label==k))<1
        bw(label==k)=0;
      else
        areas(end+1)=prop(k).Area;
        Eccentricity(end+1)=prop(k).Eccentricity;
        center(end+1,1:2)=prop(k).Centroid;
      end
    end
  
    if numel(areas)>0
      spots=struct('position', center, 'area', areas, 'Eccentricity', Eccentricity);
    else 
      spots=[];
    end
  return;
end



function T = boundValue(img)
    r=20;
    se=strel('disk',r,0);
    MAX=double(imdilate(img,se));
    MIN=double(imerode(img,se));
    
    C=(MAX-MIN)./(MAX+MIN);
    T=0.563*max(C(:))*(max(img(:))+min(img(:)))+min(img(:));
end
