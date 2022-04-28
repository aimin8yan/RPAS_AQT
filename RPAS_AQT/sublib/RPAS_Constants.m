classdef RPAS_Constants
    properties (Constant)

        %Camera addresses
        SWD_Address=0;
        LWD_Address=0;
    end

    properties (Access = public)
        %The following contants will be used for Alignment and Mag/Focus
        %algorithms
        Pixel_obj_plane = 0;
        Pixel_img_plane = 0;
        Outer_Frame_Width = 0;
        Outer_Frame_Height = 0;
        Inner_Frame_Width = 0;
        Inner_Frame_Height = 0;

        % The saved images and qualification files will be saved to the
        % following folders. These folders are relative folder to the
        QUAL_RESULT_DIR = '';%'QUAL_TEST_RESULTS';
        QUAL_IMAGE_DIR = '';%'TEST_IMAGES';
        QUAL_DATA_SHEET_DIR = '';%'QualDataSheetFolder';
        SCREEN_IMAGE_DIR = '';

        % The following constants controls the algorithm to use live
        % captured image or test image in the program
        
        ImageJ_algorithm = false;
        CameraAvailable = false;
        A3200Available = false;

        %Project home directory, i.e. the direcory of app RPAS_AQT's
        %home directory. It is determined dymatically.
        RPAS_HOME = [];

        A3200Path;
    end

    methods (Access = public)
        function obj = RPAS_Constants(DIR)
            if ~isdeployed
                arch=computer('arch');
                path = mfilename('fullpath');
                if strcmp(arch, 'win32') || strcmp(arch, 'win64')
                    pattern='\';
                else
                    pattern='/';
                end
                j=strfind(path, pattern);
                if strcmp(path(j(end)+1:end), 'RPAS_AQT')
                    path=path(1:j(end)-1);
                    obj.RPAS_HOME=path;
                else
                    path=path(1:j(end-1)-1);
                    obj.RPAS_HOME = path;
                end
            else
                obj.RPAS_HOME=DIR;
            end

            parameterFile=[obj.RPAS_HOME '/QualDataSheetFolder/parameters.txt'];

            fid=fopen(parameterFile,'rt');
            if fid==-1
                obj.errorMsg('Error open parameterFile.');
                return;
            end

            while ~feof(fid)
                tline=fgetl(fid);
                j=strfind(tline, '%');
                if ~isempty(j)
                    tline=tline(1:j(1)-1);
                end
                if contains(tline, 'QUAL_RESULT_DIR') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.QUAL_RESULT_DIR = s;
                elseif contains(tline, 'QUAL_IMAGE_DIR') && contains(tline,'=') 
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.QUAL_IMAGE_DIR = s;
                elseif contains(tline, 'QUAL_DATA_SHEET_DIR') && contains(tline,'=') 
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.QUAL_DATA_SHEET_DIR = s;
                elseif contains(tline, 'SCREEN_IMAGE_DIR') && contains(tline,'=') 
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.SCREEN_IMAGE_DIR = s;
                elseif contains(tline, 'CameraAvailable') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    if strcmp(s,'false')
                        obj.CameraAvailable=false;
                    elseif strcmp(s,'true')
                        obj.CameraAvailable=true;
                    else
                        obj.errorMsg('Unsupported value for CameraAvailable');
                        fclose(fid);
                        return;
                    end
                elseif contains(tline, 'A3200Available') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    if strcmp(s,'false')
                        obj.A3200Available=false;
                    elseif strcmp(s,'true')
                        obj.A3200Available=true;
                    else
                        obj.errorMsg('Unsupported value for A3200Available');
                        fclose(fid);
                        return;
                    end
                elseif contains(tline, 'ImageJ_algorithm') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    if strcmp(s,'false')
                        obj.ImageJ_algorithm=false;
                    elseif strcmp(s,'true')
                        obj.ImageJ_algorithm=true;
                    else
                        obj.errorMsg('Unsupported value for ImageJ_algorithm');
                        fclose(fid);
                        return;
                    end
                elseif contains(tline, 'Pixel_obj_plane') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.Pixel_obj_plane = str2double(s);
                elseif contains(tline, 'Pixel_img_plane') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.Pixel_img_plane = str2double(s);
                elseif contains(tline, 'Outer_Frame_Width') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.Outer_Frame_Width = str2double(s);
                elseif contains(tline, 'Outer_Frame_Height') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.Outer_Frame_Height = str2double(s);
                elseif contains(tline, 'Inner_Frame_Width') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.Inner_Frame_Width = str2double(s);
                elseif contains(tline, 'Inner_Frame_Height') && contains(tline,'=')
                    idx1=strfind(tline, '=')+1;
                    idx2=strfind(tline, ';')-1;
                    s=strtrim(tline(idx1:idx2));
                    obj.Inner_Frame_Height = str2double(s);
                end
            end
            fclose(fid);

            arch=computer('arch');
            if(strcmp(arch, 'win32'))
	            obj.A3200Path='C:\Program Files (x86)\Aerotech\A3200\Matlab\x86';
            elseif(strcmp(arch, 'win64'))
	            obj.A3200Path='C:\Program Files (x86)\Aerotech\A3200\Matlab\x64';
            end

            obj.QUAL_RESULT_DIR = [obj.RPAS_HOME '/' obj.QUAL_RESULT_DIR];
            obj.QUAL_IMAGE_DIR = [obj.RPAS_HOME '/' obj.QUAL_IMAGE_DIR];
            obj.QUAL_DATA_SHEET_DIR = [obj.RPAS_HOME '/' obj.QUAL_DATA_SHEET_DIR];
            obj.SCREEN_IMAGE_DIR = [obj.RPAS_HOME '/' obj.SCREEN_IMAGE_DIR];
            
            if obj.A3200Available && ~isdeployed
                addpath(obj.A3200Path);
            end
        end

        function errorMsg(~,msg)
            sz=get(0,'ScreenSize');
            ct=[sz(3)/2, sz(4)/2];
            w=300;h=160;
            fig = uifigure('position',[ct(1)-w/2, ct(2)-h/2, w, h]);
            
            title = 'Error';
            selection = uiconfirm(fig, msg, title,...
                'Options',{'OK'}, 'icon', 'error');
            switch selection
                case {'OK'}
                    %donothing;
                otherwise
                    %donothing;
            end
            delete(fig);
        end
    end
end
    
