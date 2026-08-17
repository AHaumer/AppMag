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
    par=struct([]);
    choice=menu('Is the maximum of mu_r represented in measured data?','yes','no');
    if choice~=1
        disp('The formula of Roschke requires the representation of mu_rMax');
        return;
    end
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
% correct all constant coefficients: shift characteristic to hit origin
    if isOctave
        dJ=pp.coefs(2,4)-par.JD(1);
    else
        dJ=pp.coefs(1,4)-par.JD(1);
    end
    pp.coefs(:,4)=pp.coefs(:,4)-ones(size(pp.coefs,1),1)*dJ;
% inflection point of J(H): mu_rd - mu_r = d mu_r/dH * H = 0
    fun = @(H)(fnval(pp,H)/H-fnval(dpp,H));
    par.H_muMax=fzero(fun,[0.1*par.HD(2) par.HD(end)]);
    par.J_muMax=fnval(pp, par.H_muMax);
    par.B_muMax=mu_0*par.H_muMax+par.J_muMax;
    par.mu_rMax=par.B_muMax/(mu_0*par.H_muMax);
    disp('Inflection point of J(H) = maximum of mu_r(H):');
    dispVal('H_muMax=',par.H_muMax);
    dispVal('B_muMax=',par.B_muMax);
    dispVal('mu_rMax=',par.mu_rMax);
% determine Jsat with exponential extrapolation
    H0=2000; par.k0=find(abs(H0-par.HD)<0.01*H0);
    obj = @(x)funObjEE(x, par);
    x0 = [2, 1]; % scaling x=[Jsat, Hpar/10000]
    [x,fval] = fminunc(obj, x0);
    dispVal("fminunc: fval=",fval);
    par.Jsat=x(1);       dispVal("Jsat=", par.Jsat);
%   par.Hpar=x(2)*10000; dispVal("Hpar=", par.Hpar);
% determine optimal Roschke parameters
    par.ca=20000; par.cb=4; par.n=12;
    obj = @(x)funObj(x, par);
    x0=[par.ca/10000, par.cb, par.n]; % scaling
    [x,fval] = fminunc(obj, x0);
    dispVal("fminunc: fval=",fval);
    par.ca=x(1)*10000; dispVal("ca=", par.ca);
    par.cb=x(2);       dispVal("cb=", par.cb);
    par.n =x(3);       dispVal("n =", par.n );
% plot and save result
    pltRes(par);
    savPar(par);
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

function y=funObjEE(x, par)
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
        JApp=par.JD(par.k0)+(par.Jsat-par.JD(par.k0))* ...
            (1-exp(-(par.HD(kd)-par.HD(par.k0))/par.Hpar));
        y = y + (JApp/par.JD(kd)-1)^2;
    end
end

function y=funObj(x, par)
% -----------------------------------------------------------------------
% Purpose: objective function for optimization of Roschke parameters
% Input  : Vector of optimization parameters x, struct par
% Output : objective function value to be minimized
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
par.ca=x(1)*10000; par.cb=x(2); par.n=x(3); % scaling
    mu_0=4e-7*pi;
    y=0;
    for kd = 2:length(par.JD)
        B=par.JD(kd)+mu_0*par.HD(kd);
        HApp=B/(mu_0*app_mu_r(par,B));
        y = y + (HApp/par.HD(kd)-1)^2;
    end
end

function mu_r=app_mu_r(par, B)
% -----------------------------------------------------------------------
% Purpose: Calculate relative permeability (Roschke) from flux dens. B
% Input  : parameter struct par
% Output : mu_r
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    mu_r=1+(par.mu_ri-1+par.ca*B/par.B_muMax)/ ...
        (1+par.cb*B/par.B_muMax+(B/par.B_muMax)^par.n);
end

function pltRes(par)
% -----------------------------------------------------------------------
% Purpose: Plot results
% Input  : parameter struct par
% Output : figures
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    mu_0=4e-7*pi;
    Bmin=min(min(par.JD),0);
    Bmax=max(max(par.JD),par.Jsat);
    Np=10000; % number of points
    B=linspace(Bmin,Bmax,Np);
    ND=length(par.HD);
% pre-allocate result vectors to increase speed
    J=zeros(Np,1); H=zeros(Np,1); mu_r=zeros(Np,1);
    for kp=1:Np
        mu_r(kp)=app_mu_r(par,B(kp));
        H(kp)=B(kp)/(mu_0*mu_r(kp));
        J(kp)=B(kp)-mu_0*H(kp);
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
% mu_r(H)
    figure;
    loglog(H(2:Np), mu_r(2:Np), 'b-'); hold on;
    loglog(par.HD(2:ND), par.mu_rD(2:ND), 'ro');
    title(par.material); grid on;
    xlabel("H [A/m]"); ylabel("µ_r");
    legend('µ_r(H)','measured','Location','northeast');
    figure;
    plot(H, mu_r, 'b-'); hold on;
    plot(par.HD, par.mu_rD, 'ro');
    title(par.material); grid on;
    xlabel("H [A/m]"); ylabel("µ_r");
    legend('µ_r(H)','measured','Location','northeast','AutoUpdate','off');
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
    fprintf(fID, '    label  ="%s",   \n', par.material);
    fprintf(fID, '    mu_i   = %9.2f, \n', par.mu_ri);
    fprintf(fID, '    B_myMax= %9.4f, \n', par.B_muMax);
    fprintf(fID, '    c_a    = %9.1f, \n', par.ca);
    fprintf(fID, '    c_b    = %9.4f, \n', par.cb);
    fprintf(fID, '    n      = %9.4f);\n', par.n);
    fclose(fID);
end