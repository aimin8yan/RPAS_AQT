
%---------------------------------------------------------------------------
% pb_estimate_Callback
%
% purpose: Estimate the positions of the P sensor, M sensor and reticle using
%          the previous determined spotlists.
%
% usage:   varargout = pb_estimate_Callback(h, eventdata, handles, varargin)
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
function varargout = pb_estimate_Callback()
  global PRAD_control;
  global PRAD_data;
  global markerPositions;
  global nearestSpotImage;
  global distances;
  global displayMsg;
  
  % Crossreference: colomn numbers versus contents
  X = 1; Y = 2; SPOTNUM = 3; DISTANCE = 4; A = 5;
  
  % Flag indicates how many sensors are enabled and contain an valid
  % sensor image. Used to determine if the reticle position can be
  % calculated. 'numEstimatedSensors' must be 2 !!
  numEstimatedSensors = 0;
  
  if PRAD_control.sensorConfig.captParams.captParamsP_p.sensorEnable 
    
    % Reset the flag that must indicate whether the found position matches
    % all the spots in the sensor spotlist.
    PRAD_data.sensorP.result.matchFound = 0;
    
    % First scan for the P sensor pattern in the marker
    if displayMsg
      fprintf('\n\n\nP sensor analysis\n');
    end
    [result, info]=PRAD_estimate_SingleImg(PRAD_data.spotsP, 'P', 2, pi * 0, markerPositions, nearestSpotImage);
    if ~isempty(result)
      PRAD_data.sensorP.result=result;
      PRAD_data.sensorP.info=info;
    end

    if PRAD_data.sensorP.result.matchFound                       
        numEstimatedSensors = numEstimatedSensors + 1;
    end
    
    if displayMsg
      fprintf('Found spot numbers P sensor= %d\n', ...
              PRAD_data.sensorP.info.spotsSorted.spotNumber)  
    end
  end

  if PRAD_control.sensorConfig.captParams.captParamsM_p.sensorEnable
    
    % Reset the flag that must indicate whether the found position matches
    % all the spots in the sensor spotlist.
    PRAD_data.sensorP.result.matchFound = 0;

    % First scan for the M sensor pattern in the marker
    if displayMsg
      fprintf('\n\n\nM sensor analysis\n');
    end
    
    [result, info]=PRAD_estimate_SingleImg(PRAD_data.spotsM, 'M', 2, pi * 1.0, markerPositions, nearestSpotImage);
    
    if ~isempty(result)
      PRAD_data.sensorM.result=result;
      PRAD_data.sensorM.info=info;
    end

    if PRAD_data.sensorM.result.matchFound                       
        numEstimatedSensors = numEstimatedSensors + 1;
    end
    
    if displayMsg
      fprintf('Found spot numbers M sensor= %d\n', ...
              PRAD_data.sensorM.info.spotsSorted.spotNumber)  
    end
  end
  
  % Reset flag for reticle calculations
  PRAD_data.reticle.result.present = 0;
  if numEstimatedSensors == 2 
    % Both sensors are enabled and successfully calculated
    PRAD_calculateReticle;
    
    % Set flag indicatie calculations for reticle are present
    PRAD_data.reticle.result.present = 1;
  end

  
  % Display the found estimates
  %PRAD_update_estimated(handles);

  if (PRAD_control.sensorConfig.captParams.captParamsP_p.sensorEnable &...
     ~PRAD_data.sensorP.result.matchFound &...
      PRAD_data.sensorP.info.refSpot.found)
      if displayMsg
        fprintf(1,'NO MATCH FOUND FOR THE P-SENSOR\n');
      end
  end
  if (PRAD_control.sensorConfig.captParams.captParamsM_p.sensorEnable &...
     ~PRAD_data.sensorM.result.matchFound &...
      PRAD_data.sensorM.info.refSpot.found)
      if displayMsg
        fprintf(1,'NO MATCH FOUND FOR THE M-SENSOR\n');
      end
  end
  
  PRAD_displayEstimate(markerPositions, PRAD_data.sensorP.info, 'sensor P');
  PRAD_displayEstimate(markerPositions, PRAD_data.sensorM.info, 'sensor M');
  if displayMsg
      disp('estimate function');    
  end
end



%---------------------------------------------------------------------------
% PRAD_findSensorInMarker
%
% purpose: Locate the sensor pattern in the marker.
%
% usage:   ret = PRAD_findSensorInMarker(spotList)
%
% input:   spotList spot list information
%
% output:  ret      spot matching information:
%                            The reference spot in marker coordinates.
%                            Sensor rotation.
%                            First estimate on the sensor angle.
%                            First estimate on the sensor scale factor (gain).
%
% Note:    Take the most central spot in the sensor. This will be the reference
%          spot. Find a match of the reference spot in the marker, using 2
%          spots nearest to the reference spot as validation.
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function ret = PRAD_findSensorInMarker(sensorName, spotList, defaultFlipAxis, defaultRotation)
    global markerPositions;
    global distances;
    global nearestSpotImage;
    global displayMsg;

    if spotList.numSpots == 0 
        sensorInfo.refSpot.found = 0;
        ret = sensorInfo;
        return; 
    end;
    % Crossreference: colomn numbers versus contents
    X = 1; Y = 2; SPOTNUM = 3; DISTANCE = 4; A = 5;  
    sensorInMarkerFound = 0;

    % determine number of points  
    [numPoints, nop] = size(spotList.sPos(:,1));

    sensorInfo.sensor.sizeX = 640;
    sensorInfo.sensor.sizeY = 480;
  
    % Make the coordinates relative to center of image,
    % which is also done in the RPAS-code.

    cRelPos = spotList.sPos;
    xc = cRelPos(:, X) - ((sensorInfo.sensor.sizeX - 1)/2.);
    yc = cRelPos(:, Y) - ((sensorInfo.sensor.sizeY - 1)/2.);

    % In the RPAS-code, the points are sorted based on distance to center,
    % so do the same here.
    dist = hypot(xc,yc);
    [~,order] = sort(dist);
    xc = xc(order);
    yc = yc(order);
    cRelPos = cat(2,xc,yc);
    
    if displayMsg
      fn_displaySpotPositionChange([upper(sensorName) ': Calculating distance to center + sort on distance'], '%+11.6f', order, spotList.sPos(order,:), 'top-left (x,y)', cRelPos, 'center (x,y)', dist(order), 'distance');
    end
    spotList.sPos = cRelPos;
    
    % rotate RPXA_0_5_PI_CCW:
    rotatedSpotList(:,Y:-1:X) = spotList.sPos(:, X:Y);
    rotatedSpotList(:, X) = -rotatedSpotList(:, X);
    rotatedSpotList(:,SPOTNUM) = order;
    rotatedSpotList(:,DISTANCE) = dist(order);

    if displayMsg
      rotationStr = fn_rotationToString(pi * 0.5);
      fn_displaySpotPositionChange([upper(sensorName) ': Rotation applied = ' rotationStr], '%+11.6f', order, spotList.sPos, 'source-position(x,y)', rotatedSpotList, 'dest-position(x,y)');
    end
    spotList.sPos = rotatedSpotList;

    % Default Flip
    flippedSpotList = fn_flipSpotList(spotList.sPos, defaultFlipAxis);

    if displayMsg
      axisStr = fn_flipToString(defaultFlipAxis);
      fn_displaySpotPositionChange([upper(sensorName) ': Flip detector image, flip axis: ' axisStr], '%+11.6f', order, spotList.sPos, 'source-position(x,y)', flippedSpotList, 'dest-position(x,y)');
    end
    spotList.sPos(:, X:Y) = flippedSpotList(:, X:Y);

    % Default Rotation
    rotatedSpotList = fn_rotateSpotList(spotList.sPos, defaultRotation);
  
    if displayMsg
      rotationStr = fn_rotationToString(defaultRotation);
      fn_displaySpotPositionChange([upper(sensorName) ': Rotate detector image, rotation: ' rotationStr], '%+11.6f', order, spotList.sPos, 'source-position(x,y)', rotatedSpotList, 'dest-position(x,y)');
    end
    spotList.sPos(:, X:Y) = rotatedSpotList(:, X:Y);

    sizeX = -sensorInfo.sensor.sizeY;
    sizeY = sensorInfo.sensor.sizeX;

    reticleRotation = 0;
    rotatedSpotList = spotList.sPos;
    while reticleRotation < 4
        switch reticleRotation
        case 0
            % rotate RPXA_0_PI_CCW:
            rotatedSpotList(:, X) = spotList.sPos(:, X);
            rotatedSpotList(:, Y) = spotList.sPos(:, Y);
            sensor.sizeX = sizeX;
            sensor.sizeY = sizeY;
            sensor.rotation = pi * 0;
        case 1
            % rotate RPXA_0_5_PI_CCW:
            rotatedSpotList(:, X) = -spotList.sPos(:, Y);
            rotatedSpotList(:, Y) = spotList.sPos(:, X);
            sensor.sizeX = -sizeY;
            sensor.sizeY = sizeX;
            sensor.rotation = pi * 0.5;
        case 2
            % rotate RPXA_1_0_PI_CCW:
            rotatedSpotList(:, X) = -spotList.sPos(:, X);
            rotatedSpotList(:, Y) = -spotList.sPos(:, Y);
            sensor.sizeX = -sizeX;
            sensor.sizeY = -sizeY;
            sensor.rotation = pi * 1.0;
        case 3
            % rotate RPXA_1_5_PI_CCW:
            rotatedSpotList(:, X) = spotList.sPos(:, Y);
            rotatedSpotList(:, Y) = -spotList.sPos(:, X);
            sensor.sizeX = sizeY;
            sensor.sizeY = -sizeX;
            sensor.rotation = - pi * 0.5;
        otherwise
            break;
        end

        reticleRotation = reticleRotation + 1;

        if displayMsg
          rotationStr = fn_rotationToString(sensor.rotation);
          fn_displaySpotPositionChange([upper(sensorName) ': Try fit with rotation: ' rotationStr], '%+11.6f', spotList.sPos(:,SPOTNUM), spotList.sPos, 'source-position(x,y)', rotatedSpotList, 'dest-position(x,y)');
        end
        spots.sPos = rotatedSpotList;

        [ret, xm, ym, errors,xres,yres, sm, am, kres, fitSpots, avgdist, avgdist_next] = ...
            PRAD_fitMarkers1( ...
                markerPositions, ...
                nearestSpotImage, ...
                spots, ...
                size(nearestSpotImage,2), ...
                size(nearestSpotImage,1));

        spots = fitSpots;
        refSpotNr = find(spots.sPos(:, SPOTNUM) == spots.sSpotRefPair(1, SPOTNUM));

        % The reference spot is the spot far from the center of the detector
        % image
        sX = spots.sPos(refSpotNr, X);
        sY = spots.sPos(refSpotNr, Y);

        % Create distance and angle table w.r.t. the reference spot
        spots.sPos(:, A) = atan2(spots.sPos(:,Y), spots.sPos(:,X));
    
        sensorInMarkerFound = (ret == 0);
        if sensorInMarkerFound
            testAngle = abs(am);

            if testAngle < (0.25 * pi)
                sensorInfo = spots;
                sensorInfo.sensor = sensor;
                sensorInfo.refSpot.spotNumber = spots.mPos(refSpotNr, SPOTNUM);
                sensorInfo.refSpot.sX = sX;
                sensorInfo.refSpot.sY = sY;
                sensorInfo.refSpot.mX = xm;
                sensorInfo.refSpot.mY = ym;
                sensorInfo.firstEstimate.scale = sm;
                sensorInfo.firstEstimate.angle = am;

                % adjust sensor position and angle.
                sensorInfo.spotsSorted.sPos(:,X) = spots.sPos(:,X) + sensorInfo.refSpot.sX;
                sensorInfo.spotsSorted.sPos(:,Y) = spots.sPos(:,Y) + sensorInfo.refSpot.sY;
                sensorInfo.spotsSorted.sPos(:,SPOTNUM) = spots.sPos(:,SPOTNUM);
                sensorInfo.spotsSorted.sDistance = spots.sPos(:,DISTANCE);
                sensorInfo.spotsSorted.mDistanceEstimated =...
                  spots.sPos(:,DISTANCE) * sensorInfo.firstEstimate.scale;
                sensorInfo.spotsSorted.mAngleEstimated =...
                  PRAD_sumAngles(spots.sPos(:,A), sensorInfo.firstEstimate.angle);
                break; 
            end
        end
  
    end

    %refspot position
    if displayMsg
      fprintf('Found sensor rotation =%f\n', reticleRotation) 
    end

    sensorInfo.refSpot.found = sensorInMarkerFound;
    ret = sensorInfo;
end


%---------------------------------------------------------------------------
% fn_displaySpotList
%
% purpose: Flip spot list using given flip axis
%
% author:  Alfred Abutan
% creation: 27 jan 2020
%---------------------------------------------------------------------------
function flippedSpotList = fn_flipSpotList(spotPositions, flipAxis)
    % Crossreference: colomn numbers versus contents
    X = 1; Y = 2;

    flippedSpotList = [];

    if isempty(flipAxis)
        flippedSpotList(:, X:Y) = spotPositions(:, X:Y);
        return;
    else
        if flipAxis == Y
            invertAxis = X;
        elseif flipAxis == X
            invertAxis = Y;
        else
            invertAxis = [];
        end

        if ~isempty(invertAxis)
            flippedSpotList(:, X:Y) = spotPositions(:, X:Y);
            flippedSpotList(:, invertAxis) = -flippedSpotList(:, invertAxis);
        end
    end
end


%---------------------------------------------------------------------------
% fn_rotateSpotList
%
% purpose: Rotate spot list using given rotation
%
% author:  Alfred Abutan
% creation: 27 jan 2020
%---------------------------------------------------------------------------
function rotatedSpotList = fn_rotateSpotList(spotPositions, rotation)

    % Crossreference: colomn numbers versus contents
    X = 1; Y = 2;

    rotatedSpotList = [];
    switch rotation
    case pi * 0
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = spotPositions(:, X);
      rotatedSpotList(:, Y) = spotPositions(:, Y);
    case pi * 0.5
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = -spotPositions(:, Y);
      rotatedSpotList(:, Y) = spotPositions(:, X);
    case pi * 1.0
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = -spotPositions(:, X);
      rotatedSpotList(:, Y) = -spotPositions(:, Y);
    case pi * 1.5
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = spotPositions(:, Y);
      rotatedSpotList(:, Y) = -spotPositions(:, X);
    case - pi * 0.5
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = spotPositions(:, Y);
      rotatedSpotList(:, Y) = -spotPositions(:, X);
    otherwise
    end
end


%---------------------------------------------------------------------------
% PRAD_sumAngles
%
% purpose: Addition of 2 angle's or angle arrays.
%          result:  -pi < resultingAngle < pi
%
% usage:   ret = PRAD_sumAngles(angle1, angle2)
%
% input:   angle1  Angle to be added to angle2
%          angle2  Angle to be added to angle1
%
% output:  -pi < ret < pi
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function ret = PRAD_sumAngles(angle1, angle2)

  % Add the to angle arrays or scalars
  angle = angle1 + angle2;

  num = size(angle);
  
  for i = 1 : num
    if abs(angle(i)) > pi
      % Convert an angle outside the range [-pi, pi] to
      % an angle inside this range.
      newSign = - sign(angle(i));
      angle(i) = newSign * (2 * pi - abs(angle(i)));
    end
  end
  
  ret = angle;
end


    
%---------------------------------------------------------------------------
% PRAD_calculateSensor
%
% purpose: Calculate the sensor position by fitting the sensor pattern 
%          in the marker.
%
% usage:   [result, mPos, spotNum, scale] = PRAD_calculateSensor(sensorInfo, numPoints, config)
%
% input:   sensorInfo  The reference spot in marker coordinates
%          numPoints   Number of spots in the sensor image
%          config      Sensor properties.
%
% output:  result      -
%          mPos        -
%          spotNum     -
%          scale       -
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function [result, mPos, spotNum, scale] = PRAD_calculateSensor(sensorName, sensorInfo, numPoints, config)
    global markerPositions;
    global displayMsg;

    % determine distances and angles of all spots in the marker 
    % w.r.t. the reference spot
    X = 1; Y = 2; SPOTNUM = 3; DISTANCE = 4; A = 5;

    matchFound = 1;

    % Check other spots aswell
    marker = markerPositions;

    mPos(:, X) = sensorInfo.markerPos(:, X);
    mPos(:, Y) = sensorInfo.markerPos(:, Y);
    spotNum    = sensorInfo.mPos(:,SPOTNUM);
    scale      = sensorInfo.firstEstimate.scale;

    %-------------------------------------------------------------------------
    %-- Determine the sensor position
    %-------------------------------------------------------------------------
    mPos(:,X) = sensorInfo.markerPos(:, X) - (4095/2);
    mPos(:,Y) = sensorInfo.markerPos(:, Y) - (4095/2);
    if displayMsg
      fn_displayMarkerSpotList([upper(sensorName) ': converting markerpositions to center'], '%+11.6f', ...
        spotNum, sensorInfo.markerPos, 'top left', mPos, 'center');
    end
    
    % INVERT ORIENTATION OF THE MARKER
    if sensorInfo.sensor.rotation == pi * 0.5   % 0_5_PI_CCW
      result.rotation = - pi * 0.5;  % invert sensor orientation
    elseif sensorInfo.sensor.rotation == - pi * 0.5  % 1_5_PI_CCW
      result.rotation = pi * 0.5;    % invert sensor orientation
    else
      result.rotation = sensorInfo.sensor.rotation;  % 0_0_PI_CCW or 1_0_PI_CCW
    end
    rotatedSpotList = fn_rotateSpotList(mPos, result.rotation);
    
    if displayMsg
      rotationStr = fn_rotationToString(result.rotation);
      fn_displayMarkerSpotList([upper(sensorName) ': Rotate marker positions to match reticle orientation: ' rotationStr], '%+11.6f', ...
        spotNum, mPos, 'source-position(x,y)', rotatedSpotList, 'dest-position(x,y)');
    end
    mPos(:, X:Y) = rotatedSpotList(:, X:Y);
    
    % Switch marker and detector from image coordinates to RPAS coordinates + inversion of orientation
    rotationSensor = pi * 1.0;
    rotatedSpotList = fn_rotateSpotList(sensorInfo.sPos, rotationSensor);
    
    if displayMsg
      rotationStr = fn_rotationToString(rotationSensor);
  
      fn_displaySpotPositionChange([upper(sensorName) ': Inversion of sensor image, rotation: ' rotationStr], '%+11.6f', ...
        sensorInfo.sPos(:,SPOTNUM), sensorInfo.sPos, 'source-position(x,y)', rotatedSpotList, 'dest-position(x,y)');
    end
    sensorInfo.sPos(:, X:Y) = rotatedSpotList(:, X:Y);

    rotationMarker = pi * 1.0;
    rotatedSpotList = fn_rotateSpotList(mPos, rotationMarker);
    
    if displayMsg
      rotationStr = fn_rotationToString(rotationMarker);
  
      fn_displayMarkerSpotList([upper(sensorName) ': Inversion of marker image, rotation: ' rotationStr], '%+11.6f', ...
        spotNum, mPos, 'source-position(x,y)', rotatedSpotList, 'dest-position(x,y)');
    end
    mPos(:, X:Y) = rotatedSpotList(:, X:Y);

    sensorInfo.sPos(:, X:Y) = 5.6e-6 * sensorInfo.sPos(:, X:Y);
    mPos(:, X:Y) = 1.4e-6 * mPos(:, X:Y);
    
    if displayMsg
      fn_displayMarkerSpotList([upper(sensorName) ': convert all positions from pixels to meters'], '%+11.10f', ...
        spotNum, sensorInfo.sPos, 'sensor position(x,y)', mPos, 'marker position(x,y)');
    end

    % Solve: sA = mB*bVect
    sA = [];
    mB = [];
    for sp = 1:length(mPos)
        sA(end + 1,1) = sensorInfo.sPos(sp,X);
        sA(end + 1,1) = sensorInfo.sPos(sp,Y);
        
        mB(end + 1, :) = [1, 0, mPos(sp, X), -mPos(sp, Y)];
        mB(end + 1, :) = [0, 1, mPos(sp, Y), mPos(sp, X)];
    end
    bVect = mldivide(mB, sA);
    if displayMsg
      fprintf([upper(sensorName) ': bVect: [%.10f, %.10f, %.10f, %.10f]\n'], bVect(1), bVect(2), bVect(3), bVect(4) );
    end
    
    result.mInD.vect(X) = bVect(1);
    result.mInD.vect(Y) = bVect(2);
    result.mInD.angle = atan2(bVect(4), bVect(3));
    result.mInD.scale = hypot(bVect(4), bVect(3));
    if displayMsg
      fprintf([upper(sensorName) ': mInD.vect: [%.10f, %.10f], '], result.mInD.vect(1), result.mInD.vect(2));
      fprintf('mInD.angle: [%.10f], ', result.mInD.angle);
      fprintf('mInD.scale: [%.10f]\n', result.mInD.scale);
    end
    
    
    result.sensorAngle = result.mInD.angle;
    result.sensorScale = result.mInD.scale;
    
    % mInD to dInM
    mInDVect = [];
    rotMD = [];
    rotDM = [];
    mInDVect(1,1) = result.mInD.vect(X);
    mInDVect(2,1) = result.mInD.vect(Y);
    rotMD(1, :) = [cos(result.mInD.angle), -sin(result.mInD.angle)];
    rotMD(2, :) = [sin(result.mInD.angle), cos(result.mInD.angle)];
    rotDM = rotMD'; % transposed rotMD
    dmVect = rotDM * mInDVect;
    dInMVect = dmVect * - 1.0 / result.mInD.scale;
    result.dInM.vect(X) = dInMVect(1);
    result.dInM.vect(Y) = dInMVect(2);
    
    % dInM to dInR
    dInRVect = config.mInRVect' + dInMVect;
    result.dInR.vect(X) = dInRVect(1);
    result.dInR.vect(Y) = dInRVect(2);
             
    result.sensorAngle = sensorInfo.firstEstimate.angle;
    result.sensorScale = sensorInfo.firstEstimate.scale;

    % Return the matchFound-flag
    result.matchFound = matchFound;  
end
    
%---------------------------------------------------------------------------
% PRAD_fillDebugStruct
%
% purpose: Create a debug structure containing all relevant spot information
%          for marker and sensor.
%                               
% usage:   debugOut = PRAD_fillDebugStruct(spotInfo, spotList)
%
% input:   spotInfo    Spot coordinaties of the same spots in sensor and marker
%          spotList    Original list of spots. Spots w.r.t. top left corner
%
% output:  debugOut    Spot coordinaties, distances and angle w.r.t. te reference
%                      spot, for marker and sensor.
%
% Note:    colomn 1 :  X position Sensor spots (w.r.t. top left corner)
%          colomn 2 :  Y position Sensor spots (w.r.t. top left corner)
%
%          colomn 3 :  X rotated Sensor spots w.r.t. the reference Spot
%          colomn 4 :  Y rotated Sensor spots w.r.t. the reference Spot
%
%          colomn 5 :  X corresponding marker spots w.r.t. the reference Spot
%          colomn 6 :  Y corresponding marker spots w.r.t. the reference Spot
%
%          colomn 7 :  Index/spotNumber of the corresponding marker spots found
%          colomn 8 :  Angle of the sensor spots w.r.t. the reference spot
%          colomn 9 :  Corresponding angles in the marker
%          colomn 10:  Difference between marker and sensor angles
%          colomn 11:  Difference between marker distances and sensor distances
%          colomn 12:  marker distances/sensor distances [scaling factor]
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function debugOut = PRAD_fillDebugStruct(spotInfo, spotList)
           
  % FOR DEBUG PURPOSES
  debugOut(:, 1:2) = ...
     [spotList.sPos(spotInfo.spotsSorted.sPos(:, 3), 1) ...
      spotList.sPos(spotInfo.spotsSorted.sPos(:, 3), 2)];
  debugOut(:, 3:4) = ...
     [(spotInfo.spotsSorted.sPos(:, 1) - spotInfo.spotsSorted.sPos(1, 1)) ...
      (spotInfo.spotsSorted.sPos(:, 2) - spotInfo.spotsSorted.sPos(1, 2))];
  debugOut(:, 5:6) = ...
     [(spotInfo.spotsSorted.mPos(:, 1) - spotInfo.spotsSorted.mPos(1, 1)) ...
      (spotInfo.spotsSorted.mPos(:, 2) - spotInfo.spotsSorted.mPos(1, 2))];
  debugOut(:, 7)  = spotInfo.spotsSorted.spotNumber;
  debugOut(:, 8)  = atan2(debugOut(:, 4), debugOut(:, 3));
  debugOut(:, 9)  = atan2(debugOut(:, 6), debugOut(:, 5));
  debugOut(:, 10) = PRAD_sumAngles(debugOut(:, 8), -debugOut(:, 9));
  debugOut(:, 11) = sqrt(debugOut(:, 3).^2 + debugOut(:, 4).^2) -...
                    sqrt(debugOut(:, 5).^2 + debugOut(:, 6).^2);
  numSpots = length(debugOut(:, 5));
  debugOut(2:numSpots, 12) = ...
    sqrt(debugOut(2:numSpots, 5).^2 + debugOut(2:numSpots, 6).^2) ./...
    sqrt(debugOut(2:numSpots, 3).^2 + debugOut(2:numSpots, 4).^2);
end  

%---------------------------------------------------------------------------
% PRAD_calculateReticle
%
% purpose: Calculate the reticle position out of the two (P and M) 
%          calculated sensor positions.
%
% usage:   PRAD_calculateReticle
%
% input:   -
%
% output:  -
%
% Note:    Precondition: PRAD_calculateSensor() must have been successfully 
%          applied for both the P and the M sensor.
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function PRAD_calculateReticle
    global PRAD_control;
    global PRAD_data;
    global displayMsg;

    % Solve: sA = mB*bVect
    sA = [];
    mB = [];
    sA(end + 1,1) = PRAD_data.sensorM.result.dInR.vect(1);
    sA(end + 1,1) = PRAD_data.sensorM.result.dInR.vect(2);
    sA(end + 1,1) = PRAD_data.sensorP.result.dInR.vect(1);
    sA(end + 1,1) = PRAD_data.sensorP.result.dInR.vect(2);        
    mB = PRAD_control.sensorConfig.reticleTotMat;
    bVect = mldivide(mB, sA);
    if displayMsg
      fprintf('bVect: [%.10f, %.10f, %.10f, %.10f]\n', bVect(1), bVect(2), bVect(3), bVect(4) );
    end

    PRAD_data.reticle.result.rsInR.vect = bVect(1:2);
    PRAD_data.reticle.result.rsInR.angle = atan2(bVect(4), bVect(3));
    PRAD_data.reticle.result.rsInR.scale = hypot(bVect(4), bVect(3));
    if displayMsg
      fprintf('rsInR.angle: [%.10f], ', PRAD_data.reticle.result.rsInR.angle);
      fprintf('rsInR.scale: [%.10f]\n', PRAD_data.reticle.result.rsInR.scale);
    end

    PRAD_data.reticle.result.rInRs.angle = -PRAD_data.reticle.result.rsInR.angle;
    
    % Translate into ReticleStage coordinates:
    %      The reticleStage is rotated w.r.t. reticle over rsAngle.
    rotRRs = [];
    rotRRs(1, :) = [cos(PRAD_data.reticle.result.rInRs.angle), -sin(PRAD_data.reticle.result.rInRs.angle)];
    rotRRs(2, :) = [sin(PRAD_data.reticle.result.rInRs.angle), cos(PRAD_data.reticle.result.rInRs.angle)];
    rrsVect = rotRRs * PRAD_data.reticle.result.rsInR.vect;
    rInRsVect = rrsVect * - 1.0;
    PRAD_data.reticle.result.rInRs.vect(1) = rInRsVect(1);
    PRAD_data.reticle.result.rInRs.vect(2) = rInRsVect(2);

    if displayMsg
      fprintf('rInRs.vect: [%.10f, %.10f], ', PRAD_data.reticle.result.rInRs.vect(1), PRAD_data.reticle.result.rInRs.vect(2));
      fprintf('rInRs.angle: [%.10f]\n', PRAD_data.reticle.result.rInRs.angle);
    end
end

%---------------------------------------------------------------------------
% PRAD_update_estimated
%
% purpose: Update the main window estimated values.
%
% usage:   PRAD_update_estimated(handles)
%
% input:   handles  - Handle structure of the PRAD main window
%
% output:  -
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 20 jan 2005
%---------------------------------------------------------------------------
function ret = PRAD_update_estimated(handles)
  global PRAD_control;
  global PRAD_data;
  
  %-------------------------------------------------------------------------
  %--  Update the P sensor values
  %-------------------------------------------------------------------------
  if PRAD_control.sensorConfig.captParams.captParamsP_p.sensorEnable &...
     PRAD_data.sensorP.result.matchFound 
    
    % Convert pixels into meters
    sX = PRAD_data.sensorP.result.mInD.vect(1) / 4.0;
    sY = PRAD_data.sensorP.result.mInD.vect(2) / 4.0;
    sAngle = PRAD_data.sensorP.result.mInD.angle;
    sScale = PRAD_data.sensorP.result.mInD.scale;
    
    set( handles.txt_sensor_P_estX,...
       'string', num2str(sX * 1.0e+06, '%+5.2f'));
    set( handles.txt_sensor_P_estY,...
       'string', num2str(sY * 1.0e+06, '%+5.2f'));
    set( handles.txt_sensor_P_estAngle,...
       'string', num2str(sAngle * 1.0e+03, '%+5.2f'));

    set( handles.txt_sensor_P_estRotation,...
         'string', num2str(PRAD_data.sensorP.result.rotation/(2*pi) * 360, '%+4.0f'));
    set( handles.txt_sensor_P_estGain,...
         'string', num2str(sScale, '%+4.3f'));
  else
    set( handles.txt_sensor_P_estX, 'string', '-');
    set( handles.txt_sensor_P_estY, 'string', '-');
    set( handles.txt_sensor_P_estAngle, 'string', '-');

    set( handles.txt_sensor_P_estRotation, 'string', '-');
    set( handles.txt_sensor_P_estGain, 'string', '-');
  end

  %-------------------------------------------------------------------------
  %--  Update the M sensor values
  %-------------------------------------------------------------------------
  if PRAD_control.sensorConfig.captParams.captParamsM_p.sensorEnable &...
     PRAD_data.sensorM.result.matchFound
     
    % Convert pixels into meters
    sX = PRAD_data.sensorM.result.mInD.vect(1) / 4.0;
    sY = PRAD_data.sensorM.result.mInD.vect(2) / 4.0;
    sAngle = PRAD_data.sensorM.result.mInD.angle;
    sScale = PRAD_data.sensorM.result.mInD.scale;
    
    set( handles.txt_sensor_M_estX,...
         'string', num2str(sX * 1.0e+06, '%+5.2f'));
    set( handles.txt_sensor_M_estY,...
         'string', num2str(sY * 1.0e+06, '%+5.2f'));
    set( handles.txt_sensor_M_estAngle,...
         'string', num2str(sAngle * 1.0e+03, '%+5.2f'));

    set( handles.txt_sensor_M_estRotation,...
         'string', num2str(PRAD_data.sensorM.result.rotation/(2*pi) * 360, '%+4.0f'));
    set( handles.txt_sensor_M_estGain,...
         'string', num2str(sScale, '%+4.3f'));
  else
    set( handles.txt_sensor_M_estX, 'string', '-');
    set( handles.txt_sensor_M_estY, 'string', '-');
    set( handles.txt_sensor_M_estAngle, 'string', '-');

    set( handles.txt_sensor_M_estRotation, 'string', '-');
    set( handles.txt_sensor_M_estGain, 'string', '-');
  end
  
  %-------------------------------------------------------------------------
  %--  Update the reticle position values
  %-------------------------------------------------------------------------
  if PRAD_data.reticle.result.present
    set( handles.txt_reticle_estX, 'string',...
      num2str(PRAD_data.reticle.result.rInRs.vect(1) * 1.0e+06, '%+5.2f'));
    set( handles.txt_reticle_estY, 'string',...
      num2str(PRAD_data.reticle.result.rInRs.vect(2) * 1.0e+06, '%+5.2f'));
    set( handles.txt_reticle_estAngle, 'string',...
      num2str(PRAD_data.reticle.result.rInRs.angle * 1.0e+03, '%+5.2f'));

    set( handles.txt_reticle_estRotation, 'string',...
      num2str(PRAD_data.sensorM.result.rotation/(2*pi) * 360, '%+4.0f'));
  else
    set( handles.txt_reticle_estX, 'string', '-');
    set( handles.txt_reticle_estY, 'string', '-');
    set( handles.txt_reticle_estAngle, 'string', '-');

    set( handles.txt_reticle_estRotation, 'string', '-');
  end
end
