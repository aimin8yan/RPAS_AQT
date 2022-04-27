function prop=RPAS_geoProperties_imagej(img)


  %create Image
  MIJ.createImage(img);
  
%//Image Size and Position Evaluation
  MIJ.run('Set Measurements...', 'modal min centroid bounding fit median display scientific add redirect=None decimal=4');
  MIJ.run('Specify...', 'width=460 height=440 x=320 y=240 centered');
  MIJ.setThreshold(100, 255);
  MIJ.run('Analyze Particles...','display exclude include');
  % extract required results
  prop=toImageJMeasureFmt('img', MIJ.getResultsTable());
  prop=toImageJMeasureFmt('imf', MIJ.getResultsTable());
  ij.IJ.resetThreshold();
  MIJ.run('Clear Results');
  MIJ.closeAllWindows();
  
  return;
  
  function result=toImageJMeasureFmt(title, val)
    result.Label=title;
    result.Mode=val(1);
    result.Min=val(2);
    result.Max=val(3);
    result.X=val(4);
    result.Y=val(5);
    result.BX=val(6);
    result.BY=val(7);
    result.Width=val(8);
    result.Height=val(9);
    result.Major=val(10);
    result.Minor=val(11);
    
    %converting angle to radian
    if val(12)>90
        result.Angle=(val(12)-180)*pi/180;
    else
        result.Angle=val(12)*pi/180;
    end
    result.Median=val(13);
  end
end