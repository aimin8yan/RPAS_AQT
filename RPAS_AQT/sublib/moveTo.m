function moveTo(val, coord, moveMethod)
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
    global buffer;
    if isempty(buffer)
        buffer=[0 0 0;0 0 0];
%        if isfile('tmp.dat')
%            fid=fopen('tmp.dat','rb');
%            buffer=fread(fid,'double');
%        else
%          buffer=[0 0 0];
%        end
    end
    num=20;
    initPos=buffer(1,coord+1);
    switch moveMethod
      case 'relative'
          dlt=val/(num-1);
      case 'absolute'
          dlt=(val-initPos)/(num-1);
    end
        
    %setMovingBusy(coord, 1);
    setMovingBusy(coord, 1);
    if abs(dlt)>0
        for k=1:num
          buffer(1,coord+1)=initPos+(k-1)*dlt;
          pause(0.1);
        end
    end
    setMovingBusy(coord,0);
    fid=fopen([RPAS_C.QUAL_DATA_SHEET_DIR '/tmp.dat'], 'wb');
        fwrite(fid,buffer, 'double');
    fclose(fid);
end
