function stopMotion(motionTimers)
    if RPAS_Constants.A3200Available
        axes=[0,1,2];
        % make connection
        try
            handle = A3200Connect;
        catch
            addpath(RPAS_Constants().A3200Path);
            handle = A3200Connect;
        end
        A3200MotionAbort (handle, axes);

        %make disconnection
        A3200Disconnect(handle);
    end
    for k=1:numel(motionTimers)
        motionTimers(k).stop();
    end
end