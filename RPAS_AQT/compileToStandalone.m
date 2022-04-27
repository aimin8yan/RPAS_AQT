function compileToStandalone(dest)
    if nargin~=1
        error('One input (the distribution desitination folder) is required');
    end
    addpath('sublib');
    
    appFile='RPAS_AQT.mlapp';
    img=[RPAS_Constants().RPAS_HOME  '/screenImages/AQT.PNG'];
    opts = compiler.build.StandaloneApplicationOptions(appFile, ...
        'ExecutableName', 'RPAS_AQT', ...
        'ExecutableIcon', img, ...
        'ExecutableSplashScreen', img, ...
        'Verbose', 'On', ...
        'OutputDir', dest);

    %change working directory
    modifyHome(dest);

    compiler.build.standaloneWindowsApplication(opts);

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

    %copy files to testination
    copyFiles('QualDataSheetFolder', dest);
    copyFiles('screenImages', dest);
    copyFiles('testImages/AlignMagImages', dest);
    copyFiles('testImages/contaminations', dest);
    copyFiles('testImages/PgmImages', dest);

    restoreHome();

    function modifyHome(home)
        out={};
        fid=fopen('sublib/RPAS_Constants.m','rt');
        while ~feof(fid)
            tline=fgetl(fid);
            if contains(tline, 'RPAS_HOME') & ~contains(tline,'obj.RPAS_HOME')
                idx=strfind(tline, 'RPAS_HOME');
                s=sprintf('%sRPAS_HOME = %s%s%s;', tline(1:idx-1),39,dest,39);
                out{end+1}=s;
            else
                out{end+1}=tline;
            end
        end
        fclose(fid);
    
    
        fid=fopen('sublib/RPAS_Constants.m','wt');
        for k=1:numel(out)
            fprintf(fid,'%s\n', out{k});
        end
        fclose(fid);
    end

    function restoreHome()
        out={};
        fid=fopen('sublib/RPAS_Constants.m','rt');
        while ~feof(fid)
            tline=fgetl(fid);
            if contains(tline, 'RPAS_HOME') & ~contains(tline,'obj.RPAS_HOME')
                idx=strfind(tline, 'RPAS_HOME');
                s=sprintf('%sRPAS_HOME = [];', tline(1:idx-1));
                out{end+1}=s;
            else
                out{end+1}=tline;
            end
        end
        fclose(fid);
    
    
        fid=fopen('sublib/RPAS_Constants.m','wt');
        for k=1:numel(out)
            fprintf(fid,'%s\n', out{k});
        end
        fclose(fid);
    end
    
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