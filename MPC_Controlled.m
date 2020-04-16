%%  Zadané hodnoty
clc
clear all 
close all
addpath('functions') % toto pøidá slo¾ku functions do prohlédávaných

% Definice parametr? soustavy
p = getParameters();

initializeModel();
C = [1 0 0 0; 0 1 0 0];
%%  Navrh regulatoru    
nx = 4;
ny = 2;
nu = 1;
nlobj = nlmpc(nx, ny, nu);

nlobj.PredictionHorizon = 10;
nlobj.ControlHorizon = 5;
dt = 0.1;
nlobj.Ts = dt;

nlobj.Model.StateFcn = 'pendCartC';
nlobj.Jacobian.StateFcn = 'AB';
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;
nlobj.Model.OutputFcn = @(X, u) [X(1); sawtooth(X(2), 0.5)];

nlobj.Weights.OutputVariables = [8 4];
nlobj.Weights.ManipulatedVariablesRate = 0.01;

nlobj.OV(1).Min = -0.5;
nlobj.OV(1).Max = 0.5;

nlobj.MV.Min = -12;
nlobj.MV.Max = 12;
 
%nlobj.Optimization.UseSuboptimalSolution = true;
%  nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
%nlobj.Optimization.SolverOptions.MaxIter = 5;
% nlobj.Optimization.SolverOptions.OptimalityTolerance = 1e-6;
% nlobj.Optimization.SolverOptions.UseParallel = true;
% nlobj.Optimization.SolverOptions.ConstraintTolerance = 1e-6;
% nlobj.Optimization.SolverOptions.FiniteDifferenceStepSize = 10*sqrt(eps);

% nloptions = nlmpcmoveopt;
% nloptions.Parameters = {dt};

X = [0; 0; 0; 0];
validateFcns(nlobj, X, 0, [])

%% Navrh EKF

EKF = extendedKalmanFilter(@(X, u)pendCartD(X,u,dt/10), ...
                           @(X) [X(1); X(2)]);
EKF.MeasurementNoise = diag([0.01 0.01]);
EKF.ProcessNoise = 1*eye(4);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X = [0 0 0 0]; %alpha, dAlpha, xc, dXc
EKF.State = X;
u = 0;
%nastaveni solveru
options = odeset();

simulationTime = 42;
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
computingTimes = [];
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

yref1 = [0 0.8];
yref2 = [0 -1];
yref = yref1;

%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt*10
    %% Generovani pozadovaneho stavu
    T = mod(k*dt/10, 10);
    
    if( mod(T, 0) == 0)
            yref = yref1;
            
    elseif( mod(T, 6.5) == 0)
            yref = yref1;
    end
       
        %% Generovani poruchy
    if rand(1) > 0.99      %sila
        d(1) = randn(1)*5;
        d1T = randn(1)*15;
        d1t = 0;
        d1a = 1;
        %disp("Porucha d1")
        %disp(d(1))
        %disp(d1T)
    end
    
    if rand(1) > 0.99      %moment
        d(2) = randn(1)*5;
        d2T = randn(1)*15;
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
    
    %% Estimace stavu X; pouziti mereni pro korekci predpovedi
    Xest(k,:) = correct(EKF, Y(k, :));
    %% Regulace
    if(mod(k,10)==0)
        
        tic
        [u, nloptions, info] = nlmpcmove(nlobj, Xest(k,:), U(k), yref, []);
        computingTimes = [computingTimes, toc];

              %Vizualizace predikce
              figure(4)
              for i = 1:4
                  subplot(3,2,i)
                  plot(info.Topt, info.Xopt(:,i), 'ko-')
                  grid on
              end
              subplot(313)
              stairs(info.Topt, info.MVopt(:,1), 'ko-');
              grid on

              %Vypocetni cas
              disp("Computing time: " + computingTimes(end))
              disp(k + "/" + simulationTime/dt);
    end

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendulumCart_symbolicPars(X,u,d,p), [(k-1)*dt/10 k*dt/10], Xs(k,:), options);

	Xs(k+1,:) = xs(end,:);
    Ts(k+1) = ts(end);
    U(k+1) = u;
    %Wx(k+1) = W(1);
    D(k+1, :) = d;
    Xc = [Xc; xs];
    Tc = [Tc; ts];
    
    %% Mereni a predikce EKF
    Y(k+1, :) = C * xs(end,:)' + [randn(1)*0 randn(1)*0]';  
    predict(EKF, u);

    waitbar(k*dt/simulationTime/10,hbar);
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
sol.dt = dt;
%sol.INFO = INFO;
% sol.bonked_k = bonked_k;
sol.controller = nlobj;
sol.computingTimes = computingTimes;

%vytiskne øe¹ení
sol

    figure('Name', 'Computing times')
    bar(Ts(1:10:end-1), computingTimes);
    grid on

save('results/ResultsMPC12.mat', 'sol');
