% SETUP_LAB_IP02_SPG
%
% IP02 Single Pendulum Gantry (SPG) Control Lab: 
% Design of a state-feedback controller through pole placement SISO
% 
% SETUP_LAB_IP02_SPG sets the SPG-plus-IP02 system's 
% model parameters accordingly to the user-defined configuration.
% SETUP_LAB_IP02_SPG can also set the controllers' parameters, 
% accordingly to the user-defined desired specifications.
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.

clear

% ##### USER-DEFINED SPG-plus-IP02 CONFIGURATION #####

% if IP02: Type of Cart Load: set to 'NO_WEIGHT', 'WEIGHT'
% IP02_WEIGHT_TYPE = 'NO_WEIGHT';
IP02_WEIGHT_TYPE = 'WEIGHT';
% Type of single pendulum: set to 'LONG_24IN', 'MEDIUM_12IN'
PEND_TYPE = 'LONG_24IN'; 
% PEND_TYPE = 'MEDIUM_12IN'; 
% Turn on or off the safety watchdog on the cart position: set it to 1 , or 0 
X_LIM_ENABLE = 1;       % safety watchdog turned ON
%X_LIM_ENABLE = 0;      % safety watchdog turned OFF
% Safety Limits on the cart displacement (m)
X_MAX = 0.2;            % cart displacement maximum safety position (m)
X_MIN = - X_MAX;        % cart displacement minimum safety position (m)
% Turn on or off the safety watchdog on the pendulum angle: set it to 1 , or 0 
%ALPHA_LIM_ENABLE = 1;       % safety watchdog turned ON
ALPHA_LIM_ENABLE = 0;      % safety watchdog turned OFF
% Safety Limits on the pendulum angle (deg)
global ALPHA_MAX ALPHA_MIN
ALPHA_MAX = 25;            % pendulum angle maximum safety position (deg)
ALPHA_MIN = - ALPHA_MAX;   % pendulum angle minimum safety position (deg)
% Amplifier Gain used: set VoltPAQ to 1
K_AMP = 1;
% Amplifier Type, e.g. 'VoltPAQ', or 'Q3'
AMP_TYPE = 'VoltPAQ';
% AMP_TYPE = 'Q3';
% Digital-to-Analog Maximum Voltage (V); for MultiQ cards set to 10
VMAX_DAC = 10;

% ##### USER-DEFINED CONTROLLER DESIGN #####
% Type of Controller: set it to 'PP_AUTO', 'MANUAL'  
CONTROLLER_TYPE = 'PP_AUTO';    % pole placement design: automatic mode
% CONTROLLER_TYPE = 'MANUAL';    % controller design: manual mode
% Pole Placement Design Specifications
PO = 5;     % spec #1: maximum percent overshoot
ts = 2.2;   % spec #2: maximum 2% settling time
% Rising/Falling Slew Rate (mm/s): set for +/- 30 cm square setpoint
R_SLEW_RATE = 0.75;
% Initial Condition on alpha, i.e. pendulum angle at t = 0 (deg)
% X0(2) = 20;
X0(2) = 0;
% conversion to radians
X0(2) = X0(2) / 180 * pi;
% initial state variables (at t=0)
X0 = [ 0; X0(2); 0; 0 ];
% IP02 Cart Encoder Resolution
global K_EC K_EP
% Specifications of a second-order low-pass filter
wcf = 2 * pi * 10; % filter cutting frequency
zetaf = 0.9;        % filter damping ratio
% ##### END OF USER-DEFINED CONTROLLER DESIGN #####

% variables required in the Simulink diagrams
global VMAX_AMP IMAX_AMP

% Set the model parameters accordingly to the user-defined IP02 system configuration.
% These parameters are used for model representation and controller design.
[ Rm, Jm, Kt, eta_m, Km, Kg, eta_g, Mc, r_mp, Beq ] = config_ip02( IP02_WEIGHT_TYPE, AMP_TYPE );

% Lumped Mass of the Cart System (accounting for the rotor inertia)
Jeq = Mc + eta_g * Kg^2 * Jm / r_mp^2;

% Set the model parameters for the single pendulum accordingly to the user-defined configuration.
[ g, Mp, Lp, lp, Jp, Bp ] = config_sp( PEND_TYPE );

%
if strcmp ( CONTROLLER_TYPE, 'PP_AUTO' )
    
    % For the State Vector: X = [ xc; alpha; xc_dot; alpha_dot ]
    % Initialization of the State-Space Representation of the Open-Loop System
    % Call the following Maple-generated file to initialize the State-Space Matrices: A, B, C, and D
    % ABCD Eqns relative to Fc
    [A, B, C, D] = SPG_ABCD_eqns( Rm, Kt, eta_m, Km, Kg, eta_g, Jeq, Mp, Bp, lp, g, Jp, r_mp, Beq )

    % user-chosen real poles (to the left of the dominant complex pair)
    p3 = -20;
    p4 = -40;
    % Automatically carry out pole placement as per the user-specifications above
    % and calculate the state-feedback vector
    [ K ] = d_ip02_spg_pp( A, B, C, D, Lp, X0, PO, ts, p3, p4 );
    % integral gain on xc (obtained by trial and error) [V/s/m]
    Ki = 10;
    % Display the calculated gains
    %disp( ' ' )
    %disp( 'Calculated state-feedback gain vector elements: ' )
    disp( [ 'K(1) = ' num2str( K(1) ) ' N/m' ] )
    disp( [ 'K(2) = ' num2str( K(2) ) ' N/rad' ] )
    disp( [ 'K(3) = ' num2str( K(3) ) ' N.s/m' ] )
    disp( [ 'K(4) = ' num2str( K(4) ) ' N.s/rad' ] )
    disp( [ 'and Ki = ' num2str( Ki ) ' N/s/m' ] )
elseif strcmp ( CONTROLLER_TYPE, 'MANUAL' )
    % Add actuator dynamics
    [ A, B, C, D ] = SPG_ABCD_eqns_student( Rm, Kt, eta_m, Km, Kg, eta_g, Jeq, Mp, Bp, lp, g, Jp, r_mp, Beq )
    
    K = [ 0 0 0 0 ];
    disp( ' ' )
    disp( 'STATUS: manual mode' ) 
    disp( 'The model parameters of your Single Pendulum and IP02 system have been set.' )
    disp( 'You can now design your state-feedback position controller.' )
    disp( ' ' )
else
    error( 'Error: Please set the type of controller that you wish to implement.' )
end
