function ABSMoving(Axes, MovingDistances, MovingSpeeds, motionTimers, app)
    %This routine combines the X,Y,and ZABS together to make absolute
    %moving. It added a feature of disabling the motion and closing the
    %connection. No other activity can be done while the system is moving.
    %I believe this way the system is safer. 
    %
    %
    %
    %Note: For the inputs, the Axes, and MovingDistances must
    %matching correctly. 
    %
    % Examples:
    % 1. XABS: ABSMoving(0, X-dist, xspeed)
    % 2. YABS: ABSMoving(1, Y-dist, yspeed)
    % 3. Moving X, Y, Z at the same time such as moving to home position 
    %   with the same moving speed in each direction:
    %   ABSMoving([0,1,2], [X-home, Y-home, Z-home], speed); 
    %
    % In above examples, X-dist, Y-dist, and X-home, Y-home, Z-home are
    % true distances to move in corresponding axis.

    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
    
    if numel(Axes) ~= numel(MovingDistances) numel(Axes)<1 | numel(Axes)>3
        error('The three inputs must be vectors of size 1, 2, or 3 and same length.');
    end
    if numel(MovingSpeeds) ~= numel(Axes) & ~isscalar(MovingSpeeds)
        error('The last input must be scalar of a vector of the same size as Axes');
    end
    
    if isscalar(MovingSpeeds)
        MovingSpeeds=MovingSpeeds.*ones(size(Axes));
    end

    if nargin==5
        if isprop(app, 'motionStatus')
            app.motionStatus=struct('axes', Axes, 'movingSpeeds', MovingSpeeds, ...
                'movingDistances', MovingDistances, 'movingType', 'absolute', ...
                'status', 'started', 'isPausing', false);
        end
    end
        
    for k=1:numel(motionTimers)
        motionTimers(k).start();
    end

    if ~RPAS_C.A3200Available
        for k=1:numel(Axes)
            moveTo(MovingDistances(k), Axes(k), 'absolute');
        end
        
        %waiting for all moving to stop
        flag = false;
        while ~flag
            pause(0.05);
            flag=true;
            for k=1:numel(Axes)
                flag = flag & ...
                    ~isMovingBusy(Axes(k));
            end
        end
        
    else
        % make connection
        handle = A3200Connect;
    
        %if the axes are still moving waiting for them to finish 
        %before we can make the move
        waitForMovingFinished(Axes);
        %wait a while for other process close the connection
        pause(0.1);

        %enable motions
        taskID=1;

        %check the stage status
        enabled=zeros(size(Axes));
        for k=1:numel(Axes)
            status = A3200StatusGetItem(A3200Connect, Axes(k), A3200DataSignal.DriveStatus, 0);
            enabled(k)=bitget(status, A3200DriveStatus.Enabled, 'int32');
        end

        %enable stage if necessary
        for k=1:numel(enabled)
            if ~enabled(k)
                A3200MotionEnable(handle, taskID, Axes(k));
            end
        end
            
        % start moving;
        for k=1:numel(Axes)
            A3200MotionMoveAbs(handle, taskID, Axes(k), MovingDistances(k), MovingSpeeds(k));
        end

        %wait moving finish
        waitForMovingFinished(Axes);
    
        %restore stage to it's initial condition
        for k=1:numel(enabled)
            if ~enabled(k)
                A3200MotionDisable(handle, taskID, Axes(k))
            end
        end
        %make disconnection
        A3200Disconnect(handle);
    end


    for k=1:numel(motionTimers)
        motionTimers(k).stop();
    end


    if nargin==5
        if isprop(app, 'motionStatus')
            app.motionStatus.status='finished';
        end
    end
end
        
        
    
    