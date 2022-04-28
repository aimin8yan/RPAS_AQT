function changeDriveStatus(axis, currentStatus, lampIndicator, colors)
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
    if RPAS_C.A3200Available
        handle = A3200Connect;
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