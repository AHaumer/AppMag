function par=Roschke(material, varargin)
% -----------------------------------------------------------------------
% Purpose: calculate Roschke-Approximation
% Input  : material
% optional fT='txt' or 'xlsx' or 'ods' (fileType)
% Output:  struct par with parameters
% For information on contents of par see function savPar.
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
% handling of optional input arguments
    fT='txt';
    if nargin>=2
        fT=varargin{1};
    end
    disp(material);
% define constants
    mu_0=4e-7*pi;
    isOctave=exist("OCTAVE_VERSION","builtin")>0;
    if isOctave
        pkg load splines;
        pkg load io;
    end
% read RawData
    par=struct([]);
    if strcmp(fT,"xlsx") || strcmp(fT,"ods")
        fileName=['RD' '.' fT];
        if exist(fileName,'file')~=2
            disp([fileName ' does not exist!']); return;
        else
            [~, sheets]=xlsfinfo(fileName);
            if ismember(material, sheets)
                par=read_xls(fileName, material);
            else
                disp([material 'sheet does not exist!']); return;
            end
        end
    else % "txt"
        fileName=['RD_' material '.txt'];
        if exist(fileName,'file')~=2
            disp([fileName ' does not exist!']); return;
        else
            par=read_txt(fileName);
        end
    end
    par.material=material;
% smoothed spline interpolation to calculate mu_ri and B_muMax
    pp=csaps(par.HD,par.JD,0.005);
    dpp=fnder(pp);
    par.mu_ri=1+pp.coefs(1,3)/mu_0; dispVal("µ_ri=", par.mu_ri);
    for kp=1:length(par.HD)
        par.mu_rD(kp,1) =fun_mu_r(par.JD(kp),par.HD(kp),par.mu_ri);
    end
% show inflection point of J(H): mu_rd - mu_r = d mu_r/dH * H = 0
    fun = @(H)(fnval(pp,H)/H-fnval(dpp,H));
    par.H_muMax=fzero(fun,[0.1*par.HD(2) par.HD(end)]);
    par.J_muMax=fnval(pp, par.H_muMax);
    par.B_muMax=mu_0*par.H_muMax+par.J_muMax;
    par.mu_rMax=par.B_muMax/(mu_0*par.H_muMax);
    disp('Inflection point of J(H) = maximum of mu_r(H):');
    dispVal('H_muMax=',par.H_muMax);
    dispVal('B_muMax=',par.B_muMax);
    dispVal('mu_rMax=',par.mu_rMax);
% % determine optimal Roschke parameters
%     obj = @(x)funObj(x, par);
%     x0 = [2, 1]; % scaling x=[Jsat, Hpar/10000]
%     [x,fval] = fminunc(obj, x0);
%     dispVal("fminunc: fval=",fval);
%     par.Jsat=x(1);       dispVal("Jsat=", par.Jsat);
%     par.Hpar=x(2)*10000; dispVal("Hpar=", par.Hpar);
% % plot and save result
%     pltRes(par);
end

function dispVal(s, v)
% displays string s and value v
    disp(strcat(s, mat2str(v)));
end

function mu_r=fun_mu_r(J, H, mu_ri)
% -----------------------------------------------------------------------
% Purpose: Calculate mu_r from J and H
% Input  : polarization J, magnetic field strength H,
%          initial relative permeability mu_ri
% Output : relative permeability mu_r
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    mu_0=4e-7*pi;
    Heps=1e-6; % smallest field strength to protect against division by 0
    if H<=Heps
        mu_r=mu_ri;
    else
        mu_r=1+J/(mu_0*H);
    end
end

function par=read_txt(fileName)
% -----------------------------------------------------------------------
% Purpose: read raw data from txt-file
% Input  : fileName
% Output : struct par
% Mandatory structure of raw data (txt) file:
% #1
% # M330-50A
% # vRef = 3.30
% # Bref = 1.5
% # fRef = 50
% # dens = 7650
% double JH(33, 2)
% 0.000000000	00.00000000
% Important: use the same delimiter '\t' for all lines of data!
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
% get additional scalar parameters to save them later to the parameter file
    fID=fopen(fileName); % skip first 2 lines #1 and # type
    fgetl(fID); fgetl(fID);
    line=fgetl(fID); par.vRef=str2double(line(strfind(line,"=")+1:end));
    line=fgetl(fID); par.BRef=str2double(line(strfind(line,"=")+1:end));
    line=fgetl(fID); par.fRef=str2double(line(strfind(line,"=")+1:end));
    line=fgetl(fID); par.dens=str2double(line(strfind(line,"=")+1:end));
    fclose(fID);
% raw data arrays J and H (ensure that all lines use the same delimiter!)
    if exist("OCTAVE_VERSION","builtin")>0
        RD=dlmread(fileName,'\t',7,0);
    else
        RD=readmatrix(fileName);
    end
    par.HD=RD(:,2); par.JD=RD(:,1);
    dispVal("txt: Lines of raw data=", length(par.HD));
end

function par=read_xls(fileName, material)
% -----------------------------------------------------------------------
% Purpose: read raw data from spreadsheet
% Input  : material -> -> file with raw data fileName / sheet material
% Output : struct par
% Mandatory structure of spreadsheet:
% 1 material name = sheet
% 2 vRef
% 3 BRef
% 4 fRef
% 5 dens
% 6 N = count of data lines
% 7 header: J [T] H [A/m]
% 8         0     0
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    if exist("OCTAVE_VERSION","builtin")>0
% get additional scalar parameters to save them later to the parameter file
        par.vRef=xlsread(fileName,material,'B2:B2');
        par.BRef=xlsread(fileName,material,'B3:B3');
        par.fRef=xlsread(fileName,material,'B4:B4');
        par.dens=xlsread(fileName,material,'B5:B5');
        n=8-1+   xlsread(fileName,material,'B6:B6');
% raw data arrays J and H
        RD=xlsread(fileName,material,['A8:B' mat2str(n)]);
    else
% get additional scalar parameters to save them later to the parameter file
        par.vRef=readmatrix(fileName,'Sheet',material,'Range','B2:B2');
        par.BRef=readmatrix(fileName,'Sheet',material,'Range','B3:B3');
        par.fRef=readmatrix(fileName,'Sheet',material,'Range','B4:B4');
        par.dens=readmatrix(fileName,'Sheet',material,'Range','B5:B5');
        n=8-1+   readmatrix(fileName,'Sheet',material,'Range','B6:B6');
% raw data arrays J and H
        RD=readmatrix(fileName,'Sheet',material,'Range',['A8:B' mat2str(n)]);
    end
    par.HD=RD(:,2); par.JD=RD(:,1);
    dispVal("ods/xls: Lines of raw data=", length(par.HD));
end

function y=funObj(x, par)
% -----------------------------------------------------------------------
% Purpose: objective function for optimization of exp.extrapolation
% Input  : Vector of optimization parameters x, struct par
% Output : objective function value to be minimized
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    par.Jsat=x(1); par.Hpar=x(2)*10000; % scaling
    y=0;
    for kd = par.k0:length(par.HD)
        JApp=appE_J(par, par.HD(kd));
        y = y + (JApp/par.JD(kd)-1)^2;
    end
end

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
    xlim([0 2000]);
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

function savPar(par)
% -----------------------------------------------------------------------
% Purpose: Save parameters to file for copy-paste to Modelica
% Input  : parameter struct par
% Output : file "Par_"par.material".txt"
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    fileName=['Par_' par.material '.txt'];
    fID=fopen(fileName,'w');
    fprintf(fID, '  extends BaseData(\n');
% common parameters
    fprintf(fID, '    Type="%s",\n', par.material);
    fprintf(fID, '    vRef = %9.2f,\n', par.vRef);
    fprintf(fID, '    BRef = %9.5f,\n', par.BRef);
    fprintf(fID, '    fRef = %9.2f,\n', par.fRef);
    fprintf(fID, '    dens = %9.2f,\n', par.dens);
    fprintf(fID, '    mu_ri= %9.2f,\n', par.mu_ri);
% Exponential Extrapolation
    fprintf(fID, '    k0   = %1u,\n',   par.k0);
    fprintf(fID, '    Hpar = %9.2f,\n', par.Hpar);
    fprintf(fID, '    Hsat = %9.1f,\n', par.Hsat);
    fprintf(fID, '    Jsat = %9.5f,\n', par.Jsat);
% Homotopy
    fprintf(fID, '    hH1  = %9.2f,\n', par.hH1);
    fprintf(fID, '    hH2  = %9.2f,\n', par.hH2);
%   length of raw data = 1 + length of interval coefficients
    N=length(par.HD);
    fprintf(fID, '    N    = %1u,\n', N);
% Smoothing Spline coefficients
    for m=1:4
        fprintf(fID, '    c%1u={\n', 4-m);
        kB=1; kE=min(kB+4, N-1);
        while kB<=N-1
            fprintf(fID, '    ');
            for k=kB:kE
                if k==N-1
                    fprintf(fID, '%12.5e},',par.pp.coefs(k,m));
                else
                    fprintf(fID, '%12.5e,' ,par.pp.coefs(k,m));
                end
            end
            fprintf(fID, '\n');
            kB=kE+1; kE=min(kB+4, N-1);
        end
    end
% Raw Data
    fprintf(fID, '    HD={\n');
    kB=1; kE=min(kB+6, N);
    while kB<=N
        fprintf(fID, '    ');
        for k=kB:kE
            if k==N
                fprintf(fID, '%9.2f},',par.HD(k));
            else
                fprintf(fID, '%9.2f,' ,par.HD(k));
            end
        end
        fprintf(fID, '\n');
        kB=kE+1; kE=min(kB+6, N);
    end
    fprintf(fID, '    JD={\n');
    kB=1; kE=min(kB+6, N);
    while kB<=N
        fprintf(fID, '    ');
        for k=kB:kE
            if k==N
                fprintf(fID, '%9.5f});',par.JD(k));
            else
                fprintf(fID, '%9.5f,' ,par.JD(k));
            end
        end
        fprintf(fID, '\n');
        kB=kE+1; kE=min(kB+6, N);
    end
    fclose(fID);
end