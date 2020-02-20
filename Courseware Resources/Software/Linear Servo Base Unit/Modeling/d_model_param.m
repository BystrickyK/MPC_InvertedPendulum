%% D_MODEL_PARAM
%
% Calculates the first-order model parameters, K and tau, of the Quanser
% IP02 plant.
%
% ************************************************************************
% Input parameters:
% Rm        Motor armaturce resistance                          (ohm)
% Jm        Rotor moment of inertia                             (kg.m^2)
% kt        Motor torque constant                               (N.m/A)
% Eff_m     Motor efficiency                                    
% km        Motor back-EMF constant                             (V.s/rad)
% Kg        Planetary gearbox gear ratio
% Eff_g     Planetary gearbox efficiency
% M         Mass of cart (no weight)                            (kg)
% r_mp      Motor pinion radius                                 (m)
% Beq       Equivalent viscous damping coefficient              (N.m.s/rad)
%
% ************************************************************************
% Output paramters:
% K         Model steady-state gain                             (rad/s/V)
% tau       Model time constant                                  (s)
%
% Copyright (C) 2012 Quanser Consulting Inc.
% Quanser Consulting Inc.
%%
%
function [K,tau] = d_model_param(Rm, Jm, Kt, Eff_m, Km, Kg, Eff_g, M, r_mp, Bc, AMP_TYPE ) 
    if strcmp(upper(AMP_TYPE),'Q3')        
        % Actuator gain (N.m/A)
        Am = (Eff_g*Kg*Eff_m*Kt)
        % Equivalent inertia including armature inertial force (m)
        Jeq = M + ((Eff_g*Kg^2*Jm)/(r_mp^2));
        % Steady-state gain (rad/s/A)
        K = Am / Jeq; % Am / Beq;
        % Time constant (s)
        tau = 1; % Jeq / Beq;
    else
        % Actuator gain (N.m/V)
        Am = (Eff_g*Kg*Eff_m*Kt)/(r_mp*Rm);
        % Equivalent inertia including armature inertial force (m)
        Jeq = M + ((Eff_g*Kg^2*Jm)/(r_mp^2));
        % Viscous damping relative to motor
        Beq = ((Eff_g*Kg^2*Eff_m*Kt*Km)+(Bc*r_mp^2*Rm))/(r_mp^2*Rm);
        % Steady-state gain (rad/s/V)
        K = Am / Beq;
        % Time constant (s)
        tau = Jeq / Beq;
    end
end