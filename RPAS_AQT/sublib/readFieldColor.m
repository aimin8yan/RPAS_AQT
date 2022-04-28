  function val=readFieldColor()
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
      fdir=RPAS_C.QUAL_DATA_SHEET_DIR;
      fnm=[fdir '/Report_Color_Sheet.xlsx' ];
      A=readcell(fnm);
      val=struct('RPAS_NC_COLOR', [], ...
                  'RPAS_SN_COLOR', [], ...
                  'DATE_COLOR', [], ...
                  'OPERATOR_COLOR', [], ...
                  'SWD_HEADER_COLOR', [], ...
                  'LWD_HEADER_COLOR', [], ...
                  'MEASURED_VALUE_COLOR', [], ...
                  'MEASURED_ERROR_COLOR', [], ...
                  'PASS_COLOR', [], ...
                  'FAIL_COLOR', []);
                  
     fields={'date', 'rpas 12 nc', 'rpas s/n', 'operator', 'swd header', ...
         'lwd header', 'measured value field', 'measured error field', 'pass font color', 'fail font color'};
     expr='[0123456789ABCDEF]';
     for k=1:size(A,1)
         index=find(strcmpi(A{k,1}, fields));
         if ~isempty(index)
             R=A{k,3};
             if (ischar(R) && length(R)~=2 && numel(regexpi(R, expr))~=2) ...
                     && (isnumeric(R) && (abs(R-round(R))>1.0e-6 || ...
                         R<0 || R>255))
                 msg=sprintf('Unsupported for R field value in row %d', k);
                 errorMsg(msg);
                 return;
             elseif isnumeric(R)
                 R=dec2hex(R,2);
             end

             G=A{k,4};
             if (ischar(G) && length(G)~=2 && numel(regexpi(G, expr))~=2) ...
                     && (isnumeric(G) && (abs(G-round(G))>1.0e-6 || ...
                         G<0 || G>255))
                 msg=sprintf('Unsupported for G field value in row %d', k);
                 errorMsg(msg);
                 return;
             elseif isnumeric(G)
                 G=dec2hex(G,2);
             end

             B=A{k,5};
             if (ischar(B) && length(B)~=2 && numel(regexpi(B, expr))~=2) ...
                     && (isnumeric(B) && (abs(B-round(B))>1.0e-6 || ...
                         B<0 || B>255))
                 msg=sprintf('Unsupported for B field value in row %d', k);
                 errorMsg(msg);
                 return;
             elseif isnumeric(B)
                 B=dec2hex(B,2);
             end

             color=hex2dec([B G R]);
             switch index
                 case 1
                     val.DATE_COLOR=color;
                 case 2
                     val.RPAS_NC_COLOR=color;
                 case 3
                     val.RPAS_SN_COLOR=color;
                 case 4
                     val.OPERATOR_COLOR=color;
                 case 5
                     val.SWD_HEADER_COLOR=color;
                 case 6
                     val.LWD_HEADER_COLOR=color;
                 case 7
                     val.MEASURED_VALUE_COLOR=color;
                 case 8
                     val.MEASURED_ERROR_COLOR=color;
                 case 9
                     val.PASS_COLOR=color;
                 case 10
                     val.FAIL_COLOR=color;
             end
         end
     end
     
  end
   
  function errMsg(msg)
      sz=get(0,'ScreenSize');
      ct=[sz(3)/2, sz(4)/2];
      w=300; h=160;
      fig=uifigure('position',[ct(1)-w/2, ct(2)-h/2, w, h]);
      title='Error';
      selection=uiconfirm(fig,msg,title, ...
                'Options',{'OK'}, ...
                'icon', 'error');
      switch selection
          case {'OK'}
          otherwise
      end
      delete(fig);
  end
