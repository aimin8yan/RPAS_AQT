function saveMagResults(operatorInfo, data)
  fitting=false;
  matchPos={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'};
  
  HOME=RPAS_Constants().RPAS_HOME;
  DIR=[HOME '/' RPAS_Constants.QUAL_RESULT_DIR '/AutoQual/' operatorInfo.SN];
  RPAS_Make_folder(DIR);
  
  fout=[DIR '/Magnification_Test_Result.xlsx'];
  %image folder
  IMG_DIR=[DIR '/' RPAS_Constants.QUAL_IMAGE_DIR '/Magnification'];
  RPAS_Make_folder(IMG_DIR);

  if (~isempty(data.SWD_data))
      fnm=[IMG_DIR '/SWD_MAGNIFICATION_TEST.png'];
      imwrite(data.SWD_images, fnm);
  end
  if (~isempty(data.LWD_data))
      fnm=[IMG_DIR '/LWD_MAGNIFICATION_TEST.png'];
      imwrite(data.LWD_images, fnm);
  end

  if exist(fout)
      delete(fout);
  end

  %Open an ActiveX connection to Excel
  h = actxserver('excel.application');
    
  %Create a new work book (excel file)
  wb=h.WorkBooks.Add();
    
  
  %header
  %Select the appropriate range
  range='B1';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '            Nominal Position'; 


  range='B3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Xc'; 


  range='C3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Yc'; 


  range='D3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Znom'; 


  range='E1';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '       Target Values'; 


  range='E3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Mag'; 


  range='F3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Max Error (%)'; 


  range='G1';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '                      Allowable MTF:'; 


  range='G2';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '                   X';


  range='G3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Min C. Amp (%)'; 


  range='H3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Max HWHM (1/um)'; 


  range='I2';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '                   Y'; 


  range='I3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Min C. Amp (%)'; 


  range='J3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Max HWHM (1/um)'; 


  range='M1';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '    Measured Value'; 


  range='M3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Mag'; 


  range='N3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Error (%)'; 


  range='Q1';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '                        Measured MTF'; 


  range='P2';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '                   X'; 


  range='P3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'C. Amp(%)'; 


  range='Q3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'HWHM (1/um)'; 

  range='S2';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = '                   Y'; 


  range='S3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'C. Amp(%)'; 


  range='T3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'HWHM (1/um)'; 
    
  range='M1:U6';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=hex2dec('00FF00'); %Gray

  range='A5';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'SWD'; 

  range='A6';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'LWD'; 

  %Data
  if ~isempty(data.SWD_data)
      dt=data.SWD_data;
      R=[dt.position dt.MagTarget dt.MagErr dt.CenterAmpErr_X ...
          dt.HWHMErr_X dt.CenterAmpErr_Y dt.HWHMErr_Y];
      range='B5:J5';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R; 
  end

  if ~isempty(data.LWD_data)
      dt=data.LWD_data;
      R=[dt.position dt.MagTarget dt.MagErr dt.CenterAmpErr_X ...
          dt.HWHMErr_X dt.CenterAmpErr_Y dt.HWHMErr_Y];
  
      range='B6:J6';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R; 
  end

  if ~isempty(data.SWD_result)
      result=data.SWD_result;
      R=[result.Mag result.MagError ...
          result.centerAmp_x round(result.HWHM_x,4) ...
          result.centerAmp_y round(result.HWHM_y,4)];

      range='M5:N5';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R(:,1:2); 

      range='P5:Q5';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R(:,3:4); 
    
      range='S5:T5';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R(:,5:6); 
  end
    

  if ~isempty(data.LWD_result)
      result=data.LWD_result;
      R=[result.Mag result.MagError ...
          result.centerAmp_x round(result.HWHM_x,4) ...
          result.centerAmp_y round(result.HWHM_y,4)];

      range='M6:N6';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R(:,1:2); 

      range='P6:Q6';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R(:,3:4); 
    
      range='S6:T6';
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = R(:,5:6); 
  end



  Errcolor=hex2dec('0000FF');

  if ~isempty(data.SWD_result)
      dt=data.SWD_data;
      rst=data.SWD_result;
      if abs(rst.MagError)>dt.MagErr
          range='N5';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray,
      end

      if rst.centerAmp_x<dt.CenterAmpErr_X
          range='P5';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end

      if rst.HWHM_x > dt.HWHMErr_X
          range='Q5';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end

      if rst.centerAmp_y<dt.CenterAmpErr_Y
          range='S5';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end

      if rst.HWHM_y > dt.HWHMErr_Y
          range='T5';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end
  end
    
  if ~isempty(data.LWD_result)
      dt=data.LWD_data;
      rst=data.LWD_result;
      if abs(rst.MagError)>dt.MagErr
          range='N6';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray,
      end

      if rst.centerAmp_x<dt.CenterAmpErr_X
          range='P6';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end

      if rst.HWHM_x > dt.HWHMErr_X
          range='Q6';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end

      if rst.centerAmp_y<dt.CenterAmpErr_Y
          range='S6';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end

      if rst.HWHM_y > dt.HWHMErr_Y
          range='T6';
          ran = h.Activesheet.get('Range',range); 
          ran.interior.Color=Errcolor; %Gray
      end
  end

  % save the file with the given file name, close Excel
  wb.SaveAs(fout); 
  wb.Close;
  h.Quit;
  h.delete;
end















  
