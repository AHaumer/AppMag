function pltRes(par)
% -----------------------------------------------------------------------
% Purpose: Plot results
% Input  : parameter struct par
% Output : figures
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    Hmin=min(min(par.HD),0);
    Hmax=max(max(par.HD),50000);
    Np=10000; % number of points
    H=linspace(Hmin,Hmax,Np);
    ND=length(par.HD);
% pre-allocate result vectors to increase speed
    J=zeros(Np,1); mu_r=zeros(Np,1); mu_rd=zeros(Np,1);
    for kp=1:Np
        J(kp)=app_J(par, H(kp));
        mu_rd(kp)=app_mu_rd(par, H(kp));
        mu_r(kp) =fun_mu_r(J(kp),H(kp),par.mu_ri);
    end
% J(H)
    figure;
    semilogx(H(2:Np), J(2:Np), 'b-'); hold on;
    semilogx(par.HD(2:ND), par.JD(2:ND), 'ro');
    title(par.material); grid on;
    xlabel("H [A/m]"); ylabel("J [T]");
    legend('J(H)','measured','Location','southeast');
    figure;
    plot(H, J, 'b-'); hold on;
    plot(par.HD, par.JD, 'ro');
    title(par.material); grid on;
    xlabel("H [A/m]"); ylabel("J [T]");
    legend('J(H)','measured','Location','southeast','AutoUpdate','off');
    xlim([0 1000]);
% mu_r(H) and mu_rd(H)
    figure;
    loglog(H(2:Np), mu_r(2:Np), 'b-'); hold on;
    loglog(par.HD(2:ND), par.mu_rD(2:ND), 'ro');
    loglog(H(2:Np), mu_rd(2:Np), 'k--');
    title(par.material); grid on;
    xlabel("H [A/m]"); ylabel("µ_r");
    legend('µ_r(H)','measured','µ_r_d(H)','Location','northeast');
    figure;
    plot(H, mu_r, 'b-'); hold on;
    plot(par.HD, par.mu_rD, 'ro');
    plot(H, mu_rd, 'k--');
    title(par.material); grid on;
    xlabel("H [A/m]"); ylabel("µ_r");
    legend('µ_r(H)','measured','µ_r_d(H)','Location','northeast','AutoUpdate','off');
    xlim([0 500]);
end
