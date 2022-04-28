% function geoProperties used to calculate the image 
% geometric properties of the interested regions. The region
% is determined by the ROI. The properties include 
% 'Centroid', 'Orientation', 'BoundingBox', and the ellipse 
% 'MajorAxisLength', 'MinorAxisLength'.
%
% Inputs:
%   img: image matrix variable representing the image to compute
%   ROI: Region of interest. A vector variable of size 4. 
%           The first two values represent the x, y starting location
%           The last two values represent the width and height of the
%           rectiangle.
%   thresh: An optional variable representing the threshold in determining
%           the retrested regions.
%           If thresh is unpresent, the threshold is defined as
%              thresh = median(img(:))+2*std(img(:));
%
% Output:
%   a struct variable with fields:
%       'X', 'Y': representing the centroid position of the interested
%       region.
%       'BX', 'BY': representing the starting position of the bounding box.
%       'Width', 'Height': representing the width and height of the
%       bounding box
%       'Angle':    representing the rotation angle relating to X-axis
%       'Major', 'Minor': representing the Major and Minor axis length of
%       the ellipse
%

function result=RPAS_geoProperties(img, ROI, thresh)
    %check for correct number of inputs
    error(nargchk(2,3,nargin));
    
    %ROI image
    img1=zeros(size(img));
    mm=ROI(1):ROI(1)+ROI(3)-1;
    nn=ROI(2):ROI(2)+ROI(4)-1;
    img1(mm,nn)=img(mm,nn);
    
    
    %threshold
    if nargin<3
        thresh=round(median(img1(:))+2*std(img1(:)));
    end
    
    % binary image
    bwimg=img1>thresh;
    bwimg=imfill(bwimg,'holes'); % interested only the outer frame
    [label, numLabel]=bwlabel(bwimg); % labeling the blobs
    
    %compute properties
    prop=regionprops(label, img, 'Area', 'Centroid', 'Orientation', ...
         'BoundingBox', 'MajorAxisLength', 'MinorAxisLength');
     
    %select proper blob
    a=0;
    idx=0;
    for k=1:numLabel
    	if a< prop(k).Area
            a=prop(k).Area;
            idx=k;
        end
    end
    if idx>0
        %record result

        %center point
        result.X=prop(idx).Centroid(1)-0.5;
        result.Y=prop(idx).Centroid(2)-0.5;

        %Orentation converting to radian
        result.Angle=prop(idx).Orientation*pi/180;

        %BoundingBox
        result.BX=prop(idx).BoundingBox(1)-0.5;
        result.BY=prop(idx).BoundingBox(2)-0.5;
        result.Width=prop(idx).BoundingBox(3);
        result.Height=prop(idx).BoundingBox(4);
    
    
        %MajorAxisLength
        result.Major=prop(idx).MajorAxisLength;

        %MinorAxisLength
        result.Minor=prop(idx).MinorAxisLength;
        return
    else
        result=[];
    end
end