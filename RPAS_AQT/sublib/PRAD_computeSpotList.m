function [spotList, bwImg, thresh]=PRAD_computeSpotList(img)
    
    global PRAD_config;
    global PRAD_control;
    global PRAD_data;
    global PRAD_gui;
    global SPOT_DISTANCE;


    global markerPositions;
    global nearestSpotImage;
    %global distances;
    global reticlePixel;
    global imagePixel;
    
    PRAD_init();
    [spotList, bwImg, thresh]=PRAD_threshold_SingleImg(img, SPOT_DISTANCE);
end