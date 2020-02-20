% SETUP_SP_CONFIGURATION
%
% SETUP_SP_CONFIGURATION accepts the user-defined configuration 
% of the Quanser Single Pendulum (SP) module. 
% SETUP_SP_CONFIGURATION then sets up 
% the Single Pendulum configuration-dependent model variables accordingly,
% and finally returns the calculated model parameters of the Single Pendulum Quanser module.
%
% Single Pendulum system nomenclature:
% g       Gravitational Constant                         (m/s^2)
% Mp      Pendulum Mass with T-fitting                   (kg)
% Lp      Full Length of the Pendulum (with T-fitting)   (m)
% lp      Distance from Pivot to Centre Of Gravity       (m)
% Jp      Pendulum Moment of Inertia                     (kg.m^2)
% Bp      Viscous Damping Coefficient 
%                       as seen at the Pendulum Axis     (N.m.s/rad)
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


%% returns the model parameters accordingly to the USER-DEFINED Single Pendulum (SP) configuration
function [ g, Mp, Lp, lp, Jp, Bp ] = setup_sp_configuration( PEND_TYPE )
% Calculate useful conversion factors
calc_conversion_constants;
% Gravity Constant
g = 9.81;
% Calculate the pendulum model parameters
[ Mp, Lp, lp, Jp, Bp ] = calc_sp_parameters( PEND_TYPE );
% end of 'setup_sp_configuration( )'


%% Calculate the Single Pendulum (SP) model parameters 
function [ Mp, Lp, lp, Jp, Bp ] = calc_sp_parameters( PEND_TYPE )
global K_IN2M
% Set these variables (used in Simulink Diagrams)
if strcmp( PEND_TYPE, 'LONG_24IN')
    % Pendulum Mass (with T-fitting)
    Mp = 0.230;
    % Pendulum Full Length (with T-fitting, from axis of rotation to tip)
    Lp = ( 25 + 1 / 4 ) * K_IN2M;  % = 0.6413;
    % Distance from Pivot to Centre Of Gravity
    lp = 13 * K_IN2M;  % = 0.3302
    % Pendulum Moment of Inertia (kg.m^2) - approximation
    Jp = Mp * Lp^2 / 12;  % = 7.8838 e-3
    % Equivalent Viscous Damping Coefficient (N.m.s/rad)
    Bp = 0.0024;
elseif strcmp( PEND_TYPE, 'MEDIUM_12IN')
    % Pendulum Mass (with T-fitting)
    Mp = 0.127;
    % Pendulum Full Length (with T-fitting, from axis of rotation to tip)
    Lp = ( 13 + 1 / 4 ) * K_IN2M;  % = 0.3365
    % Distance from Pivot to Centre Of Gravity
    lp = 7 * K_IN2M;  % = 0.1778
    % Pendulum Moment of Inertia (kg.m^2) - approximation
    Jp = Mp * Lp^2 / 12;  % = 1.1987 e-3
    % Equivalent Viscous Damping Coefficient (N.m.s/rad)
    Bp = 0.0024;
else 
    error( 'Error: Set the type of pendulum.' )
end
% end of 'calc_sp_parameters( )'


%% Calculate Useful Conversion Factors w.r.t. Units
function calc_conversion_constants ()
global K_D2R K_IN2M K_RADPS2RPM K_OZ2N
% from radians to degrees
K_R2D = 180 / pi;
% from degrees to radians
K_D2R = 1 / K_R2D;
% from Inch to Meter
K_IN2M = 0.0254;
% from Meter to Inch
K_M2IN = 1 / K_IN2M;
% from rad/s to RPM
K_RADPS2RPM = 60 / ( 2 * pi );
% from RPM to rad/s
K_RPM2RADPS = 1 / K_RADPS2RPM;
% from oz-force to N
K_OZ2N = 0.2780139;
% from N to oz-force
K_N2OZ = 1 / K_OZ2N;
% end of 'calc_conversion_constants( )'
