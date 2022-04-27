function saveTwinScanResults(operatorInfo, ALLOWED_ERROR, QUAL, TWNSCN)
  matchPos={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T','U','V','W', 'X', 'Y','Z'};

  fieldColor=readFieldColor();

  HOME=RPAS_Constants().RPAS_HOME;
  DIR=[HOME '/' RPAS_Constants.QUAL_RESULT_DIR '/Twinscan/' operatorInfo.ID];
  RPAS_Make_folder(DIR);

  dt=datetime();
  datetimestring=datestr(dt, 'mmm_dd_yyyy_HH_MM_SS');
  fout=[DIR '/RPAS_TWINSCAN_Report_' datetimestring '.xlsx'];

  %image folder
  IMG_DIR=[DIR '/' RPAS_Constants.QUAL_IMAGE_DIR ];
  RPAS_Make_folder(IMG_DIR);
  if (~isempty(QUAL.SWDvalue))
      images=QUAL.SWD_images;
      names=fieldnames(images);
      for k=1:numel(names)
          img=getfield(images,names{k});
          fnm=[IMG_DIR '/SWD_QUALIFICATION_' names{k} '.png'];
          imwrite(img, fnm);
      end
  end
  if (~isempty(QUAL.LWDvalue))
      images=QUAL.LWD_images;
      names=fieldnames(images);
      for k=1:numel(names)
          img=getfield(images,names{k});
          fnm=[IMG_DIR '/LWD_QUALIFICATION_' names{k} '.png'];
          imwrite(img, fnm);
      end
  end

  %Open an ActiveX connection to Excel
  h = actxserver('excel.application');
    
  %Create a new work book (excel file)
  wb=h.WorkBooks.Add();
  
    
  %operatorInfo
  range='A1:B3';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'DATE', datestr(dt, 'mmm-dd-yyyy HH:MM:SS'); ...
                'RPAS ID', operatorInfo.ID; ...
                'Operator', operatorInfo.operator};

  range='A1:B1';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.DATE_COLOR;

  range='A2:B2';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.RPAS_SN_COLOR;

  range='A3:B3';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.OPERATOR_COLOR;

  for k=1:2
    range=[matchPos{k} '1:' matchPos{k} '2'];
    ran = h.Activesheet.get('Range',range); 
    val=ran.value;
    width=4;
    for l=1:length(val)
      width=max(width, length(val{l}));
    end
    ran.ColumnWidth=width;
  end


  
  %data ALOWED ERROR header
  %Select the appropriate range
  range='A6:B7';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'Test Point', 'Allowed error';
               '', 'X/Y(um), Rz(mrad)'};

  %data: ALLOWED ERROR
  N=8;
  M=3;
  n=size(ALLOWED_ERROR,1);

  range=['A8:B' num2str(N+n-1)];
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  val=cell(n,1);
  for k=1:n
      val{k,1}=num2str(k);
      val{k,2}=[num2str(ALLOWED_ERROR(k,2)) ',  ' num2str(ALLOWED_ERROR(k,3) )];
  end
  ran.value = val;

  if ~isempty(QUAL.SWDvalue)
      %data RPAS QUAL header
      %Select the appropriate range
      range=[matchPos{M} '4:' matchPos{M+5} '7'];
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = {'', '', 'SWD', '', '', '';
                    'RPAS QUAL', '', '', 'TWINSCAN', '', 'PASS/FAIL?';
                   'Measure Value', 'Measured Error', '', 'Measure Value', 'Measured Error', '';
                   'X(um), Y(um), Rz(mrad)', 'X(um), Y(um), Rz(mrad)','','X(um), Y(um), Rz(mrad)', 'X(um), Y(um), Rz(mrad)', '' };
      
      ran.interior.Color=fieldColor.SWD_HEADER_COLOR;

      %data: RPAS QUAL
      val=cell(n,5);
      for k=1:n
          val{k,1}=[num2str(QUAL.SWDvalue(k,1)) ',  ' num2str(QUAL.SWDvalue(k,2)) ',  ' num2str(QUAL.SWDvalue(k,3) )];
          val{k,2}=[num2str(QUAL.SWDerror(k,1)) ',  ' num2str(QUAL.SWDerror(k,2)) ',  ' num2str(QUAL.SWDerror(k,3) )];
          val{k,4}=[num2str(TWNSCN.SWDvalue(k,1)) ',  ' num2str(TWNSCN.SWDvalue(k,2)) ',  ' num2str(TWNSCN.SWDvalue(k,3) )];
          val{k,5}=[num2str(TWNSCN.SWDerror(k,1)) ',  ' num2str(TWNSCN.SWDerror(k,2)) ',  ' num2str(TWNSCN.SWDerror(k,3) )];
          if any(abs(QUAL.SWDerror(k,:))-ALLOWED_ERROR(k,:))>0 || any(abs(TWIN.SWDerror(k,:))-ALLOWED_ERROR(k,:))>0
              range=[matchPos{M+5} num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.value='FAIL';
              ran.Font.Color=fieldColor.FAIL_COLOR;;
          else
              range=[matchPos{M+5} num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.value='PASS';
              ran.Font.Color=fieldColor.PASS_COLOR;;
          end
      end
      range=[matchPos{M} '8:' matchPos{M+4} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = val;

      range=[matchPos{M} '8:' matchPos{M} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;
      range=[matchPos{M+1} '8:' matchPos{M+1} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

      M=M+3;
      range=[matchPos{M} '8:' matchPos{M} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;
      range=[matchPos{M+1} '8:' matchPos{M+1} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range);
      ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

      M=M+3;
  end

  if ~isempty(QUAL.LWDvalue)
      %data RPAS QUAL header
      %Select the appropriate range
      range=[matchPos{M} '4:' matchPos{M+5} '7'];
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = {'', '', 'LWD', '', '', '';
                    'RPAS QUAL', '', '', 'TWINSCAN', '', 'PASS/FAIL?';
                   'Measure Value', 'Measured Error', '', 'Measure Value', 'Measured Error', '';
                   'X(um), Y(um), Rz(mrad)', 'X(um), Y(um), Rz(mrad)','','X(um), Y(um), Rz(mrad)', 'X(um), Y(um), Rz(mrad)', '' };
      ran.interior.Color=fieldColor.LWD_HEADER_COLOR;

      %data: RPAS QUAL
      val=cell(n,5);
      for k=1:n
          val{k,1}=[num2str(QUAL.LWDvalue(k,1)) ',  ' num2str(QUAL.LWDvalue(k,2)) ',  ' num2str(QUAL.LWDvalue(k,3) )];
          val{k,2}=[num2str(QUAL.LWDerror(k,1)) ',  ' num2str(QUAL.LWDerror(k,2)) ',  ' num2str(QUAL.LWDerror(k,3) )];
          val{k,4}=[num2str(TWNSCN.LWDvalue(k,1)) ',  ' num2str(TWNSCN.LWDvalue(k,2)) ',  ' num2str(TWNSCN.LWDvalue(k,3) )];
          val{k,5}=[num2str(TWNSCN.LWDerror(k,1)) ',  ' num2str(TWNSCN.LWDerror(k,2)) ',  ' num2str(TWNSCN.LWDerror(k,3) )];
          if any(abs(QUAL.LWDerror(k,:))-ALLOWED_ERROR(k,:))>0 || any(abs(TWIN.LWDerror(k,:))-ALLOWED_ERROR(k,:))>0
              range=[matchPos{M+5} num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.value='FAIL';
              ran.Font.Color=fieldColor.FAIL_COLOR;
          else
              range=[matchPos{M+5} num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.value='PASS';
              ran.Font.Color=fieldColor.PASS_COLOR;
          end
      end
      range=[matchPos{M} '8:' matchPos{M+4} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      %write the data to the range
      ran.value = val;

      range=[matchPos{M} '8:' matchPos{M} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;
      range=[matchPos{M+1} '8:' matchPos{M+1} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

      M=M+3;
      range=[matchPos{M} '8:' matchPos{M} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;
      range=[matchPos{M+1} '8:' matchPos{M+1} num2str(N+n-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

      M=M+3;
  end


  for k=2:M-1
    range=[matchPos{k} '4:' matchPos{k} num2str(N+n-1)];
    ran = h.Activesheet.get('Range',range); 
    val=ran.value;
    if ismember(k, [3, 4, 6, 7, 9, 10, 12, 13])
        width=4;
        for l=1:length(val)
            width=max(width, length(val{l})-3);
        end
    else
        width=4;
        for l=1:length(val)
            width=max(width, length(val{l}));
        end
    end
    ran.ColumnWidth=width;
  end

  % save the file with the given file name, close Excel
  wb.SaveAs(fout); 
  wb.Close;
  h.Quit;
  h.delete;
end

  



