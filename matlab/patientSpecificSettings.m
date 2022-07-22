function patientSettings = patientSpecificSettings(allPatientIDs, defaultPrior)

patientSettings = containers.Map;

patientSettings('RMH_RSRC002') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC007') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC008') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'merge_myxoid_dediff', true);
patientSettings('RMH_RSRC015') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC019') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC021') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC024') = myStruct('only_probe_dediff', true, 'fill_dediff', true);

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
patientSettings('RMH_RSRC027') = myStruct('only_probe_dediff', true, 'prior', thisPrior);

thisPrior = defaultPrior; 
thisPrior.mu_mu(4) = 250;
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(4) = 40^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.sigmaLimits.high(4) = 100^2;
thisPrior.dataPercentileThresholds(2) = 100;
thisPrior.calcificationThreshold = 110;
thisPrior.signalHigh = 500;
patientSettings('RMH_RSRC032') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'prior', thisPrior);

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
patientSettings('RMH_RSRC033') = myStruct('merge_myxoid_dediff', true, 'only_probe_dediff', true, 'convert_welldiff_to_myxoid', true, 'number_largest_dediff_and_myxoid', [1 1], 'prior', thisPrior);

patientSettings('RMH_RSRC036') = myStruct('only_probe_dediff', true, 'fill_dediff', true);

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

patientSettings('RMH_RSRC046') = myStruct('number_largest_dediff_and_myxoid', [1 2]);

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
thisPrior.mu_mu(2:3) = [20; 100];
patientSettings('RMH_RSRC057') = myStruct('number_largest_dediff_and_myxoid', [1 2]);

patientSettings('RMH_RSRC064') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC065') = myStruct('only_probe_dediff', true, 'merge_myxoid_dediff', true);
patientSettings('RMH_RSRC080') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC081') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC083') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu(1:3) = [-110; -70; -40];
thisPrior.mu_sigma(1:3) = 0.1^2;
thisPrior.sigma_mu(1:3) = 10^2;
thisPrior.sigma_cov(1:3) = 0.001;
patientSettings('RMH_RSRC085') = myStruct('only_probe_dediff', true, 'number_largest_myxoid', 2, 'prior', thisPrior);

patientSettings('RMH_RSRC087') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC088') = myStruct('only_probe_dediff', true, 'fill_dediff', true);

% try two versions for this one
thisPrior = defaultPrior;
thisPrior.mu_mu(2) = -70;
thisPrior.mu_sigma(2) = 0.1^2;
thisPrior.sigma_mu(2) = 20^2;
thisPrior.sigma_cov(2) = 0.001;
patientSettings('RMH_RSRC092') = [myStruct('only_probe_dediff', true, 'convert_myxoid_to_welldiff', true);
                                  myStruct('only_probe_dediff', true, 'number_largest_myxoid', 4, 'prior', thisPrior)];

patientSettings('RMH_RSRC094') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC096') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC097') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC099') = myStruct('merge_myxoid_dediff', true, 'number_largest_dediff', 2, 'fill_dediff', true);

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
patientSettings('RMH_RSRC111') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.sigma_mu(1:2) = 8^2;
thisPrior.sigma_cov(1:2) = 0.005;
patientSettings('RMH_RSRC125') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'prior', thisPrior);

thisPrior = defaultPrior; 
thisPrior.mu_mu(2:3) = [-30; 10];
thisPrior.mu_sigma(2:3) = 0.1^2;
thisPrior.sigma_mu(2:3) = 10^2;
thisPrior.sigma_cov(2:3) = 0.005;
thisPrior.alpha(1:4) = [1 2000 1 1];
patientSettings('RMH_RSRC129') = myStruct('only_probe_dediff', true, 'number_largest_dediff_and_myxoid', [1 3], 'prior', thisPrior);


patientSettings('RMH_RSRC131') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC134') = myStruct('all_dediff', true);
patientSettings('RMH_RSRC135') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC139') = myStruct('all_dediff', true);

patientSettings('RMH_RSRC143') = myStruct('merge_myxoid_dediff', true, 'number_largest_dediff', 2, 'convert_myxoid_to_welldiff', true, 'minPixelCount_welldiff_hole_fill_per_slice', 50);

thisPrior = defaultPrior; 
thisPrior.sigma_mu(2:3) = [5 10].^2;
thisPrior.sigma_cov(2:3) = 0.001;
thisPrior.alpha(1:4) = [1 1 2000 1];
patientSettings('RMH_RSRC154') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'convert_welldiff_to_myxoid', true, 'prior', thisPrior);

patientSettings('RMH_RSRC155') = myStruct('only_probe_dediff', true, 'fill_dediff', true);

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
patientSettings('RMH_RSRC166') = myStruct('only_probe_dediff', true, 'fill_dediff', true);
patientSettings('RMH_RSRC169') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-80; 10; 90; 190];
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(4) = 10^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.alpha(1:4) = [1 1 1 1000];
thisPrior.calcificationThreshold = 120;
patientSettings('RMH_RSRC170') = myStruct('number_largest_dediff', 1, 'prior', thisPrior);

patientSettings('RMH_RSRC175') = myStruct('all_dediff', true);

thisPrior = defaultPrior; 
thisPrior.mu_mu = [-80; -30; 21.7; 160];
thisPrior.mu_sigma(4) = 0.1^2;
thisPrior.sigma_mu(3:4) = [12 30].^2;
thisPrior.sigma_cov(4) = 0.001;
thisPrior.alpha(1:4) = [1 1 1 1000];
thisPrior.dediffThresholdFactor = 1.8;
patientSettings('RMH_RSRC177') = myStruct('number_largest_dediff', 2, 'lowThresholdMyxoidToWellDiff', -30, 'minPixelCount_welldiff_hole_fill_per_slice', 70, 'prior', thisPrior);

patientSettings('RMH_RSRC178') = myStruct('only_probe_dediff', true, 'fill_dediff', true);

thisPrior = defaultPrior; 
thisPrior.sigma_mu(2:3) = [5 10].^2;
thisPrior.sigma_cov(2:3) = 0.001;
thisPrior.alpha(1:4) = [1 1 2000 1];
patientSettings('RMH_RSRC179') = myStruct('only_probe_dediff', true, 'fill_dediff', true, 'convert_welldiff_to_myxoid', true, 'prior', thisPrior);

patientSettings('RMH_RSRC181') = myStruct('only_probe_dediff', true, 'merge_myxoid_dediff', true);




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
                     'fill_dediff', ...
                     'number_largest_dediff', ...
                     'merge_myxoid_dediff', ...
                     'convert_myxoid_to_welldiff', ...
                     'all_dediff', ...
                     'convert_welldiff_to_myxoid', ...
                     'number_largest_dediff_and_myxoid', ...
                     'number_largest_myxoid', ...
                     'minPixelCount_welldiff_to_myxoid_per_slice', ...
                     'minPixelCount_welldiff_hole_fill_per_slice', ...
                     'maxImageValue_welldiff', ...
                     'lowThresholdMyxoidToWellDiff', ...
                     'lowThresholdDediffToMyxoid'};
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