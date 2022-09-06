function patientSettings = patientSpecificSettings(allPatientIDs, defaultPrior)

patientSettings = containers.Map;

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

% try two versions for this one
thisPrior = defaultPrior;
thisPrior.mu_mu(2) = -70;
thisPrior.mu_sigma(2) = 0.1^2;
thisPrior.sigma_mu(2) = 20^2;
thisPrior.sigma_cov(2) = 0.001;
%patientSettings('RMH_RSRC092') = myStruct('only_probe_dediff', true, 'convert_myxoid_to_welldiff', true);
patientSettings('RMH_RSRC092') = myStruct('only_probe_dediff', true, 'number_largest_myxoid', 4, 'prior', thisPrior, 'minPixelCount_welldiff_hole_fill_per_slice', 200, 'minPixelCount_myxoid_hole_fill_per_slice', 200);


patientSettings('RMH_RSRC094') = myStruct('all_dediff', true);


% thisPrior = defaultPrior;
% thisPrior.mu_mu(1) = -70;
% thisPrior.mu_mu(2) = -20;
% thisPrior.mu_mu(3) = 0;
% thisPrior.mu_sigma(1:3) = 0.1^2;
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
                     'maxImageValue_welldiff', ...
                     'lowThresholdMyxoidToWellDiff', ...
                     'highThresholdMyxoidToDeDiff_per_slice', ...
                     'highThresholdWellDiffToMyxoid_per_slice', ...
                     'lowThresholdDediffToMyxoid', ...
                     'lowThresholdCalcToDediff'};
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