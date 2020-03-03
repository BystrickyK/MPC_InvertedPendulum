%%  Zadan� hodnoty
clc
clear all 
close all
addpath('functions') % toto p�id� slo�ku functions do prohl�d�van�ch

%vytvo�en� struct pro v�echny zadan� hodnoty syst�mu

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
    
nx = 4;
ny = 2;
nu = 1;
dt = 0.1;
nlobj = nlmpc(nx, ny, nu);

nlobj.PredictionHorizon = 20;
nlobj.ControlHorizon = 5;
dt = 0.05;
nlobj.Ts = dt;

nlobj.Model.StateFcn = @(X, u) pendulumCart(X ,u ,[0 0],p);
nlobj.Jacobian.StateFcn = @(X, u) ABCD(X, u, p);
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;
nlobj.Model.OutputFcn = @(X, u) [X(1); X(2)];
nlobj.Jacobian.OutputFcn = @(X, u) [1 0 0 0; 0 1 0 0];

nlobj.Weights.OutputVariables = [3 3];

nlobj.OV(1).Min = -1;
nlobj.OV(1).Max = 1;

nlobj.MV.Min = -25;
nlobj.MV.Max = 25;

validateFcns(nlobj, X_operating, 0, [])

%% Navrh EKF

%EKF = extendedKalmanFilter(@(X, u) pendulumCart(X, u, [0 0], p), ...
%    @(X, u) [X(1); X(2)]);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X = [0, 0, 0, 0]; %alpha, dAlpha, xc, dXc
%EKF.State = X;

%nastaveni solveru
options = odeset();

simulationTime = 8;
dt = dt; %samplovaci perioda
kRefreshPlot = 100; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 1; % ^

%predalokace poli pro data
Xs = zeros(simulationTime/dt, 4); %skutecny stav
Xs(1,:) = X;
Ts = zeros(simulationTime/dt, 1);   %cas
U = zeros(simulationTime/dt, 1);   %vstupy
U(1) = 0;
%Wx = zeros(simulationTime/dt, 1); %pozadovana poloha xc
D = zeros(simulationTime/dt, 2); %poruchy
Y = zeros(simulationTime/dt, 2); %mereni
Y(1,:) = X(1, 1:2);
%Wx(1) = W(1);

d = [0 0];
d1T = 0;
d1t = 0;
d1a = 0;
d2T = 0;
d2t = 0;
d2a = 0;

yref1 = [0 0];
yref2 = [0 pi];

bonked_k = -1;
k_afterBonk = 0;

%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt
    X = Xs(k,:);
    %% Generovani pozadovaneho stavu
    if k*dt < 5
        yref = yref2;
    else
        yref = yref1;
    end
    
    %% Estimace stavu X
    %xe = correct(EKF, Y(k, :));
    %% Regulace
    [u, nloptions, info] = nlmpcmove(nlobj, Xs(k,:), U(k), yref, []);
    %predict(EKF, [u; dt]);    
    u

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendulumCart(X,u,d,p), [(k-1)*dt k*dt], X, options);
    
%     %mezni polohy xc <-1 1>
%     %po odrazu je velikost rychlosti 10% rychlosti pred narazem
%     if(Xs(k,1)>1)
%         Xs(k,3) = -abs(Xs(k,3)*0);
%         Xs(k,1) = 1;
%         disp("bonk")
%         if(bonked_k==-1)    
%             bonked_k = k;
%         end
%     elseif(Xs(k,1)<-1)
%         Xs(k,3) = +abs(Xs(k,3)*0);
%         Xs(k,1) = -1;
%         disp("bonk")
%         if(bonked_k==-1)
%             bonked_k = k;
%         end
%     end
%     
	Xs(k+1,:) = xs(end,:);
    Ts(k+1) = ts(end);
    U(k+1) = u;
    %Wx(k+1) = W(1);
    D(k+1, :) = d;
    
    % mereni Y
    Y(k+1, :) = C * xs(end,:)' + [randn(1)*0.001 randn(1)*0.001]';
    
    
    %% Vizualizace
    
    
    %refresh plotu
    if(mod(k+1,kRefreshPlot)==1)
       %plotRefresh(Ts,Xs,Xest+X_operating,Wx,U,D,Y,k,kRefreshPlot);
    end
    
    %refresh animace
    if(mod(k,kRefreshAnim)==0)
        animRefresh(Ts,Xs,[],k);
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
%sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.D = D;
sol.Y = Y;
sol.bonked_k = bonked_k;

%vytiskne �e�en�
sol

save('ResultsMPC.mat', 'sol');
