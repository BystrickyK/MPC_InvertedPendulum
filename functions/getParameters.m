function p = getParameters()
    %vytvoøení struct pro v¹echny zadané hodnoty systému

    p.B_eq = 4.3; %equivalent viscous damping coefficient (cart)
    p.B_p = 0.0024; %equivalent viscous damping coefficient (pendulum)
    p.J_p = 1.2e-3; %moment of inertia about CoM, medium length pendulum
    p.K_g = 3.71; %gearbox gear ratio
    p.M_p = 0.127; %pendulum mass
    p.R_m = 2.6; %motor armature resistance
    p.eta_g = 0.9; %gearbox efficiency
    p.eta_m = 0.69; %motor efficiency
    p.g = 9.81;
    p.k_m = 7.68e-3; %motor back-emf constant
    p.k_t = 7.68e-3; %motor current-torque constant
    p.L_p = 0.3365; %full length of the pendulum
    p.l_p = p.L_p/2; % the centre of mass of the pendulum
    p.r_mp = 6.35e-3; %motor pinion radius (prumer pastorku)
    p.M_c = 0.38; %cart mass
    p.J_m = 3.9e-7; %motor moment of inertia
    p.J_eq = p.M_c + p.eta_g*p.K_g^2*p.J_m/p.r_mp^2;
end