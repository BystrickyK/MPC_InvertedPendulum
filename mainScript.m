%%  Zadané hodnoty
clc
clear all 
close all
addpath('functions') % toto pøidá slo¾ku functions do prohlédávaných

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
%%  Navrh regulatoru
    %X_operating je stavovy bod pro linearizaci
    X_operating = [0 pi 0 0];
    [A,B,C,D] = ABCD(X_operating, 0, p)
    
    Q = diag([10 10 1 1]);
    R = 0.15;
    K_lqr = lqr(A,B,Q,R)
    disp(eigs(A-B*K_lqr))
    
    %pole = [ -2, -2.1, -2.2, -2.3];
    %K_pp = place(A,B,pole)
    %disp(eigs(A-K_pp*B))
%% Navrh estimatoru

    Vd = 1*diag(4);      %disturbance covariance
    Vd(1,1) = 10;
    
    Vn = [100 0; 0 0.5];                 %noise covariance

    Af = A-B*K_lqr;
    Bf = B*K_lqr
    
    Cf = eye(4); 
    
    Kf = (lqr(Af', C', Vd, Vn))';
    
    KF = ss(Af-Kf*C, [Bf Kf], Cf, 0*[Bf Kf]);
    disp(eigs(KF.A))

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X = [0, pi, 0, 0]; %alpha, dAlpha, xc, dXc
%pozadovany stav
W = [0, pi, 0, 0];
Wrel = W - X_operating;

%nastaveni solveru
options = odeset();

simulationTime = 1e2;
dt = 0.02; %samplovaci perioda
kRefreshPlot = 50; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 5; % ^

%predalokace poli pro data
Xs = zeros(simulationTime/dt, 4); %skutecny stav
Xs(1,:) = X;
Xest = zeros(simulationTime/dt, 4); %estimovany stav
Xest(1,:) = X - X_operating;
Ts = zeros(simulationTime/dt, 1);   %cas
U = zeros(simulationTime/dt, 1);   %vstupy
U(1) = 0;
Wx = zeros(simulationTime/dt, 1); %pozadovana poloha xc
D = zeros(simulationTime/dt, 2); %poruchy
Y = zeros(simulationTime/dt, 2); %mereni
Y(1,:) = X(1, 1:2) - X_operating(1:2);
Wx(1) = W(1);

d = [0 0];
d1T = 0;
d1t = 0;
d1a = 0;
d2T = 0;
d2t = 0;
d2a = 0;

bonked_k = -1;
k_afterBonk = 0;

%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt
    % Soucasny stav
    X = Xs(k,:);
    
    % Generovani pozadovaneho stavu
    if rand(1) > 0.99      
        W = [(2*rand(1)-1)*0.50, pi, 0, 0];
        %W = [sign(2*rand(1)-1)*0.9, pi, 0, 0];
        %W = [sin(pi/16*k*dt), pi, 0, 0];
        Wrel = W - X_operating;
    end
    
    %% Generovani poruchy
    if rand(1) > 0.99      %sila
        d(1) = randn(1)*.5;
        d1T = randn(1)*100;
        d1t = 0;
        d1a = 1;
        %disp("Porucha d1")
        %disp(d(1))
        %disp(d1T)
    end
    
    if rand(1) > 0.99      %moment
        d(2) = randn(1)*.5;
        d2T = randn(1)*100;
        d2t = 0;
        d2a = 1;
        %disp("Porucha d2")
        %disp(d(2))
        %disp(d2T)
    end
    
    if d1a==1
        d1t = d1t + 1;
        if (d1t >= d1T)
            d(1) = 0;
        end
    end
    
    if d2a==1
        d2t = d2t + 1;
        if (d2t >= d2T)
            d(2) = 0;
            d2a = 0;
        end
    end
    


    %% Regulace
    %definice vstupu a saturace do <-12,12>
    Xr = Xest(k,:) + X_operating;
    if(Xr(1)<0.99 && Xr(1)>-0.99)
        u = -K_lqr * ( Xr' - W' );
        u = min(12, max(-12, u));
    elseif(Xr(1)>0.99)
        u = 0
        disp("!")
    elseif(Xr(1)<-0.99)
        u = 0;
        disp("!")
    end
    
    %% Estimace stavu X
    xe = Xs(k,:)' - X_operating';
    y = Y(k, :)';
    yError = y - C*xe;
    %dxeA = KF.A*xe;
    %dxeB = KF.B * [Wrel'; yError];
    %dxeBW = KF.B(:, 1:4)*Wrel';
    %dxeBYERROR = KF.B(:, 5:6)*yError;
    dxe = KF.A*xe + KF.B*[Wrel'; yError];
    Xest(k+1, :) = xe+dxe*dt; 
       % Xest are coords relative to X_operating

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendulumCart(X,u,d,p), [(k-1)*dt k*dt], X, options);
    
    %mezni polohy xc <-1 1>
    %po odrazu je velikost rychlosti 10% rychlosti pred narazem
    if(Xs(k,1)>1)
        Xs(k,3) = -abs(Xs(k,3)*0);
        Xs(k,1) = 1;
        disp("bonk")
        if(bonked_k==-1)    
            bonked_k = k;
        end
    elseif(Xs(k,1)<-1)
        Xs(k,3) = +abs(Xs(k,3)*0);
        Xs(k,1) = -1;
        disp("bonk")
        if(bonked_k==-1)
            bonked_k = k;
        end
    end
    
	Xs(k+1,:) = xs(end,:);
    Ts(k+1) = ts(end);
    U(k+1) = u;
    Wx(k+1) = W(1);
    D(k+1, :) = d;
    
    % mereni Y
    Y(k+1, :) = C * xs(end,:)' + [randn(1)*0.1 randn(1)*0.1]' - X_operating(1:2)';
    
    
    %% Vizualizace
    
    
    %refresh plotu
    if(mod(k+1,kRefreshPlot)==1)
        %plotRefresh(Ts,Xs,Xest+X_operating,Wx,U,D,Y,k,kRefreshPlot);
    end
    
    %refresh animace
    if(mod(k,kRefreshAnim)==0)
        animRefresh(Xs(k,:),Wx(k,:));
    end
      
    %progress meter a vypocetni cas na 1000 vzorku
    if (mod(k,1000)==0) 
        disp("Computing time: " + toc)
        disp(k + "/" + simulationTime/dt);
        tic
    end
    
    if(bonked_k ~= -1)
        k_afterBonk = k_afterBonk + 1;
    end
    
    if k_afterBonk>1000
        break
    end
    
    waitbar(k*dt/simulationTime,hbar);
end

close(hbar);

sol.X = Xs;
sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.Wx = Wx;
sol.D = D;
sol.Y = Y;
sol.bonked_k = bonked_k;

%vytiskne øe¹ení
sol

save('Results1.mat', 'sol');
