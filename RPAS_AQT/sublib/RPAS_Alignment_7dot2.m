function val=RPAS_Alignment_7_dot_2(in)

  %This routine is to compute the Center position (X,Y) and Rz
  %
  % Inputs: 
  % in: a string or matlab matrix variable. 
  %     if in is string, it indicates the path name for the image to be processed
  %     if in is a matrix, it  represents the image to be processed
  % ReticleCenter: a real vector of size 3, representing the center
  % position of the RETICLE in world coordinate system.
  %
  % Output:
  % A struct variable contains the following fields with self explaining
  % 'X_in_pixels', 'X_in_mu_image_plane', 'X_in_mu_in_object_plane';
  % 'Y_in_pixels', 'Y_in_mu_image_plane', 'Y_in_mu_in_object_plane';
  % 'Rz' -- in milliradians
  %
  % Note: The value of X and Y indicate the value relating to the
  % lower-left corner of the image
  %
  
  
  if ischar(in)
    img=imread(in);
  else
    img=in;
  end
  
  if (RPAS_Constants.ImageJ_algorithm)
    prop=RPAS_geoProperties_imagej(img);
  else
    % determine ROI
    ct=floor((size(img)+1)/2);
    width=460;
    height=440;
    ROI=[ct(1)-height/2+1, ct(2)-width/2+1, height, width];
    prop=RPAS_geoProperties(img, ROI,100);
  end

  
  %relative position to image center
  %ct=floor((size(img)+1)/2);
  x=prop.X;
  y=prop.Y;
  Rz=prop.Angle*1.0e3;%To mrad
  val=struct(...
      'X_in_pixels', x,...
      'X_in_mu_image_plane', x*RPAS_Constants.Pixel_img_plane, ...
      'X_in_mu_in_object_plane', x*RPAS_Constants.Pixel_obj_plane, ...
      'Y_in_pixels', y,...
      'Y_in_mu_image_plane', y*RPAS_Constants.Pixel_img_plane, ...
      'Y_in_mu_in_object_plane', y*RPAS_Constants.Pixel_obj_plane, ...
      'Rz', Rz);
  return;
end
  
  
  
