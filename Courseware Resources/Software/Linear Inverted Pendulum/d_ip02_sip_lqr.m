% D_IP01_2_SIP_LQR
%
% Control Lab: Design of a LQR Controller
% for a Single Inverted Pendulum (SIP) mounted on an IP01 or IP02
%
% D_IP01_2_SIP_LQR designs a LQR controller for the SIP-plus-IP01-or-IP02 system,
% and returns the corresponding gain vector: K
%
% Copyright (C) 2003 Quanser Consulting Inc.
% Quanser Consulting Inc.


function [ K ] = d_ip01_2_sip_lqr( A, B, C, D, PEND_TYPE, IP02_LOAD_TYPE, AMP_TYPE)
% PLOT_RESPONSE = 'YES';
PLOT_RESPONSE = 'NO';
% SYS_ANALYSIS = 'YES';
SYS_ANALYSIS = 'NO';

% LQR Controller Design Specifications
if strcmp( IP02_LOAD_TYPE, 'NO_LOAD' )
    if strcmp( PEND_TYPE, 'LONG_24IN' )
        if ( strcmp( AMP_TYPE, 'VoltPAQ' ) )
            Q = diag( [ 0.4 4.5 0 0 ] );
            R(1,1) = [ 0.0002 ];
        elseif ( strcmp( AMP_TYPE, 'Q3') )
            Q = diag( [ 0.4 4.5 0 0 ] );
            R(1,1) = [ 0.002 ];
        else
            error( 'Error: Set the amplifier type.' );
        end
    elseif strcmp( PEND_TYPE, 'MEDIUM_12IN' )
        if ( strcmp( AMP_TYPE, 'VoltPAQ' ) )
            Q = diag( [ 0.5 4 0 0 ] );
            R(1,1) = [ 0.0003 ];
        elseif ( strcmp( AMP_TYPE, 'Q3') )
            Q = diag( [ 0.5 4 0 0 ] );
            R(1,1) = [ 0.008 ];
        else
            error( 'Error: Set the amplifier type.' );
        end
    else
        error( 'Error: Set the type of pendulum.' )
    end
elseif strcmp( IP02_LOAD_TYPE, 'WEIGHT' )
    if strcmp( PEND_TYPE, 'LONG_24IN' )
        if ( strcmp( AMP_TYPE, 'VoltPAQ' ) )
            Q = diag( [ 0.75 4 0 0 ] );
            R(1,1) = [ 0.0003 ];
        elseif ( strcmp( AMP_TYPE, 'Q3') )
            Q = diag( [ 0.75 4 0 0 ] );
            R(1,1) = [ 0.002 ];
        else
            error( 'Error: Set the amplifier type.' );
        end
    elseif strcmp( PEND_TYPE, 'MEDIUM_12IN' )
        if ( strcmp( AMP_TYPE, 'VoltPAQ' ) )
            Q = diag( [ 1 6 0 0 ] );
            R(1,1) = [ 0.0004 ];
        elseif ( strcmp( AMP_TYPE, 'Q3') )
            Q = diag( [ 1 6 0 0 ] );
            R(1,1) = [ 0.004 ];
        else
            error( 'Error: Set the amplifier type.' );
        end
    else
        error( 'Error: Set the type of pendulum.' )
    end
else
    error( 'Error: Set the IP02 load configuration.' )
end

% needed by the Simulink simulation models
C = eye( 4 );
D = zeros( 4, 1 );

% Open Loop system
IP01_2_SIP_OL_SYS = ss( A, B, C, D, 'statename', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' }, 'inputname', 'Vm', 'outputname', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' } );


% calculate the LQR gain vector, K
[ K, S, EIG_CL ] = lqr( A, B, Q, R );


% Closed-Loop State-Space Model
A_CL = A - B * K;
B_CL = B * K( 1 ); % corresponds to the first state: xc
C_CL = eye( 4 );
D_CL = zeros( 4, 1 );

% Closed-Loop System
IP01_2_SIP_CL_SYS = ss( A_CL, B_CL, C_CL, D_CL, 'statename', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' }, 'inputname', 'Vm', 'outputname', { 'xc' 'alpha' 'xc_dot' 'alpha_dot' } );


if strcmp( PLOT_RESPONSE, 'YES' )
    % initialization
    close all
    fig_h = 1; % figure handle number
    
    % let's look at the step response of the closed-loop system
    % unit step closed-loop response of all 4 states
    figure( fig_h )
    % plotting of a step response re. xc
    step( IP01_2_SIP_CL_SYS )
    set( fig_h, 'name', strcat( 'Closed-Loop System: SIP + IP01_2 + LQR' ) )
    grid on
    orient tall
    fig_h = fig_h + 1;
    
    % unit step closed-loop response
    figure( fig_h )
    [ yss, tss, xss ] = step( IP01_2_SIP_CL_SYS );
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
    set( fig_h, 'name', strcat( 'Closed-Loop System: SIP + IP01_2 + LQR' ) )
    fig_h = fig_h + 1;
end

% carry out some additional system analysis
if strcmp( SYS_ANALYSIS, 'YES' )
    if strcmp( PLOT_RESPONSE, 'YES' )
        % free fall: response to alpha0 == IC_ALPHA0 != 0
        % linear model limits
        figure( fig_h )
        global IC_ALPHA0
        X0_IC = [ 0; IC_ALPHA0; 0; 0 ];
        tss_IC = 0 : 0.001 : 1.8;
        [ yss_IC, tss_IC, xss_IC ] = initial( IP01_2_SIP_OL_SYS, X0_IC, tss_IC );
        subplot( 2, 1, 1 )
        plot( tss_IC, xss_IC( :, 1 )*1000 )
        grid on
        title( [ 'Free Fall: Open-Loop State-Space Response to \alpha_0 = ' num2str( IC_ALPHA0*180/pi ) ' deg' ] )
        xlabel( 'Time (s)' )
        ylabel( 'x_c (mm)' )
        subplot( 2, 1, 2 )
        plot( tss_IC, xss_IC( :, 2 ) * 180 / pi )
        grid on
        xlabel( 'Time (s)' )
        ylabel( '\alpha (deg)' )
        set( fig_h, 'name', strcat( 'Open-Loop System: SIP + IP01_2' ) )
        fig_h = fig_h + 1;
    end
    ULABELS = [ 'V_m' ];
    XLABELS = [ 'xc alpha xc_dot alpha_dot' ];
    YLABELS = XLABELS;
    % print the Open-Loop State-Space Matrices
    disp( 'Open-Loop System' )
    printsys( A, B, C, D, ULABELS, YLABELS, XLABELS )
    % one unstable open-loop pole
    OL_poles = eig( A )
    % print the Closed-Loop State-Space Matrices
    disp( 'Closed-Loop System' )
    printsys( A_CL, B_CL, C_CL, D_CL, ULABELS, YLABELS, XLABELS )
    % Closed-Loop poles, damping, and natural frequency
    damp( IP01_2_SIP_CL_SYS )
    % or: Closed-Loop eigenvalues
    CL_poles = eig( A_CL ); % = EIG_CL
end
% end of function 'd_ip01_2_sip_lqr( )'
