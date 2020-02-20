% D_IP02_SPG_PP
%
% Control Lab: Design of a State-Feedback Controller by Pole Placement
% for a Single Pendulum Gantry (SPG) suspended in front of an IP02
%
% D_IP02_SPG_PP designs a pole-assigned controller for the SPG-plus-IP02 system,
% and returns the corresponding gain vector: K
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


function [ K ] = d_ip02_spg_pp( A, B, C, D, Lp, X0, PO, ts, p3, p4 )
% PLOT_RESPONSE = 'YES';
PLOT_RESPONSE = 'NO';
% SYS_ANALYSIS = 'YES';
SYS_ANALYSIS = 'NO';

% needed by the Simulink simulation models (for full-state feedback)
C = eye( 4 );
D = zeros( 4, 1 );
% if SISO
Csiso = [ 1 Lp 0 0 ];
Dsiso = [ 0 ];

% Open-Loop system
IP02_SPG_OL_SIMO_SYS = ss( A, B, C, D, 'statename', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' }, 'inputname', 'Vm', 'outputname', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' } );
IP02_SPG_OL_SISO_SYS = ss( A, B, Csiso, Dsiso, 'statename', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' }, 'inputname', 'Vm', 'outputname', { 'xt' } );

% CL pole placement
% i) spec #1: maximum Percent Overshoot (PO)
if ( PO > 0 )
    % using the *Hint formula provided in the student handout, zeta_min is given by:
    zeta_min = abs( log( PO / 100 ) ) / sqrt( pi^2 + log( PO / 100)^2 );
    zeta = zeta_min;
else
    error( 'Error: Set Percentage Overshoot.' )
end
% ii) spec #2: ts - using the *Hint formula provided in the student handout:
% 2% settling time: ts = 4 / ( zeta * wn )
wn = 4 / ( zeta * ts );
% iii) dominating pair of complex poles (satisfying desired bandwidth and damping)
beta = sqrt( 1 - zeta^2 );
p1 = - zeta * wn + beta * wn * i;
p2 = - zeta * wn - beta * wn * i;
% chosen closed-loop poles
cl_poles = [ p1 p2 p3 p4 ];

% computes the state-feedback vector K, through pole placement technique
K = acker( A, B, cl_poles );

% Closed-Loop State-Space Model
A_CL = A - B * K;
B_CL = B * K( 1 );  % corresponds to the first state: xc
C_CL = eye(4);
D_CL = zeros( 4, 1 );
IP02_SPG_CL_SIMO_SYS = ss( A_CL, B_CL, C_CL, D_CL, 'statename', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' }, 'inputname', 'Vm', 'outputname', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' } );
IP02_SPG_CL_SISO_SYS = ss( A_CL, B_CL, Csiso, Dsiso, 'statename', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' }, 'inputname', 'Vm', 'outputname', { 'xt' } );

if strcmp( PLOT_RESPONSE, 'YES' )
    % initialization
    close all
    fig_h = 1; % figure handle number

    % check the open-loop pole-zero locations: SISO
    figure( fig_h ) 
    pzmap( IP02_SPG_OL_SISO_SYS )
    set( fig_h, 'name', strcat( 'Open-Loop System: SPG + IP02' ) )
    fig_h = fig_h + 1;

    % check the closed-loop pole-zero locations: SISO
    figure( fig_h ) 
    pzmap( IP02_SPG_CL_SISO_SYS )
    set( fig_h, 'name', strcat( 'Closed-Loop System: SPG + IP02 + PP' ) )
    fig_h = fig_h + 1;
    
    % let's look at the step response of the closed-loop system
    % unit step closed-loop response: SISO
    figure( fig_h ) 
    % plotting of a step response re. xt: xt = xc + Lp * sin( alpha )
    step( IP02_SPG_CL_SISO_SYS )
    set( fig_h, 'name', strcat( 'Closed-Loop System: SPG + IP02 + PP' ) )
    grid on
    fig_h = fig_h + 1;

    % unit step closed-loop response of all 4 states: SIMO
    figure( fig_h )
    [ yss, tss, xss ] = step( IP02_SPG_CL_SIMO_SYS );
    subplot( 2, 1, 1 )
    plot( tss, xss( :, 1 ) )
    grid on
    title( 'Unit Step Response on x_c' )
    xlabel( 'Time (s)' )
    ylabel( 'x_c (m)' )
    subplot( 2, 1, 2 )
    plot( tss, ( xss( :, 2 ) * 180 / pi ) )
    grid on
    xlabel( 'Time (s)' )
    ylabel( '\alpha (deg)' )
    set( fig_h, 'name', strcat( 'Closed-Loop System: SPG + IP02 + PP' ) )
    fig_h = fig_h + 1;
    
    % open-loop free swing: response to alpha0 == X0(2) != 0
    % X0(2) should be within the linear model limits
    figure( fig_h )
    tss_IC = 0 : 0.001 : 5.0;
    [ yss_IC, tss_IC, xss_IC ] = initial( IP02_SPG_OL_SIMO_SYS, X0, tss_IC );
    subplot( 2, 1, 1 )
    plot( tss_IC, xss_IC( :, 1 )*1000 )
    grid on
    title( [ 'Free Swing: Open-Loop State Response to \alpha_0 = ' num2str( X0(2)*180/pi ) ' deg' ] )
    xlabel( 'Time (s)' )
    ylabel( 'x_c (mm)' )
    subplot( 2, 1, 2 )
    plot( tss_IC, xss_IC( :, 2 ) * 180 / pi )
    grid on
    xlabel( 'Time (s)' )
    ylabel( '\alpha (deg)' )
    set( fig_h, 'name', strcat( 'Open-Loop System: SPG + IP02' ) )
    fig_h = fig_h + 1;
end

% carry out some additional system analysis
if strcmp( SYS_ANALYSIS, 'YES' )
    % pole placement is possible iff (A,B) is controllable
    % controllability matrix
    Co = ctrb( A, B );
    % the system is controllable iff Co has full rank (i.e. = number of states)
    % number of uncontrollable states
    unco = length( A ) - rank( Co );    % = 0
    % SISO models
    ULABELS = [ 'V_m' ];
    XLABELS = [ 'xc alpha xc_dot alpha_dot' ];
    YLABELS = [ 'xt' ];
    % print the Open-Loop State-Space Matrices
    disp( 'Open-Loop System' )
    printsys( A, B, Csiso, Dsiso, ULABELS, YLABELS, XLABELS )
    % open-loop pole-zero locations: NMP (zero in RHP)
    [ z_ol, p_ol, k_ol ] = ss2zp( A, B, Csiso, Dsiso, 1 )
    % print the Closed-Loop State-Space Matrices
    disp( 'Closed-Loop System' )
    printsys( A_CL, B_CL, Csiso, Dsiso, ULABELS, YLABELS, XLABELS )
    % closed-loop pole-zero locations: NMP (zero in RHP)
    [ z_cl, p_cl, k_cl ] = ss2zp( A_CL, B_CL, Csiso, Dsiso, 1 )
    % or: Closed-Loop eigenvalues
    CL_poles = eig( A_CL );
end

% end of function 'd_ip02_spg_pp( )'
