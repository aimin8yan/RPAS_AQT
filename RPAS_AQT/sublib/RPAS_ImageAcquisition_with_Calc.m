function RPAS_ImageAcquisition_with_Calc(cameraSource, axe, targetVals, ...
        errorFields, lamps, lampColors, pauseTime)
    global stopICBSignal;
    stopICBSignal=0;

    global systemVar;
    if isempty(systemVar)
        systemVar=savedVariables(); %read in system setup
    end
    var=systemVar.engineeringPar1Var;
    factor=1/var.ImageConversFactor;

    %create cam object
    cam=cameraObject(cameraSource);

    %begin capture image
    while isvalid(axe) & stopICBSignal==0
        %capture image
        try
            img=snapshot(cam);
            %display images
            R=imref2d(size(img));
            imshow(img, R,'Parent', axe);
            drawnow;

            %alignment values
            a=RPAS_Alignment_7dot2(imrotate(img, 90));
            ct=floor((size(img)+1)/2);
            errorFields(1).Value=(a.X_in_pixels-ct(1))*factor*1.0e3; % to um
            errorFields(2).Value=(a.Y_in_pixels-ct(2))*factor*1.0e3; % to um
            errorFields(3).Value=a.Rz*1.0e3; % to um

            %lamp colors
            for j=1:3
                if abs(errorFields(j).Value)>targetVals(j)
                    lamps(j).Color=lampColors.Fail;
                else
                    lamps(j).Color=lampColors.Pass;
                end
            end
            pause(pauseTime);
        catch
            msg= sprintf( 'Failed to capture image\n');
            errorMsg(msg);
            stopICBSignal = 1;
        end
    end
    %disconnect camera and delete the object
    cam.capture_req=0;
    cam.icbspwron = 0;
    % clearvars -global
    imaqreset; %disconnection
    delete(cam); %delete the object

end

function cam=cameraObject(source)
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