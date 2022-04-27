
%---------------------------------------------------------------------------
% pb_threshold_Callback
%
% purpose: Generate a spotList for the P and M image.
%          Determine the thresholds (for the P and M) and use this value
%          to create a Black/White image. Out of the black/White image a
%          a spotList will be extracted.
%
% usage:   varargout = pb_threshold_Callback(h, eventdata, handles, varargin)
%
% input:   (regular callback input parameters)
%
% output:  -
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function varargout = pb_threshold_Callback()
  global PRAD_control;
  global PRAD_data;
  global SPOT_DISTANCE;
  global displayMsg;
  
  % Determine P sensor spotList (if enabled)
  if PRAD_control.sensorConfig.captParams.captParamsP_p.sensorEnable

    [PRAD_data.spotsP, PRAD_data.thresHoldImageP, PRAD_data.thresholdP] = PRAD_threshold_SingleImg(PRAD_data.imageP, SPOT_DISTANCE);
    if PRAD_data.thresholdP==0
      PRAD_data.spotsP.numSpots = 0;
      cdataMapping = 'direct';
    else
      % "scale" because the threshold image consist of zeros and ones
      cdataMapping = 'scaled';
    end
  end

  % Determine M sensor spotList (if enabled)
  if PRAD_control.sensorConfig.captParams.captParamsM_p.sensorEnable

    [PRAD_data.spotsM, PRAD_data.thresHoldImageM, PRAD_data.thresholdM] = PRAD_threshold_SingleImg(PRAD_data.imageM, SPOT_DISTANCE);
    if PRAD_data.thresholdP==0
      PRAD_data.spotsP.numSpots = 0;
      cdataMapping = 'direct';
    else
      % "scale" because the threshold image consist of zeros and ones
      cdataMapping = 'scaled';
    end
  end
end
 
 
%---------------------------------------------------------------------------
% PRAD_histogram
%
% purpose: Determine the histogram and median of the given image.
%
% usage:   [histogram, thresholdLevel] = PRAD_histogram(image)
%
% input:   -
%
% output:  -
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function [thresholdLevel] = PRAD_histogram(image)
    global displayMsg;
    
    stdev = std(double(image(:)));
    md = double(median(image(:)));
    thresholdLevel = round(md + 2 * stdev);

    if displayMsg
      txt=sprintf('Median=%f, STD=%f Threshold=%f ',md,stdev,thresholdLevel);
      disp(txt);
    end
    return
end

%---------------------------------------------------------------------------
% PRAD_makeSpotList
%
% purpose: Determine the positions of the spots in the Balck&White Image
%
% usage:   ret = PRAD_makeSpotList(thresHoldImage, grayImage, threshold)
%
% input:   thresHoldImage   Black&White image
%          grayImage        Gray level image (NOT USED YET)
%          threshold        threshold
%
% output:  ret    Resulting spotlist
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function ret = PRAD_makeSpotList(sensorName, thresHoldImage, grayImage, threshold)
  % Get coordinates of all pixels NOT EQUAL to zero
  % Flip the image back
  global SPOT_DISTANCE;
  global displayMsg;
  
  [AA(:,1), AA(:,2)] = find(thresHoldImage);
  
  % Sort pixels on distance to top left
  AA(:,3) = sqrt(AA(:, 1).^2 + AA(:,2).^2);
  AA = sortrows(AA, 3);
  
  % Add the angle w.r.t. top left
  AA(:,4) = atan2(AA(:,2), AA(:,1));

  % Determine the positions of the spots in the sensor image 
  % Walk through all NON-zero pixels of the sensor
  spotNum = 0;
  % 1000 indicates that a pixel is already used !!!!

    %figure;
    set(0,'DefaultFigureWindowStyle','docked')
  while AA(1,3) < 1000
    count = 0; % number of pixels in spot
    sumX = 0;  % sum of the X coordinates of the spot
    sumY = 0;  % sum of the Y coordinates of the spot
    i = 0;
    
    angle = AA(1,4);    % Angle of first pixel of a spot.
    distance = AA(1,3); % Distance of first pixel of a spot.
    maxAngle = atan2(SPOT_DISTANCE, distance);

    singleSpotImage = [];
    % Walk through sorted list (on distance to top left) of pixels
   
    for item = AA'
      i = i + 1;

      % If the current pixel is close enough to the reference pixel
      % it might be a pixel of the same spot
      if abs(distance - item(3)) < SPOT_DISTANCE
        % Check also the angle of the pixel w.r.t. the angle of the reference pixel
        if abs(item(4) - angle) < maxAngle
           % Count all the pixels contained in a spot
           count = count + 1;
        
           AA(i, 3) = 1000; % Mark pixel as used
           
           % Add the X and Y coordinates of one spot
           sumX = sumX + item(1);
           sumY = sumY + item(2);
           
           singleSpotImage(count, 1) = item(1);
           singleSpotImage(count, 2) = item(2);
           singleSpotImage(count, 3) = double(grayImage(item(1), item(2)));
   
        end
      else
        % goto next spot.
        break;
      end
    end
      % if the spot is big enough
    if count > 150
      % Calculated spot position
      posX = floor((sumX + floor(count/2))/count);
      posY = floor((sumY + floor(count/2))/count);
      
      % Filter-out the spots laying NOT entirely in the sensor
      if (posX > 25) & (posX < 640 - 25)
        if (posY > 25) & (posY < 480 - 25)
          % Determine the center of the spot (Center Of Gravity)
          [centerX, centerY] = PRAD_getCOG(singleSpotImage, [posX posY], threshold);

          % Store the spotlist information
          spotNum = spotNum + 1;
          spotData.surface(spotNum) = count;
          spotData.sPosEstimate(spotNum, 1) = posX - 1;
          spotData.sPosEstimate(spotNum, 2) = posY - 1;
          spotData.sPos(spotNum, 1) = centerX - 1;
          spotData.sPos(spotNum, 2) = centerY - 1;
          
        end
      end
    end
    
    % sort rows on distance this way the disabled pixels are moved 
    % to bottom of the list
    AA = sortrows(AA, 3);  
  end
  
  if displayMsg
    fn_displaySpotPositionChange([upper(sensorName) ': Calculate Center Of Gravity'], '%+11.6f', [1:length(spotData.sPosEstimate)], spotData.sPosEstimate, 'Spot Center', spotData.sPos, 'Spot Center Of Gravity', spotData.surface, 'Size');
  end
  
  spotData.numSpots = spotNum;
  ret = spotData;
end
  

%---------------------------------------------------------------------------
% PRAD_getCOG
%
% purpose: Determine the Center Of Gravity of a single Spot
%
% usage:   [cogX, cogY] = PRAD_getCOG(spotImage)
%
% input:   spotImage   Spot Graylevel information: 
%                                spotImage(:,1) = X-coordinate
%                                spotImage(:,2) = Y-coordinate
%                                spotImage(:,3) = grayLevel
%
% output:  -
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function [cogX, cogY] = PRAD_getCOG(spotImage, spotCenter, threshold)

  cX = spotCenter(1);
  cY = spotCenter(2);
  cRelX = spotImage(:, 1) - cX;
  cRelY = spotImage(:, 2) - cY;
  sumX = 0;
  sumY = 0;
  sumPx = 0;
  radius = 25;
  for px = 1:length(spotImage)
      if (abs(cRelX(px)) <= radius) && (abs(cRelY(px)) <= radius)
          if hypot(cRelX(px), cRelY(px)) <= radius
              pxVal = spotImage(px, 3) - threshold;
              if pxVal > 0.0
                  sumX = sumX + spotImage(px, 3) * (cRelX(px) + cX);
                  sumY = sumY + spotImage(px, 3) * (cRelY(px) + cY);
                  sumPx = sumPx + spotImage(px, 3);
              end
          end
      end
  end
  cogX = sumX / sumPx;
  cogY = sumY / sumPx;
  return;
end
