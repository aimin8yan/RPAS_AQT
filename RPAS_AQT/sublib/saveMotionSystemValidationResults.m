function saveMotionSystemValidationResults(data)
    global systemVar;
    if isempty(systemVar)
        systemVar=savedVariables();
    end
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
    matchPos={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T','U','V','W', 'X', 'Y','Z'};
    fieldColor=readFieldColor();
    passColor=hex2dec('FFFFFF');
    failColor=fieldColor.FAIL_COLOR;

    DIR=[RPAS_C.QUAL_RESULT_DIR '/MotionSystemValidation'];
    RPAS_Make_folder(DIR);

    fout=[DIR '/SPC_controlLog.xlsx'];
    if ~exist(fout)
        copyfile([RPAS_C.QUAL_DATA_SHEET_DIR '/sampleSPC_controlLog.xlsx'], fout);
    end

    mat=readmatrix(fout);

    %Open an ActiveX connection to Excel
    h = actxserver('excel.application');
    exlWkbk = h.Workbooks;
    exlFile = exlWkbk.Open(fout);
    exlSheet1 = exlFile.Sheets.Item('Sheet1');

    nrow=size(mat,1)+1;
    ncol=size(mat,2);
    data_range=['A1:' matchPos{ncol} num2str(nrow)];
    rngObj = exlSheet1.Range(data_range);
    exlData = rngObj.Value;

    str=datestr(datetime(), 'mmm dd, yyyy HH:MM:SS');
    datestring=str(1:12);
    timestring=str(14:end);

    var=systemVar.motionSysValSetupVar;

    val=exlData(4:5, 3:5);
    limitChanged=false;
    if val{1,1}~=var.XupperLimit
        val{1,1}=var.XupperLimit;
        limitChanged=true;
    end
    if val{2,1}~=var.XlowerLimit
        val{2,1}=var.XlowerLimit;
        limitChanged=true;
    end
    if val{1,2}~=var.YupperLimit
        val{1,2}=var.YupperLimit;
        limitChanged=true;
    end
    if val{2,2}~=var.YlowerLimit
        val{2,2}=var.YlowerLimit;
        limitChanged=true;
    end
    if val{1,3}~=var.ZupperLimit
        val{1,3}=var.ZupperLimit;
        limitChanged=true;
    end
    if val{2,3}~=var.ZlowerLimit
        val{2,3}=var.ZlowerLimit;
        limitChanged=true;
    end

    if limitChanged
        range='C4:E5';
        rngObj = exlSheet1.Range(range);
        rngObj.Value=val;
        if nrow>=10
            for k=10:nrow
                fail=false;
                range=['C' num2str(k)];
                rngObj = exlSheet1.Range(range);
                if rngObj.Value<var.XlowerLimit | rngObj.Value>var.XupperLimit
                    rngObj.interior.Color=failColor;
                    fail=true;
                else
                    rngObj.interior.Color=passColor;
                end

                range=['D' num2str(k)];
                rngObj = exlSheet1.Range(range);
                if rngObj.Value<var.YlowerLimit | rngObj.Value>var.YupperLimit
                    rngObj.interior.Color=failColor;
                    fail=true;
                else
                    rngObj.interior.Color=passColor;
                end

                range=['E' num2str(k)];
                rngObj = exlSheet1.Range(range);
                if rngObj.Value<var.ZlowerLimit | rngObj.Value>var.ZupperLimit
                    rngObj.interior.Color=failColor;
                    fail=true;
                else
                    rngObj.interior.Color=passColor;
                end

                range=[matchPos{ncol} num2str(k)];
                rngObj = exlSheet1.Range(range);
                if fail
                    rngObj.font.Color=fieldColor.FAIL_COLOR;
                else
                    rngObj.font.Color=fieldColor.PASS_COLOR;
                end
            end
        end
    end

    range=['A' num2str(nrow+1) ':B' num2str(nrow+1)];
    val={datestring, timestring};
    rngObj = exlSheet1.Range(range);
    rngObj.Value=val;

    fail=false;
    range=['C' num2str(nrow+1)];
    rngObj = exlSheet1.Range(range);
    rngObj.Value=data(1);
    if rngObj.Value<var.XlowerLimit | rngObj.Value>var.XupperLimit
        rngObj.interior.Color=failColor;
        fail=true;
    else
        rngObj.interior.Color=passColor;
    end

    range=['D' num2str(nrow+1)];
    rngObj = exlSheet1.Range(range);
    rngObj.Value=data(2);
    if rngObj.Value<var.YlowerLimit | rngObj.Value>var.YupperLimit
        rngObj.interior.Color=failColor;
        fail=true;
    else
        rngObj.interior.Color=passColor;
    end

    range=['E' num2str(nrow+1)];
    rngObj = exlSheet1.Range(range);
    rngObj.Value=data(3);
    if rngObj.Value<var.ZlowerLimit | rngObj.Value>var.ZupperLimit
        rngObj.interior.Color=failColor;
        fail=true;
    else
        rngObj.interior.Color=passColor;
    end
    
    range=[matchPos{ncol} num2str(nrow+1)];
    rngObj = exlSheet1.Range(range);
    if fail
        rngObj.Value='Fail';
        rngObj.font.Color=fieldColor.FAIL_COLOR;
    else
        rngObj.Value='Pass';
        rngObj.font.Color=fieldColor.PASS_COLOR;
    end

    
    exlWkbk.Close;
    return;
end



