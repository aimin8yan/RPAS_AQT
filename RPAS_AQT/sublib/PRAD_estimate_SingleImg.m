%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function PRAD_estimate_SingleImg output:
%
%matchInfo is struct with fields:
%  sPos: Nx5 double: (N is the number of spots)
%        column 1: X coordinate, relative to center (m-1)/2
%        column 3: Y coordinate, relative to center (n-1)/2
%        column 3: Spot number in original order.
%        column 4: Spot distance to center
%        column 5: Spot Angle relative to center
%        
%        Note: sPos(1,:) is the spot that has the largest distance to other spots.
%              sPos are sorted according to the distances the spots are far away from sPos(1,:).
%              So sPos(end,:) is the spot most far away from sPos(1,:).
%              
%  sSpotRefPair: row 1: sPos(1,:)
%                row 2: sPos(end,:)
%        Note: See notes in sPos for explanations
%
%  mSpotRefPair: corresponding matched two most far away spots in markerPositions.
%              where pair(1) corresponding to sSpotRefPair(1), and pair(2) corresponding to sSpotRefPair(2).
%        column 1: X coordinate,
%        column 2: Y coordinate,
%        column 3: markerPositions order number.
%        
%  mPos: Mx3 double: (M is the number of spots matched (with in  allowable error))
%        column 1: X coordinate of the transformed spots in reticle
%        column 2: Y coordinate of the transformed spots in reticle
%        column 3: Corresponding spot order number in markerPositions.
%        
%        Note: the mapping from sPos to mPos is sPos(k) --> mPos(k) if M=N.
%              and sSpotRefPair --> mSpotRefPair
%              
%  markerPos:  Corresponding markerPositions in the mapping from sPos to mPos. 
%              In other words is there are no errors, mPos should equal to markerPos
%              
%  sensor: a struct representing the overall sensor information:
%        sizeX, sizeY, rotation: values representing the sensor width, height and rotation angle
%        
%        Note: the value could be negative depending on the rotation
%        
%  refSpot: a struct representing the first spot in sPos and the shifts in the transform to reticle and its corresponding transformed point
%        sX, sY: the coordinates of sPos(1), i.e. sPos(1,1:2).
%        mX, mY: the shift in the transformation
%        spotNumber: corresponding order number in markerPositions. That is (sX, sY) should corresponding to markerPositions(spotNumber), if there is no errors.
%        found: flag indicate if the match is found or not.
%        
%  firstEstimate: a struct representing the matching transformation's angle and scale
%  
%  spotsSorted: a struct representing the adjusted spots. That is the spots are adjusted by the 
%                shift in field refSpot.sX and refSpot.sY;
%        spotsSorted.sPos(:,1:2) = sPos(:,1:2) + [refSpot.sX, refSpot.sY];
%        spotsSorted.sPos(:,3) = sPos(:,3);
%        spotsSorted.sDistance= sPos(:,4);
%        spotsSorted.mDistanceEstimated = spotsSorted.sDistance* sensorInfo.firstEstimate.scale;
%        spotsSorted.mAngleEstimated = spots.sPos(:,5) + sensorInfo.firstEstimate.angle;
%        
%        spotsSorted.mPos(:,1:2) = markerPos(:,1:2) -[4095/2 4095/2]; relative to reticle center and then rotated back to 
%                        to its original direction and coverted to unit in meters.
%        spotsSorted.spotNum = mPos(:,3);  marker order in markerPositions
%        spotsSorted.scale = firstEstimate.scale;
%        
%matchResult: 
%  mInD: a struct with field values for layout fields:
%      vect: a vector of two elements representing X, Y values in X, Y fields. 
%            Need converting to reticle coordinate system (times reticlePixel/imagePixel) and in units um (times 1.0e6)
%      angle: The rotation angle when spots transform to reticle positions. It is the value for field angle. 
%            Need converting to mrad (time 1.0e3).
%      scale: The scale when spots transform to reticle positions. It is the value for field gain.
%      dist: The distribution of X, Y, and Rz for the counted points in the transformation.
%  
%  sensorScale = matchInfo.firstEstimate.scale;
%  
%  sensorAngle = matchInfo.firstEstimate.angle;
%  
%  dInM: ???????????????????
%  
%  dInR: used to calculate Reticle
%  
%  matchFount: flag representing if the match is found
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [matchResult, matchInfo] = PRAD_estimate_SingleImg(spots, sensorName, defaultFlipAxis, defaultRotation, markerPositions, nearestSpotImage)
  global PRAD_control;
  global displayMsg;
  % Crossreference: colomn numbers versus contents
  X = 1; Y = 2; SPOTNUM = 3; DISTANCE = 4; A = 5;
  
  
  % Scan for the sensor pattern in the marker
  matchInfo = PRAD_findSensorInMarker(sensorName, spots, defaultFlipAxis, defaultRotation, markerPositions, nearestSpotImage);
  
  % Reset the flag that must indicate whether the found position matches
  % all the spots in the sensor spotlist.
  
  if matchInfo.refSpot.found
    % determine number of points  
    [numPoints, nop] = size(spots.sPos(:,1));
    
    % Validate the found spotlist and calculate the sensor position
    
    if isequal(sensorName, 'P')
      [matchResult,...
      matchInfo.spotsSorted.mPos,...
      matchInfo.spotsSorted.spotNumber,...
      matchInfo.spotsSorted.scale]  =...
          PRAD_calculateSensor(sensorName, matchInfo, numPoints,...
                                PRAD_control.sensorConfig.sensorP, markerPositions);
    else
      [matchResult,...
      matchInfo.spotsSorted.mPos,...
      matchInfo.spotsSorted.spotNumber,...
      matchInfo.spotsSorted.scale]  =...
          PRAD_calculateSensor(sensorName, matchInfo, numPoints,...
                                PRAD_control.sensorConfig.sensorM, markerPositions);
    end
    
                              
    if matchResult.matchFound
        
      % FOR DEBUG PURPOSES
      matchInfo.debug = ...
         PRAD_fillDebugStruct(matchInfo, spots);
    end
  else
    matchResult=[];
    matchInfo=[];
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


function ret = PRAD_findSensorInMarker(sensorName, spotList, defaultFlipAxis, defaultRotation, markerPositions, nearestSpotImage)
    global displayMsg;

    if spotList.numSpots == 0 
        ret.refSpot.found = 0;
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
            PRAD_fitMarkers( ...
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

    a=round(2*rotation/pi);
    rotatedSpotList = [];
    switch a
    case {0}
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = spotPositions(:, X);
      rotatedSpotList(:, Y) = spotPositions(:, Y);
    case {1}
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = -spotPositions(:, Y);
      rotatedSpotList(:, Y) = spotPositions(:, X);
    case {2}
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = -spotPositions(:, X);
      rotatedSpotList(:, Y) = -spotPositions(:, Y);
    case {3}
      rotatedSpotList = spotPositions;
      rotatedSpotList(:, X) = spotPositions(:, Y);
      rotatedSpotList(:, Y) = -spotPositions(:, X);
    case {-1}
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
function [result, mPos, spotNum, scale] = PRAD_calculateSensor(sensorName, sensorInfo, numPoints, config, markerPositions)
    global displayMsg;
    global imagePixel;
    global reticlePixel;

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

    sensorInfo.sPos(:, X:Y) = imagePixel * sensorInfo.sPos(:, X:Y);
    mPos(:, X:Y) = reticlePixel * mPos(:, X:Y);
    
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
    
    
    
    a=sA(:)-mB(:,3:4)*bVect(3:4);
    dist2=[a(1:2:end-1) a(2:2:end)];
    a=atan2(sensorInfo.sPos(:,2)-bVect(2), sensorInfo.sPos(:,1)-bVect(1));
    b=atan2(mPos(:,2),mPos(:,1));
    dist2(:,3)=a-b;
    result.mInD.dist=dist2;
    

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

% I asume there will be no spots near the boundaries.
% The caller should remove them from the list!

function ...
   [ret, ...
    xm, ...
    ym, ...
    errors, ...
    xres, ...
    yres, ...
    sm, ...
    am, ...
    kres, ...
    spots, ...
    avgdist, ...
    avgdist_nextbest ...
   ] = PRAD_fitMarkers( ...
   stars, ...
   neareststar, ...
   spots, ...
   areax, ...
   areay)
%-----------------------------------------------------------------------------%
%
%                        MATLAB Module
%
%-----------------------------------------------------------------------------%
%
% Ident        : @(#) PRAD_fitMarker.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.0
% LastCheckin  : @(#) 19/11/15 11:20:00
%
% History      : See SCCS
%
%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

  global displayMsg;
  
  % Crossreference: colomn numbers versus contents
  X = 1; Y = 2; SPOTNUM = 3; DISTANCE = 4; A = 5;

  xstars = stars(:,1);
  ystars = stars(:,2);

  nstars = numel(xstars);

  % I expect the stars are in a square matrix, so I can find neighbors

  starstep = fix(sqrt(nstars+.5));

  xspots = spots.sPos(:,X);
  yspots = spots.sPos(:,Y);

  nspots = numel(xspots);

  % Original indices of the spots

  ispots = [1:nspots];

  % Select two points as far as possible from each other

  index = -1;
  dd = 0;

  for i = 1:nspots-1
    for j = i+1:nspots
        d = hypot(xspots(j)-xspots(i),yspots(j)-yspots(i));
        if (d > dd)
           dd = d;
           index = i;
        end
    end
  end

  % Make positions relative to the found point

  dspots = hypot(xspots-xspots(index),yspots-yspots(index));
  [~,order] = sort(dspots);
  dspots = dspots(order);
  xspots = xspots(order);
  yspots = yspots(order);
  ispots = ispots(order);
  spots.sPos = spots.sPos(order,:);
  
  % The optimal found values

  avgdist = 1e10;
  avgdist_nextbest = 1e10;

  kres = zeros(nspots,1);
  spots.sSpotRefPair(1, :) = spots.sPos(1, :);
  spots.sSpotRefPair(2, :) = spots.sPos(nspots, :);

  if displayMsg
    fprintf('Dots with largest distance: (x,y)=(%+.6f, %+.6f) -> (%+.6f, %+.6f) Distance = %.6f\n', spots.sPos(1, X), spots.sPos(1, Y), ...
      spots.sPos(nspots, X), spots.sPos(nspots, Y), ...
      hypot(spots.sPos(1, X) - spots.sPos(nspots, X), spots.sPos(1, Y) - spots.sPos(nspots, Y)));
  end

  for k = 1:nstars

   % Assuming this is the match, calculate the error on the next marker

   xx = xstars(k)+xspots(nspots)-xspots(1);
   yy = ystars(k)+yspots(nspots)-yspots(1);

   % This differs from the original algorithm, now I simply take
   % the nearest, no matter what the distance is.
   % Maybe this can stil go wrong when the displacement is large?

   o = neareststar(max(1,min(areay,fix(yy)+1)),max(1,min(areax,fix(xx)+1)));

   % Try all neigbors, this is only needed to add enough tolerance.
   % When scale is almost 1 and angle is almost 0, dx=0 and dy=0 is enough!

   for dx = -1:1
     for dy = -1:1

      sx = mod((o-1),starstep)+dx;
      sy = fix((o-1)/starstep)+dy;

      if ((sx >= 0) & (sx < starstep) & (sy >= 0) & (sy < starstep))

         oo = sx+starstep*sy+1;

         % What happens when this is equal??

         if (oo ~= k)

            % Possible fit, calculate scaling+rotation, rel to first [xy]spots
  
            scale = hypot(xspots(nspots)-xspots(1),yspots(nspots)-yspots(1));
            scale = scale/hypot(xstars(oo)-xstars(k),ystars(oo)-ystars(k));
            angle = atan2(ystars(oo)-ystars(k),xstars(oo)-xstars(k))- ...
                    atan2(yspots(nspots)-yspots(1),xspots(nspots)-xspots(1));

            cang = cos(angle);
            sang = sin(angle);

            cx = xstars(k);
            cy = ystars(k);

            cx = cx+((xspots-xspots(1))*cang-(yspots-yspots(1))*sang)/scale;
            cy = cy+((xspots-xspots(1))*sang+(yspots-yspots(1))*cang)/scale;

            sum = 0;

            on = zeros(nspots,1);

            for i = 1:nspots

               icy = max(1,min(areay,fix(cy(i))+1));
               icx = max(1,min(areax,fix(cx(i))+1));

               on(i) = neareststar(icy,icx);

               dist = hypot(ystars(on(i))-cy(i),xstars(on(i))-cx(i));
               sum = sum + dist;

            end

            % The first and the last are per definition 0

            sum = (sum/(nspots-2));
            
            % Save optimal values, including the scaled/rotated points

            if (sum < avgdist)

               avgdist_nextbest = avgdist;
               avgdist = sum;
               kres = on;

            end
         end
      end
     end
   end

  end 
  
  [xres,yres] = PRAD_calculatePoints(xspots,yspots,xstars,ystars,kres);

  spots.mSpotRefPair(1, 1) = xres(1);
  spots.mSpotRefPair(1, 2) = yres(1);
  spots.mSpotRefPair(1, 3) = kres(1);
  spots.mSpotRefPair(2, 1) = xres(nspots);
  spots.mSpotRefPair(2, 2) = yres(nspots);
  spots.mSpotRefPair(2, 3) = kres(nspots);

  % Calculate the estimation distances of the spots

  errors = hypot(xres-xstars(kres),yres-ystars(kres));

  % Squeeze unused entries

  RPMP_MAX_ERROR = 5;
  RPMP_USEDOTS = 6;

  indices = find(errors <= RPMP_MAX_ERROR);
  if displayMsg
    fprintf('Labels = %d, Bad Labels = %d, avgdist_next = %.6f, avgdist * 2.0 = %.6f\n', ...
      numel(errors), numel(errors) - numel(indices), avgdist_nextbest, avgdist*2.0);
  end

  if ((numel(indices) < RPMP_USEDOTS) | ...
      (avgdist_nextbest < (avgdist*2)))
     xspots;
     yspots;
     errors;
     kres;
     ispots;
  end

  xspots = xspots(indices);
  yspots = yspots(indices);
  errors = errors(indices);
  xres = xres(indices);
  yres = yres(indices);
  kres = kres(indices);
  ispots = ispots(indices);
  nspots = numel(xspots);
  spots.sPos = spots.sPos(indices,:);

  if (numel(errors) < RPMP_USEDOTS)
     ret = -2;
     xm = 0;
     ym = 0;
     sm = 1;
     am = 0;
     if displayMsg
       fprintf('nUsed = %d, matchFound = %s\n', numel(indices), 'FALSE');
     end
     return
  end

  if displayMsg
    fprintf('nUsed = %d, matchFound = %s\n', numel(indices), 'TRUE');
  end

  % and calculate again the resulting points
  % This time, only the spots with allowable errors are used
  [xres,yres] = PRAD_calculatePoints(xspots,yspots,xstars,ystars,kres);

  %[xm,ym,sm,am] = calculateCenter(xspots,yspots,xstars(kres),ystars(kres));
  [xm,ym,sm,am] = PRAD_calculateCenterLSQ(xspots,yspots,xstars(kres),ystars(kres));
  %[xres, yres, refSpotNr, errors, ki, xm, ym, sm, am] = PRAD_reCalculatePoints(errors, xspots,yspots,xstars,ystars,kres);

  refSpotNr = 1;

  % Sort back to original order
  % [~,order] = sort(ispots);
  % errors = errors(order);
  % xres = xres(order);
  % yres = yres(order);
  % spots.sPos = spots.sPos(order, :);
  % refSpotNr = find(order == refSpotNr);
  % kres = kres(order);

  spots.mPos(:,SPOTNUM) = kres;
  spots.markerPos(:, X) = xstars(kres);
  spots.markerPos(:, Y) = ystars(kres);
  spots.mPos(:, X) = xres;
  spots.mPos(:, Y) = yres;
  
  ret = 0;
end

function [xres,yres] = PRAD_calculatePoints(xspots,yspots,xstars,ystars,kres)
%-----------------------------------------------------------------------------%
%
%                        MATLAB Module
%
%-----------------------------------------------------------------------------%
%
% Ident        : @(#) PRAD_calculatePoints.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.0
% LastCheckin  : @(#) 19/11/15 11:20:00
%
% History      : See SCCS
%
%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

% For all combinations of two points, calculate the position of
% all other points. For each point, take the median of these estimations.

  nspots = numel(kres);

  xres = zeros(nspots,((nspots-1)*(nspots-2))/2);
  yres = zeros(nspots,((nspots-1)*(nspots-2))/2);
  ires = zeros(nspots,1);

    % For all combinations of 2 points

    for i = 1:nspots
      for j = i+1:nspots

       % Star number in the ground truth space

       ki = kres(i);
       kj = kres(j);

       % Calculate rotation/scale, based on these two points

       scale = hypot(xspots(i)-xspots(j),yspots(i)-yspots(j));
       scale = scale/hypot(xstars(ki)-xstars(kj),ystars(ki)-ystars(kj));
       angle = atan2(ystars(kj)-ystars(ki),xstars(kj)-xstars(ki));
       angle = angle-atan2(yspots(j)-yspots(i),xspots(j)-xspots(i));

       cang = cos(angle);
       sang = sin(angle);

       % Estimate the positions of the other points

       xtmp = xstars(ki)+((xspots-xspots(i))*cang-(yspots-yspots(i))*sang)/scale;
       ytmp = ystars(ki)+((xspots-xspots(i))*sang+(yspots-yspots(i))*cang)/scale;
       for k = 1:nspots
          if ((k ~= i) & (k ~= j))
             xres(k,ires(k)+1) = xtmp(k);
             yres(k,ires(k)+1) = ytmp(k);
             ires(k) = ires(k)+1;
          end
       end
    end
  end

  % Take medians of all the other points

  xresn = zeros(nspots,1);
  yresn = zeros(nspots,1);
  for k = 1:nspots
     xtmp = sort(xres(k,:));
     ytmp = sort(yres(k,:));
     xresn(k) = xtmp(fix(numel(xtmp)/2)+1);
     yresn(k) = ytmp(fix(numel(ytmp)/2)+1);
  end
  xres = xresn;
  yres = yresn;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% xm,ym,sm,am is the transformation matrix (M) of xspots to points in xstars;
% of which, am is the rotation angle, sm is the scale, xm, and ym are the shift.
% Note, in the computation, am is assumed small, so am is approximated to tan(am).
% xres, yres is the transformed points in xstars: [xres, yres] = M*[xspots, yspots]';
% errors are the corresponding error between [xres, yres] and xstars(i)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xm,ym,sm,am,xres,yres,errors] = ...
   PRAD_calculateCenterLSQ(xspots,yspots,xstars,ystars)

  A_data = zeros(2*size(xstars,1),4);
  b_data = zeros(2*size(xstars,1),1);
  for i = 1:size(xstars,1)
    pt0 = xspots(i);
    pt1 = yspots(i);
    A_data(2*i-1:2*i-1,1:4) = [[-pt1,pt0,1,0]];
    A_data(2*i-0:2*i-0,1:4) = [[ pt0,pt1,0,1]];
    pt0 = xstars(i);
    pt1 = ystars(i);
    b_data(2*i-1) = pt0;
    b_data(2*i-0) = pt1;
  end

  c = A_data\b_data;

  xm = c(3);
  ym = c(4);
  sm = 1/c(2);
  am = c(1);

  errors = [];
  xres = [];
  yres = [];

  for i = 1:size(xstars,1)
     x1 = c(2)*(xspots(i) * cos(c(1)) - yspots(i) * sin(c(1)))+c(3);
     y1 = c(2)*(yspots(i) * cos(c(1)) + xspots(i) * sin(c(1)))+c(4);
     x2 = xstars(i);
     y2 = ystars(i);
     xres(i) = x1;
     yres(i) = y1;
     errors(i) = hypot(x2-x1,y2-y1);
  end

end



%---------------------------------------------------------------------------
% fn_displayMarkerSpotList
%
% purpose: Display spots using a fprintf to matlab console
%
% author:  Alfred Abutan
% creation: 27 jan 2020
%---------------------------------------------------------------------------
function fn_displayMarkerSpotList(listTitle, numberFormat, markerSpotNumbers, spotPostionsFrom, titleFrom, spotPositionsTo, titleTo, dist, titleDist)

    nf = numberFormat;
    fprintf('\n%s\n', upper(listTitle));
    
    if exist('dist', 'var') && ~isempty(dist)
        fprintf('                         %-31s%-30s%-20s\n', titleFrom, titleTo, titleDist);
        for sp = 1:length(spotPostionsFrom)
            fprintf(['Marker Spotnumber = %3d ((' nf ', ' nf ')-> (' nf ', ' nf '))   ' nf '\n'], ...
                markerSpotNumbers(sp), spotPostionsFrom(sp, 1), spotPostionsFrom(sp, 2), ...
                spotPositionsTo(sp, 1), spotPositionsTo(sp, 2), ...
                dist(sp));
        end
    else
        fprintf('                         %-31s%-30s\n', titleFrom, titleTo);
        for sp = 1:length(spotPostionsFrom)
            fprintf(['Marker Spotnumber = %3d ((' nf ', ' nf ')-> (' nf ', ' nf '))\n'], ...
                markerSpotNumbers(sp), spotPostionsFrom(sp, 1), spotPostionsFrom(sp, 2), ...
                spotPositionsTo(sp, 1), spotPositionsTo(sp, 2));
        end
    end
end
