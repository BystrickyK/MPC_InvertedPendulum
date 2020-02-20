%% D_PI_DESIGN
%
% Designs a proportional-integra (PI) speed controller for the SRV02 
% plant based on the desired overshoot and peak time specifications.
%
% ************************************************************************
% Input paramters:
% K         Model steady-state gain                 (rad/s/V)
% tau       Model time constant                     (s)
% PO        Percentage overshoot specification      (%)
% tp        Peak time specifications                (s)
% AMP_TYPE  Type of amplifier (e.g. Q3)
%
% ************************************************************************
% Output parameters:
% kp        Proportional gain                       (V.s/rad)
% ki        Integral gain                           (V/rad)
%
% Copyright (C) 2010 Quanser Consulting Inc.
% Quanser Consulting Inc.
%%
%
function [ kp, ki ] = d_ip02_speed_pi( K, tau, PO, tp, AMP_TYPE )
    % Damping ratio from overshoot specification.
    zeta = -log(PO/100) * sqrt( 1 / ( ( log(PO/100) )^2 + pi^2 ) );
    % Natural frequency from specifications (rad/s)
    wn = pi / ( tp * sqrt(1-zeta^2) );
    if strcmp(AMP_TYPE,'Q3')
        % Proportional gain (V.s/rad)
        kp = 2*zeta*wn/K;
        % Integral gain (V/rad)
        ki = wn^2/K;
    else        
        % Proportional gain (V.s/rad)
        kp = (-1+2*zeta*wn*tau)/K;
        % Integral gain (V/rad)
        ki = wn^2*tau/K;
    end
end