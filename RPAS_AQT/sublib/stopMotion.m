function stopMotion(motionTimers, app)
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
    if RPAS_C.A3200Available
        axes=[0,1,2];
        % make connection
        handle = A3200Connect;
        A3200MotionAbort (handle, axes);

        %make disconnection
        A3200Disconnect(handle);
    end
    for k=1:numel(motionTimers)
        motionTimers(k).stop();
    end
    if nargin==2
        if isprop(app, 'motionStatus') && ~isempty(app.motionStatus)
            status=app.motionStatus.status;
            if ~strcmp(status,'finished')
                app.motionStatus.status='aborted';
            end
        end
    end
end