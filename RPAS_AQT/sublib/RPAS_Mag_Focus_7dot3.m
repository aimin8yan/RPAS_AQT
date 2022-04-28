function out=RPAS_Mag_Focus_7_dot_3(in)

  %This routine is to compute the Magnification and MTF
  %
  % Inputs: 
  % in: a string or matlab matrix variable. 
  %     if in is string, it indicates the path name for the image to be processed
  %     if in is a matrix, it  represents the image to be processed
  %
  % Output:
  % A scalar represent the magnification
  %
  % Note: A negative of X indicate the x-position is located to the left of  the image center
  %
  
  % parameter for subpixel refining 
    global RPAS_C
    if isempty(RPAS_C)
        RPAS_C=RPAS_Constants(parentDir(pwd));
    end
  BIN= 4;
  
  if ischar(in)
    img=imread(in);
  else
    img=in;
  end
  

  if (RPAS_C.ImageJ_algorithm)
    prop=RPAS_geoProperties_imagej(img);
  else
    % determine ROI
    ct=floor((size(img)+1)/2);
    width=460;
    height=440;
    ROI=[ct(1)-height/2+1, ct(2)-width/2+1, height, width];
    prop=RPAS_geoProperties(img, ROI,100);
  end
  
  % if necessary, rotate the image back and recompute the properties
  if prop.Angle~=0
    mat=[cos(prop.Angle) sin(prop.Angle) 0; -sin(prop.Angle) cos(prop.Angle) 0; 0 0 1];
    tform = affine2d(mat);
    img=imwarp(img,tform);
    
    if (RPAS_C.ImageJ_algorithm)
      prop=RPAS_geoProperties_imagej(img);
    else
      % determine ROI
      ct=floor((size(img)+1)/2);
      width=460;
      height=440;
      ROI=[ct(1)-height/2+1, ct(2)-width/2+1, height, width];
      prop=RPAS_geoProperties(img, ROI,100);
    end
  end

  
  % compute the magnification
  M = 0.5*(prop.Width/RPAS_C.Outer_Frame_Width + prop.Height/RPAS_C.Outer_Frame_Height);
  M = M*RPAS_C.Pixel_img_plane/RPAS_C.Pixel_obj_plane; % converting to nominal position;
  

  % generate MAX image 
  r=20;
  se=strel('disk',r,0);
  MAX=double(imdilate(img,se));

  
  %ESF
  ct=[round(prop.Y), round(prop.X)];

  esf_x=MAX(ct(1), ct(2):ct(2)+floor(RPAS_C.Outer_Frame_Width/2));
  esf_y=MAX(ct(1):ct(1)+floor(RPAS_C.Outer_Frame_Height/2), ct(2))';


  
  % padding the shorter line so that the two lines have the same length
  esf_x=padarray(esf_x,[0,37], 'pre','replicate');
  esf_y=padarray(esf_y,[0,numel(esf_x)-numel(esf_y)], 'pre','replicate');

  if (ct(2)>ct(1))
      tmpa=esf_x;
      esf_x=esf_y;
      esf_y=tmpa;
      clear empa;
  end

  esf_x=padarray(esf_x,[0,100], 'replicate');
  esf_y=padarray(esf_y,[0,100], 'replicate');

  % refine data
  x=1:numel(esf_x);
  x1=1:1/BIN:numel(esf_x);
  
  y=1:numel(esf_y);
  y1=1:1/BIN:numel(esf_y);
  esf_x=interp1(x,esf_x, x1,'spline');
  esf_y=interp1(y,esf_y, y1,'spline');
  N=numel(esf_x);
  
  % compute the LSF
  lsf_x=gradient(esf_x);
  lsf_y=gradient(esf_y);
  
  
  % compute the MTF
  mtf_x=abs(fftshift(fft(lsf_x))); 
  mtf_y=abs(fftshift(fft(lsf_y))); 
  
  %first smooth data
  mtf_x=smooth_f(mtf_x,64);
  mtf_y=smooth_f(mtf_y,64);
  
  %normalization
  mtf_x=mtf_x./max(mtf_x(:));
  mtf_y=mtf_y./max(mtf_y(:));
  
  %keep the part with positive frequencies
  [~,id]=max(mtf_x); mtf_x=mtf_x(id:end);
  [~,id]=max(mtf_y); mtf_y=mtf_y(id:end);
  
  % determine the cut point
  m=find(mtf_x(1:end-1)-mtf_x(2:end)<0 |mtf_x(1:end-1)<0.05);
  mtf_x=mtf_x(1:m(1));
  
  m=find(mtf_y(1:end-1)-mtf_y(2:end)<0 |mtf_y(1:end-1)<0.05);
  mtf_y=mtf_y(1:m(1));
  
      
  % frequency in units (\mu m^{-1})
  pix=RPAS_C.Pixel_img_plane/BIN;
  dlt=1/(N*pix);
  freq_x= (0:numel(mtf_x)-1)*dlt;
  freq_y= (0:numel(mtf_y)-1)*dlt;
      
  %HWHM_x=freq_x(end)/2;
  %HWHM_y=freq_y(end)/2;
  
  % converting to percentage
  mtf_x=mtf_x*100;
  mtf_y=mtf_y*100;
  
  [C,ia]=unique(mtf_x);
  HWHM_x=interp1(mtf_x(ia), freq_x(ia), 50);
  centerAmp_x=interp1( freq_x(ia), mtf_x(ia), 0.5*(freq_x(1)+freq_x(end)));
  [C,ia]=unique(mtf_y);
  HWHM_y=interp1(mtf_y(ia), freq_y(ia), 50);
  centerAmp_y=interp1( freq_y(ia), mtf_y(ia), 0.5*(freq_y(1)+freq_y(end)));
  out=struct('frequency_x', freq_x, 'frequency_y', freq_y, 'mtf_x', mtf_x, 'mtf_y', mtf_y,...
              'HWHM_x', HWHM_x, 'HWHM_y', HWHM_y, 'centerAmp_x', centerAmp_x, 'centerAmp_y', centerAmp_y, 'Mag', M);
          
  return;
end