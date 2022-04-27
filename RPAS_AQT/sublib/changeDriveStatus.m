function changeDriveStatus(axis, currentStatus, lampIndicator, colors)
    if RPAS_Constants.A3200Available
        try
            handle = A3200Connect;
        catch
            addpath(RPAS_Constants().A3200Path);
            handle = A3200Connect;
        end
        taskId=1;
    
        if currentStatus==1
            A3200MotionDisable(handle, taskId, axis);
            lampIndicator.Color= colors.Disabled;
        else 
            A3200MotionEnable(handle, taskId, axis);
            lampIndicator.Color= colors.Enabled;
        end
    else
        if currentStatus==1
            lampIndicator.Color= colors.Disabled;
        else 
            lampIndicator.Color= colors.Enabled;
        end
    end
    return;
end