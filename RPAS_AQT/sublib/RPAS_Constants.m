classdef RPAS_Constants
    properties (Constant)
        %The following contants will be used for Alignment and Mag/Focus
        %algorithms
        Pixel_obj_plane = 1.4; % virtual pixel size in object plane unit \mu m
        Pixel_img_plane = 6; % pixel size in image plane unit \mu m
        Outer_Frame_Width = 400; % outer frame width in pixels
        Outer_Frame_Height = 300; % outer frame height in pixels
        Iner_Frame_Width = 240; % iner frame width in pixels
        Iner_Frame_Height = 140; % iner frame height in pixels

        % The saved images and qualification files will be saved to the
        % following folders. These folders are relative folder to the
        QUAL_RESULT_DIR = 'QUAL_TEST_RESULTS';
        QUAL_IMAGE_DIR = 'TEST_IMAGES';
        QUAL_DATA_SHEET_DIR='QualDataSheetFolder';

        % The following constants controls the algorithm to use live
        % captured image or test image in the program
        
        %In the final programs, the HardwareAvailiable and A3200Available
        %should set to true;
        ImageJ_algorithm = false;
        HardwareAvailable= false;
        A3200Available=false;%true;

        %Camera addresses
        SWD_Address=0;
        LWD_Address=0;
    end

    properties (Access = public)
        %Project home directory, i.e. the direcory of app RPAS_AQT's
        %home directory. It is determined dymatically.
        RPAS_HOME = [];

        A3200Path;
    end

    methods (Access = public)
        function obj = RPAS_Constants()
            if isempty(obj.RPAS_HOME)
                path = mfilename('fullpath');
                arch=computer('arch');
                if strcmp(arch, 'win32') || strcmp(arch, 'win64')
                    pattern='\';
                else
                    pattern='/';
                end
                j=strfind(path, pattern);
                obj.RPAS_HOME = path(1:j(end-1)-1);
            end

            arch=computer('arch');
            if(strcmp(arch, 'win32'))
	            obj.A3200Path='C:\Program Files (x86)\Aerotech\A3200\Matlab\x86';
            elseif(strcmp(arch, 'win64'))
	            obj.A3200Path='C:\Program Files (x86)\Aerotech\A3200\Matlab\x64';
            end
        end
    end
end
    
