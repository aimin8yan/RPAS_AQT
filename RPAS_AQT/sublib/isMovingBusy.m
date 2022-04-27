function flag=isMovingBusy(coord)
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
    
    if buffer(2,coord+1)==0
        flag=false;
    else
        flag=true;
    end
    return;
end
