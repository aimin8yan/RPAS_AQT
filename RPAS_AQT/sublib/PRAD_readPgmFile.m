function [data] = PRAD_readPgmFile( fname, showComment )
% PRAD_readPgmFile - RPAS ADT
%
% Prototype  : [data] = PRAD_readPgmFile( fname, showComment )
%
% Description: -
%
% Input(s)   : -
%
% Output(s)  : -
%
% Notes      : -
%

%-----------------------------------------------------------------------------%
%
%                        MATLAB Module
%
%-----------------------------------------------------------------------------%
%
% Ident        : @(#) PRAD_readPgmFile.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.1
% LastCheckin  : @(#) 05/08/15 12:20:10
%
% History      : See SCCS
%
%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

% start functie
if nargin<1,
   fprintf(2,'No filename specified !!');
   return
end;

if nargin<2,
   showComment=0;
end

if isempty(fname)
   fprintf(2,'Filename is empty');
   return
end

[fid, msg] = fopen(fname,'r');
if ~isempty(msg)
   error(['Could not open file ' fname ':' char(10) msg]);
end

% for now we only support 'binary' PGM format'
magicnum = fgetl(fid);
if ( magicnum ~= 'P5' )
   error([ fname 'Wrong file type (magic-cookie incorrect :' magicnum ')' ]);
end
line = fgets(fid);
while strncmp(line,'#',1)
   if ( showComment ~= 0 )
      fprintf(1,'%s', line);
   end
   line = fgets(fid);
end
imsize = sscanf(line,'%d %d');
line = fgets(fid);
while strncmp(line,'#',1)
   if ( showComment ~= 0 )
      fprintf(1,'%s', line);
   end
   line = fgets(fid);
end

% check width of the data, if it fits in 8 bits, read 8 bits, else 16 bits
imbits = sscanf(line,'%d');
if ( imbits <= 255 )
   dataformat='uint8=>uint8';
else
   dataformat='uint16=>uint16';
end
[data] = fread(fid, [imsize(1), imsize(2)], dataformat ); 

fclose(fid);


