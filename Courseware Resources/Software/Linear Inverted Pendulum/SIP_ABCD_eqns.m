% Matlab equation file: "SIP_ABCD_eqns.m"
% Open-Loop State-Space Matrices: A, B, C, and D
% for the Quanser Single Inverted Pendulum Experiment.

function [ A, B, C, D ] = SIP_ABCD_eqns(Rm, Kt, eta_m, Km, Kg, eta_g, Jeq, Mp, Bp, lp, g, Jp, r_mp, Beq)

Jt = (Jeq + Mp)*Jp + Jeq*Mp*lp^2;
A = [0 0 1 0;
     0 0 0 1;
     0 Mp^2*lp^2*g/Jt -Beq*(Jp+Mp*lp^2)/Jt -Mp*lp*Bp/Jt;
     0 Mp*g*lp*(Jeq+Mp)/Jt -Beq*Mp*lp/Jt -Bp*(Jeq+Mp)/Jt];

B = [0; 0; (Jp+Mp*lp^2)/Jt; Mp*lp/Jt];
C = eye(2,4);
D = zeros(2,1);

A(3,3) = A(3,3) - B(3)*eta_g*Kg^2*eta_m*Kt*Km/r_mp^2/Rm;
A(4,3) = A(4,3) - B(4)*eta_g*Kg^2*eta_m*Kt*Km/r_mp^2/Rm;
B = eta_g*Kg*eta_m*Kt/r_mp/Rm*B;