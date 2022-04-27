function img=RPAS_ImageAcquisition_7dot1(cameraSource, shotMode, axe, pauseTime)
    if nargin==4 & nargout>0
        errorMsg('Too many outputs, No output required.');
        return;
    elseif nargin==2 & nargout~=1
        errorMsg('One output required.');
        return;
    elseif nargin~=4 & nargin~=2
        errorMsg('Two or four inputs required.');
        return;
    end

    switch cameraSource
        case {0,1} %gigE camera: (SDW,LWD)
            switch shotMode
                case 0 % continuous shot 
                    contShot_gigE(cameraSource, axe, pauseTime);
                case 1 % %single shot
                    img=singleShot_gigE(cameraSource);
            end
        case 2 %Telescope
            obj=usbObj();
            if ~isempty(obj) && isvalid(obj)
                switch shotMode
                    case 0 % continuous shot
                        contShot_USB(obj, axe, pauseTime)
                    case 1 % single shot
                        img=singleShot_USB(obj);
                end
            end
    end
end

function obj=usbObj()
    info=imaqhwinfo;
    obj=[];

    adaptorName=[];
    for k=1:numel(info.InstalledAdaptors)
        if strcmp(info.InstalledAdaptors{k}, 'gentl')
            adaptorName=info.InstalledAdaptors{k};
        end
    end
    if isempty(adaptorName)
        errorMsg("No appropriate adaptor available for USB Camera.");
        return;
    end

    imaqreset;
    info=imaqhwinfo(adaptorName);

    if isempty(info.DeviceIDs)
        warningMsg("Please connect the USB Camera.");
        return;
    end
       
    adaptorID=info.DeviceIDs{1};
    videoFmt=info.DeviceInfo.DefaultFormat;
    obj=videoinput(adaptorName, adaptorID, videoFmt);

    sz=obj.VideoResolution;
    if sz(1)<640 || sz(2)<480
        errorMsg("The sensor size is too small!");
        obj=[];
        return;
    elseif sz(1)>640 || sz(2)>480
        roi=[sz(1)/2-320, sz(2)/2-240, 640, 480];
        set(obj, 'ROIPosition', roi);
    end
end

function errorMsg(msg)
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

function warningMsg(msg)
    sz=get(0,'ScreenSize');
    ct=[sz(3)/2, sz(4)/2];
    w=300;h=160;
    fig = uifigure('position',[ct(1)-w/2, ct(2)-h/2, w, h]);

    title = 'Warning';
    selection = uiconfirm(fig, msg, title,...
        'Options',{'OK'}, 'icon', 'warning');
    switch selection
        case {'OK'}
            %donothing;
        otherwise
            %donothing;
    end
    delete(fig);
    return;
end

function img=singleShot_USB(cam)
    triggerconfig(cam, 'manual');
    start(cam);
    img=getsnapshot(cam);
    stop(cam);
    delete(cam);
end

function contShot_USB(cam, axe, pauseTime)
    global stopICBSignal;
    stopICBSignal=0;

    triggerconfig(cam, 'manual');
    start(cam);
    while isvalid(axe) & stopICBSignal == 0
        %capture image
        try
            img=getsnapshot(cam);
            %display images
            R=imref2d(size(img));
            imshow(img, R,'Parent', axe);
            drawnow;
            pause(pauseTime);
        catch
            msg= sprintf( 'Failed to capture image\n');
            errorMsg(msg);
            stopICBSignal = 1;
        end
    end
    
    if isvalid(cam)
        stop(cam);
        delete(cam); %delete the object
    end
end

function contShot_gigE(source, axe, pauseTime)
    global stopICBSignal;

    stopICBSignal=0;

    SWD=1;
    LWD=0;
    if source==SWD
        cameraAddress=RPAS_Constants.SWD_Address;
    elseif source==LWD
        cameraAddress=RPAS_Constants.LWD_Address;
    else
        errorMsg("Unsupported Camera Source.");
    end

    cam = gigecam;
    cam.site_sel=0;

    cam.capture_mode=1; % set 10 fps (for cont. shot)

    if source==SWD
        %assume SWD corresponding to M sensor
        cam.str_sensor_sel=1;
    else
        cam.str_sensor_sel=0;
    end
    cam.dac_curr_p_1=1;
    cam.dac_curr_m_1=1;
    cam.flash_dur_p=5;
    cam.flash_dur_m=5;

    cam.icbspwron=1;
    pause(1);

    if cam.str_sensor_sel==1
        %assume SWD corresponding to M sensor
        cam.m_i2c_control=1;
        cam.m_i2c_control=3;
    else
        cam.p_i2c_control=1;
        cam.p_i2c_control=3;
    end
    timeFlag=2;
    tic;

    while (cam.str_sensor_sel==1 & cam.m_i2c_control==27) || ...
            (cam.str_sensor_sel==0 & cam.p_i2c_control==27)
        t=toc;
        if t>=timeFlag
            msg= sprintf( 'I2C bus is still busy after %g seconds. Stop.\n', t);
            errorMsg(msg);
            cam.icbspwron = 0; %power down ICB's
            % clearvars -global
            imaqreset;
            delete(cam);
            return;
        end
    end

    cam.capture_req=1;
    %begin capture image
    while isvalid(axe) & stopICBSignal == 0
        %capture image
        try
            img=snapshot(cam);
            %display images
            R=imref2d(size(img));
            imshow(img, R,'Parent', axe);
            drawnow;
            pause(pauseTime);
        catch
            msg= sprintf( 'Failed to capture image\n');
            errorMsg(msg);
            stopICBSignal = 1;
        end
    end
    cam.capture_req=0;
    cam.icbspwron = 0;
    % clearvars -global
    imaqreset; %disconnection
    delete(cam); %delete the object
    
end

function img=singleShot_gigE(source)
    SWD=1;
    LWD=0;
    if source==SWD
        cameraAddress=RPAS_Constants.SWD_Address;
    elseif source==LWD
        cameraAddress=RPAS_Constants.LWD_Address;
    else
        errorMsg("Unsupported Camera Source.");
    end

    cam = gigecam; %create GigE camera object
                   %need to make sure if multiple camera addresses exist
                   %in real situations

    cam.site_sel = 0; %site 1 selected
                      %need to make sure in real situations
                      %what would be changed with site chaged.

    cam.capture_mode = 0; %set camera to 3 frame capture mode
                      % only one image (the first one) is required
                      % in the capturing

    cam.dac_curr_p_1 = 1;
    cam.dac_curr_m_1 = 1;
    cam.flash_dur_p = 5;
    cam.flash_dur_m = 5;
    cam.icbspwron = 1; % power on the ICB

    pause(1);%POWER_TREE_STAT will need to be polled but values are not valid yet on FUMO

    cam.m_i2c_control = 1;
    cam.m_i2c_control = 3;

    cam.p_i2c_control = 1;
    cam.p_i2c_control = 3;

    timeFlag=2; %%%%%%%%%%%%%%%%%%%
                % setting a time flag to 2 seconds
                % as breaking point in the following
                % this value can be modified depending on real situations.
                %%%%%%%%%%%%%%%%%%%
    tic; %%%%%%%%%%%%%%%%%%%%%
         %%% bookmark current time
         %%%%%%%%%%%%%%%%%%%%%
    while bitget(cam.m_i2c_control, 4)~=0 | ... 
              bitget(cam.p_i2c_control,4)~=0
        t=toc;
        if t>=timeFlag %%% waiting for at most timeFlag seconds for ICB ready
            msg=sprintf('I2C bus is still busy after %g seconds. Stop.\n', t);
            errorMsg(msg);
            cam.icbspwron = 0; %power down ICB
            % clearvars 
            imaqreset; %disconnection
            delete(cam); %delete the object
            return;
        end
        pause(0.05); %%pausing for 5/100 seconds
    end

    cam.capture_req = 1;

    tic; %%%%%%%%%%%%%%%%%%%%%
         %%% bookmark current time
         %%%%%%%%%%%%%%%%%%%%%
    while (cam.frame_complete ~= 0b111111) % frame not complete
        t=toc;
        if t>=timeFlag %%% waiting for at most timeFlag seconds for ICB complete
            msg=sprintf( 'Capture not Complete within %g seconds. Stop.\n Frame complete status: %s\n', t, dec2bin(cam.frame_complete) );
            errorMsg(msg);
            cam.capture_req=0;
            cam.icbspwron = 0; %power down ICB's
            % clearvars -global
            imaqreset; %disconnection
            delete(cam); %delete the object
            return;
        end
        pause(0.05);
    end

    %capture image
    img = snapshot(cam);
    try                 % JPD HACK TO TURN OFF ACQ CONTROL
        cam.Timeout = 1;  %JPD Trying to save myself some time
        snapshot(cam);
    end

    % power down ICBS
    cam.capture_req=0;
    cam.icbspwron = 0;
    % clearvars -global
    imaqreset; %disconnection
    delete(cam); %delete the object
    return;
end