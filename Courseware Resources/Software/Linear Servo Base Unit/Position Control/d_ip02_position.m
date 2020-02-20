% D_IP01_2_POSITION_PV
%
% IP01 or IP02 Position Control Lab: Design of a PV Controller
%
% D_IP01_2_PV_CONTROLLER designs a Proportional-plus-Velocity (PV) controller 
% for the IP01 or IP02 system, and returns the corresponding gains, Kp and Kv.
%
% PV controller nomenclature:
% Kp    Proportional Gain   (V/m)
% Kv    Velocity Gain       (V.s/m)
%
% Copyright (C) 2012 Quanser Consulting Inc.
% Quanser Consulting Inc.


function [ kp, kv ] = d_ip01_2_position_pv(K, tau, PO, tp, AMP_TYPE )

% Damping ratio from overshoot specification.
    zeta = -log(PO/100) * sqrt( 1 / ( ( log(PO/100) )^2 + pi^2 ) );
    % Natural frequency from specifications (rad/s)
    wn = pi / ( tp * sqrt(1-zeta^2) );
    %
    if strcmp(AMP_TYPE,'Q3')        
        % Proportional gain (V/rad)
        kp = wn^2/K;
        % Velocity gain (V.s/rad)
        kv = 2*zeta*wn/K;
    else
        % Proportional gain (V/rad)
        kp = wn^2/K*tau;
        % Velocity gain (V.s/rad)
        kv = (-1+2*zeta*wn*tau)/K;
    end  
end

