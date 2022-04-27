function PRAD_init_global()
%-----------------------------------------------------------------------------%
%
%                        MATLAB Module
%
%-----------------------------------------------------------------------------%
%
% Ident        : @(#) PRAD_init_global.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.2
% LastCheckin  : @(#) 05/09/30 11:03:09
%
% History      : See SCCS
%

%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

  global PRAD_config;
  global PRAD_control;
  global PRAD_data;
  global PRAD_gui;
  global displayMsg;
  global reticlePixel;
  global imagePixel;
  

  %-------------------------------------------------------------------------------
  %-- Config parameters
  %-------------------------------------------------------------------------------
  displayMsg=0;
  reticlePixel=1.4e-6;
  imagePixel=5.6e-6;
  %imagePixel=1.0e-3/savedVariables().engineeringPar1Var.ImageConversFactor;
  

  PRAD_config.exec_path = '/home/aabutan/RPAS/';
  PRAD_config.pgm_dir_path = './';
  PRAD_config.pgm_dir_name = '.';

  %-------------------------------------------------------------------------------
  %-- Control variables
  %-------------------------------------------------------------------------------
  PRAD_control.plotInit = 0;
  PRAD_control.scaled = 'scaled'; % 'direct'
  PRAD_control.liveMode = 0;
  PRAD_control.fakeMode = 0;
  PRAD_control.dumpMode = 0;
  PRAD_control.simulation = 0;
  PRAD_control.initialized = 0;

  PRAD_control.load = 0;

  % image handles
  PRAD_control.imagePHandle = 0;
  PRAD_control.imageMHandle = 0;

  PRAD_control.sensorPSelect = 1;
  PRAD_control.sensorMSelect = 1;

  PRAD_control.emptyImage = ones(640, 480);


  % location of the PRAD markers on the Reticle
  PRAD_control.sensorConfig.sensorM.mInRVect = [64.0e-3 0];
  PRAD_control.sensorConfig.sensorP.mInRVect = [-64.0e-3  0];

  PRAD_control.sensorConfig.sensorM.rpInRs0Vect = [64.0e-3 0];
  PRAD_control.sensorConfig.sensorP.rpInRs0Vect = [-64.0e-3  0];

  % PRAD_control.sensorConfig.sensorM.mInRVect = [-65.5e-3 -65.5e-3];
  % PRAD_control.sensorConfig.sensorP.mInRVect = [65.5e-3  -65.5e-3];
  % 
  % PRAD_control.sensorConfig.sensorM.rpInRs0Vect = [-65.5e-3 -65.5e-3];
  % PRAD_control.sensorConfig.sensorP.rpInRs0Vect = [65.5e-3  -65.5e-3];

  %PRAD_control.sensorConfig.sensorM.mInRVect = [-64.0e-3 0.0];
  %PRAD_control.sensorConfig.sensorP.mInRVect = [64.0e-3  0.0];

  %PRAD_control.sensorConfig.sensorM.rpInRs0Vect = [-64.0e-3 0.0];
  %PRAD_control.sensorConfig.sensorP.rpInRs0Vect = [64.0e-3  0.0];


  %PRAD_control.sensorConfig.rsInZ0Vect = [0.0 -0.13];
  PRAD_control.sensorConfig.rsInZ0Vect = [0.0 0.0];

  PRAD_control.sensorConfig.reticleTotMat = [...
  1.0, 0.0,...
  (PRAD_control.sensorConfig.sensorM.rpInRs0Vect(1) - PRAD_control.sensorConfig.rsInZ0Vect(1)),...
  - (PRAD_control.sensorConfig.sensorM.rpInRs0Vect(2) - PRAD_control.sensorConfig.rsInZ0Vect(2));...

  0.0, 1.0,...
  (PRAD_control.sensorConfig.sensorM.rpInRs0Vect(2) - PRAD_control.sensorConfig.rsInZ0Vect(2)),...
  (PRAD_control.sensorConfig.sensorM.rpInRs0Vect(1) - PRAD_control.sensorConfig.rsInZ0Vect(1));...

  1.0, 0.0,...
  (PRAD_control.sensorConfig.sensorP.rpInRs0Vect(1) - PRAD_control.sensorConfig.rsInZ0Vect(1)),...
  - (PRAD_control.sensorConfig.sensorP.rpInRs0Vect(2) - PRAD_control.sensorConfig.rsInZ0Vect(2));...

  0.0, 1.0,...
  (PRAD_control.sensorConfig.sensorP.rpInRs0Vect(2) - PRAD_control.sensorConfig.rsInZ0Vect(2)),...
  (PRAD_control.sensorConfig.sensorP.rpInRs0Vect(1) - PRAD_control.sensorConfig.rsInZ0Vect(1));...
  ];

  %---------------------------------------------------------------------------

  try
    PRAD_control.sensorConfig.captParams=ASML('create', 'IBXA.set_capture_params');
    PRAD_control.sensorConfig.flashM_p=ASML('create', 'IBXA:capt_params_union_t',...
       struct('disc', 'LED_MODE_FLASH'));
    PRAD_control.sensorConfig.continuousM_p=ASML('create', 'IBXA:capt_params_union_t',...
       struct('disc', 'LED_MODE_CONTINUOUS'));
       
    ASML('config','map_vectors',0);
    PRAD_control.standAlone = 0;
  catch
    PRAD_control.standAlone = 1;
  end

  %---------------------------------------------------------------------------
  [captParams flash continuous] = PRAD_getCaptureParms;
  PRAD_control.sensorConfig.flashP_p = flash.flashP_p;
  PRAD_control.sensorConfig.flashM_p = flash.flashP_p;
  PRAD_control.sensorConfig.continuousP_p = continuous.continuousP_p;
  PRAD_control.sensorConfig.continuousM_p = continuous.continuousP_p;
  PRAD_control.sensorConfig.captParams = captParams;

  %-------------------------------------------------------------------------------
  %-- Data variables
  %-------------------------------------------------------------------------------
  PRAD_data.statusOk = 0; 
  PRAD_data.imageP = ones(640, 480) * 180; 
  PRAD_data.imageM = ones(640, 480) * 180; 
  PRAD_data.thresHoldImageP = zeros(640, 480); 
  PRAD_data.thresHoldImageM = zeros(640, 480); 
  PRAD_data.thresholdP = 30;
  PRAD_data.thresholdM = 30;
  PRAD_data.spotsP = 0;
  PRAD_data.spotsM = 0;
  PRAD_data.medianP = 0;
  PRAD_data.medianM = 0;


  PRAD_data.calculated.doneP = 0;
  PRAD_data.calculated.doneM = 0;
  PRAD_data.calculated.posP = 0;
  PRAD_data.calculated.posM = 0;
  PRAD_data.calculated.posRetical = 0;

  PRAD_data.sensorP.result.matchFound = 0;
  PRAD_data.sensorM.result.matchFound = 0;
  PRAD_data.reticle.result.present = 0;

  PRAD_data.sensorP.info.refSpot.found = 0;
  PRAD_data.sensorM.info.refSpot.found = 0;

  %-------------------------------------------------------------------------------
  %-- GUI variables
  %-------------------------------------------------------------------------------
  PRAD_gui.statusFrame.sensorP.enable = 1;
  PRAD_gui.statusFrame.sensorP.ledModeFlash = 0;
  %PRAD_gui.statusFrame.sensorP.ledIntensity = 1;
  PRAD_gui.statusFrame.sensorP.flashTime = [0;0;0;0];
  PRAD_gui.statusFrame.sensorP.ledEnable = [0;0;0;0];

  PRAD_gui.statusFrame.sensorM.enable = 1;
  PRAD_gui.statusFrame.sensorM.ledModeFlash = 0;
  %PRAD_gui.statusFrame.sensorM.ledIntensity = 1;
  PRAD_gui.statusFrame.sensorM.flashTime = [0;0;0;0];
  PRAD_gui.statusFrame.sensorM.ledEnable = [0;0;0;0];

  PRAD_gui.statusFrame.framesPerCycle = 0;
  PRAD_gui.statusFrame.handles = 0;
  PRAD_gui.statusFrame.init = 0;
  PRAD_gui.statusFrame.open = 0;

  PRAD_gui.mainFrame.handles = 0;
  PRAD_gui.mainFrame.sensorM.selected = 0;
  PRAD_gui.mainFrame.sensorM.histogram.X = 1;
  PRAD_gui.mainFrame.sensorM.histogram.Y = 1;
  PRAD_gui.mainFrame.sensorM.histogram.max = 0;
  PRAD_gui.mainFrame.sensorM.histogram.min = 0;

  PRAD_gui.mainFrame.sensorP.selected = 0;
  PRAD_gui.mainFrame.sensorP.histogram.X = 1;
  PRAD_gui.mainFrame.sensorP.histogram.Y = 1;
  PRAD_gui.mainFrame.sensorP.histogram.max = 0;
  PRAD_gui.mainFrame.sensorP.histogram.min = 0;

  PRAD_gui.onLineMenu.handles = 0;
  PRAD_gui.onLineMenu.open = 0;

  PRAD_gui.videoModeMenu.handles = 0;
  PRAD_gui.videoModeMenu.open = 0;

  % read in marker_Positions
  PRAD_marker_1();
  % generate nearestPositionImage
  PRAD_distances();
end

function [captParams, flash, continuous] = PRAD_getCaptureParms()
% PRAD_getCaptureParms - RPAS ADT
%
% Prototype  : [captParams, flash, continuous] = PRAD_getCaptureParms()
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
% Ident        : @(#) PRAD_getCaptureParms.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.1
% LastCheckin  : @(#) 05/08/15 12:20:00
%
% History      : See SCCS
%
%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

  flash.flashP_p.disc = 'UNKNOWN';
  flash.flashM_p.disc = 'UNKNOWN';
  continuous.continuousP_p.disc = 'UNKNOWN';
  continuous.continuousM_p.disc = 'UNKNOWN';
  captParams.captParamsP_p.parms.disc = 'UNKNOWN';
  captParams.captParamsM_p.parms.disc = 'UNKNOWN';

  try
    captParams = ASML('RP_IB', 'IBXA.get_capture_params');

    switch captParams.captParamsP_p.parms.disc
    case 'LED_MODE_FLASH'
      flash.flashP_p = captParams.captParamsP_p.parms;
    case 'LED_MODE_CONTINUOUS'
      continuous.continuousP_p = captParams.captParamsP_p.parms;
    end

    switch captParams.captParamsM_p.parms.disc
    case 'LED_MODE_FLASH'
      flash.flashM_p = captParams.captParamsM_p.parms;
    case 'LED_MODE_CONTINUOUS'
      continuous.continuousM_p = captParams.captParamsM_p.parms;
    end
  catch
    lclFpcCount = 1;
    captParams.captParamsM_p.sensorId = 'SENSOR_ID_ICBS_M';
    captParams.captParamsM_p.fpcCount = lclFpcCount;
    captParams.captParamsM_p.sensorEnable = 1;
    captParams.captParamsP_p.sensorId = 'SENSOR_ID_ICBS_P';
    captParams.captParamsP_p.fpcCount = lclFpcCount;
    captParams.captParamsP_p.sensorEnable = 1;

  end

  try
    RP_machine_constants = ASML('RP', 'RPXAxMC.get');
    mSide = 1;
    pSide = 2;
    
    if strcmp(flash.flashP_p.disc, 'UNKNOWN')
      flash.flashP_p.disc = 'LED_MODE_FLASH';
      flash.flashP_p.flash.ledEnable = ...
        RP_machine_constants.HW.sensor(pSide).ledEnable;
      flash.flashP_p.flash.ledFlashTime = [...
        RP_machine_constants.HW.sensor(pSide).ledMeanFlashTime; ...
        RP_machine_constants.HW.sensor(pSide).ledMeanFlashTime; ...
        RP_machine_constants.HW.sensor(pSide).ledMeanFlashTime; ...
        RP_machine_constants.HW.sensor(pSide).ledMeanFlashTime];
    end

    if strcmp(flash.flashM_p.disc, 'UNKNOWN')
      flash.flashM_p.disc = 'LED_MODE_FLASH';
      flash.flashM_p.flash.ledEnable = ...
        RP_machine_constants.HW.sensor(mSide).ledEnable;
      flash.flashM_p.flash.ledFlashTime = [...
        RP_machine_constants.HW.sensor(mSide).ledMeanFlashTime; ...
        RP_machine_constants.HW.sensor(mSide).ledMeanFlashTime; ...
        RP_machine_constants.HW.sensor(mSide).ledMeanFlashTime; ...
        RP_machine_constants.HW.sensor(mSide).ledMeanFlashTime];
    end
    
    if strcmp(continuous.continuousP_p.disc, 'UNKNOWN')
      continuous.continuousP_p.disc = 'LED_MODE_CONTINUOUS';
      continuous.continuousP_p.continuous.ledContCurr = ...
        RP_machine_constants.HW.sensor(pSide).ledContCurrent;
    end

    if strcmp(continuous.continuousM_p.disc, 'UNKNOWN')
      continuous.continuousM_p.disc = 'LED_MODE_CONTINUOUS';
      continuous.continuousM_p.continuous.ledContCurr = ...
        RP_machine_constants.HW.sensor(mSide).ledContCurrent;
    end

    if strcmp(captParams.captParamsP_p.parms.disc, 'UNKNOWN')
      switch RP_machine_constants.HW.sensor(pSide).ledOpMode
      case 'LED_MODE_FLASH'
        captParams.captParamsP_p.parms = flash.flashP_p;
      case 'LED_MODE_CONTINUOUS'
        captParams.captParamsP_p.parms = continuous.continuousP_p;
      end
    end


    if strcmp(captParams.captParamsM_p.parms.disc, 'UNKNOWN')
      switch RP_machine_constants.HW.sensor(mSide).ledOpMode
      case 'LED_MODE_FLASH'
        captParams.captParamsM_p.parms = flash.flashM_p;
      case 'LED_MODE_CONTINUOUS'
        captParams.captParamsM_p.parms = continuous.continuousM_p;
      end
    end

  catch
    mFlashTime=2.4e-3;
    pFlashTime=2.4e-3;
    if strcmp(flash.flashP_p.disc, 'UNKNOWN')
      flash.flashP_p.disc = 'LED_MODE_FLASH';
      flash.flashP_p.flash.ledEnable = [1;1;1;1];
      flash.flashP_p.flash.ledFlashTime = [pFlashTime;pFlashTime;pFlashTime;pFlashTime];
    end

    if strcmp(flash.flashM_p.disc, 'UNKNOWN')
      flash.flashM_p.disc = 'LED_MODE_FLASH';
      flash.flashM_p.flash.ledEnable = [1;1;1;1];
      flash.flashM_p.flash.ledFlashTime = [mFlashTime;mFlashTime;mFlashTime;mFlashTime];
    end

    intensity = 'CON_CURR_OFF';
    if strcmp(continuous.continuousP_p.disc, 'UNKNOWN')
      continuous.continuousP_p.disc = 'LED_MODE_CONTINUOUS';
      continuous.continuousP_p.continuous.ledContCurr = intensity;
    end

    if strcmp(continuous.continuousM_p.disc, 'UNKNOWN')
      continuous.continuousM_p.disc = 'LED_MODE_CONTINUOUS';
      continuous.continuousM_p.continuous.ledContCurr = intensity;
    end

    if strcmp(captParams.captParamsP_p.parms.disc, 'UNKNOWN')
      captParams.captParamsM_p.parms = flash.flashM_p;
    end
    if strcmp(captParams.captParamsP_p.parms.disc, 'UNKNOWN')
      captParams.captParamsP_p.parms = flash.flashP_p;
    end

  end

% --------------------------------------------------------------------
end

function PRAD_marker_1()
%-----------------------------------------------------------------------------%
%
%                        MATLAB Module
%
%-----------------------------------------------------------------------------%
%
% Ident        : @(#) PRAD_marker.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.1
% LastCheckin  : @(#) 05/08/15 12:20:06
%
% History      : See SCCS
%
%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

% THE positions (x,y) for the centres of the stars in the RPAS marker

  global markerPositions;
  global distances;
  global SPOT_DISTANCE

  SPOT_DISTANCE = 50;

  distances = zeros(729, 7);

  markerPositions = [

    240,  40, 	1 ;
    369,  98,   2 ;
    518,  99,   3 ;
    705,  63,   4 ;
    845,  52,   5 ;
    967, 104,   6 ;
   1117,  66,   7 ;
   1287,  78,   8 ;
   1453,  64,   9 ;
   1570,  42,  10 ;
   1695, 102,  11 ;
   1911,  88,  12 ;
   2026, 111,  13 ;
   2203,  56,  14 ;
   2325,  81,  15 ;
   2459, 107,  16 ;
   2643,  87,  17 ;
   2801,  97,  18 ;
   2945,  55,  19 ;
   3051,  47,  20 ;
   3245,  93,  21 ;
   3374,  58,  22 ;
   3520,  39,  23 ;
   3644,  69,  24 ;
   3817,  82,  25 ;
   3944,  57,  26 ;
    101, 232,  27 ;
    227, 249,  28 ;
    404, 235,  29 ;
    507, 210,  30 ;
    677, 247,  31 ;
    794, 261,  32 ;
    940, 207,  33 ;
   1095, 224,  34 ;
   1289, 231,  35 ;
   1393, 201,  36 ;
   1578, 225,  37 ;
   1702, 234,  38 ;
   1906, 240,  39 ;
   2028, 221,  40 ;
   2159, 192,  41 ;
   2337, 250,  42 ;
   2475, 233,  43 ;
   2649, 189,  44 ;
   2767, 256,  45 ;
   2888, 196,  46 ;
   3102, 195,  47 ;
   3210, 229,  48 ;
   3365, 215,  49 ;
   3542, 255,  50 ;
   3654, 223,  51 ;
   3852, 242,  52 ;
   3969, 206,  53 ;
     54, 376,  54 ;
    199, 354,  55 ;
    361, 390,  56 ;
    488, 383,  57 ;
    656, 343,  58 ;
    860, 410,  59 ;
   1010, 377,  60 ;
   1131, 403,  61 ;
   1303, 385,  62 ;
   1392, 363,  63 ;
   1554, 342,  64 ;
   1700, 386,  65 ;
   1856, 358,  66 ;
   2054, 372,  67 ;
   2173, 392,  68 ;
   2315, 397,  69 ;
   2469, 366,  70 ;
   2594, 388,  71 ;
   2762, 345,  72 ;
   2908, 382,  73 ;
   3093, 341,  74 ;
   3253, 360,  75 ;
   3389, 407,  76 ;
   3538, 375,  77 ;
   3672, 398,  78 ;
   3793, 408,  79 ;
   3977, 347,  80 ;
     69, 536,  81 ;
    202, 525,  82 ;
    338, 512,  83 ;
    520, 526,  84 ;
    684, 547,  85 ;
    851, 514,  86 ;
   1000, 518,  87 ;
   1114, 503,  88 ;
   1239, 539,  89 ;
   1401, 490,  90 ;
   1609, 544,  91 ;
   1701, 515,  92 ;
   1867, 493,  93 ;
   2053, 517,  94 ;
   2167, 496,  95 ;
   2310, 500,  96 ;
   2443, 498,  97 ;
   2631, 519,  98 ;
   2763, 509,  99 ;
   2961, 537, 100 ;
   3103, 560, 101 ;
   3262, 495, 102 ;
   3391, 558, 103 ;
   3551, 531, 104 ;
   3661, 506, 105 ;
   3836, 501, 106 ;
   3985, 491, 107 ;
     59, 641, 108 ;
    229, 660, 109 ;
    395, 702, 110 ;
    523, 678, 111 ;
    712, 693, 112 ;
    836, 639, 113 ;
    939, 671, 114 ;
   1152, 689, 115 ;
   1245, 669, 116 ;
   1413, 644, 117 ;
   1592, 664, 118 ;
   1712, 640, 119 ;
   1882, 710, 120 ;
   2055, 707, 121 ;
   2138, 703, 122 ;
   2301, 670, 123 ;
   2446, 663, 124 ;
   2637, 697, 125 ;
   2775, 673, 126 ;
   2911, 658, 127 ;
   3108, 692, 128 ;
   3212, 657, 129 ;
   3371, 706, 130 ;
   3527, 684, 131 ;
   3706, 652, 132 ;
   3853, 696, 133 ;
   3961, 688, 134 ;
     46, 860, 135 ;
    259, 813, 136 ;
    340, 817, 137 ;
    540, 854, 138 ;
    696, 834, 139 ;
    797, 818, 140 ;
    964, 821, 141 ;
   1091, 807, 142 ;
   1300, 831, 143 ;
   1430, 843, 144 ;
   1595, 797, 145 ;
   1703, 793, 146 ;
   1874, 788, 147 ;
   2042, 835, 148 ;
   2180, 838, 149 ;
   2361, 832, 150 ;
   2494, 815, 151 ;
   2603, 836, 152 ;
   2812, 812, 153 ;
   2891, 790, 154 ;
   3099, 826, 155 ;
   3246, 833, 156 ;
   3395, 828, 157 ;
   3510, 804, 158 ;
   3710, 789, 159 ;
   3828, 827, 160 ;
   3989, 803, 161 ;
     99, 971, 162 ;
    207, 989, 163 ;
    375, 973, 164 ;
    512, 974, 165 ;
    697, 942, 166 ;
    803, 957, 167 ;
    948, 940, 168 ;
   1122, 950, 169 ;
   1242, 955, 170 ;
   1445,1000, 171 ;
   1572, 952, 172 ;
   1747, 994, 173 ;
   1868, 972, 174 ;
   2045, 985, 175 ;
   2188, 948, 176 ;
   2351, 951, 177 ;
   2458, 945, 178 ;
   2652, 996, 179 ;
   2780,1003, 180 ;
   2934,1008, 181 ;
   3066, 943, 182 ;
   3231, 964, 183 ;
   3384, 946, 184 ;
   3539,1002, 185 ;
   3656, 960, 186 ;
   3821,1005, 187 ;
   4001, 995, 188 ;
     47,1110, 189 ;
    232,1094, 190 ;
    379,1152, 191 ;
    554,1119, 192 ;
    640,1143, 193 ;
    806,1109, 194 ;
    951,1153, 195 ;
   1144,1145, 196 ;
   1309,1139, 197 ;
   1434,1103, 198 ;
   1580,1140, 199 ;
   1759,1118, 200 ;
   1901,1159, 201 ;
   2032,1100, 202 ;
   2190,1134, 203 ;
   2355,1136, 204 ;
   2482,1146, 205 ;
   2598,1125, 206 ;
   2750,1135, 207 ;
   2924,1142, 208 ;
   3062,1097, 209 ;
   3249,1123, 210 ;
   3401,1101, 211 ;
   3541,1098, 212 ;
   3694,1091, 213 ;
   3809,1106, 214 ;
   3978,1162, 215 ;
    107,1239, 216 ;
    218,1308, 217 ;
    349,1254, 218 ;
    495,1293, 219 ;
    647,1312, 220 ;
    823,1287, 221 ;
   1002,1252, 222 ;
   1147,1281, 223 ;
   1311,1259, 224 ;
   1416,1244, 225 ;
   1562,1271, 226 ;
   1721,1280, 227 ;
   1881,1301, 228 ;
   2025,1269, 229 ;
   2195,1282, 230 ;
   2308,1261, 231 ;
   2455,1247, 232 ;
   2602,1292, 233 ;
   2806,1262, 234 ;
   2895,1302, 235 ;
   3085,1246, 236 ;
   3211,1258, 237 ;
   3388,1294, 238 ;
   3514,1241, 239 ;
   3675,1256, 240 ;
   3816,1290, 241 ;
   4010,1295, 242 ;
    103,1411, 243 ;
    191,1447, 244 ;
    362,1409, 245 ;
    545,1396, 246 ;
    649,1418, 247 ;
    804,1399, 248 ;
    988,1454, 249 ;
   1155,1403, 250 ;
   1276,1453, 251 ;
   1456,1452, 252 ;
   1584,1404, 253 ;
   1691,1457, 254 ;
   1873,1406, 255 ;
   2000,1429, 256 ;
   2185,1449, 257 ;
   2288,1425, 258 ;
   2499,1443, 259 ;
   2661,1398, 260 ;
   2740,1444, 261 ;
   2899,1400, 262 ;
   3039,1426, 263 ;
   3243,1433, 264 ;
   3368,1407, 265 ;
   3500,1412, 266 ;
   3698,1446, 267 ;
   3818,1417, 268 ;
   3997,1430, 269 ;
    108,1569, 270 ;
    217,1609, 271 ;
    383,1605, 272 ;
    516,1582, 273 ;
    693,1568, 274 ;
    813,1588, 275 ;
    966,1558, 276 ;
   1160,1597, 277 ;
   1254,1548, 278 ;
   1448,1539, 279 ;
   1606,1540, 280 ;
   1730,1561, 281 ;
   1869,1541, 282 ;
   2031,1565, 283 ;
   2149,1587, 284 ;
   2329,1566, 285 ;
   2464,1559, 286 ;
   2624,1589, 287 ;
   2779,1551, 288 ;
   2949,1607, 289 ;
   3071,1596, 290 ;
   3256,1576, 291 ;
   3366,1577, 292 ;
   3505,1585, 293 ;
   3689,1545, 294 ;
   3841,1600, 295 ;
   3959,1538, 296 ;
     73,1735, 297 ;
    261,1736, 298 ;
    397,1729, 299 ;
    549,1710, 300 ;
    651,1707, 301 ;
    793,1731, 302 ;
    984,1739, 303 ;
   1088,1719, 304 ;
   1250,1702, 305 ;
   1437,1713, 306 ;
   1611,1750, 307 ;
   1760,1722, 308 ;
   1844,1746, 309 ;
   2043,1727, 310 ;
   2177,1691, 311 ;
   2319,1747, 312 ;
   2453,1717, 313 ;
   2600,1741, 314 ;
   2796,1689, 315 ;
   2955,1697, 316 ;
   3072,1690, 317 ;
   3232,1758, 318 ;
   3372,1725, 319 ;
   3544,1714, 320 ;
   3676,1700, 321 ;
   3798,1751, 322 ;
   3955,1694, 323 ;
     49,1844, 324 ;
    224,1884, 325 ;
    346,1866, 326 ;
    543,1872, 327 ;
    675,1905, 328 ;
    801,1871, 329 ;
    973,1883, 330 ;
   1110,1848, 331 ;
   1285,1894, 332 ;
   1447,1900, 333 ;
   1565,1854, 334 ;
   1713,1860, 335 ;
   1860,1851, 336 ;
   2016,1873, 337 ;
   2197,1874, 338 ;
   2328,1878, 339 ;
   2486,1840, 340 ;
   2620,1899, 341 ;
   2751,1885, 342 ;
   2956,1897, 343 ;
   3048,1867, 344 ;
   3240,1889, 345 ;
   3382,1841, 346 ;
   3561,1881, 347 ;
   3693,1839, 348 ;
   3806,1903, 349 ;
   3966,1896, 350 ;
     98,2030, 351 ;
    196,2005, 352 ;
    392,2053, 353 ;
    510,2013, 354 ;
    664,2020, 355 ;
    819,2038, 356 ;
    975,1997, 357 ;
   1100,2012, 358 ;
   1241,1993, 359 ;
   1415,2046, 360 ;
   1596,2032, 361 ;
   1722,2014, 362 ;
   1866,2051, 363 ;
   1995,2058, 364 ;
   2146,2026, 365 ;
   2327,2060, 366 ;
   2454,1989, 367 ;
   2640,2035, 368 ;
   2760,2024, 369 ;
   2902,2016, 370 ;
   3067,2008, 371 ;
   3198,1988, 372 ;
   3377,1990, 373 ;
   3490,2044, 374 ;
   3681,2029, 375 ;
   3791,2043, 376 ;
   3957,2049, 377 ;
    109,2156, 378 ;
    262,2203, 379 ;
    382,2151, 380 ;
    506,2188, 381 ;
    648,2150, 382 ;
    831,2159, 383 ;
   1006,2143, 384 ;
   1121,2209, 385 ;
   1275,2178, 386 ;
   1426,2172, 387 ;
   1540,2180, 388 ;
   1753,2149, 389 ;
   1909,2199, 390 ;
   2017,2208, 391 ;
   2199,2185, 392 ;
   2347,2206, 393 ;
   2507,2163, 394 ;
   2589,2201, 395 ;
   2804,2211, 396 ;
   2923,2167, 397 ;
   3070,2152, 398 ;
   3236,2162, 399 ;
   3363,2177, 400 ;
   3534,2192, 401 ;
   3655,2147, 402 ;
   3814,2157, 403 ;
   3995,2200, 404 ;
     50,2354, 405 ;
    205,2308, 406 ;
    393,2341, 407 ;
    526,2334, 408 ;
    689,2362, 409 ;
    841,2349, 410 ;
   1003,2314, 411 ;
   1150,2303, 412 ;
   1304,2356, 413 ;
   1405,2302, 414 ;
   1538,2315, 415 ;
   1719,2345, 416 ;
   1904,2361, 417 ;
   2022,2343, 418 ;
   2202,2339, 419 ;
   2289,2333, 420 ;
   2467,2304, 421 ;
   2656,2346, 422 ;
   2811,2296, 423 ;
   2938,2328, 424 ;
   3097,2329, 425 ;
   3220,2322, 426 ;
   3351,2320, 427 ;
   3526,2309, 428 ;
   3653,2317, 429 ;
   3795,2297, 430 ;
   3942,2289, 431 ;
     82,2510, 432 ;
    212,2503, 433 ;
    388,2468, 434 ;
    528,2472, 435 ;
    687,2465, 436 ;
    827,2441, 437 ;
    954,2440, 438 ;
   1112,2469, 439 ;
   1247,2458, 440 ;
   1412,2501, 441 ;
   1604,2506, 442 ;
   1748,2453, 443 ;
   1886,2470, 444 ;
   2011,2460, 445 ;
   2174,2451, 446 ;
   2316,2438, 447 ;
   2441,2455, 448 ;
   2625,2450, 449 ;
   2798,2457, 450 ;
   2937,2482, 451 ;
   3059,2508, 452 ;
   3200,2446, 453 ;
   3383,2498, 454 ;
   3547,2491, 455 ;
   3669,2489, 456 ;
   3822,2449, 457 ;
   4006,2502, 458 ;
     38,2595, 459 ;
    189,2648, 460 ;
    365,2615, 461 ;
    494,2624, 462 ;
    641,2603, 463 ;
    825,2612, 464 ;
    996,2588, 465 ;
   1103,2616, 466 ;
   1277,2622, 467 ;
   1423,2658, 468 ;
   1601,2634, 469 ;
   1694,2644, 470 ;
   1879,2601, 471 ;
   2029,2637, 472 ;
   2206,2640, 473 ;
   2344,2655, 474 ;
   2460,2620, 475 ;
   2632,2614, 476 ;
   2810,2629, 477 ;
   2953,2598, 478 ;
   3061,2633, 479 ;
   3189,2652, 480 ;
   3357,2619, 481 ;
   3498,2649, 482 ;
   3712,2643, 483 ;
   3804,2661, 484 ;
   3949,2653, 485 ;
     75,2749, 486 ;
    242,2770, 487 ;
    390,2767, 488 ;
    538,2758, 489 ;
    666,2777, 490 ;
    833,2768, 491 ;
    944,2779, 492 ;
   1149,2806, 493 ;
   1243,2798, 494 ;
   1431,2785, 495 ;
   1573,2739, 496 ;
   1709,2804, 497 ;
   1880,2789, 498 ;
   2008,2808, 499 ;
   2186,2774, 500 ;
   2300,2807, 501 ;
   2490,2755, 502 ;
   2604,2800, 503 ;
   2778,2791, 504 ;
   2932,2744, 505 ;
   3052,2802, 506 ;
   3213,2763, 507 ;
   3402,2741, 508 ;
   3507,2810, 509 ;
   3682,2805, 510 ;
   3833,2771, 511 ;
   3953,2775, 512 ;
     92,2924, 513 ;
    228,2908, 514 ;
    354,2947, 515 ;
    558,2920, 516 ;
    662,2906, 517 ;
    818,2927, 518 ;
    987,2915, 519 ;
   1129,2949, 520 ;
   1268,2894, 521 ;
   1450,2929, 522 ;
   1559,2907, 523 ;
   1727,2936, 524 ;
   1883,2899, 525 ;
   1993,2902, 526 ;
   2165,2895, 527 ;
   2298,2932, 528 ;
   2442,2935, 529 ;
   2597,2922, 530 ;
   2776,2937, 531 ;
   2890,2944, 532 ;
   3073,2934, 533 ;
   3239,2931, 534 ;
   3399,2938, 535 ;
   3524,2962, 536 ;
   3705,2946, 537 ;
   3838,2926, 538 ;
   3994,2948, 539 ;
     70,3107, 540 ;
    235,3070, 541 ;
    405,3097, 542 ;
    515,3100, 543 ;
    698,3104, 544 ;
    830,3091, 545 ;
    949,3068, 546 ;
   1093,3099, 547 ;
   1261,3069, 548 ;
   1390,3110, 549 ;
   1547,3040, 550 ;
   1749,3059, 551 ;
   1895,3060, 552 ;
   2061,3085, 553 ;
   2140,3088, 554 ;
   2313,3063, 555 ;
   2451,3087, 556 ;
   2644,3052, 557 ;
   2744,3096, 558 ;
   2952,3074, 559 ;
   3068,3043, 560 ;
   3229,3051, 561 ;
   3379,3101, 562 ;
   3488,3058, 563 ;
   3684,3044, 564 ;
   3840,3042, 565 ;
   3958,3073, 566 ;
     78,3249, 567 ;
    260,3220, 568 ;
    374,3200, 569 ;
    529,3230, 570 ;
    652,3237, 571 ;
    835,3247, 572 ;
    972,3215, 573 ;
   1106,3236, 574 ;
   1279,3258, 575 ;
   1461,3205, 576 ;
   1608,3225, 577 ;
   1744,3252, 578 ;
   1857,3248, 579 ;
   2040,3244, 580 ;
   2208,3211, 581 ;
   2303,3257, 582 ;
   2508,3197, 583 ;
   2590,3259, 584 ;
   2807,3260, 585 ;
   2898,3232, 586 ;
   3049,3255, 587 ;
   3260,3223, 588 ;
   3367,3204, 589 ;
   3508,3199, 590 ;
   3680,3239, 591 ;
   3788,3202, 592 ;
   3998,3190, 593 ;
     48,3370, 594 ;
    188,3358, 595 ;
    391,3401, 596 ;
    521,3383, 597 ;
    669,3342, 598 ;
    799,3343, 599 ;
    990,3405, 600 ;
   1111,3407, 601 ;
   1269,3339, 602 ;
   1410,3360, 603 ;
   1579,3393, 604 ;
   1696,3410, 605 ;
   1893,3408, 606 ;
   2014,3404, 607 ;
   2142,3382, 608 ;
   2292,3366, 609 ;
   2496,3371, 610 ;
   2608,3344, 611 ;
   2752,3350, 612 ;
   2927,3396, 613 ;
   3042,3362, 614 ;
   3244,3381, 615 ;
   3410,3365, 616 ;
   3516,3356, 617 ;
   3692,3355, 618 ;
   3859,3394, 619 ;
   3946,3380, 620 ;
     77,3540, 621 ;
    210,3493, 622 ;
    389,3500, 623 ;
    537,3508, 624 ;
    663,3501, 625 ;
    811,3530, 626 ;
    946,3536, 627 ;
   1124,3527, 628 ;
   1272,3531, 629 ;
   1389,3556, 630 ;
   1587,3559, 631 ;
   1758,3489, 632 ;
   1896,3532, 633 ;
   2056,3512, 634 ;
   2171,3499, 635 ;
   2341,3510, 636 ;
   2444,3555, 637 ;
   2650,3537, 638 ;
   2755,3560, 639 ;
   2894,3506, 640 ;
   3080,3543, 641 ;
   3255,3525, 642 ;
   3407,3505, 643 ;
   3496,3552, 644 ;
   3673,3544, 645 ;
   3837,3511, 646 ;
   3941,3520, 647 ;
     53,3680, 648 ;
    194,3642, 649 ;
    339,3662, 650 ;
    492,3649, 651 ;
    643,3681, 652 ;
    805,3639, 653 ;
    957,3708, 654 ;
   1126,3653, 655 ;
   1278,3668, 656 ;
   1459,3704, 657 ;
   1568,3690, 658 ;
   1707,3645, 659 ;
   1864,3675, 660 ;
   2049,3665, 661 ;
   2153,3698, 662 ;
   2306,3658, 663 ;
   2466,3650, 664 ;
   2610,3679, 665 ;
   2772,3692, 666 ;
   2910,3656, 667 ;
   3079,3694, 668 ;
   3242,3682, 669 ;
   3356,3700, 670 ;
   3537,3643, 671 ;
   3704,3712, 672 ;
   3844,3640, 673 ;
   3945,3711, 674 ;
    111,3809, 675 ;
    219,3797, 676 ;
    372,3790, 677 ;
    542,3840, 678 ;
    679,3793, 679 ;
    792,3795, 680 ;
    953,3805, 681 ;
   1139,3806, 682 ;
   1296,3820, 683 ;
   1395,3859, 684 ;
   1550,3803, 685 ;
   1693,3800, 686 ;
   1849,3861, 687 ;
   1999,3791, 688 ;
   2189,3822, 689 ;
   2352,3850, 690 ;
   2478,3842, 691 ;
   2636,3862, 692 ;
   2745,3843, 693 ;
   2962,3818, 694 ;
   3053,3837, 695 ;
   3261,3810, 696 ;
   3376,3815, 697 ;
   3562,3814, 698 ;
   3660,3807, 699 ;
   3829,3823, 700 ;
   4005,3853, 701 ;
     44,3993, 702 ;
    236,3950, 703 ;
    376,3986, 704 ;
    550,3946, 705 ;
    673,3972, 706 ;
    817,3975, 707 ;
    959,3973, 708 ;
   1104,3981, 709 ;
   1252,4008, 710 ;
   1436,3990, 711 ;
   1603,4011, 712 ;
   1734,3938, 713 ;
   1839,3994, 714 ;
   2009,3954, 715 ;
   2193,3974, 716 ;
   2346,3947, 717 ;
   2462,3961, 718 ;
   2621,4010, 719 ;
   2791,4005, 720 ;
   2954,3998, 721 ;
   3109,3979, 722 ;
   3238,3989, 723 ;
   3340,3995, 724 ;
   3554,3951, 725 ;
   3652,3977, 726 ;
   3820,3949, 727 ;
   3986,3991, 728 ;
      0,   0, 729];

  %markerPositions(:,1) = 4095 - markerPositions(:,1);
  %markerPositions(:,2) = 4096 - markerPositions(:,2);
end

function PRAD_distances()
% PRAD_distances - RPAS ADT
%
% Prototype  : PRAD_distances
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
% Ident        : @(#) PRAD_distances.m
% Author       : Alfred Abutan [TNO]
% FileVersion  : @(#) 1.1
% LastCheckin  : @(#) 05/08/15 12:19:57
%
% History      : See SCCS
%
%-----------------------------------------------------------------------------%
%
%       Copyright (c) 2004, ASML Holding N.V. (including affiliates).
%                         All rights reserved
%
%-----------------------------------------------------------------------------%

  global markerPositions;
  global distances;
  global nearestSpotImage;
  global PRAD_data;

  % All marker points
  B = markerPositions;
  
  markerPositions = B;

  % Create distance table
  distances = B;
  
  % Create nearest spot image
  if exist('nearestSpotImage.mat', 'file')
       load('nearestSpotImage.mat')
   else
       nearestSpotImage = PRAD_make_nearest_spot_image(markerPositions);
       save('-v7','nearestSpotImage.mat','nearestSpotImage')
   end

  starNum = 0;
  for mPos = B'
    starNum = starNum + 1;
    
    % Create structure realative to current position
    A(:, 1) = B(:, 1) - mPos(1);
    A(:, 2) = B(:, 2) - mPos(2);
    A(:, 3) = A(:,1).^2 + A(:,2).^2;
    A = sortrows(A, 3);
    
    % Store distance and angle of nearest point
    i = 2;
    distances(starNum, 4) = sqrt(A(i,3));
    distances(starNum, 5) = atan2(A(i,2), A(i,1));
      
    % Store also distance and angle of next nearest point
    i = 3;
    distances(starNum, 6) = sqrt(A(i,3));
    distances(starNum, 7) = atan2(A(i,2), A(i,1));
      
  end  
end
  
%---------------------------------------------------------------------------
% PRAD_make_nearest_spot_image
%
% purpose: Create the nearest spot image, used as a lookup image. With
%          the image wthe second reference spot number can be determined.
%                               
% usage:   varargout = pb_scale_Callback(h, eventdata, handles, varargin)
%
% input:   (regular callback input parameters)
%
% output:  -
%
% Note:    -
%
% author:  Alfred Abutan
% creation: 19 nov 2019
%---------------------------------------------------------------------------
function nearestSpotImage = PRAD_make_nearest_spot_image(spotPositions)

   xm = spotPositions(:,1);
   ym = spotPositions(:,2);

   nearestSpotImage = zeros([4096,4096]);

   xx = repmat([0:4095],4096,1);
   yy = repmat([0:4095]',1,4096);

   dimg = zeros([4096,4096])+65535.;

   for m = 1:numel(xm)
        txt=sprintf('Spot = %d/729 ', m);
        disp(txt);
        drawnow;
        dist = hypot(xx-xm(m),yy-ym(m));
        less = (dist < dimg);
        dimg = min(dimg,dist);
        nearestSpotImage = m*less+nearestSpotImage.*(1-less);
   end

   nearestSpotImage = uint16(nearestSpotImage);
end


