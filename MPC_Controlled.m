%%  Zadan� hodnoty
clc
clear all 
close all
addpath('functions') % toto p�id� slo�ku functions do prohl�d�van�ch

% Definice parametr? soustavy
p = getParameters();

% Dosazen� zn�m�ch parametr? do stavov�ch rovnic neline�rn�ho modelu
% Nezn�m� "?�d�c�" prom?nn� jako stavov� vektor |Y|, poruchy |d|, a ak?n�
% veli?ina |u| se dosad� jako symbolick�.
syms Y [1 4] %   Y [1 4] = stavov� vektor, sloupcov� 4x1 
syms d [1 2]
syms u
% Vytvo?�me symbolick� rovnice s dosazen�mi parametry
dXdt = pendulumCart(Y,u,d,p);
% Za poruchu dosazuji 0. Poruchy jsou dv?, jedna pro s�lu a jedna pro
% moment -> proto je porucha d vektor 2x1
dXdt = subs(dXdt, d, [0 0]);
% Ze symbolick� rovnice vytvo?�me function handler, kter� ulo��me jako .m
% file do slo�ky functions. Vytvo?en� funkce vrac� 4x1 vektor dY.
matlabFunction(dXdt,...
    'file','functions/pendCartC',...
    'vars', {[Y1; Y2; Y3; Y4], u});

% Podobn? se postupuje p?i dosazov�n� parametr? do rovnice linearizovan�ho
% popisu. Vytvo?en� funkce vrac� dv? matice, A a B.
[A,B,C,~] = ABCD(Y,u,p);
matlabFunction(A, B,...
    'file', 'functions/AB',...
    'vars', {[Y1; Y2; Y3; Y4], u});

%%  Navrh regulatoru    
nx = 4;
ny = 2;
nu = 1;
nlobj = nlmpc(nx, ny, nu);

nlobj.PredictionHorizon = 5;
nlobj.ControlHorizon = 5;
dt = 0.1;
nlobj.Ts = dt;

nlobj.Model.StateFcn = 'pendCartC';
nlobj.Jacobian.StateFcn = 'AB';
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;
nlobj.Model.OutputFcn = @(X, u) [X(1); sawtooth(X(2), 0.5)];

nlobj.Weights.OutputVariables = [8 4];
nlobj.Weights.ManipulatedVariablesRate = 0.0001;

nlobj.OV(1).Min = -0.5;
nlobj.OV(1).Max = 0.5;

nlobj.MV.Min = -12;
nlobj.MV.Max = 12;
 
nlobj.Optimization.UseSuboptimalSolution = true;
nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlobj.Optimization.SolverOptions.MaxIter = 8;
nlobj.Optimization.SolverOptions.OptimalityTolerance = 1e-6;
nlobj.Optimization.SolverOptions.UseParallel = true;
nlobj.Optimization.SolverOptions.ConstraintTolerance = 1e-6;
nlobj.Optimization.SolverOptions.FiniteDifferenceStepSize = 10*sqrt(eps);

% nloptions = nlmpcmoveopt;
% nloptions.Parameters = {dt};

X = [0; 0; 0; 0];
validateFcns(nlobj, X, 0, [])

%% Navrh EKF

EKF = extendedKalmanFilter(@(X, u)pendCartD(X,u), ...
                           @(X) [X(1); X(2)]);
EKF.MeasurementNoise = 5*eye(2);
EKF.ProcessNoise = 1*eye(4);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X = [0 0 0 0]; %alpha, dAlpha, xc, dXc
EKF.State = X;

%nastaveni solveru
options = odeset();

simulationTime = 40;
dt = dt; %samplovaci perioda
kRefreshPlot = 100; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 5; % ^

%predalokace poli pro data
Xs = zeros(simulationTime/dt, 4); %skutecny stav
Xs(1,:) = X;
Xest(1,:) = X;
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
    %% Generovani pozadovaneho stavu
    T = k*dt
    if( mod(T, 4.5) == 0)
        if(yref == yref1)
            yref = yref2;
        else
            yref = yref1;
        end
    end
    
    %% Estimace stavu X; pouziti mereni pro korekci predpovedi
    Xest(k,:) = correct(EKF, Y(k, :));
    %% Regulace
    tic
    [u, nloptions, info] = nlmpcmove(nlobj, Xest(k,:), U(k), yref, []);
    computingTimes(k) = toc;
    
          %Vizualizace predikce
%           figure(4)
%           for i = 1:4
%               subplot(3,2,i)
%               plot(info.Topt, info.Xopt(:,i), 'ko-')
%               grid on
%           end
%           subplot(313)
%           stairs(info.Topt, info.MVopt(:,1), 'ko-');
%           grid on
        
          %Vypocetni cas
          disp("Computing time: " + computingTimes(k))
          disp(k + "/" + simulationTime/dt);

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendulumCart(X,u,d,p), [(k-1)*dt k*dt], Xs(k,:), options);

	Xs(k+1,:) = xs(end,:);
    Ts(k+1) = ts(end);
    U(k+1) = u;
    %Wx(k+1) = W(1);
    D(k+1, :) = d;
    Xc = [Xc; xs];
    Tc = [Tc; ts];
    
    %% Mereni a predikce EKF
    Y(k+1, :) = C * xs(end,:)' + [randn(1)*0.01 randn(1)*0.01]';  
    predict(EKF, u);

    waitbar(k*dt/simulationTime,hbar);
end

close(hbar);

sol.X = Xs;
sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.D = D;
sol.Y = Y;
sol.Xc = Xc;
sol.Tc = Tc;
%sol.INFO = INFO;
% sol.bonked_k = bonked_k;
sol.controller = nlobj;
sol.computingTimes = computingTimes;

%vytiskne �e�en�
sol

    figure('Name', 'Computing times')
    bar(Ts(1:end-1), computingTimes);
    grid on

save('results/ResultsMPC11.mat', 'sol');
