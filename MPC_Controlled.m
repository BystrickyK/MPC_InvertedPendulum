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

syms Y [1 4]
syms d [1 2]
syms u 
pendCart = pendulumCart(Y,u,d,p);
pendCart = subs(pendCart, d, [0 0]);
matlabFunction(pendCart,...
    'file','functions/pendCartC',...
    'vars', {[Y1; Y2; Y3; Y4], u});


[A,B,C,D] = ABCD(Y,u,p);
matlabFunction(A, B,...
    'file', 'functions/AB',...
    'vars', {[Y1; Y2; Y3; Y4], u});

%%  Navrh regulatoru    
nx = 4;
ny = 2;
nu = 1;
nlobj = nlmpc(nx, ny, nu);

nlobj.PredictionHorizon = 6;
nlobj.ControlHorizon = 6;
dt = 0.075;
nlobj.Ts = dt;

nlobj.Model.StateFcn = 'pendCartC';
nlobj.Jacobian.StateFcn = 'AB';
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;
nlobj.Model.OutputFcn = @(X, u) [X(1); sawtooth(X(2), 0.5)];
%nlobj.Jacobian.OutputFcn = @(X, u) [1 0 0 0; 0 -sin(X(2)) 0 0];

nlobj.Weights.OutputVariables = [8 4];
nlobj.Weights.ManipulatedVariablesRate = 0.001;

nlobj.OV(1).Min = -0.5;
nlobj.OV(1).Max = 0.5;

nlobj.MV.Min = -12;
nlobj.MV.Max = 12;
 
nlobj.Optimization.UseSuboptimalSolution = true;
nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlobj.Optimization.SolverOptions.MaxIter = 5;
nlobj.Optimization.SolverOptions.OptimalityTolerance = 1e-6;
nlobj.Optimization.SolverOptions.UseParallel = true;
nlobj.Optimization.SolverOptions.ConstraintTolerance = 1e-6;
nlobj.Optimization.SolverOptions.FiniteDifferenceStepSize = 10*sqrt(eps);

% nloptions = nlmpcmoveopt;
% nloptions.Parameters = {dt};

X = [0; 0; 0; 0];
validateFcns(nlobj, X, 0, [])

%% Navrh EKF

%EKF = extendedKalmanFilter(@(X, u) pendulumCart(X, u, [0 0], p), ...
%    @(X, u) [X(1); X(2)]);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X = [0, 0, 0, 0]; %alpha, dAlpha, xc, dXc
%EKF.State = X;

%nastaveni solveru
options = odeset();

simulationTime = 24;
dt = dt; %samplovaci perioda
kRefreshPlot = 100; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 5; % ^

%predalokace poli pro data
Xs = zeros(simulationTime/dt, 4); %skutecny stav
Xs(1,:) = X;
Ts = zeros(simulationTime/dt, 1);   %cas
U = zeros(simulationTime/dt, 1);   %vstupy
U(1) = 0;
D = zeros(simulationTime/dt, 2); %poruchy
Y = zeros(simulationTime/dt, 2); %mereni
Y(1,:) = X(1, 1:2);
computingTimes = zeros(simulationTime/dt, 1);
Xc = X;
Tc = [];
%INFO = zeros(simulationTime/dt, 1);

d = [0 0];
d1T = 0;
d1t = 0;
d1a = 0;
d2T = 0;
d2t = 0;
d2a = 0;

yref1 = [0 1];
yref2 = [0 -1];
yref = yref1;

bonked_k = -1;
k_afterBonk = 0;

%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt
    X = Xs(k,:);
%     %% Poruchy
%     if rand(1) > 0.90      %sila
%         d(1) = randn(1)*.5;
%         d1T = randn(1)*5;
%         d1t = 0;
%         d1a = 1;
%         %disp("Porucha d1")
%         %disp(d(1))
%         %disp(d1T)
%     end
%     
%     if rand(1) > 0.90      %moment
%         d(2) = randn(1)*.5;
%         d2T = randn(1)*5;
%         d2t = 0;
%         d2a = 1;
%         %disp("Porucha d2")
%         %disp(d(2))
%         %disp(d2T)
%     end
%     
%     if d1a==1
%         d1t = d1t + 1;
%         if (d1t >= d1T)
%             d(1) = 0;
%         end
%     end
%     
%     if d2a==1
%         d2t = d2t + 1;
%         if (d2t >= d2T)
%             d(2) = 0;
%             d2a = 0;
%         end
%     end
    %% Generovani pozadovaneho stavu
    T = k*dt
    if( mod(T, 4.5) == 0)
        if(yref == yref1)
            yref = yref2;
        else
            yref = yref1;
        end
    end
    
    %% Estimace stavu X
    %xe = correct(EKF, Y(k, :));
    %% Regulace
    tic
    [u, nloptions, info] = nlmpcmove(nlobj, Xs(k,:), U(k), yref, []);
    computingTimes(k) = toc;
    %INFO(k) = info;
%    predict(EKF, [u; dt]);    
%     figure(4)
%     subplot(321)
%     plot(info.Topt, info.Xopt(:,1), 'bo-');
%     grid on
%     subplot(322)
%     plot(info.Topt, info.Xopt(:,2), 'bo-');
%     grid on
%     subplot(323)
%     plot(info.Topt, info.Xopt(:,3), 'ro-');
%     grid on
%     subplot(324)
%     plot(info.Topt, info.Xopt(:,4), 'ro-');
%     grid on
%     subplot(313)
%     stairs(info.Topt, info.MVopt(:,1), 'ko-');
%     grid on
%         
    disp("Computing time: " + computingTimes(k))
    disp(k + "/" + simulationTime/dt);

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendulumCart(X,u,d,p), [(k-1)*dt k*dt], X, options);

	Xs(k+1,:) = xs(end,:);
    Xs(k+1, 2) = mod(Xs(k+1, 2), 2*pi);
    Ts(k+1) = ts(end);
    U(k+1) = u;
    %Wx(k+1) = W(1);
    D(k+1, :) = d;
    Xc = [Xc; xs];
    Tc = [Tc; ts];
    
    % mereni Y
    Y(k+1, :) = C * xs(end,:)' + [randn(1)*0.001 randn(1)*0.001]';
    
    
    %% Vizualizace
    
    
    %refresh plotu
    if(mod(k+1,kRefreshPlot)==1)
       %plotRefresh(Ts,Xs,Xest+X_operating,Wx,U,D,Y,k,kRefreshPlot);
    end
    
    %refresh animace
    if(mod(k,kRefreshAnim)==0)
%         animRefresh(Ts,Xs,[],k);
    end
      
    %progress meter a vypocetni cas na 1000 vzorku
%     if (mod(k,1)==0) 
%         disp("Computing time: " + toc)
%         disp(k + "/" + simulationTime/dt);
%         tic
%     end
    
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
sol.Xc = Xc;
sol.Tc = Tc;
%sol.INFO = INFO;
sol.bonked_k = bonked_k;
sol.controller = nlobj;
sol.computingTimes = computingTimes;

%vytiskne øe¹ení
sol

    figure('Name', 'Computing times')
    bar(Ts(1:end-1), computingTimes);
    grid on

save('ResultsMPC11.mat', 'sol');
