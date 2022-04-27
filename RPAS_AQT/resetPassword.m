function status = resetPassword()

  status=false;
  numTry=0;
  records=readinRecord();
  
  passed=false;
  while numTry<3
    if numTry==0
      inputs=passwordUI('Query', 'Enter Old Password');
    else
      inputs=passwordUI('Query', 'Reenter Old Password');
    end
    
    if isMatch(inputs, records)
      passed=true;
      break;
    else
      numTry=numTry+1;
    end
  end

  % create new password
  if passed
    inputs=passwordUI('Create', 'New Password');
    
    if ~isempty(inputs)
      PATH=[RPAS_Constants().RPAS_HOME '/sublib'];
      fnm=[PATH '/passwordFile.dat'];
      fid=fopen(fnm,'wb');
    
      if fid>0
        fprintf(fid,inputs, '%s');
        fclose(fid);
        status=true;
      else
        str=sprintf('Unable to open file "%s" to write.', fnm);
        error(str);
      end
    end
  else
    status=false;
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
  
