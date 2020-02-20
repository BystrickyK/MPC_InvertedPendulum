
function [Er, a_max] = d_swing_up(eta_m, eta_g, Kg, Kt, Rm, r_mp, Jeq, Mp, lp)
    % Reference Energy (J)
    Er = 2*Mp*lp*9.81;
    % Maximum force for 5 V
    Fc_max = (eta_m*eta_g*Kg*Kt*5)/(Rm*r_mp);
    % Maximum acceleration of pivot (m/s^2)
    a_max = (Fc_max / Jeq);
end
