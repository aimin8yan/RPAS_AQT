function compileToStandalone(dest)
    if nargin~=1
        error('One input (the distribution desitination folder) is required');
    end
    addpath('sublib');
    
    appFile='RPAS_AQT.mlapp';
    img='screenImages/AQT.PNG';
    arch=computer('arch');
    if(strcmp(arch, 'win32'))
        filesToAdd='C:\Program Files (x86)\Aerotech\A3200\Matlab\x86';
    elseif(strcmp(arch, 'win64'))
        filesToAdd='C:\Program Files (x86)\Aerotech\A3200\Matlab\x64';
    end

    opts = compiler.build.StandaloneApplicationOptions(appFile, ...
        'AdditionalFiles', filesToAdd, ...
        'ExecutableName', 'RPAS_AQT', ...
        'ExecutableIcon', img, ...
        'ExecutableSplashScreen', img, ...
        'Verbose', 'On', ...
        'AutoDetectDataFiles', 'On', ...
        'OutputDir', dest);

    %copy files to testination
    copyFiles('QualDataSheetFolder', dest);
    copyFiles('screenImages', dest);
    copyFiles('testImages/AlignMagImages', dest);
    copyFiles('testImages/contaminations', dest);
    copyFiles('testImages/PgmImages', dest);

    compiler.build.standaloneWindowsApplication(opts);
    
return;
    appFile='setPassword.m';
    opts = compiler.build.StandaloneApplicationOptions(appFile, ...
        'ExecutableName', 'setPassword', ...
        'OutputDir', [dest '/setPassword']);
    compiler.build.standaloneWindowsApplication(opts);

    appFile='resetPassword.m';
    opts = compiler.build.StandaloneApplicationOptions(appFile, ...
        'ExecutableName', 'resetPassword', ...
        'OutputDir', [dest '/resetPassword']);
    compiler.build.standaloneWindowsApplication(opts);

    return;
    
    function copyFiles(fdir, dest)
        listing=dir(fdir);
        names={};
        for k=1:numel(listing)
            name=listing(k).name;
            if ~strcmp(name,'.')&& ~strcmp(name,'..')
                names{end+1}=name;
            end
        end

        fdest=[dest '/' fdir];
        RPAS_Make_folder(fdest);
        for k=1:numel(names)
            copyfile([fdir '/' names{k}], fdest);
        end
    end
end