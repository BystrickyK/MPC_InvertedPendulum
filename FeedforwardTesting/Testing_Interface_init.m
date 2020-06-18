%% Init
clc
clear all 
close all

cd('..\');
parentDir = cd('.\FeedforwardTesting');
addpath(strcat(parentDir,'\functions')); %enables access to scripts in the folder
resultsDir = strcat(parentDir,'\results');
savefileDir = strcat(resultsDir, '\Testing');
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

    wcf = 2 * pi * 10.0;  % filter cutting frequency
    zetaf = 0.9;  
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
XMAX = 0.30;

ALPHA_LIM_ENABLE = 0;
ALPHAMAX = pi/4;

KF_Ts = 0.02;

VMAX_AMP = 6;

% Initial state
X0 = [0; 0; 0; 0];
