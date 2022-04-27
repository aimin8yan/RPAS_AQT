function waitForMovingFinished(Axes)
        % make connection
        try
            handle = A3200Connect;
        catch
            addpath(RPAS_Constants().A3200Path);
            handle = A3200Connect;
        end
        
        %waiting for all moving to stop
        oldVal=zeros(size(Axes));
        newVal=zeros(size(Axes));
        for k=1:numel(Axes)
            newVal(k)=round(A3200StatusGetItem(handle, Axes(k), ...
                A3200StatusItem.PositionFeedback, 0),6);
        end

        while any(oldVal~=newVal)
            oldVal=newVal;
            pause(0.1);
            for k=1:numel(Axes)
                newVal(k)=round(A3200StatusGetItem(handle, Axes(k), ...
                    A3200StatusItem.PositionFeedback, 0),6);
            end
        end

        %make disconnection
        A3200Disconnect(handle);
end