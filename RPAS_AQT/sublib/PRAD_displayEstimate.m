  function displayEstimate(markerPositions, info, imageName)
    flipx=-1;
    flipy=-1;
    fig=figure('Name',['P sensor pattern']);
      plot3(markerPositions(:,1)*flipx, markerPositions(:,2)*flipy, markerPositions(:,3), '.', ...
      'MarkerSize', 10, 'MarkerEdgeColor','k'), view(0,90); hold on;
      plot3(info.mPos(:,1)*flipx, info.mPos(:,2)*flipy, info.mPos(:,3),'O', ...
      'MarkerSize',10, 'MarkerEdgeColor','b'),view(0,90);
      plot3(info.mSpotRefPair([1:2], 1)*flipx, info.mSpotRefPair([1:2], 2)*flipy, info.mSpotRefPair([1:2], 3),'O', ...
      'MarkerSize',12, 'MarkerEdgeColor','r'), view(0,90); 
      axis image;
      title(imageName);



  end
