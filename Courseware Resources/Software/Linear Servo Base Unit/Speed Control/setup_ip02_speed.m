% SETUP_IP02_SPEED
%
% IP02 Speed Control Lab - Design of a LEAD-based compensator
% 
% SETUP_IP02_SPEED sets the IP02 system's 
% model parameters according to the user-defined configuration.
% SETUP_IP02_SPEED can also set the controllers' parameters
% according to the desired specifications.
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
X_MAX = 0.35;            % cart displacement maximum safety position
X_MIN = - X_MAX;        % cart displacement minimum safety position
% Amplifier Gain used: set VoltPAQ to 1
K_AMP = 1;
% Amplifier Type: set to 'VoltPAQ' or 'Q3'
AMP_TYPE = 'VoltPAQ';
% Digital-to-Analog Maximum Voltage (V); for Q4/Q8 cards set to 10
VMAX_DAC = 10;

% ############### USER-DEFINED CONTROLLER DESIGN ###############
% Type of Controller: set it to 'LEAD', or 'MANUAL'  
CONTROLLER_TYPE = 'LEAD';    % LEAD controller design: automatic mode
%CONTROLLER_TYPE = 'MANUAL';    % controller design: manual mode

%CONTROLLER_TYPE = 'PI'; % PI controller design: automatic mode

    % performance requirements for the IP02 system
    e_ss_des = 0.0005;    % spec #1: maximum steady-state error (in m/s)
    wc_des = 80;         % spec #2: desired bandwidth (in rad/s)
    PM_des = 85;      % spec #3: desired phase margin (in degrees)
    PO = 5;
    tp = 0.05;
    
    % Cart Encoder Resolution
    global K_EC K_EP
    % Specifications of a second-order low-pass filter 
    wcf = 2 * pi * 70;  % filter cutting frequency 70
    zetaf = 0.9;        % filter damping ratio
% ############### END OF USER-DEFINED CONTROLLER DESIGN ###############

% variables required in the Simulink diagrams
global K_EC K_EP K_PC K_PP VMAX_AMP IMAX_AMP

% Set the model parameters accordingly to the USER-DEFINED IP01 or IP02 system configuration.
% These parameters are used for model representation and controller design.
[ Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Beq ] = config_ip02( IP02_LOAD_TYPE, AMP_TYPE );
[K,tau] = d_model_param(Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Beq, AMP_TYPE);

if strcmp ( CONTROLLER_TYPE, 'LEAD' )
    % Automatically design a ( Lead + K + I ) controller as per the user-specifications above
    [ Kc, a, T ] = d_ip02_speed_lead(K, tau, e_ss_des, wc_des, PM_des);
    % Display the calculated gains
    disp( ' ' )
    disp( 'Calculated lead compensator gains: ' )
    disp( [ 'Kc = ' num2str( Kc ) ' V-s/m' ] )
    disp( [ 'a = ' num2str( a ) ' ' ] )
    disp( ' ' )
    disp( [ 'T = ' num2str( T ) ' ' ] )      % compensator's phase lead
elseif strcmp ( CONTROLLER_TYPE, 'PI' )
    % Automatically design a PI controller as per the user-specifications above
    [ kp, ki ] = d_ip02_speed_pi(K, tau, PO, tp, AMP_TYPE);
    bsp = 0;
    % Display the calculated gains
    disp( ' ' )
    disp( 'Calculated lead compensator gains: ' )
    disp( [ 'kp = ' num2str( kp ) ' V-s/m' ] )
    disp( [ 'ki = ' num2str( ki ) 'V/m' ] )
    disp( ' ' )
elseif strcmp ( CONTROLLER_TYPE, 'MANUAL' )
    disp( ' ' )
    disp( 'STATUS: manual mode' ) 
    disp( 'The model parameters of your IP02 system have been set.' )
    disp( 'You can now design your speed controller.' )
    disp( ' ' )
else
    error( 'Error: Please set the type of controller that you wish to implement.' )
end

