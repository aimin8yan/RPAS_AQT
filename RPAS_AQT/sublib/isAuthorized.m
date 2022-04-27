function val = isAuthorized()
  val=false;
  numTry=0;
  records=readinRecord();
  
  while numTry<3
    if numTry==0
      inputs=passwordUI('Query', 'Enter Password');
    else
      inputs=passwordUI('Query', 'Reenter Password');
    end
    
    if length(inputs)>0
      if isMatch(inputs, records)
        val=true;
        return;
      else
        numTry=numTry+1;
      end
    else
      val=false;
      return;
    end
  end
  return;
  
  
  % nested functions
  % compare with records
  function status=isMatch(input, records)
    status=false;
    for j=1:numel(records)
      if strcmp(input, records{j})
        status=true;
        return; 
      end
    end
    return;
  end
  
  % read in saved records from file, decryption is required if needed
  function records=readinRecord()
    PATH=[RPAS_Constants().RPAS_HOME '/sublib'];
    fnm=[PATH '/passwordFile.dat'];
    fid=fopen(fnm,'rb');
    if fid>0
      str=fscanf(fid,'%s');
      records{1}=char(str);
      fclose(fid);
    else
      str=sprintf('Unable to open file "%s" to write.', fnm);
      error(str);
    end
  end
end      
