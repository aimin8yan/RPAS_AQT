classdef savedVariables < handle
    properties (Access=public)
        
        %Variables for MotionSetup
        motionSetupVar;
        motionSysValSetupVar;
        engineeringPar1Var;
        engineeringPar2Var;
        engineeringPar3Var;
        toolCalibrationVar;
    end
    
    properties (Access=private)
        path;
        fileName='PositionRecords.xlsx';
        appNames={'MotionSetup', 'motionSysValSetup', 'engPar1',...
            'engPar2','engPar3','toolCalibration'};
        
        motionSetupSheet='motionSetupVariables';
        motionSysValSetupSheet='motionSysValSetupVariables';
        engineeringParSheet1='engineeringParameterVariables1';
        engineeringParSheet2='engineeringParameterVariables2';
        engineeringParSheet3='engineeringParameterVariables3';
        toolCalSheet='toolCalibrationVariables';
    end
        
    
    methods (Access=public)
        function obj=savedVariables(obj)
            obj.path=[RPAS_Constants().RPAS_HOME '/' RPAS_Constants.QUAL_DATA_SHEET_DIR];
            fnm=[obj.path  '\' obj.fileName];
            if isfile(fnm)
              names=sheetnames(fnm);
              for k=1:numel(names)
                t=readtable(fnm, 'VariableNamingRule', 'preserve',...
                    'ReadVariableNames', true, ...
                    'Sheet', k);
                switch names{k}
                  case obj.motionSetupSheet
                    obj.motionSetupVar=obj.tableToStruct(t);
                  case obj.motionSysValSetupSheet
                    obj.motionSysValSetupVar=obj.tableToStruct(t);
                  case obj.engineeringParSheet1
                    obj.engineeringPar1Var=obj.tableToStruct(t);
                  case obj.engineeringParSheet2
                    obj.engineeringPar2Var=obj.tableToStruct(t);
                  case obj.engineeringParSheet3
                    obj.engineeringPar3Var=obj.tableToStruct(t);
                  case obj.toolCalSheet
                    obj.toolCalibrationVar=obj.tableToStruct(t);
                  case obj.autoQualTableSheet
                    obj.autoQualTableVar=obj.tableToStruct(t);
                  otherwise
                    error('Unsupported sheet');
                end
              end
            end
             
            if isempty(obj.motionSetupVar)
                %Motion Setup Variables
                obj.motionSetupVar=struct(...
                    'Xlimit_Plus', 0, 'Xlimit_Minus', 0, ...
                    'Ylimit_Plus', 0, 'Ylimit_Minus', 0, ...
                    'Zlimit_Plus', 0, 'Zlimit_Minus', 0, ...
                    'Xhome', 0, 'Yhome', 0, 'Zhome', 0, ...
                    'XPark', 0, 'YPark', 0, 'ZPark', 0);
            end
            
            if isempty(obj.motionSysValSetupVar)
                %Motion System Validation Setup Variables
                obj.motionSysValSetupVar=struct(...
                    'XlowerLimit', 0, 'XupperLimit', 0, ...
                    'YlowerLimit', 0, 'YupperLimit', 0, ...
                    'ZlowerLimit', 0, 'ZupperLimit', 0, ...
                    'checkingPosition_X', 0, ...
                    'checkingPosition_Y', 0, ...
                    'checkingPosition_Z', 0, ...
                    'approachPosition_X', 0, ...
                    'approachPosition_Y', 0, ...
                    'approachPosition_Z', 0);
            end
            
            if isempty(obj.engineeringPar1Var)
                obj.engineeringPar1Var=struct(...
                    'ManualMotionSpeed', 1, ...
                    'AutoQualScanSpeed', 2, ...
                    'ZOffset', 0, ...
                    'SWDNominalZ', 60.94, ...
                    'LWDNominalZ', 103.14, ...
                    'ZRange', 1.7, ...
                    'ImageConversFactor', 1.0e3/RPAS_Constants.Pixel_img_plane, ...
                    'MinTimeBetweenImageCaptures', 0, ...
                    'AllowableXYError', 0, ...
                    'AllowableRzError', 0, ...
                    'NominalImageCapturePositions_X', 0, ...
                    'NominalImageCapturePositions_Y', 0, ...
                    'NominalRPASImageMagnification', 4.29, ...
                    'MagErrorLimit', 0, ...
                    'MinAllowableMTFCenterAmp_X', 0, ...
                    'MinAllowableMTFCenterAmp_Y', 0, ...
                    'MaxAllowableMTFHWHM_X', 0, ...
                    'MaxAllowableMTFHWHM_Y', 0);
            end
            
            if isempty(obj.engineeringPar2Var)
                obj.engineeringPar2Var=struct(...
                    'X_pos_1', 0, ...
                    'X_pos_2', 0, ...
                    'X_pos_3', 0, ...
                    'X_pos_4', 0, ...
                    'Y_pos_1', 0, ...
                    'Y_pos_2', 0, ...
                    'Y_pos_3', 0, ...
                    'Y_pos_4', 0, ...
                    'MaxAllowableDefectArea', 0, ...
                    'MaxAllowableDefectNo', 0, ...
                    'MaxReportedDefectArea', 0);
            end
            
            if isempty(obj.engineeringPar3Var)
                    arch=computer('arch');
                    spliter='/';
                    if strcmp(arch,'win32') | strcmp(arch,'win64')
                        spliter='\';
                    end
                    HOME=[RPAS_Constants().RPAS_HOME spliter RPAS_Constants.QUAL_DATA_SHEET_DIR];
                obj.engineeringPar3Var=struct(...
                    'pos_1', [HOME spliter 'Test_1.xlsx'], ...
                    'pos_2', [HOME spliter 'Test_2.xlsx'], ...
                    'pos_3', [HOME spliter 'Test_3.xlsx'], ...
                    'pos_4', [HOME spliter 'Test_4.xlsx'], ...
                    'pos_5', [HOME spliter 'Test_5.xlsx'], ...
                    'pos_6', [HOME spliter 'Test_6.xlsx'], ...
                    'twinscanFnm', [HOME spliter 'Test_7.xlsx']);
            end
            
            if isempty(obj.toolCalibrationVar)
                obj.toolCalibrationVar=struct(...
                    'ZOffset', 0, ...
                    'SWD_Xc', 0, ...
                    'SWD_Yc', 0, ...
                    'LWD_Xc', 0, ...
                    'LWD_Yc', 0);
            end
        end

        function sheets=autoQualTableVar(obj)
              var1 = obj.engineeringPar1Var;
              var2 = obj.engineeringPar2Var;
              var3 = obj.engineeringPar3Var;   
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Magnification
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              magVar={};
              v=struct('qualName', 'Magnification', ...
                       'position',  [var1.NominalImageCapturePositions_X, ...
                            var1.NominalImageCapturePositions_Y, var1.SWDNominalZ], ...
                       'MagTarget', var1.NominalRPASImageMagnification, ...
                       'MagErr', var1.MagErrorLimit, ...
                       'CenterAmpErr_X', var1.MinAllowableMTFCenterAmp_X, ...
                       'HWHMErr_X', var1.MaxAllowableMTFHWHM_X, ...
                       'CenterAmpErr_Y', var1.MinAllowableMTFCenterAmp_Y, ...
                       'HWHMErr_Y', var1.MaxAllowableMTFHWHM_Y, ...
                       'enabled', 0, 'camera', 'SWD', 'saved', 0);
              
              %SWD
              magVar{end+1}=v;
              
              %LWD
              v.camera='LWD';
              v.position(3)=var1.LWDNominalZ;
              magVar{end+1}=v;
             
             
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Contamination
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              contamVar={};
              v=struct('qualName', 'Magnification', ...
                       'positions',  ...
                          [var2.X_pos_1, var2.Y_pos_1, var1.SWDNominalZ ; ...
                           var2.X_pos_2, var2.Y_pos_2, var1.SWDNominalZ; ...
                           var2.X_pos_3, var2.Y_pos_3, var1.SWDNominalZ; ...
                           var2.X_pos_4, var2.Y_pos_4, var1.SWDNominalZ], ...
                           'MaxDefectNum',  var2.MaxAllowableDefectNo, ...
                           'MaxSingleSize', var2.MaxAllowableDefectArea, ...
                           'enabled', 0, 'camera', 'SWD', 'saved', 0);
                 
              %SWD
              contamVar{end+1}=v;
               
              %LWD
              v.camera='LWD';
              v.positions(:,3)=var1.LWDNominalZ;
              contamVar{end+1} = v;
              
              magStruct=struct('SWD', magVar{1}, 'LWD', magVar{2});
              contamStruct=struct('SWD', contamVar{1}, 'LWD', contamVar{2});
              qualVar=struct('pos1', var3.pos_1, ...
                  'pos2', var3.pos_2, ...
                  'pos3', var3.pos_3, ...
                  'pos4', var3.pos_4, ...
                  'pos5', var3.pos_5, ...
                  'pos6', var3.pos_6);

              sheets=struct('magSheet', magStruct, ...
                            'contamSheet', contamStruct, ...
                            'qualSheets', qualVar);
        end
        
        function updateRecords(obj, var, appName)
            switch lower(appName)
                case {lower(obj.appNames{1})} % MotionSetup
                    obj.motionSetupVar=var;
                case {lower(obj.appNames{2})} % MotionValidation
                    obj.motionSysValSetupVar=var;
                case {lower(obj.appNames{3})} % EngineeringParameter1
                    obj.engineeringPar1Var=var;
                case {lower(obj.appNames{4})} % EngineeringParameter2
                    obj.engineeringPar2Var=var;
                case {lower(obj.appNames{5})} % EngineeringParameter3
                    obj.engineeringPar3Var=var;
                case {lower(obj.appNames{6})} % ToolCalibration
                    obj.toolCalibrationVar=var;
                otherwise
                    error('Unsupported Sheet.');
            end
            obj.saveRecords(lower(appName));
        end
    end
    
    methods(Access=private)
        function strt=tableToStruct(app, t)
            names=t.Properties.VariableNames;
            strt=struct();
            for k=1:numel(names)
                a=t.(names{k});
                if iscell(a)
                    strt=setfield(strt, names{k}, a{1});
                else
                    strt=setfield(strt, names{k}, a);
                end
            end
            return;
        end
        
        function saveRecords(obj, appName)
            switch appName
                case {lower(obj.appNames{1})} % MotionSetup
                    var=obj.motionSetupVar;
                    sheet=obj.motionSetupSheet;
                case {lower(obj.appNames{2})} % MotionValidation
                    var=obj.motionSysValSetupVar;
                    sheet=obj.motionSysValSetupSheet;
                case {lower(obj.appNames{3})} % EngineeringParameter1
                    var=obj.engineeringPar1Var;
                    sheet=obj.engineeringParSheet1;
                case {lower(obj.appNames{4})} % EngineeringParameter1
                    var=obj.engineeringPar2Var;
                    sheet=obj.engineeringParSheet2;
                case {lower(obj.appNames{5})} % EngineeringParameter1
                    var=obj.engineeringPar3Var;
                    sheet=obj.engineeringParSheet3;
                case {lower(obj.appNames{6})} % EngineeringParameter1
                    var=obj.toolCalibrationVar;
                    sheet=obj.toolCalSheet;
            end
            fields=fieldnames(var);
            varTypes={};
            for k=1:numel(fields)
              varTypes{end+1}='single';
            end
            t=table('Size',[1, numel(fields)], 'VariableTypes', varTypes, 'VariableNames', fields);
            for k=1:numel(fields)
                t.(fields{k})=getfield(var, fields{k});
            end
            fnm=[obj.path '/' obj.fileName];
            writetable(t, fnm, 'WriteVariableNames', true, ...
                'WriteMode', 'OverwriteSheet', ...
                'Sheet', sheet);
        end
    end
end
    
