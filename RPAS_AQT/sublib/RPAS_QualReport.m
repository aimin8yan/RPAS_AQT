
function saveQualResults(operatorInfo, data)
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
  fitting=false;
  matchPos={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T','U','V','W', 'X', 'Y','Z'};
  fieldColor=readFieldColor();
  
  DIR=[RPAS_C.QUAL_RESULT_DIR '/AutoQual/' operatorInfo.SN];
  RPAS_Make_folder(DIR);
  
  fout=[DIR '/RPAS_Qual_Report.xlsx'];

  if exist(fout)
      delete(fout);
  end
  
  
  %Open an ActiveX connection to Excel
  h = actxserver('excel.application');
    
  %Create a new work book (excel file)
  wb=h.WorkBooks.Add();
  
    
  %operatorInfo
  range='A1:B4';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'DATE', datestr(datetime(), 'mmm-dd-yyyy HH:MM:SS'); ...
                'RPAS 12NC', operatorInfo.NC; ...
                'RPAS S/N', operatorInfo.SN; ...
                'Operator', operatorInfo.operator};
  
  range='A1:B1';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.DATE_COLOR;
  range='A2:B2';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.RPAS_NC_COLOR;
  range='A3:B3';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.RPAS_SN_COLOR;
  range='A4:B4';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.OPERATOR_COLOR;
  
  for k=1:2
    range=[matchPos{k} '1:' matchPos{k} '4'];
    ran = h.Activesheet.get('Range',range); 
    val=ran.value;
    width=4;
    for l=1:length(val)
      width=max(width, length(val{l}));
    end
    ran.ColumnWidth=width;
  end

  
  %data header
  %Select the appropriate range
  range='A7:D8';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'Test Number', 'Test Point', 'Execute ?', 'Allowed error';
              '', '', '', 'X/Y(um), Rz(mrad)'};
  
  
  %SWD
  range='G6';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'SWD'};
  range='F7:H8';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'Measured Value', 'Measured Error', 'Pass/Fail?';
              'X(um), Y(um), Rz(mrad)', 'X(um), Y(um), Rz(mrad)', ''};

  range='F6:H8';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.SWD_HEADER_COLOR;
              
  %LWD
  range='K6';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'LWD'};
  range='J7:L8';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = {'Measured Value', 'Measured Error', 'Pass/Fail?';
              'X(um), Y(um), Rz(mrad)', 'X(um), Y(um), Rz(mrad)', ''};

  range='J6:L8';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.LWD_HEADER_COLOR;
   
  N=9;
  for i=1:numel(data)
    obj=data{i};
    if ~isempty(obj)
      %Test number
      range=['A' num2str(N)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = {['Test ' num2str(obj.Pos)]};
      
      %Test Point
      val=cell(obj.numTestPoints,1);
      for k=1:obj.numTestPoints
          val{k} = num2str(obj.TestPoint(k));
      end
      range=['B' num2str(N) ':B' num2str(N+obj.numTestPoints-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = val;
      
      %Execute?
      val=cell(obj.numTestPoints,1);
      for k=1:obj.numTestPoints
          val{k} = num2str(obj.BI(k));
      end
      range=['C' num2str(N) ':C' num2str(N+obj.numTestPoints-1)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = val;
      
      %Allowed Error
      range=['D' num2str(N) ':D' num2str(N+obj.numTestPoints-1)];
      ran = h.Activesheet.get('Range',range); 
      val=cell(obj.numTestPoints,1);
      for k=1:obj.numTestPoints
        val{k} = [num2str(round(obj.Error(k,2),2)) ',  ' num2str(round(obj.Error(k,3)))];
      end
      ran.value = val;
      
      
      %SWD
      if ~isempty(obj.SWD_result)
        %value, error, pass/fail
        val=cell(obj.numTestPoints,3);
        result=obj.SWD_result;
        for k=1:obj.numTestPoints
          if any(isnan(result(k,:)))
            val{k, 1}='';
            val{k, 2}='';
            val{k, 3}='';
          else
            val{k, 1} = [num2str(round(result(k,1),2)) ',  '...
                          num2str(round(result(k,2),2)) ',  '...
                          num2str(round(result(k,3),2))];
            val{k, 2} = [num2str(round(result(k,4),2)) ',  '...
                          num2str(round(result(k,5),2)) ',  '...
                          num2str(round(result(k,6),2))];
            if any(result(k,4:6)-obj.Error(k,:))>0
              val{k,3}='Fail';
              range=['H' num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.font.Color=fieldColor.FAIL_COLOR;
            else
              val{k,3}='Pass';
              range=['H' num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.font.Color=fieldColor.PASS_COLOR;
            end    
          end
        end
        range=['F' num2str(N) ':H' num2str(N+obj.numTestPoints-1)];
        ran = h.Activesheet.get('Range',range); 
        ran.value = val;
      end
      
      %LWD
      if ~isempty(obj.LWD_result)
        %value, error, pass/fail
        val=cell(obj.numTestPoints,3);
        result=obj.LWD_result;
        for k=1:obj.numTestPoints
          if any(isnan(result(k,:)))
            val{k, 1}='';
            val{k, 2}='';
            val{k, 3}='';
          else
            val{k, 1} = [num2str(round(result(k,1),2)) ',  '...
                          num2str(round(result(k,2),2)) ',  '...
                          num2str(round(result(k,3),2))];
            val{k, 2} = [num2str(round(result(k,4),2)) ',  '...
                          num2str(round(result(k,5),2)) ',  '...
                          num2str(round(result(k,6),2))];
            if any(result(k,4:6)-obj.Error(k,:))>0
              val{k,3}='Fail';
              range=['L' num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.font.Color=fieldColor.FAIL_COLOR;
            else
              val{k,3}='Pass';
              range=['L' num2str(N+k-1)];
              ran = h.Activesheet.get('Range',range); 
              ran.font.Color=fieldColor.PASS_COLOR;
            end    
          end
        end
        range=['J' num2str(N) ':L' num2str(N+obj.numTestPoints-1)];
        ran = h.Activesheet.get('Range',range); 
        ran.value = val;
      end
      N=N+obj.numTestPoints;
    end
  end

  range=['F9:H' num2str(8+N)];


  for k=1:12
    range=[matchPos{k} '6:' matchPos{k} num2str(N)];
    ran = h.Activesheet.get('Range',range); 
    val=ran.value;
      if ismember(k, [6,7,10,11])
          width=4;
          for l=1:length(val)
              width=max(width, length(val{l})-2);
          end
      else
          width=4;
          for l=1:length(val)
              width=max(width, length(val{l}));
          end
      end
    ran.ColumnWidth=width;
  end
    
  range=['F9:F' num2str(N-1)];
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;

  range=['G9:G' num2str(N-1)];
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

  range=['J9:J' num2str(N-1)];
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;

  range=['K9:K' num2str(N-1)];
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

  % save the file with the given file name, close Excel
  wb.SaveAs(fout); 
  wb.Close;
  h.Quit;
  h.delete;
end
    

