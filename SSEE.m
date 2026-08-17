function par=SSEE(material, varargin)
% -----------------------------------------------------------------------
% Purpose: calculate Smoothing Splines + Exponential Extrapolation
% Input  : material
% optional fT='txt' or 'xlsx' or 'ods' (fileType)
%          p=0.005  smoothing parameter 0<p<1
%          H0=2000 where exponential extrapolation starts
%             check whether a value in HD exists near H0!
%          H1=5000 start of switch-over from SS to EE
%          H2=20000 end  of switch-over from SS to EE
% Output:  struct par with parameters
% For information on contents of par see function savPar.
% Additional (not used in savPar):
%   dpp (struct of differentiated splines), mu_rD
%   H, J, B and mu_rMax at inflection point of J(H)
% Author : A. Haumer
% Date   : 2026-08-15
% -----------------------------------------------------------------------
    addpath('functions');
    rawData='rawData/';
    par=struct([]);
% handling of optional input arguments
    fT='txt';
    p =0.005; H0=2000;
    H1= 5000; H2=20000;
    if nargin>=2
        fT=varargin{1};
    end
    if nargin>=3
        p =varargin{2};
    end
    if nargin>=4
        H0=varargin{3};
    end
    if nargin>=5
        H1=varargin{4};
    end
    if nargin>=6
        H2=varargin{5};
    end
    disp(material);
    dispVal("p =", p ); dispVal("H0=", H0);
    dispVal("H1=", H1); dispVal("H2=", H2);
% define constants
    mu_0=4e-7*pi;
    isOctave=exist("OCTAVE_VERSION","builtin")>0;
    if isOctave
        pkg load splines;
        pkg load io;
    end
% read RawData
    if strcmp(fT,"xlsx") || strcmp(fT,"ods")
        fileName=[rawData 'RD' '.' fT];
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
        fileName=[rawData 'RD_' material '.txt'];
        if exist(fileName,'file')~=2
            disp([fileName ' does not exist!']); return;
        else
            par=read_txt(fileName);
        end
    end
    par.material=material;
% smoothed spline interpolation
    par.pp=csaps(par.HD,par.JD,p);
    par.dpp=fnder(par.pp);
% correct all constant coefficients: shift characteristic to hit origin!
% calculate mu_ri and mu_r (of raw data)
    if isOctave
        dJ=par.pp.coefs(2,4)-par.JD(1);
        par.mu_ri=1+par.pp.coefs(2,3)/mu_0; dispVal("µ_ri=", par.mu_ri);
    else
        dJ=par.pp.coefs(1,4)-par.JD(1);
        par.mu_ri=1+par.pp.coefs(1,3)/mu_0; dispVal("µ_ri=", par.mu_ri);
    end
    par.pp.coefs(:,4)=par.pp.coefs(:,4)-ones(size(par.pp.coefs,1),1)*dJ;
    for kp=1:length(par.HD)
        par.mu_rD(kp,1) =fun_mu_r(par.JD(kp),par.HD(kp),par.mu_ri);
    end
% search for grid point near H0
    [~, par.k0]=min(abs(par.HD-H0));
    par.hH1=H1; par.hH2=H2;
% determine optimal exponential extrapolation
    obj = @(x)funObjEE(x, par);
    x0=[2, 1]; % scaling x=[Jsat, Hpar/10000]
    [x,fval]=fminunc(obj, x0);
    dispVal("fminunc: fval=",fval);
    par.Jsat=x(1);       dispVal("Jsat=", par.Jsat);
    par.Hpar=x(2)*10000; dispVal("Hpar=", par.Hpar);
% Hsat to approach "near" Jsat (with 1 ppm deviation)
    par.Hsat=par.HD(par.k0)-par.Hpar*log(1e-6*par.Jsat/ ...
        (par.Jsat-par.JD(par.k0)));
% plot and save result
    pltRes(par);
% show inflection point of J(H): mu_rd - mu_r = d mu_r/dH * H = 0
    q='Is the inflection point of J(H) = the maximum of mu_r present ?';
    choice=menu(q,'yes','no');
    if choice==1
        fun = @(H)(fnval(par.pp,H)/H-fnval(par.dpp,H));
        par.H_muMax=fzero(fun,[0.1*par.HD(2),par.HD(par.k0)]);
        par.J_muMax=app_J(par, par.H_muMax);
        par.B_muMax=mu_0*par.H_muMax+par.J_muMax;
        par.mu_rMax=par.B_muMax/(mu_0*par.H_muMax);
        disp('Inflection point of J(H) = maximum of mu_r(H):');
        dispVal('H_muMax=',par.H_muMax);
        dispVal('B_muMax=',par.B_muMax);
        dispVal('mu_rMax=',par.mu_rMax);
        figure(2); plot([0,par.H_muMax],[0,par.J_muMax], 'r-.');
        figure(4); plot([par.H_muMax,par.H_muMax],[0,par.mu_rMax],'r-.');
    end
% Octave shows additional points at the beginning and at the end!
    if isOctave
        par.pp=corOct(par.pp); par.dpp=corOct(par.dpp);
    end
    savPar(par);
end