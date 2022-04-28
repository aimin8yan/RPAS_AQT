function status = resetPassword()
  if ~isdeployed
      addpath('sublib');
  end

  if isdeployed
      fnm='RPAS_AQT.exe';
  else
      fnm='RPAS_AQT.mlapp';
  end
  if exist(fnm)
      obj=RPAS_Constants(pwd);
  elseif exist(['../' fnm])
      obj=RPAS_Constants(parentDir(pwd));
  else
      PATH=inputdlg(['Enter the home directory of ' fnm], 'Input RPAS_AQT Home');
      if isempty(PATH)||isempty(PATH{1})
          showInfoMsg('No password created.');
          exit;
      end
      obj=RPAS_Constants(PATH{1});
  end
  
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
      fnm=[obj.QUAL_DATA_SHEET_DIR  '/passwordFile.dat'];
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
    fnm=[obj.QUAL_DATA_SHEET_DIR  '/passwordFile.dat'];
    fid=fopen(fnm,'rb');
    if fid>0
      str=fscanf(fid,'%s');
      records{1}=char(str);
      fclose(fid);
    else
      str=sprintf('Unable to open file "%s" to read.', fnm);
      error(str);
    end
  end

    function showInfoMsg(msg)
        sz=get(0,'ScreenSize');
        ct=[sz(3)/2, sz(4)/2];
        w=300; h=160;
        fig=uifigure('position',[ct(1)-w/2, ct(2)-h/2, w, h]);
        title='Info';
        selection=uiconfirm(fig,msg,title, ...
            'Options',{'OK'}, ...
            'icon', 'info');
        switch selection
            case {'OK'}
            otherwise
        end
        delete(fig);
    end
end  
  
