% D_IP01_2_SPEED_LEAD
%
% IP01 or IP02 Speed Control Lab: Design of a ( Lead + K + I ) Controller
%
% D_IP01_2_SPEED_LEAD designs an 
% Integrator-plus-Gain-plus-Lead controller for the IP01 or IP02 system,
% and returns the corresponding parameters: 
% K, alpha, as well as the provided phase lead, phi_c.
%
% The lead compensator transfer function is such as: 
% Gc(s) = alpha * ( s + wc / alpha ) / ( s + alpha * wc )
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


function [ Kc, a, T ] = d_ip02_speed_lead(K, tau, e_ss_des, wc_des, PM_des)
% flag to generate analysis plots
%PLOT_RESPONSE = 'YES';
PLOT_RESPONSE = 'NO';

    % To plot figures: set plot_fig = 1
plot_fig = 1;
%
%% Specifications
% Step amplitude (rad/s)
R0 = 1;

%% Compensator Design
% Plant transfer function
P = tf([K],[tau 1]);
% Integrator transfer function
I = tf([1],[1 0]);
% Plant with Integrator transfer function
Pi = series(P,I);
% Proportional gain (V.s/rad): design to get wc = 50 rad/s (lead adds gain
% which will increase the wg later)
Kc = db2mag(57);
% Phase margin of Hp(s) = Kc*P(s)/s (deg)
PM_meas = 23.2;
% Maximum phase of lead (rad)
phi_m = (PM_des - PM_meas + 5) * pi / 180;
% Gain needed to get desired phase margin
a = (1+sin(phi_m)) / (1-sin(phi_m));
% High-frequency gain of lead compensator (dB)
gain_hf = 20*log10(a);
% Gain in Kc*P(s)/s where wm should be at is -a/2, i.e the
% negative of half the high-frequency gain (dB)
g_m = -a/2;
g_m_db = -10*log10(a);
% Frequency where max lead phase should occur (rad/s)
w_m = 110;
% Lead compensator parameter: T
T = 1 / (w_m * sqrt(a));
% Lead Compensator
LEAD = tf([a*T 1],[T 1]);
% Complete Compensator: C(s) = (1+a*Ts)/(1+T*s)*Kc/s
C = Kc*series(LEAD,I);
% Loop transfer function: Lp(s) = Kc*P(s)/s
Lp = Kc*series(P,I);
% Loop transfer function: L(s) = C(s)*P(s)
L = series(P,C);
% Closed-loop system
G = feedback(L,1);
%
%% Plots
if strcmp ( PLOT_RESPONSE, 'YES' )
    % Bode of Pi(s)
    figure(1)
    margin(Pi);
    set (1,'name','Pi(s)');
    % Bode of Kc*Pi(s)
    figure(2)
    margin(Lp);
    set (2,'name','Kc*Pi(s)');
    % Bode of Lead compensator
    figure(3)
    margin(LEAD)
    set (3,'name','Lead');
    % Bode of loop transfer function L(s)
    figure(4);
    margin(L);
    set (4,'name','L(s)');
    % Step response
    figure(5)
    step(R0*G);
    stepinfo(R0*G)
    set (5,'name','Step Response');
end