% Bayesian EM fitting function, with special data preparation and prior
% adjustments (if indicated)
function [gmm, prior] = fitBayesianGMM(prior, imHere, maskHere, dediffProbe)

data = imHere(maskHere);

% crop pixels to hard limits to avoid influence of outliers
data = data(data > prior.signalLow);
data = data(data < prior.signalHigh);
pct = prctile(data, prior.dataPercentileThresholds);
data = data(data>=pct(1) & data<=pct(2));

% Use no more than 20000 pixels for the GMM fitting.  This is so that the
% power of the prior is similar for large and small ROIs
data = data(1:ceil(length(data)/20000):end);

% NaNs in the prior stats indicate these values should be set using
% the dediff prob statistics
if isnan(prior.mu_mu(2))
    prior.mu_mu(2) = 0.5*(prior.mu_mu(1) + mean(dediffProbe.pixels));
end
if isnan(prior.mu_mu(3))
    prior.mu_mu(3) = mean(dediffProbe.pixels);
end
if isnan(prior.sigma_mu(3))
    prior.sigma_mu(3) = var(dediffProbe.pixels);
end

% fit Bayesian EMM
gmm = kSeparatePriorsEMfunc(data, prior.mu_mu, prior.mu_sigma, prior.sigma_mu, prior.sigma_cov, prior.alpha, prior.sigmaLimits);

