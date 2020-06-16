%% Init
clc
clear all 
close all

cd('..\');
parentDir = cd('.\NLMPC');
addpath(strcat(parentDir,'\functions')); %enables access to scripts in the folder
resultsDir = strcat(parentDir,'\results');
savefileDir = strcat(resultsDir, '\NLMPC');
if ~exist(savefileDir,'dir')
    mkdir(savefileDir);
end
timeLabel = datetime;
timeLabel.Format = 'dd-MM-uu_HH-mm_ss';
timeLabel = string(timeLabel);
saveFilePath = strcat(savefileDir,'\data_',timeLabel);

%%  Initialize interface
% Cart Position Pinion number of teeth
N_pp = 56;

% Rack Pitch (m/teeth)
Pr = 1e-2 / 6.01; % = 0.0017

global K_EC K_EP
    % Cart Encoder Resolution (m/count)
    K_EC = Pr * N_pp / ( 4 * 1024 ); % = 22.7485 um/count
    % Pendulum Encoder Resolution (rad/count)
    % K_EP is positive, since CCW is the positive sense of rotation
    K_EP = 2 * pi / ( 4 * 1024 ); % = 0.0015
   
K_AMP = 1;

X_LIM_ENABLE = 1;
XMAX = 0.35;

ALPHA_LIM_ENABLE = 0;
ALPHAMAX = pi/4;

KF_Ts = 0.01;
MPC_Ts = 0.1;

VMAX_AMP = 6;

% Initial state
X0 = [0; 0; 0; 0];
%%  Synthesize NLMPC controller and set reference

% Reference
yref = [0 1]; % x alpha (1 is up | -1 is down)

nx = 4;
ny = 2;
nu = 1;
nlobj = nlmpc(nx, ny, nu);


nlobj.PredictionHorizon = 7;
nlobj.ControlHorizon = 4;
nlobj.Ts = MPC_Ts;

nlobj.Model.StateFcn = 'pendCartC';
nlobj.Jacobian.StateFcn = 'AB';
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;

triangleWaveFourier3 = @(x) 8/pi^2 * (sin(x) - 1/9*sin(3*x) + 1/25*sin(5*x));
nlobj.Model.OutputFcn = @(X, u) [X(1); triangleWaveFourier3(X(3)-pi/2)];

nlobj.Weights.OutputVariables = [8 4];
nlobj.Weights.ManipulatedVariablesRate = 0.01;

%  nlobj.OV(1).Min = -0.33;
%  nlobj.OV(1).Max = 0.33;
%  
nlobj.MV.Min = -5;
nlobj.MV.Max = 5;
 
nlobj.Optimization.UseSuboptimalSolution = true;
nlobj.Optimization.SolverOptions.MaxIter = 3;
% nlobj.Optimization.SolverOptions.UseParallel = true;
nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlobj.Optimization.SolverOptions.Display = 'none';

validateFcns(nlobj, X0, 0, [])