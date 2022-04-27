
function out=readDataSheet(fname)
  out = [];
  
  [path, file, ext]=fileparts(fname);
  
  if ~isempty(ext)
     if ~strcmp(ext, '.xlsx')
        errID = 'RPAS_ReadDataSheet:ext';
        msg= sprintf('Unsupported file extension: %s', ext);
        ME = MExcdption(errID, msg);
        throw(ME);
      end
  else
    fname = [fname '.xlsx'];
  end
  
  if ~exist(fname)
      errID = 'RPAS_ReadDataSheet:FileNotFound';
      msg= sprintf('File %s Not Found in directory: \n%s.', file, path);
      msg=replace( msg, '\', '\\');
      ME = MException(errID, msg);
      throw(ME);
  end
    
  T1=readmatrix(fname);
  T2=[];
  for k=1:size(T1,2)
      if ~all(isnan(T1(:,k)))
          T2=[T2 T1(:,k)];
      end
  end
  T=[];
  for k=1:size(T2,1)
      if ~all(isnan(T2(k,:)))
          T=[T;T2(k,:)];
      end
  end

  [m,n]=size(T);

  if n==10
    out=struct('numTestPoints', size(T,1), 'TestPoint', T(:,1), 'BI', T(:,2), ...
      'Stage', T(:,3:5), 'Expected', T(:,6:8), 'Error', [T(:,9) T(:,9:10)]);
  else
      out=struct('numTestPoints', size(T,1), 'TestPoint', T(:,1), 'BI', ones(size(T,1),1), ...
      'Stage', T(:,2:4), 'Expected', T(:,5:7), 'Error', [T(:,8) T(:,8:9)]);
  end
end
    

