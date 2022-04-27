function RelativeMoving(Axe, MovingIncrement, MovingSpeed, motionTimer)
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
    

    motionTimer.start();

    if ~RPAS_Constants.A3200Available
        %start moving
        moveTo(MovingIncrement, Axe, 'relative');
        
        %wait for moving stops
        while isMovingBusy(Axe)
            pause(0.05);
        end
        
    else
        % make connection% make connection
        try
            handle = A3200Connect;
        catch
            addpath(RPAS_Constants().A3200Path);
            handle = A3200Connect;
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
end
        
        
    
    