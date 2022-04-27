function PRAD_displayThreshold(image, threshImg, spots, thresh, imageName)

  % Create a gray color map with 255 gray levels
  gray255 = zeros(255, 3);
  delta = 1/(255 - 1);
  for i = 0:(255 - 1)
    gray255(i + 1, 1) = i * delta; 
    gray255(i + 1, 2) = gray255(i + 1, 1); 
    gray255(i + 1, 3) = gray255(i + 1, 1); 
  end
  
  fig=figure('Name', imageName);
    subplot(1,2,1), imagesc(image); axis image;
      title(imageName);
    subplot(1,2,2), imagesc(threshImg); axis image; hold on;
    subplot(1,2,2), plot3(spots.sPosEstimate(:,2)+1, spots.sPosEstimate(:,1) +1, spots.surface(:), 'o', ...
                          'MarkerSize',30, 'MarkerEdgeColor', 'r'), view(0,90);
      txt=sprintf('Thresholded: %g ', thresh);
      title(txt);
    colormap(gray255);
end
