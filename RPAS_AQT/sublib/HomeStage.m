function HomeStage(Axes, motionTimers, lampIndicators, colors)
    %This routine moves stage to the home position (0,0,0) 
    %
    %
    %
    %Note: For the inputs, the Axes, and motionTimers must
    %matching correctly. 
    %
    % Examples:
    % 1. HomeStage(0, app.xupdater) moves x coordinate to 0, where
    % app.xupdater will be used to monitor the x-movements
    % 2. HomeStage(1, app.yupdater) moves y coordinate to 0, where
    % app.yupdater will be used to monitor the y-movements
    % 3. HomeStage(2, app.zupdater) moves z coordinate to 0, where
    % app.zupdater will be used to monitor the z-movements
    % 4. HomeStage([0, 1, 2], [app.xupdater, app.yupdater, app.zupdater]) moves (x,y,z) to (0,0,0), where
    %  [app.xupdater, app.yupdater, app.zupdater] will be used to monitor all the x, y, z movements
    %


    for k=1:numel(motionTimers)
        motionTimers(k).start();
    end


    if ~RPAS_Constants.A3200Available
        ABSMoving(Axes, zeros(size(Axes)), 1, motionTimers)
    else
        % make connection
        try
            handle = A3200Connect;
        catch
            addpath(RPAS_Constants().A3200Path);
            handle = A3200Connect;
        end
    
        %if the axes are still moving waiting for them to finish 
        %before we can make the move
        waitForMovingFinished(Axes);
        %wait a while for other process close the connection
        pause(0.3);

        %enable motions
        taskID=1;

        %check the stage status
        enabled=zeros(size(Axes));
        for s=1:numel(Axes)
            status = A3200StatusGetItem(handle, Axes(s), A3200DataSignal.DriveStatus, 0);
            enabled(s)=bitget(status, A3200DriveStatus.Enabled, 'int32');
        end

        %set indicators to disable
        for s=1:numel(Axes)
            lampIndicators(s).Color=colors.Disabled;
        end

        %Home stage all axis
        for s=1:numel(Axes)
            if ~enabled(s)
                A3200MotionEnable(handle, taskID, Axes(s));
            end
            A3200MotionHome(A3200Connect, taskID, Axes(s));
        end
        

        %wait moving finish
        waitForMovingFinished(Axes);
        for s=1:numel(Axes)
            lampIndicators(s).Color=colors.Enabled;
        end
    
        %restore stage to initial condition
        for k=1:numel(Axes)
            if ~enabled(k)
                %disable motion
                A3200MotionDisable(handle, taskID, Axes(k))
            end
        end
        %make disconnection
        A3200Disconnect(handle);
    end


    for k=1:numel(motionTimers)
        motionTimers(k).stop();
    end
end
