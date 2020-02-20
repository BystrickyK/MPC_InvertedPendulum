% Matlab equation file: "SPG_ABCD_eqns_student.m"
% Open-Loop State-Space Matrices: A, B, C, and D
% for the Quanser Single Pendulum Gantry Experiment.

function [A, B, C, D] = SPG_ABCD_eqns_student(Rm, Kt, eta_m, Km, Kg, eta_g, Jeq, Mp, Bp, lp, g, Jp, r_mp, Beq)

A = eye(4,4);
B = [0;0;0;1];
C = eye(2,4);
D = zeros(2,1);

%Actuator Dynamics
A(3,3) = A(3,3) - B(3)*eta_g*Kg^2*eta_m*Kt*Km/r_mp^2/Rm;
A(4,3) = A(4,3) - B(4)*eta_g*Kg^2*eta_m*Kt*Km/r_mp^2/Rm;
B = eta_g*Kg*eta_m*Kt/r_mp/Rm*B;