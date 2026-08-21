function par=showRD(material, varargin)
% -----------------------------------------------------------------------
% Purpose: show Raw Data in figures
% Input  : material
% optional fT='txt' or 'xlsx' or 'ods' (fileType)
% Output:  struct par with parameters
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
% determine mu_ri, then mu_r
    for kp=1:length(par.HD)
        par.mu_rD(kp,1) =fun_mu_r(par.JD(kp),par.HD(kp),app_mu_ri(par));
    end
    fig=pltRes(par, true);
end
