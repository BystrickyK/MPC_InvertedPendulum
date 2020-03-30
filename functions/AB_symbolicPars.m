function [A,B] = AB_symbolicPars(X, u, p)

    B_eq = p.B_eq;
    B_p = p.B_p;
    J_eq = p.J_eq;
    J_p = p.J_p;
    K_g = p.K_g;
    M_p = p.M_p;
    R_m = p.R_m;
    eta_g = p.eta_g;
    eta_m = p.eta_m;
    g = p.g;
    k_m = p.k_m;
    k_t = p.k_t;
    l_p = p.l_p;
    r_mp = p.r_mp;
    
	A = reshape([0.0,0.0,0.0,0.0,0.0,0.0,(1.0./r_mp.^2.*(M_p.^2.*R_m.*g.*l_p.^2.*r_mp.^2.*cos(X(2)).^2-M_p.^2.*R_m.*g.*l_p.^2.*r_mp.^2.*sin(X(2)).^2+M_p.^2.*R_m.*l_p.^3.*r_mp.^2.*X(4).^2.*cos(X(2))+J_p.*M_p.*R_m.*l_p.*r_mp.^2.*X(4).^2.*cos(X(2))-B_p.*M_p.*R_m.*l_p.*r_mp.^2.*X(4).*sin(X(2))))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2))-(M_p.^2.*l_p.^2.*1.0./r_mp.^2.*cos(X(2)).*sin(X(2)).*1.0./(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2).^2.*(-B_eq.*J_p.*R_m.*r_mp.^2.*X(3)-J_p.*K_g.^2.*eta_g.*k_m.*k_t.*X(3)-B_eq.*M_p.*R_m.*l_p.^2.*r_mp.^2.*X(3)+M_p.^2.*R_m.*l_p.^3.*r_mp.^2.*X(4).^2.*sin(X(2))+J_p.*K_g.*eta_g.*eta_m.*k_t.*r_mp.*u+M_p.^2.*R_m.*g.*l_p.^2.*r_mp.^2.*cos(X(2)).*sin(X(2))+J_p.*M_p.*R_m.*l_p.*r_mp.^2.*X(4).^2.*sin(X(2))+B_p.*M_p.*R_m.*l_p.*r_mp.^2.*X(4).*cos(X(2))-K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.^2.*X(3)+K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.^2.*r_mp.*u).*2.0)./R_m,-(1.0./r_mp.^2.*(M_p.^2.*R_m.*l_p.^2.*r_mp.^2.*X(4).^2.*cos(X(2)).^2-M_p.^2.*R_m.*l_p.^2.*r_mp.^2.*X(4).^2.*sin(X(2)).^2+M_p.^2.*R_m.*g.*l_p.*r_mp.^2.*cos(X(2))+J_eq.*M_p.*R_m.*g.*l_p.*r_mp.^2.*cos(X(2))+B_eq.*M_p.*R_m.*l_p.*r_mp.^2.*X(3).*sin(X(2))+K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.*X(3).*sin(X(2))-K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.*r_mp.*u.*sin(X(2))))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2))+(M_p.^2.*l_p.^2.*1.0./r_mp.^2.*cos(X(2)).*sin(X(2)).*1.0./(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2).^2.*(B_p.*J_eq.*R_m.*r_mp.^2.*X(4)+B_p.*M_p.*R_m.*r_mp.^2.*X(4)+M_p.^2.*R_m.*g.*l_p.*r_mp.^2.*sin(X(2))+M_p.^2.*R_m.*l_p.^2.*r_mp.^2.*X(4).^2.*cos(X(2)).*sin(X(2))-B_eq.*M_p.*R_m.*l_p.*r_mp.^2.*X(3).*cos(X(2))+J_eq.*M_p.*R_m.*g.*l_p.*r_mp.^2.*sin(X(2))-K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.*X(3).*cos(X(2))+K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.*r_mp.*u.*cos(X(2))).*2.0)./R_m,1.0,0.0,-(1.0./r_mp.^2.*(B_eq.*J_p.*R_m.*r_mp.^2+J_p.*K_g.^2.*eta_g.*k_m.*k_t+B_eq.*M_p.*R_m.*l_p.^2.*r_mp.^2+K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.^2))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2)),(1.0./r_mp.^2.*(B_eq.*M_p.*R_m.*l_p.*r_mp.^2.*cos(X(2))+K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.*cos(X(2))))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2)),0.0,1.0,(1.0./r_mp.^2.*(B_p.*M_p.*R_m.*l_p.*r_mp.^2.*cos(X(2))+M_p.^2.*R_m.*l_p.^3.*r_mp.^2.*X(4).*sin(X(2)).*2.0+J_p.*M_p.*R_m.*l_p.*r_mp.^2.*X(4).*sin(X(2)).*2.0))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2)),-(1.0./r_mp.^2.*(B_p.*J_eq.*R_m.*r_mp.^2+B_p.*M_p.*R_m.*r_mp.^2+M_p.^2.*R_m.*l_p.^2.*r_mp.^2.*X(4).*cos(X(2)).*sin(X(2)).*2.0))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2))],[4,4]);
    
    
    B = [0.0;
        0.0;
        (1.0./r_mp.^2.*(J_p.*K_g.*eta_g.*eta_m.*k_t.*r_mp+K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.^2.*r_mp))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2));
        -(K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.*cos(X(2)))./(R_m.*r_mp.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*cos(X(2)).^2+J_eq.*M_p.*l_p.^2))];
    
    
    C = [1 0 0 0;
        0 1 0 0];
    
    
    D = 0;
end