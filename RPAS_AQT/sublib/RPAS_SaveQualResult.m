
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
  
  fout=[DIR '/Test_Result_Test_No=' num2str(data.Pos) '.xlsx'];

  %image folder
  IMG_DIR=[DIR '/TEST_IMAGES/Qualification/TEST_NO=' num2str(data.Pos)];
  RPAS_Make_folder(IMG_DIR);
  
  if (~isempty(data.SWD_result))
      images=data.SWD_images;
      names=fieldnames(images);
      for k=1:numel(names)
          img=getfield(images,names{k});
          fnm=[IMG_DIR '/SWD_QUALIFICATION_' names{k} '.png'];
          imwrite(img, fnm);
      end
  end
  
  if (~isempty(data.LWD_result))
      images=data.LWD_images;
      names=fieldnames(images);
      for k=1:numel(names)
          img=getfield(images,names{k});
          fnm=[IMG_DIR '/LWD_QUALIFICATION_' names{k} '.png'];
          imwrite(img, fnm);
      end
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
  range='A2';
  ran = h.Activesheet.get('Range',range); 
  %write the data to the range
  ran.value = 'Test Point'; 
  
  range='A3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '    (i)   '; 
  
  range='B2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Execute?'; 
  
  range='D2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Stage Coordinates';
  
  range='G2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Expected Reading';
  
  range='I2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Allowed error';
  
  range='C3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X (mm)';
  
  range='D3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Y (mm)';
  
  range='E3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Z (mm)';
  
  range='F3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X (um)';
  
  range='G3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Y (um)';
  
  range='H3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Rz (mrad)';
  
  range='I3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X/Y (um)';
  
  range='J3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Rz (mrad)';
  
  %SWD
  range='L2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '               Measured Value';
  
  range='O2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '                Error (Delta E)';
  
  range='N1';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '                SWD';

  range='L1:Q3';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.LWD_HEADER_COLOR;


  
  range='L3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X (um)';
  
  range='M3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Y (um)';
  
  range='N3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Rz (mrad)';
  
  range='O3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X (um)';
  
  range='P3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Y (um)';
  
  range='Q3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Rz (mrad)';
  
  %LWD
  range='S2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '               Measured Value';
  
  range='V2';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '                Error (Delta E)';
  
  range='U1';
  ran = h.Activesheet.get('Range',range); 
  ran.value = '                LWD';

  range='S1:X3';
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.LWD_HEADER_COLOR;


  
  range='S3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X (um)';
  
  range='T3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Y (um)';
  
  range='U3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Rz (mrad)';
  
  range='V3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'X (um)';
  
  range='W3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Y (um)';
  
  range='X3';
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Rz (mrad)';

  %DATA
  R=[data.TestPoint data.BI data.Stage data.Expected data.Error(:,2:3)];
  N=size(R,1);
  range=['A4:J' num2str(N+3)];
  ran = h.Activesheet.get('Range',range); 
  ran.value = R;

  %SWD Result
  range=['L4:N' num2str(data.numTestPoints+3)];
  ran = h.Activesheet.get('Range',range);
  ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

  range=['O4:Q' num2str(data.numTestPoints+3)];
  ran = h.Activesheet.get('Range',range);
  ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;

  range=['S4:U' num2str(data.numTestPoints+3)];
  ran = h.Activesheet.get('Range',range);
  ran.interior.Color=fieldColor.MEASURED_ERROR_COLOR;

  range=['V4:X' num2str(data.numTestPoints+3)];
  ran = h.Activesheet.get('Range',range);
  ran.interior.Color=fieldColor.MEASURED_VALUE_COLOR;

  ErrColor=fieldColor.FAIL_COLOR;

  bg=1;
  k=1;
  result=data.SWD_result;
  if ~isempty(result)
      while k<=size(result,1)
          while k<=size(result,1)&isnan(result(k,1))
              bg=k+1;
              k=k+1;
          end
    
          while k<=size(result,1)& ~isnan(result(k,1))
              ed=k;
              k=k+1;
          end
          range=['L' num2str(bg+3) ':Q' num2str(ed+3)];
          ran = h.Activesheet.get('Range',range); 
          ran.value = round(result(bg:ed,:),2);
      end

      for k=1:data.numTestPoints
        for l=1:3
          if abs(result(k,l+3))>data.Error(k,l)
            range=[matchPos{14+l} num2str(k+3)];
            ran = h.Activesheet.get('Range',range); 
            ran.interior.Color=ErrColor;
          end
        end
      end
  end
  

  %LWD Result
  bg=1;
  k=1;
  result=data.LWD_result;
  if ~isempty(result)
      while k<=size(result,1)
          while k<=size(result,1)&isnan(result(k,1))
              bg=k+1;
              k=k+1;
          end
    
          while k<=size(result,1)& ~isnan(result(k,1))
              ed=k;
              k=k+1;
          end
          range=['S' num2str(bg+3) ':X' num2str(ed+3)];
          ran = h.Activesheet.get('Range',range); 
          ran.value = round(result(bg:ed,:),2);
      end

      for k=1:data.numTestPoints
        for l=1:3
          if abs(result(k,l+3))>data.Error(k,l)
            range=[matchPos{21+l} num2str(k+3)];
            ran = h.Activesheet.get('Range',range); 
            ran.interior.Color=ErrColor;
          end
        end
      end
  end

  %statistics
  row=numel(data.TestPoint)+5;
  if ~isempty(data.SWD_result)
    mat=~isnan(data.SWD_result);
  else
    mat=~isnan(data.LWD_result);
  end

  N=sum(mat(:,1));
  range=['C' num2str(row)];
  ran = h.Activesheet.get('Range',range); 
  ran.value = N;
  
  range=['D' num2str(row)];
  ran = h.Activesheet.get('Range',range); 
  ran.value = 'Points measured';

  range=['C' num2str(row) ':E'  num2str(row)];
  ran = h.Activesheet.get('Range',range); 
  ran.interior.Color=fieldColor.LWD_HEADER_COLOR;
  
  if ~isempty(data.SWD_result)
      %SWD
      range=['N' num2str(row)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = 'Average';
      range=['N' num2str(row+1)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = 'Std Dev';
  
      v=data.SWD_result(mat);
      v=reshape(v,[numel(v)/6 6]);

      a=v(:,4);
      sta=round(std(a),3);
      a=round(mean(a),3);
      b=v(:,5);stb=round(std(b),3);b=round(mean(b),3);
      c=v(:,6);stc=round(std(c),3);c=round(mean(c),3);
  
      range=['O' num2str(row) ':Q' num2str(row+1)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = [a b c;sta stb stc];
 
      range=['N' num2str(row) ':Q'  num2str(row+1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.LWD_HEADER_COLOR;
  end

  if ~isempty(data.LWD_result)
      %LWD
      range=['U' num2str(row)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = 'Average';
      range=['U' num2str(row+1)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = 'Std Dev';
  
      v=data.LWD_result(mat);
      v=reshape(v,[numel(v)/6 6]);
    
      a=v(:,4);
      sta=round(std(a),3);
      a=round(mean(a),3);
      b=v(:,5);stb=round(std(b),3);b=round(mean(b),3);
      c=v(:,6);stc=round(std(c),3);c=round(mean(c),3);
  
      range=['V' num2str(row) ':X' num2str(row+1)];
      ran = h.Activesheet.get('Range',range); 
      ran.value = [a b c;sta stb stc];
     
      range=['U' num2str(row) ':X'  num2str(row+1)];
      ran = h.Activesheet.get('Range',range); 
      ran.interior.Color=fieldColor.LWD_HEADER_COLOR;
  end


  % save the file with the given file name, close Excel
  wb.SaveAs(fout); 
  wb.Close;
  h.Quit;
  h.delete;
end
    

