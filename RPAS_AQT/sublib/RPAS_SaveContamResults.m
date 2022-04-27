function saveContamResults(operatorInfo, data)
  fitting=false;
  matchPos={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'};
  
  HOME=RPAS_Constants().RPAS_HOME;
  DIR=[HOME '/' RPAS_Constants.QUAL_RESULT_DIR '/AutoQual/' operatorInfo.SN];
  RPAS_Make_folder(DIR);
  
  fout=[DIR '/Contam_Qual_Test_Result.xlsx'];

  %image folder
  IMG_DIR=[DIR '/' RPAS_Constants.QUAL_IMAGE_DIR '/Detector_Contamination'];
  RPAS_Make_folder(IMG_DIR);

  if (~isempty(data.SWD_data))
      images=data.SWD_images;
      fnm=[IMG_DIR '/SWD_CONTAMINATION_TEST_POS_1.png'];
      imwrite(images.Pos1, fnm);
      fnm=[IMG_DIR '/SWD_CONTAMINATION_TEST_POS_2.png'];
      imwrite(images.Pos2, fnm);
      fnm=[IMG_DIR '/SWD_CONTAMINATION_TEST_POS_3.png'];
      imwrite(images.Pos3, fnm);
      fnm=[IMG_DIR '/SWD_CONTAMINATION_TEST_POS_4.png'];
      imwrite(images.Pos4, fnm);
  end

  if (~isempty(data.LWD_data))
      images=data.LWD_images;
      fnm=[IMG_DIR '/LWD_CONTAMINATION_TEST_POS_1.png'];
      imwrite(images.Pos1, fnm);
      fnm=[IMG_DIR '/LWD_CONTAMINATION_TEST_POS_2.png'];
      imwrite(images.Pos2, fnm);
      fnm=[IMG_DIR '/LWD_CONTAMINATION_TEST_POS_3.png'];
      imwrite(images.Pos3, fnm);
      fnm=[IMG_DIR '/LWD_CONTAMINATION_TEST_POS_4.png'];
      imwrite(images.Pos4, fnm);
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
  ran.value = '          Positions';

  range='B3';
  ran = h.Activesheet.get('Range',range);
  ran.value = 'X';

  range='C3';
  ran = h.Activesheet.get('Range',range);
  ran.value = 'Y';

  range='A4:A7';
  ran = h.Activesheet.get('Range',range);
  ran.value = {'Pos 1';'Pos 2'; 'Pos 3'; 'Pos 4'};

  range='F1';
  ran = h.Activesheet.get('Range',range);
  ran.value = 'Znom';

  range='E3:E4';
  ran = h.Activesheet.get('Range',range);
  ran.value = {'SWD'; 'LWD'};

  range='H1';
  ran = h.Activesheet.get('Range',range);
  ran.value = 'Max Single Spot Size (um^2)';

  range='K1';
  ran = h.Activesheet.get('Range',range);
  ran.value = '      Max Allowable Defect No.';

  range='O1';
  ran = h.Activesheet.get('Range',range);
  ran.value = '  No. Defects Found';

  range='O3:O4';
  ran = h.Activesheet.get('Range',range);
  ran.value = {'SWD';'LWD'};

  if isempty(data.SWD_data)
      R=data.LWD_data.positions;
  else
      R=data.SWD_data.positions;
  end

  range='B4:C7';
  ran = h.Activesheet.get('Range',range);
  ran.value = R(:,1:2);

  if ~isempty(data.SWD_data)
      range='F3';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.SWD_data.positions(1,3);
  end
  if ~isempty(data.LWD_data)
      range='F4';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.LWD_data.positions(1,3);
  end

  if isempty(data.SWD_data)
      range='I3';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.LWD_data.MaxSingleSize;

      range='L3';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.LWD_data.MaxDefectNum;
  else
      range='I3';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.SWD_data.MaxSingleSize;

      range='L3';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.SWD_data.MaxDefectNum;
  end

  range='O1:P4';
  ran = h.Activesheet.get('Range',range);
  ran.interior.Color=hex2dec('00FF00'); %

  if ~isempty(data.SWD_result)
      range='P3';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.SWD_result;
        
      if data.SWD_result>data.SWD_data.MaxDefectNum;
          ran.interior.Color=hex2dec('0000FF'); %
      end
  end

  if ~isempty(data.LWD_result)
      range='P4';
      ran = h.Activesheet.get('Range',range);
      ran.value = data.LWD_result;
        
      if data.LWD_result>data.LWD_data.MaxDefectNum;
          ran.interior.Color=hex2dec('0000FF'); %
      end
  end


  % save the file with the given file name, close Excel
  wb.SaveAs(fout); 
  wb.Close;
  h.Quit;
  h.delete;
end















  
