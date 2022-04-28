function val = setPassword()
  val=false;

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
  
  inputs=passwordUI('Create', 'Password');

  if ~isempty(inputs) 
    fnm=[obj.QUAL_DATA_SHEET_DIR '/passwordFile.dat'];

    if exist(fnm)
        flag=confirmChange({'Old password will be overwritten.', 'Are you sure to change?'});
    else
        flag=1;
    end
        fprintf(1,'flag=%d\n', flag);
    if flag==1
        fid=fopen(fnm,'wb');
        
        if fid>0
          fprintf(fid,inputs, '%s');
          fclose(fid);
          val=true;
        else
          str=sprintf('Unable to open file "%s" to write.', fnm);
          error(str);
        end
    end
  end
  return;

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

      function flag=confirmChange(msg)
          sz=get(0,'ScreenSize');
          ct=[sz(3)/2, sz(4)/2];
          w=300; h=160;
          fig=uifigure('position',[ct(1)-w/2, ct(2)-h/2, w, h]);
          title='Info';
          selection=uiconfirm(fig,msg,title, ...
              'Options',{'Yes', 'No'}, ...
              'icon', 'info');
          switch selection
              case {'Yes'}
                  flag=1;
              otherwise
                  flag=0;
          end
          delete(fig);
      end
end
