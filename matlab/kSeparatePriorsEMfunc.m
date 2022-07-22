function out = kSeparatePriorsEMfunc(X, mu_mu, mu_sigma, sigma_mu, sigma_cov, tau_alpha, sigmaLimits)

% set tau_alpha = 1 to revert to MLE version

% convert prior parameters for variance terms into inverse-gamma coefficients
sigma_alpha = 2 + 1./sigma_cov.^2;
sigma_beta = sigma_mu.*(sigma_alpha-1);

% initialise to prior values
mu = mu_mu;
sigma = sigma_mu;

K = length(mu_mu);
N = length(X);

sum_alpha = sum(tau_alpha);

tau = ones(1,K)/K;
T = zeros(size(X,1),K);
for iter = 1:500
    % E-step
    for k = 1:K
        T(:,k) = tau(k)*normpdf(X,mu(k),sqrt(sigma(k)));
    end
    T = T./sum(T,2);
    % M-step
    tau = (sum(T) + tau_alpha - 1)/(sum_alpha - K + N);
    for kk = 1:2
        for k = 1:K
            sumT = sum(T(:,k));
            mu(k) = ((T(:,k)'*X)/sigma(k) + mu_mu(k)/mu_sigma(k))/(sumT/sigma(k) + 1/mu_sigma(k));
            s = sqrt(T(:,k)).*(X-mu(k));
            sigma(k) = (s'*s + 2*sigma_beta(k))/(sumT + 2*sigma_alpha(k) - 2);
            if sigma(k)>sigmaLimits.high(k)
                sigma(k) = sigmaLimits.high(k);
            end
            if sigma(k)<sigmaLimits.low(k)
                sigma(k) = sigmaLimits.low(k);
            end
        end
    end
end
%disp(num2str([mu(:)' sigma(:)']))
%disp(num2str(mu'))
%disp(num2str(sqrt(sigma)))

tau(tau==0) = eps;
tau(tau==1) = 1-eps;
tau = tau/sum(tau);

out = gmdistribution(mu,reshape(sigma,[1 1 K]),tau);
