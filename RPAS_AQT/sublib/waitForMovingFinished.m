function waitForMovingFinished(Axes)
        % make connection
        handle=A3200Connect;
            
        pause(0.1);
        moveDoneBit=23;
        status=A3200StatusItem.AxisStatus;
        flags=0;
        for k=2:numel(Axes)
            status(end+1)=A3200StatusItem.AxisStatus;
            flags(end+1)=0;
        end
        %waiting for all moving to stop
        while any(~bitget(A3200StatusGetItems(handle, Axes, status,flags),moveDoneBit))
            pause(0.1);
        end
        pause(0.1);                                 
%         
%         oldVal=zeros(size(Axes));
%         newVal=zeros(size(Axes));
%         for k=1:numel(Axes)
%             newVal(k)=round(A3200StatusGetItem(handle, Axes(k), ...
%                 A3200StatusItem.PositionFeedback, 0),5);
%         end
%         moveDone=0;
%         moveDoneFlag=A3200AxisStatus.MoveDone;
%         while any(oldVal~=newVal)
%             oldVal=newVal;
%             pause(0.1);
%             temp=A3200StatusGetItem(handle, Axes(1), ...
%                 A3200StatusItem.AxisStatus,0);
%             for k=1:numel(Axes)
%                 newVal(k)=round(A3200StatusGetItem(handle, Axes(k), ...
%                     A3200StatusItem.PositionFeedback, 0),5);
%             end
%             moveDone=bitget(A3200StatusGetItem(handle, Axes(1), ...
%                 A3200StatusItem.AxisStatus,0),23);
%             fprintf(1,'NotDone: temp=%d: %s : ox%s: moveDone=%d, oldVal~=newVal=%d : %g\n', temp, dec2bin(temp), dec2hex(temp), moveDone, any(oldVal~=newVal), sum(oldVal-newVal));
%         end
% 
%         pause(1)
%             temp=A3200StatusGetItem(handle, Axes(1), ...
%                 A3200StatusItem.AxisStatus,0);
%             if temp>=moveDoneFlag
%                 moveDone=bitget(temp, 23);
%                 fprintf(1,'bitget performed\n')
%             else
%                 moveDone=0;
%             end
%             fprintf(1,'Done: temp=%d: %s : ox%s : moveDone=%d\n', temp, dec2bin(temp), dec2hex(temp), moveDone);
        %make disconnection
        pause(0.1); %pause extra time
        A3200Disconnect(handle);
end