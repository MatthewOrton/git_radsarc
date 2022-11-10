function patientSettings = patientSpecificSettings(allPatientIDs, defaultPrior)

patientSettings = containers.Map;

% The RMH data had dediff ROIs whenever all_dediff=True, which means the NaN in element (3) of the prior was filled in
% using the dediff ROI.  The EORTC do not have these ROIs, so get rid of
% the NaNs.  The prior isn't actually used, it's just so the code runs
% before it gets to the part that sets all pixels to dediff
eortcDefaultPrior = defaultPrior;
eortcDefaultPrior.mu_mu(3) = 100;
eortcDefaultPrior.sigma_mu(3) = 10;

patientSettings('EORTCRSRC_001') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-80.1162; -31.4775; 12.0144; 500];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.0539; 10.0888; 17.3344; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_004') = myStruct('only_probe_dediff', true, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-60.1284; -33.6999; 44.4113; 171.8017]; % -32.884, -25.3368, 106.9648, 125.6064
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [23.8692; 17.5337; 30.1625; 74.746];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 135; %125
patientSettings('EORTCRSRC_006') = myStruct('prior', thisPrior, 'minPixelCount_calc_to_dediff_per_slice', 20, 'calcificationSliceRange', 43:52, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 75);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-62.9093; -17.6262; 31.1057; 229.7045];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [11.4531; 14.9938; 15.0678; 123.4692];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_008') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 250, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 100);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-55.7938; -0.58287; 89.0688; 500];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [24.8344; 9.9216; 11.2825; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_009') = myStruct('prior', thisPrior, 'convert_myxoid_to_dediff', true, 'minPixelCount_dediff_hole_fill_per_slice', 150, 'minPixelCount_myxoid_hole_fill_per_slice', 150, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_010') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-79.9356; -2.8715; 35.431; 158.1967];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [25.1683; 10.3291; 12.3124; 20.9256];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_011') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 150, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-69.198; -14.059; 36.6832; 174.8854]; % -42.5876, 7.008, 96, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [19.0461; 17.0138; 18.682; 145.5442];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 100;
patientSettings('EORTCRSRC_012') = myStruct('prior', thisPrior);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-75.9304; -19.6986; 25.9365; 246.0746];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.0666; 13.1486; 13.789; 161.3866];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_014') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

patientSettings('EORTCRSRC_015') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_017') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-73.5898; -5.4627; 25.811; 156.9792];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [21.4125; 10.7914; 9.6864; 31.8575];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_018') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 500, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-73.6176; -22.3827; 34.1963; 104.6551];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [9.5911; 16.6005; 14.726; 5.9578];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_020') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-76.7896; -38.5341; 43.2741; 500];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [5.5009; 23.7905; 9.2927; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_022') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_023') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_025') = myStruct('prior', eortcDefaultPrior, 'all_welldiff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-79.0226; -39.2503; 13.2262; 500]; % -52.2912, -25.3368, 139.6228, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [16.7101; 12.5384; 15.5592; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_030') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-69.6385; -22.7353; 35.6643; 137.6]; % -49.6496, 2.6956, 123.45, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.6085; 20.9641; 24.0132; 6.5334];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_035') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_040') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_042') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
% thisPrior.mu_mu = [-79.1033; -30.6813; 70.0688; 218.8389]; % -58.76, 0, 125.6064, 148.248
% thisPrior.mu_sigma(1:4) = 0.001^2;
% thisPrior.sigma_mu = [11.7254; 19.7756; 30.7991; 88.8632];
% thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.mu_mu = [-75.9915; -11.7912; 72.9099; 198.4493]; % -53.3692, 17.7896, 139.6228, 121.294
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [13.2827; 24.1976; 28.4516; 81.6373];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_045') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200);

patientSettings('EORTCRSRC_051') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

% first edit
% patientSettings('EORTCRSRC_052') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-81.3939; 35.2343; 80.1464; 500]; % -70, 70, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [9.1615; 14.6948; 10.4264; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_052') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-62.8364; -1.1871; 57.0008; 500]; % -27.4932, 24.2588, 176.2804, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [21.139; 17.9038; 12.9577; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_054') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_057') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-96.7709; -30.8586; 42.1231; 500]; % -73.8544, 22.1024, 100, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.7185; 30.7729; 20.6312; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_058') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_059') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-69.9089; -6.8238; 56.8861; 500]; % -40.4312, 24.2588, 173.046, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [20.894; 23.951; 20.3221; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_061') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_063') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_067') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-70.0837; -21.1371; 41.5176; 130.6364]; % -47.9784, 0.5392, 123.45, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.7124; 17.0552; 22.8552; 4.7175];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_069') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-55.213; -14.9166; 19.9916; 500]; % -39.3532, 2.6956, 100, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [12.8601; 13.8687; 11.6131; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_080') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-61.7624; -23.2967; 32.9719; 233.8288]; % -37.5416, -12, 100, 124
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.2904; 8.9198; 17.0773; 131.9475];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 124;
thisPrior.dataPercentileThresholds = [0 99.5];
patientSettings('EORTCRSRC_086') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% patientSettings('EORTCRSRC_087') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; 23.3794; 64.8939; 500]; % -70, 42, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 16.7263; 16.9659; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_087') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-78.195; -0.80243; 75.0509; 500]; % -59.8384, 57.682, 120.2156, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [13.7284; 26.5774; 13.2874; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_089') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 150, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-83.7786; -30.206; 29.4856; 500]; % -59.8384, 5.93, 100, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [16.6688; 21.7036; 14.7924; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_091') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-55.2545; -10.658; 29.1778; 141.1176]; % -28.5716, 3.7736, 130.9972, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.0234; 12.816; 18.6489; 10.5705];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_095') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 400, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_097') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_100') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-84.9215; -23.7182; 60.3557; 201.7308]; % -47.5256, 41.5096, 40.4312, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.093; 21.6161; 15.6427; 158.4979];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_101') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 150);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-78.462; -10.505; 88.1213; 424.8518]; % -46.9004, 26.4152, 169.8112, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.4447; 24.6996; 29.9096; 192.6402];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 100;
patientSettings('EORTCRSRC_111') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_113') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-82.9937; -8.1056; 82.4545; 178.6]; % -38.2748, 84.636, 100, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.8648; 26.548; 18.3323; 96.4479];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 100;
patientSettings('EORTCRSRC_115') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-96.8728; -54.6071; 67.8039; 500]; % -72.7764, 37.1968, 100, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [11.2312; 18.0673; 9.5646; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_117') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% might need dediff mask
thisPrior = defaultPrior;
thisPrior.mu_mu = [-65.3674; -11.6185; 30.1405; 500]; % -40.4312, 12.3988, 100, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.8348; 16.6929; 15.8474; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_123') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_125') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

% first edit
% patientSettings('EORTCRSRC_126') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; 17.0646; 83.0006; 500]; % -70, 50, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 18.7142; 20.6198; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_126') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_127') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-69.6445; -9.7885; 50.6906; 177.7288]; % -37.1968, 15.6336, 148.248, 100
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [19.2548; 18.2631; 22.4026; 27.0516];
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('EORTCRSRC_132') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_138') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-46.3149; -11.6102; 64.9778; 276.5849]; % -28, 5, 120
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [13.0413; 12.7412; 24.1794; 156.7041];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 146;
patientSettings('EORTCRSRC_140') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 5, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-78.975; -7.6785; 65.2234; 500]; % -45, 29, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.2944; 24.8203; 23.5996; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_145') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-73.5548; -7.4305; 35.4261; 344.3276]; % -53, 19, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [16.662; 20.2529; 17.6445; 153.1471];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_150') = myStruct('prior', thisPrior, 'only_probe_dediff', true, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-54.9806; -39.8392; -5.5137; 500]; % -39, -37, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [13.1355; 6.4916; 18.4035; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_153') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 350, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% thisPrior = defaultPrior;
% thisPrior.mu_mu = [-92.0711; -41.0169; 78.1274; 500]; % -80, 9, 147
% thisPrior.mu_sigma(1:4) = 0.001^2;
% thisPrior.sigma_mu = [9.8438; 24.8112; 53.6166; 1];
% thisPrior.sigma_cov(1:4) = 0.0001;
% thisPrior.calcificationThreshold = 200;
% patientSettings('EORTCRSRC_155') = myStruct('prior', thisPrior, 'only_probe_dediff', true, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-92.0711; -37.3503; 96.903; 500]; % -80, 29, 147
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [9.8438; 28.0935; 47.7018; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_155') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_158') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; -14.3245; 30.1475; 500]; % -130, 10, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 18.3693; 17.6804; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_160') = myStruct('prior', thisPrior, 'number_largest_dediff', 1, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-75.1822; -14.6513; 44.2986; 513.5341]; % -35, 6, 103
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [46.8855; 19.9106; 25.8434; 323.0019];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 130;
patientSettings('EORTCRSRC_170') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-59.7238; -1.4235; 69.1955; 500]; % -30, 42, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [19.0854; 23.0525; 15.9473; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_179') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-72.7533; -11.9668; 57.7488; 500]; % -40, 30, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.1493; 21.3459; 21.3847; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_181') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_188') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_190') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

patientSettings('EORTCRSRC_191') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-68.0566; -24.7724; 27.7042; 500]; % -40, -10, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.3691; 11.7769; 14.3023; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_192') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 250, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-83.3766; -26.1281; 33.8467; 500]; % -50, 10, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.6899; 18.9437; 22.1986; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_195') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-74.6153; -21.4386; 34.8376; 500]; % -54, 10, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.6215; 20.048; 17.6235; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_210') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; -54.05; 44.7001; 157.1973]; % -70, -39, 90
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 8.5394; 22.4168; 58.1305];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 120;
patientSettings('EORTCRSRC_214') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% patientSettings('EORTCRSRC_219') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; 31.3421; 82.0635; 500]; % -70, 48, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 16.5488; 19.2166; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_219') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 300, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);


thisPrior = defaultPrior;
thisPrior.mu_mu = [-75.5476; -25.6498; 30.8634; 500]; % -40, -10, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [17.4682; 13.1833; 16.8294; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_221') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% thisPrior = defaultPrior;
% thisPrior.mu_mu = [-35.0728; -20.2604; 35.89; 500]; % -19, -18, 150
% thisPrior.mu_sigma(1:4) = 0.001^2;
% thisPrior.sigma_mu = [12.9195; 6.67; 23.6658; 1];
% thisPrior.sigma_cov(1:4) = 0.0001;
% thisPrior.calcificationThreshold = 190;
% patientSettings('EORTCRSRC_223') = myStruct('prior', thisPrior, 'convert_myxoid_to_welldiff', true, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-34.4778; 20.5951; 57.426; 500]; % -18, 36, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [13.0552; 11.8141; 18.9463; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_223') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);


patientSettings('EORTCRSRC_227') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

% first edit
% patientSettings('EORTCRSRC_229') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-94; 24.6707; 57.9056; 500]; % -70, 40, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 15.1258; 14.4429; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_229') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; 29.5017; 76.6594; 500]; % -70, 46, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 10.54; 17.6252; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_230') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_231') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-68.6389; -31.2104; 26.7272; 500]; % -50, -8, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [12.6554; 15.3617; 14.4053; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_235') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-59.1972; -22.2232; 28.7795; 500]; % -48, 1, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [10.4725; 15.9962; 17.6345; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_237') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 400, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);


% first edit
% thisPrior = defaultPrior;
% thisPrior.mu_mu = [-89.7692; -29.0173; 65.2494; 280.6038]; % -70, -10, 150
% thisPrior.mu_sigma(1:4) = 0.001^2;
% thisPrior.sigma_mu = [10.521; 17.6422; 31.4835; 126.4506];
% thisPrior.sigma_cov(1:4) = 0.0001;
% thisPrior.calcificationThreshold = 190;
% patientSettings('EORTCRSRC_239') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-89.7692; 18.3191; 78.6694; 280.6038]; % -70, 44, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [10.521; 23.5702; 21.636; 126.4506];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_239') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% patientSettings('EORTCRSRC_241') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; 70.959; 106.743; 500]; % -70, 90, 190
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [1; 16.2705; 15.2696; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_241') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-57.6398; -5.1522; 45.3402; 500]; % -30, 21, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.7012; 17.3648; 17.265; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_247') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 500);

% first edit
% thisPrior = defaultPrior;
% thisPrior.mu_mu = [-72.561; -56.2941; 27.1238; 193.869]; % -61, -51, 104
% thisPrior.mu_sigma(1:4) = 0.001^2;
% thisPrior.sigma_mu = [7.583; 10.549; 23.0583; 84.4022];
% thisPrior.sigma_cov(1:4) = 0.0001;
% thisPrior.calcificationThreshold = 147;
% patientSettings('EORTCRSRC_249') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-72.6816; 22.4481; 74.4577; 190.2615]; % -61, 56, 104
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [10.4066; 18.1927; 17.8764; 80.7265];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 147;
patientSettings('EORTCRSRC_249') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-61.0248; -9.8106; 35.0375; 500]; % -39, 18, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [19.6227; 22.5988; 19.0402; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_251') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 500, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% patientSettings('EORTCRSRC_252') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-91.3519; 35.9181; 65.9647; 500]; % -70, 51, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [13.3546; 17.0898; 12.1634; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_252') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 500, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% patientSettings('EORTCRSRC_255') = myStruct('prior', eortcDefaultPrior, 'all_dediff', true);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-87.9583; 30.6244; 64.883; 500]; % -70, 48, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.3382; 18.1044; 17.3732; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_255') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-61.9239; -25.8559; 53.5779; 500]; % -29, -24, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [28.1273; 16.5341; 32.6566; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_256') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-71.6305; -33.8015; 53.8713; 500]; % -51, -10, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [12.2891; 14.017; 21.6806; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_259') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

% first edit
% thisPrior = defaultPrior;
% thisPrior.mu_mu = [-32.3266; -14.037; 27.9498; 500]; % -13, -12, 150
% thisPrior.mu_sigma(1:4) = 0.001^2;
% thisPrior.sigma_mu = [16.1593; 7.6035; 17.2268; 1];
% thisPrior.sigma_cov(1:4) = 0.0001;
% thisPrior.calcificationThreshold = 190;
% patientSettings('EORTCRSRC_261') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);
thisPrior = defaultPrior;
thisPrior.mu_mu = [-40.3158; 19.0244; 45.0218; 500]; % -22, 34, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [14.6706; 14.955; 11.299; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_261') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 350, 'minPixelCount_myxoid_hole_fill_per_slice', 350, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('EORTCRSRC_262') = myStruct('prior', eortcDefaultPrior, 'all_welldiff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-57.8761; 21.3329; 75.2264; 500]; % -34, 53, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [15.3298; 26.7185; 15.1999; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_264') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 1000, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-91.4222; -18.0667; 7.4638; 500]; % -20, -19, 150
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu = [18.7518; 8.7527; 17.438; 1];
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 190;
patientSettings('EORTCRSRC_265') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 200);








%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

patientSettings('RMH_RSRC002') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);
patientSettings('RMH_RSRC003') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_myxoid_to_welldiff_per_slice', 400, 'minPixelCount_welldiff_to_myxoid_per_slice', 400);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-90; -57; -16; 50];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [8 11.5 15.5 45].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.sigmaLimits.high(4) = 50^2;
thisPrior.calcificationThreshold = 70;
patientSettings('RMH_RSRC004') = myStruct('prior', thisPrior, 'merge_dediff_myxoid', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 1000, 'highThresholdWellDiffToMyxoid_per_slice',-95, 'merge_dediff_myxoid', true);

patientSettings('RMH_RSRC007') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC008') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'merge_myxoid_dediff', true);
patientSettings('RMH_RSRC012') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_myxoid_to_welldiff_per_slice', 200, 'minPixelCount_welldiff_to_myxoid_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-20; 47; 100; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 11 20 12].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC013') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'convert_welldiff_to_myxoid', true);


patientSettings('RMH_RSRC015') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-43; 6.9; 37; 333];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [14 9.3 12.2 178].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.sigmaLimits.high(4) = 200^2;
thisPrior.calcificationThreshold = 125;
patientSettings('RMH_RSRC016') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100);

patientSettings('RMH_RSRC019') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

patientSettings('RMH_RSRC021') = myStruct('all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-100; 22.3; 44; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 9.4 5.25 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC022') = myStruct('prior', thisPrior, 'convert_welldiff_to_myxoid', true, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'number_largest_dediff', 1);

patientSettings('RMH_RSRC024') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu(4) = 250;
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(4) = 40^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.sigmaLimits.high(4) = 100^2;
thisPrior.dataPercentileThresholds(2) = 100;
thisPrior.calcificationThreshold = 120;
thisPrior.signalHigh = 500;
thisPrior.apply2Dtidying = false;
patientSettings('RMH_RSRC027') = myStruct('only_probe_dediff', true, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-36; 26.3; 53; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [10 10 10 62].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC030') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu(4) = 250;
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(4) = 40^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.sigmaLimits.high(4) = 100^2;
thisPrior.dataPercentileThresholds(2) = 100;
thisPrior.calcificationThreshold = 110;
thisPrior.signalHigh = 500;
patientSettings('RMH_RSRC032') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-20; 21; 52; 225];
thisPrior.mu_sigma(:) = 0.1^2;
thisPrior.sigma_mu(1) = 20^2;
thisPrior.sigma_cov(1) = 0.001;
thisPrior.sigma_mu(4) = 40^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.alpha = 500*[1 1 1 1];
thisPrior.sigmaLimits.high(4) = 100^2;
thisPrior.dediffThresholdFactor = 1000;
thisPrior.dataPercentileThresholds(2) = 100;
thisPrior.calcificationThreshold = 110;
thisPrior.signalHigh = 500;
thisPrior.apply2Dtidying = false;
thisPrior.imageSmoothingWidth = 1;
patientSettings('RMH_RSRC033') = myStruct('merge_myxoid_dediff', true, 'only_probe_dediff', true, 'convert_welldiff_to_myxoid', true, 'number_largest_dediff_and_myxoid', [1 1], 'prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-90; 23; 64; 119];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [2 12 15.7 18].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 132;
patientSettings('RMH_RSRC035') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'convert_welldiff_to_myxoid', true);

patientSettings('RMH_RSRC036') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-42; 7.5; -5000; 241];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [13 24 1 141].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 150;
patientSettings('RMH_RSRC038') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'merge_dediff_myxoid', true);


thisPrior = defaultPrior; 
thisPrior.mu_mu(4) = 250;
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(4) = 40^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.sigmaLimits.high(4) = 100^2;
thisPrior.dataPercentileThresholds(2) = 100;
thisPrior.calcificationThreshold = 120;
thisPrior.signalHigh = 500;
thisPrior.apply2Dtidying = false;
patientSettings('RMH_RSRC039') = myStruct('merge_myxoid_dediff', true, 'only_probe_dediff', true, 'prior', thisPrior);

patientSettings('RMH_RSRC043') = myStruct('all_dediff', true);

patientSettings('RMH_RSRC046') = myStruct('number_largest_dediff_and_myxoid', [1 2], 'minPixelCount_dediff_hole_fill_per_slice', 300, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'highThresholdMyxoidToDeDiff_per_slice', -20);

patientSettings('RMH_RSRC049') = myStruct('minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50);

patientSettings('RMH_RSRC054') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu(2:4) = [14; 55; 250];
thisPrior.mu_sigma(2:4) = 0.1^2;
thisPrior.sigma_mu(2:4) = [25 23 40].^2;
thisPrior.sigma_cov(2:4) = 0.001;
thisPrior.sigmaLimits.high(4) = 100^2;
thisPrior.dataPercentileThresholds(2) = 100;
thisPrior.calcificationThreshold = 120;
thisPrior.signalHigh = 500;
thisPrior.apply2Dtidying = false;
patientSettings('RMH_RSRC055') = myStruct('prior', thisPrior);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-1000; 18.2; 75.7; 1000];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 14 18 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC056') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'convert_welldiff_to_myxoid', true);


thisPrior = defaultPrior; 
thisPrior.mu_mu(2:3) = [20; 100];
patientSettings('RMH_RSRC057') = myStruct('only_probe_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-84; -26; 1000; 2000];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [14.5 18.2 1 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC058') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 500, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'merge_dediff_myxoid', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-59; 21; 1000; 2000];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [18.5 14.2 1 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC062') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'merge_dediff_myxoid', true);

patientSettings('RMH_RSRC063') = myStruct('minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

patientSettings('RMH_RSRC064') = myStruct('all_dediff', true);

patientSettings('RMH_RSRC065') = myStruct('only_probe_dediff', true, 'merge_myxoid_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100);

patientSettings('RMH_RSRC067') = myStruct('only_probe_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

patientSettings('RMH_RSRC069') = myStruct('only_probe_dediff', true, 'minPixelCount_myxoid_to_welldiff_per_slice', 50, 'minPixelCount_welldiff_to_myxoid_per_slice', 50);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-150; 18; 46; 2000];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 6.6 10.6 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC070') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);

patientSettings('RMH_RSRC073') = myStruct('only_probe_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 50, 'minPixelCount_dediff_hole_fill_per_slice', 50, 'minPixelCount_myxoid_hole_fill_per_slice', 50);

% myxoid throughout
% patientSettings('RMH_RSRC074') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-200; 24.7; 53.4; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 11.2 7.2 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC076') = myStruct('prior', thisPrior, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'convert_welldiff_to_myxoid', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-81; -21; 500; 102];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [15 24 1 20].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC078') = myStruct('prior', thisPrior, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'merge_dediff_myxoid', true);


patientSettings('RMH_RSRC080') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC081') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-200; 38.2; 78.3; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 10.9 14.3 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC082') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);


patientSettings('RMH_RSRC083') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu(1:3) = [-110; -70; -40];
thisPrior.mu_sigma(1:3) = 0.1^2;
thisPrior.sigma_mu(1:3) = 10^2;
thisPrior.sigma_cov(1:3) = 0.001;
patientSettings('RMH_RSRC085') = myStruct('only_probe_dediff', true, 'number_largest_myxoid', 2, 'prior', thisPrior, 'minPixelCount_myxoid_hole_fill_per_slice', 50, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

patientSettings('RMH_RSRC087') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);
patientSettings('RMH_RSRC088') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC089') = myStruct('all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-500; -200; 56; 391];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 1 15.5 314].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.sigmaLimits.high(4) = 500^2;
thisPrior.calcificationThreshold = 140;
patientSettings('RMH_RSRC091') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice_including_calcif', 50); %, 'merge_dediff_myxoid', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 1000, 'highThresholdWellDiffToMyxoid_per_slice',-95, 'merge_dediff_myxoid', true);


thisPrior = defaultPrior;
thisPrior.mu_mu(2) = -70;
thisPrior.mu_sigma(2) = 0.1^2;
thisPrior.sigma_mu(2) = 20^2;
thisPrior.sigma_cov(2) = 0.001;
patientSettings('RMH_RSRC092') = myStruct('only_probe_dediff', true, 'number_largest_myxoid', 4, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);


patientSettings('RMH_RSRC094') = myStruct('all_dediff', true);


patientSettings('RMH_RSRC095') = myStruct('convert_myxoid_to_dediff', true, 'only_probe_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 400);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-100; 37.9; 70.6; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 10.3 14.3 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC096') = myStruct('prior', thisPrior, 'convert_welldiff_to_myxoid', true, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200); %, 'number_largest_dediff', 1);


patientSettings('RMH_RSRC097') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-42; -7.4; 200; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [14 10.7 1 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC098') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'merge_dediff_myxoid', true);

patientSettings('RMH_RSRC099') = myStruct('merge_myxoid_dediff', true, 'number_largest_dediff', 2, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 400, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu(1:2) = [-81; -50];
thisPrior.mu_sigma(1:2) = 0.1^2;
thisPrior.sigma_mu(1:2) = [13 40].^2;
thisPrior.sigma_cov(1:2) = 0.001;
thisPrior.alpha(1:4) = [10000 1 1 1];
thisPrior.apply2Dtidying = false;
thisPrior.imageSmoothingWidth = 1.5;
patientSettings('RMH_RSRC101') = myStruct('number_largest_dediff', 2, 'minPixelCount_welldiff_to_myxoid_per_slice', 13^2, 'minPixelCount_welldiff_hole_fill_per_slice', 13^2, 'maxImageValue_welldiff', -75, 'prior', thisPrior);

patientSettings('RMH_RSRC104') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC106') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_myxoid_to_welldiff_per_slice', 200, 'minPixelCount_welldiff_to_myxoid_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-200; 22.7; 72.3; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 9.7 16.5 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC109') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);

patientSettings('RMH_RSRC111') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-200; 34.5; 86.2; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 18.5 16.7 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC112') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);

patientSettings('RMH_RSRC114') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 500, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_dediff_to_myxoid_per_slice', 200);

patientSettings('RMH_RSRC120') = myStruct('minPixelCount_myxoid_to_dediff_per_slice', 80);

patientSettings('RMH_RSRC121') = myStruct('exact_probe_dediff_no_myxoid', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-60; 2.9; 200; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [19.7 14.3 1 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC122') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'merge_dediff_myxoid', true);

thisPrior = defaultPrior; 
thisPrior.sigma_mu(1:2) = 8^2;
thisPrior.sigma_cov(1:2) = 0.005;
patientSettings('RMH_RSRC125') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu(2:3) = [-30; 10];
thisPrior.mu_sigma(2:3) = 0.1^2;
thisPrior.sigma_mu(2:3) = 10^2;
thisPrior.sigma_cov(2:3) = 0.005;
thisPrior.alpha(1:4) = [1 2000 1 1];
patientSettings('RMH_RSRC129') = myStruct('only_probe_dediff', true, 'number_largest_dediff_and_myxoid', [1 3], 'prior', thisPrior);


patientSettings('RMH_RSRC130') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC131') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-200; 46.9; 82.4; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 14.5 12.5 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC132') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-200; 24.5; 103; 250];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 11.3 24.6 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC133') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);

patientSettings('RMH_RSRC134') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC135') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-28; 17; 53; 205];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [21 7 13 170].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.sigmaLimits.high(4) = 500^2;
thisPrior.calcificationThreshold = 100;
patientSettings('RMH_RSRC136') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'minPixelCount_dediff_hole_fill_per_slice', 200);


thisPrior = defaultPrior; 
thisPrior.mu_mu = [-82; -37; -1000; 180];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [12.8 18.6 1 130].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.calcificationThreshold = 120;
patientSettings('RMH_RSRC137') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice_including_calcif', 400, 'minPixelCount_myxoid_hole_fill_per_slice_including_calcif', 400, 'merge_dediff_myxoid', true);

patientSettings('RMH_RSRC139') = myStruct('all_dediff', true);

patientSettings('RMH_RSRC143') = myStruct('merge_myxoid_dediff', true, 'number_largest_dediff', 2, 'convert_myxoid_to_welldiff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_welldiff_hole_fill_per_slice', 200);
patientSettings('RMH_RSRC144') = myStruct('all_dediff', true);

patientSettings('RMH_RSRC145') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-150; 33; 87; 2000];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 12.6 18.6 1].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC149') = myStruct('prior', thisPrior, 'minPixelCount_dediff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'convert_welldiff_to_myxoid', true);

patientSettings('RMH_RSRC150') = myStruct('exact_probe_dediff_no_myxoid', true);

patientSettings('RMH_RSRC152') = myStruct('minPixelCount_myxoid_to_welldiff_per_slice', 400);
patientSettings('RMH_RSRC153') = myStruct('minPixelCount_myxoid_to_welldiff_per_slice', 400, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior; 
thisPrior.sigma_mu(2:3) = [5 10].^2;
thisPrior.sigma_cov(2:3) = 0.001;
thisPrior.alpha(1:4) = [1 1 2000 1];
patientSettings('RMH_RSRC154') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'exact_probe_dediff', true, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 500, 'minPixelCount_myxoid_hole_fill_per_slice', 500);

patientSettings('RMH_RSRC155') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 200);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-100; -40; 39; 150];
thisPrior.mu_sigma(1:4) = 0.1^2;
thisPrior.sigma_mu([3 4]) = [20 30].^2;
thisPrior.sigma_cov(3:4) = 0.001;
thisPrior.alpha(1:4) = [1 1 5000 50000];
thisPrior.calcificationThreshold = 80;
patientSettings('RMH_RSRC156') = myStruct('merge_myxoid_dediff', true, 'prior', thisPrior);


thisPrior = defaultPrior; 
thisPrior.mu_mu = [-80; 0; 80; 250];
thisPrior.mu_sigma(1:4) = 0.1^2;
thisPrior.sigma_mu(1:4) = [30 16 16 40].^2;
thisPrior.sigma_cov(1:4) = 0.001;
thisPrior.alpha(1:4) = 10000;
thisPrior.sigmaLimits.high(4) = 101^2;
thisPrior.calcificationThreshold = 180;
thisPrior.removeOnlyJustConnectedComponents = false;
patientSettings('RMH_RSRC157') = myStruct('merge_myxoid_dediff', true, 'prior', thisPrior);

patientSettings('RMH_RSRC159') = myStruct('all_dediff', true);

patientSettings('RMH_RSRC160') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC162') = myStruct('all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-55; -3.3; 54; 150];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [16 15 12 54].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC164') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100);

patientSettings('RMH_RSRC166') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 150, 'minPixelCount_myxoid_hole_fill_per_slice', 50);
patientSettings('RMH_RSRC169') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-80; 10; 90; 190];
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(4) = 10^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.alpha(1:4) = [1 1 1 1000];
thisPrior.calcificationThreshold = 120;
patientSettings('RMH_RSRC170') = myStruct('number_largest_dediff', 1, 'prior', thisPrior);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-100; 41; 74; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [1 14 11.5 12].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC171') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'convert_welldiff_to_myxoid', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-96; -24; 31; 300];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [15 12 16.5 245].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
thisPrior.sigmaLimits.high(4) = 500^2;
thisPrior.calcificationThreshold = 70;
patientSettings('RMH_RSRC172') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 50);


thisPrior = defaultPrior;
thisPrior.mu_mu = [-40; 7.9; 150; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [11 19 2 2].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC174') = myStruct('prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 100, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'highThresholdWellDiffToMyxoid_per_slice', -40, 'merge_dediff_myxoid', true);

patientSettings('RMH_RSRC175') = myStruct('all_dediff', true);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-62; -7.5; 47; 200];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [17.5 17.7 19.5 2].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC176') = myStruct('prior', thisPrior, 'number_largest_dediff', 3, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'merge_dediff_myxoid', true);



thisPrior = defaultPrior; 
thisPrior.mu_mu = [-80; -30; 21.7; 160];
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(3:4) = [12 30].^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.alpha(1:4) = [1 1 1 1000];
thisPrior.dediffThresholdFactor = 1.8;
patientSettings('RMH_RSRC177') = myStruct('number_largest_dediff', 2, 'lowThresholdMyxoidToWellDiff', -30, 'minPixelCount_welldiff_hole_fill_per_slice', 1000, 'minPixelCount_myxoid_hole_fill_per_slice', 200, 'prior', thisPrior);

patientSettings('RMH_RSRC178') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

% thisPrior = defaultPrior; 
% thisPrior.sigma_mu(2:3) = [5 10].^2;
% thisPrior.sigma_cov(2:3) = 0.001;
% thisPrior.alpha(1:4) = [1 1 2000 1];
% patientSettings('RMH_RSRC179') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'convert_welldiff_to_myxoid', true, 'prior', thisPrior);
patientSettings('RMH_RSRC179') = myStruct('exact_probe_dediff_no_well_diff', true);

patientSettings('RMH_RSRC181') = myStruct('only_probe_dediff', true, 'merge_myxoid_dediff', true, 'minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

patientSettings('RMH_RSRC182') = myStruct('minPixelCount_dediff_hole_fill_per_slice', 100, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);

thisPrior = defaultPrior;
thisPrior.mu_mu = [-70; -30; 21; 150];
thisPrior.mu_sigma(1:4) = 0.001^2;
thisPrior.sigma_mu(:) = [9.6 15.5 10 54].^2;
thisPrior.sigma_cov(1:4) = 0.0001;
patientSettings('RMH_RSRC185') = myStruct('prior', thisPrior, 'minPixelCount_myxoid_hole_fill_per_slice', 100, 'minPixelCount_dediff_hole_fill_per_slice', 200);


patientSettings('RMH_RSRC186') = myStruct('all_dediff', true);


% default settings for patients not set specifically
patientsToAdd = setdiff(allPatientIDs, patientSettings.keys);
for m = 1:length(patientsToAdd)
    patientSettings(patientsToAdd{m}) = myStruct();
end

    function s = myStruct(varargin)

        % fill in specified fields
        if nargin>0
            s = struct(varargin{1}, varargin{2});
            for mm = 3:2:length(varargin)
                s.(varargin{mm}) = varargin{mm+1};
            end
        else
            s = struct();
        end

        % fill in other fields with default values
        allFields = {'only_probe_dediff', ...
                     'exact_probe_dediff_no_well_diff', ...
                     'exact_probe_dediff', ...
                     'exact_probe_dediff_no_myxoid', ...
                     'fill_dediff', ...
                     'number_largest_dediff', ...
                     'merge_myxoid_dediff', ...
                     'merge_dediff_myxoid', ...
                     'convert_myxoid_to_dediff', ...
                     'convert_myxoid_to_welldiff', ...
                     'all_dediff', ...
                     'all_welldiff', ...
                     'convert_welldiff_to_myxoid', ...
                     'number_largest_dediff_and_myxoid', ...
                     'number_largest_myxoid', ...
                     'minPixelCount_dediff_to_myxoid_per_slice', ...
                     'minPixelCount_welldiff_to_myxoid_per_slice', ...
                     'minPixelCount_myxoid_to_welldiff_per_slice', ...
                     'minPixelCount_myxoid_to_dediff_per_slice', ...
                     'minPixelCount_welldiff_hole_fill_per_slice', ...
                     'minPixelCount_dediff_hole_fill_per_slice', ...
                     'minPixelCount_myxoid_hole_fill_per_slice', ...
                     'minPixelCount_myxoid_hole_fill_per_slice_including_calcif', ...
                     'minPixelCount_welldiff_hole_fill_per_slice_including_calcif', ...
                     'minPixelCount_dediff_hole_fill_per_slice_including_calcif', ...
                     'minPixelCount_calc_to_dediff_per_slice', ...
                     'maxImageValue_welldiff', ...
                     'lowThresholdMyxoidToWellDiff', ...
                     'highThresholdMyxoidToDeDiff_per_slice', ...
                     'highThresholdWellDiffToMyxoid_per_slice', ...
                     'lowThresholdDediffToMyxoid', ...
                     'lowThresholdCalcToDediff', ...
                     'calcificationSliceRange'};
        for mm = 1:length(allFields)
            if ~isfield(s,allFields{mm})
                s.(allFields{mm})= false;
            end
        end

        if ~isfield(s, 'prior')
            s.prior = defaultPrior;
        end

    end

end