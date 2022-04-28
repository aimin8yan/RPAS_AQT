function RelativeMoving(Axe, MovingIncrement, MovingSpeed, motionTimer, app)
    %This routine combines the X,Y,and Z Relative moving together. 
    %It added a feature of disabling the motion and closing the
    %connection. No other activity can be done while the system is moving.
    %I believe this way the system is safer. 
    %
    %
    %
    %Note: For the inputs, the Axe, and MovingIncrement must
    %matching correctly. 
    %
    % Examples:
    % 1. XRelativeMove: RelativeMoving(0, X-dist, xspeed)
    % 2. YRelativeMove: RelativeMoving(1, Y-dist, yspeed)
    %
    % In above examples, X-dist, Y-dist are the true relative moving
    % distances corresponding the axis.
    

    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end

    motionTimer.start();

    if ~RPAS_C.A3200Available
        if nargin==5
            if isprop(app, 'motionStatus')
                global buffer;
                if isempty(buffer)
                    buffer=[0 0 0; 0 0 0];
                end
                value=movingIncrement+buffer(1, app.coord+1);
                app.motionStatus=struct('axes', Axe, 'movingSpeeds', MovingSpeed, ...
                    'movingDistances', value, 'status', 'started', 'isPausing', false);
            end
        end

        %start moving
        moveTo(MovingIncrement, Axe, 'relative');
        
        %wait for moving stops
        while isMovingBusy(Axe)
            pause(0.05);
        end
        
    else
        % make connection% make connection
        handle = A3200Connect;
        if nargin==5
            if isprop(app, 'motionStatus')
                value=MovingIncrement+A3200StatusGetItem(handle, Axe, ...
                  A3200StatusItem.PositionFeedback, 0);
                app.motionStatus=struct('axes', Axe, 'movingSpeeds', MovingSpeed, ...
                    'movingDistances', value, 'status', 'started', 'isPausing', false);
            end
        end

        %if the axes are still moving waiting for them to finish 
        %before we can make the move
        waitForMovingFinished(Axe);
        %wait a while for other process close the connection
        pause(0.3);

        taskID=1;
        
        %start moving
        status = A3200StatusGetItem(A3200Connect, Axe, A3200DataSignal.DriveStatus, 0);
        enabled=bitget(status, A3200DriveStatus.Enabled, 'int32');
        if ~enabled
            A3200MotionEnable(handle, taskID, Axe);
        end

        %start moving
        A3200MotionMoveInc(handle, 1, Axe, MovingIncrement, MovingSpeed);

        %A3200ProgramGetTaskState  ( in  handle,  in  taskId   );
        % A3200ProgramGetTaskStateString  ( in  handle,  in  taskId  )  

        %wait moving finish
        waitForMovingFinished(Axe);
    
        %disable motion and connection
        if ~enabled %disable if necessary
            A3200MotionDisable(handle, 1, Axe);
        end

        %make disconnection
        A3200Disconnect(handle);
    end

    motionTimer.stop();

    if nargin==5
        if isprop(app, 'motionStatus')
            app.motionStatus.status='finished';
        end
    end
end
        
        
    
    