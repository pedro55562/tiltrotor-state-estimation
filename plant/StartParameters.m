
load(fullfile(fileparts(mfilename('fullpath')), 'VetAlphaT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetBetaT.txt'));

%Logitudinal
load(fullfile(fileparts(mfilename('fullpath')), 'VetCLwT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCLtT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCLfT.txt'));

load(fullfile(fileparts(mfilename('fullpath')), 'VetCDwxzT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCDtxzT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCDfxzT.txt'));

load(fullfile(fileparts(mfilename('fullpath')), 'VetCMwT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCMtT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCMfT.txt'));

%lateral
load(fullfile(fileparts(mfilename('fullpath')), 'VetCYwT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCYtT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCYfT.txt'));

load(fullfile(fileparts(mfilename('fullpath')), 'VetCDwxyT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCDtxyT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCDfxyT.txt'));

load(fullfile(fileparts(mfilename('fullpath')), 'VetCNwT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCNtT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCNfT.txt'));

%interference
load(fullfile(fileparts(mfilename('fullpath')), 'VetCLiT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCDixzT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCMiT.txt'));

load(fullfile(fileparts(mfilename('fullpath')), 'VetCYiT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCDixyT.txt'));
load(fullfile(fileparts(mfilename('fullpath')), 'VetCNiT.txt'));

global VetAlpha VetBeta VetCLw VetCLt VetCLf VetCDwxz VetCDtxz VetCDfxz VetCYw
global VetCYt VetCYf VetCDwxy VetCDtxy VetCDfxy VetCLi VetCDixz VetCMi VetCYi
global VetCDixy VetCNi VetCMw VetCMt VetCMf VetCNw VetCNt VetCNf

VetAlpha = VetAlphaT;
VetBeta = VetBetaT;

%Logitudinal
VetCLw = VetCLwT;
VetCLt = VetCLtT;
VetCLf = VetCLfT;

VetCDwxz = VetCDwxzT;
VetCDtxz = VetCDtxzT;
VetCDfxz = VetCDfxzT;

VetCMw = VetCMwT;
VetCMt = VetCMtT;
VetCMf = VetCMfT;

%lateral
VetCYw = VetCYwT;
VetCYt = VetCYtT;
VetCYf = VetCYfT;

VetCDwxy = VetCDwxyT;
VetCDtxy = VetCDtxyT;
VetCDfxy = VetCDfxyT;

VetCNw = VetCNwT;
VetCNt = VetCNtT;
VetCNf = VetCNfT;


%interference
VetCLi = VetCLiT;
VetCDixz = VetCDixzT;
VetCMi = VetCMiT;

VetCYi = VetCYiT;
VetCDixy = VetCDixyT;
VetCNi = VetCNiT;