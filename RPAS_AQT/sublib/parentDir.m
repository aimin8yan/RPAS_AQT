function parent=parentDir(DIR)
    arch=computer('arch');
    if strcmp(arch, 'win32') || strcmp(arch, 'win64')
        pattern='\';
    else
        pattern='/';
    end
    j=strfind(DIR, pattern);
    parent = DIR(1:j(end)-1);
end