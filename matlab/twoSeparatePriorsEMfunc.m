function out = twoSeparatePriorsEMfunc(X, mu_mu, mu_sigma, sigma_mu, sigma_cov)

alpha = 2 + 1./sigma_cov.^2;
beta = sigma_mu.*(alpha-1);

mu = mu_mu;
sigma = sigma_mu;

tau = [1 1]/2;
T = zeros(size(X,1),2);
for iter = 1:500
    % E-step
    for k = 1:2
        T(:,k) = tau(k)*normpdf(X,mu(k),sqrt(sigma(k)));
    end
    T = T./sum(T,2);
    % M-step
    tau = mean(T);
    for kk = 1:2
        for k = 1:2
            sumT = sum(T(:,k));
            mu(k) = ((T(:,k)'*X)/sigma(k) + mu_mu(k)/mu_sigma(k))/(sumT/sigma(k) + 1/mu_sigma(k));
            s = sqrt(T(:,k)).*(X-mu(k));
            sigma(k) = (s'*s + 2*beta(k))/(sumT + 2*alpha(k) - 2);
            if sigma(k)>25^2
                sigma(k) = 25^2;
            end
            if sigma(k)<10^2
                sigma(k) = 10^2;
            end
            if mu(1)<10
                mu(1)=10;
            end
        end
    end
end
%disp(num2str([mu(:)' sigma(:)']))
%disp(num2str(mu'))
%disp(num2str(sqrt(sigma)))

% make sure tau is not [0 1] or [1 0]
[minTau,idxMin] = min(tau);
tau(idxMin) = minTau+eps;

[maxTau,idxMax] = max(tau);
tau(idxMax) = maxTau-eps;

out = gmdistribution(mu,reshape(sigma,[1 1 2]),tau);
