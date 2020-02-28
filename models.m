clc
clear all 
close all

eta_g = 0.9; %gearbox efficiency
K_g = 3.71; %gearbox gear ratio
k_t = 7.68e-3; %motor current-torque constant
k_m = 7.68e-3; %motor back-emf constant
R_m = 2.6; %motor armature resistance
r_mp = 6.35e-3; %motor pinion radius (prumer pastorku)
eta_m = 0.69; %motor efficiency
J_p = 1.2e-3; %moment of inertia about CoM, medium length pendulum
L_p = 0.3365; %full length of the pendulum
l_p = L_p/2;
M_p = 0.127; %pendulum mass
%J_p = J_pCoM + M_p * l_p^2
M_c = 0.38; %cart mass
J_m = 3.9e-7; %motor moment of inertia
J_eq = M_c + eta_g*K_g^2*J_m/r_mp^2;
B_eq = 4.3; %equivalent viscous damping coefficient (cart)
B_p = 0.0024; %equivalent viscous damping coefficient (pendulum)
g = 9.81;

    p.B_eq = B_eq;
    p.B_p = B_p;
    p.J_eq = J_eq;
    p.J_p = J_p;
    p.K_g = K_g;
    p.M_p = M_p;
    p.R_m = R_m;
    p.eta_g = eta_g;
    p.eta_m = eta_m;
    p.g = g;
    p.k_m = k_m;
    p.k_t = k_t;
    p.l_p = l_p;
    p.r_mp = r_mp;
%%
    X_operating = [0 pi 0 0];
    [A,B,C,D] = ABCD(X_operating, 0, p);
    
    Q = diag([10 10 1 1]);
    R = 0.1;
    K_lqr = lqr(A,B,Q,R)
    
    pole = [ -2, -2.1, -2.2, -2.3];
    K_pp = place(A,B,pole)
%%
X = [0, 17/16*pi, 0, 0]; %alpha, Dalpha, xc, Dxc
W = [0, pi, 0, 0];
Wx = W(1);

Ts = 0;
Xs = X;
U = 0;
options = odeset('InitialStep', 0.1);

simulationTime = 1e4;
dt = 0.06;
kRefreshPlot = 60000;
kRefreshAnim = 2;

figure(1)
figure(2)
for k = 1:simulationTime/dt
    X = Xs(end,:);
    if rand(1) > 0.900
       % W = [2*rand(1)-1, pi, 0, 0];
        W = [sign(2*rand(1)-1)*0.5, pi, 0, 0];
    end
    
    u = -K_lqr * ( X' - W' );
    u = min(10, max(-10, u));
    [ts, xs] = ode45(@(t, X) pendulumCart(X,u,p), [(k-1)*dt k*dt], X, options);
	Xs = [Xs; xs(end,:)];
    Ts = [Ts ts(end)];
    U = [U; u];
    Wx = [Wx W(1)];
    
    if(Xs(end,1)>1)
        Xs(end,3) = -abs(Xs(end,3)*0);
        Xs(end,1) = 0;
        disp("bonk")
    end
    if(Xs(end,1)<-1)
        Xs(end,3) = +abs(Xs(end,3)*0);
        Xs(end,1) = 0;
        disp("bonk")
    end
    
    if(mod(k,kRefreshPlot)==0)
        plotRefresh(Ts,Xs,Wx,U,k,kRefreshPlot);
    end

     if(mod(k,kRefreshAnim)==0)
         animRefresh(Ts,Xs,W);
     end
      
    if (mod(k,2000)==0) 
        disp(k + "/" + simulationTime/dt);
        disp(X)
        disp(W)
        disp(u)
    end
end

sol.X = Xs
sol.T = Ts
sol.U = U
