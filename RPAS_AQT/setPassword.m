function val = setPassword()
  val=false;
  
  inputs=passwordUI('Create', 'Password');

  if ~isempty(inputs)
    PATH=[RPAS_Constants().RPAS_HOME '/sublib'];
    fnm=[PATH '/passwordFile.dat'];
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
