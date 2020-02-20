% SETUP_IP02_MODELING
%
% IP02 Modeling Lab
% 
% SETUP_LAB_IP02_MODELING sets IP02 system model parameters 
% according to the user-defined configuration.
%
% Copyright (C) 2012 Quanser Consulting Inc.
% Quanser Consulting Inc.

clear all;

% ############### IP02 CONFIGURATION ###############
% Type of Cart Load: set to 'NO_LOAD', 'WEIGHT'
IP02_LOAD_TYPE = 'NO_LOAD';
% IP02_LOAD_TYPE = 'WEIGHT';
% Turn on or off the safety watchdog on the cart position: set it to 1 , or 0 
X_LIM_ENABLE = 1;       % safety watchdog turned ON
%X_LIM_ENABLE = 0;      % safety watchdog turned OFF
% Safety Limits on the cart displacement (m)
X_MAX = 0.3;            % cart displacement maximum safety position
X_MIN = - X_MAX;        % cart displacement minimum safety position
% Amplifier Gain: set VoltPAQ amplifier gain to 1
K_AMP = 1;
% Power Amplifier Type: set to 'VoltPAQ'
AMP_TYPE = 'VoltPAQ';
% Digital-to-Analog Maximum Voltage (V); for Q2-USB cards set to 10
VMAX_DAC = 10;
% ##############################

% ############### LAB CONFIGURATION ###############
% Type of Controller: set it to 'AUTO', 'MANUAL'
MODELING_TYPE = 'AUTO';   
% MODELING_TYPE = 'MANUAL';
% ##############################

% variables required in the Simulink diagrams
global VMAX_AMP IMAX_AMP

% Set the model parameters accordingly to the USER-DEFINED IP02 system configuration.
% These parameters are used for model representation and controller design.
[ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Bc ] = config_ip02(IP02_LOAD_TYPE, AMP_TYPE);

% ############### MODEL SPECIFICATIONS ###############
% Specifications of a second-order low-pass filter 
    % Cart Encoder Resolution
    global K_EC K_EP
    % Specifications of a second-order low-pass filter
    wcf = 2 * pi * 50;  % filter cutting frequency
    zetaf = 0.9;        % filter damping ratio
% Model Specifications
if strcmp ( MODELING_TYPE , 'MANUAL' )
    K = 0.1;
    tau = 0.01;
else
    [K,tau] = d_model_param(Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Bc, AMP_TYPE);
end
% ############### END OF MODEL SPECIFICATIONS ###############