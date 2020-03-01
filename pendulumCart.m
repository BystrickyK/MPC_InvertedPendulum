function dy = pendulumCart(Y,u,d,p)
    
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

    s2 = sin(Y(2));
    c2 = cos(Y(2));
    
        dy = [        
        Y(3);
        Y(4);
        d(1)+(1.0./r_mp.^2.*(-B_eq.*J_p.*R_m.*r_mp.^2.*Y(3)-J_p.*K_g.^2.*eta_g.*k_m.*k_t.*Y(3)-B_eq.*M_p.*R_m.*l_p.^2.*r_mp.^2.*Y(3)+M_p.^2.*R_m.*l_p.^3.*r_mp.^2.*Y(4).^2.*s2+J_p.*K_g.*eta_g.*eta_m.*k_t.*r_mp.*u+M_p.^2.*R_m.*g.*l_p.^2.*r_mp.^2.*c2.*s2+J_p.*M_p.*R_m.*l_p.*r_mp.^2.*Y(4).^2.*s2+B_p.*M_p.*R_m.*l_p.*r_mp.^2.*Y(4).*c2-K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.^2.*Y(3)+K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.^2.*r_mp.*u))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*c2.^2+J_eq.*M_p.*l_p.^2));
        d(2)-(1.0./r_mp.^2.*(B_p.*J_eq.*R_m.*r_mp.^2.*Y(4)+B_p.*M_p.*R_m.*r_mp.^2.*Y(4)+M_p.^2.*R_m.*g.*l_p.*r_mp.^2.*s2+M_p.^2.*R_m.*l_p.^2.*r_mp.^2.*Y(4).^2.*c2.*s2-B_eq.*M_p.*R_m.*l_p.*r_mp.^2.*Y(3).*c2+J_eq.*M_p.*R_m.*g.*l_p.*r_mp.^2.*s2-K_g.^2.*M_p.*eta_g.*k_m.*k_t.*l_p.*Y(3).*c2+K_g.*M_p.*eta_g.*eta_m.*k_t.*l_p.*r_mp.*u.*c2))./(R_m.*(M_p.^2.*l_p.^2+J_eq.*J_p+J_p.*M_p-M_p.^2.*l_p.^2.*c2.^2+J_eq.*M_p.*l_p.^2));
        ];
end