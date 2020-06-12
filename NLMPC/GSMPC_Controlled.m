%%  Zadané hodnoty
clc
clear all 
close all
addpath('functions') % toto pøidá slo¾ku functions do prohlédávaných

% Definice parametr? soustavy
p = getParameters();

initializeModel();
C = [1 0 0 0; 0 0 1 0];
%%  Navrh NLMPC   
nx = 4;
ny = 2;
nu = 1;
nlmpc = nlmpc(nx, ny, nu);

nlmpc.PredictionHorizon = 15;
nlmpc.ControlHorizon = 5;
dt = 0.1;
nlmpc.Ts = dt;

nlmpc.Model.StateFcn = 'pendCartC';
nlmpc.Jacobian.StateFcn = 'AB';
nlmpc.Model.IsContinuousTime = true;
nlmpc.Model.NumberOfParameters = 0;
nlmpc.Model.OutputFcn = @(X, u) [X(1); sawtooth(X(3), 0.5)];

nlmpc.Weights.OutputVariables = [4 4];
nlmpc.Weights.ManipulatedVariablesRate = 0.2;

 
% nlobj.Optimization.UseSuboptimalSolution = true;
% nlobj.Optimization.SolverOptions.MaxIter = 5;
% nlobj.Optimization.SolverOptions.OptimalityTolerance = 1e-6;
% nlobj.Optimization.SolverOptions.UseParallel = true;
% nlobj.Optimization.SolverOptions.ConstraintTolerance = 1e-6;
% nlobj.Optimization.SolverOptions.FiniteDifferenceStepSize = 10*sqrt(eps);

% nloptions = nlmpcmoveopt;
% nloptions.Parameters = {dt};

X = [0; 0; 0; 0];
validateFcns(nlmpc, X, 0, [])

%% Navrh MPC

MPC_operatingPoints = [0 0 0 0;
          0 0 pi/2 0;
          0 0 pi 0;
          0 0 3/2*pi 0];
inputs = [0;0;0;0];

% MPCarray = convertToMPC(nlmpc,states,inputs);
MPCArray = {};
MPCState = {};
for i = 1:length(MPC_operatingPoints)
    MPC = convertToMPC(nlmpc,MPC_operatingPoints(i,:), inputs(i));
    setEstimator(MPC,'custom');
    State = mpcstate(MPC);
    MPCState{end+1} = State;
    MPCArray{end+1} = MPC;
end


%% Navrh EKF

EKF = extendedKalmanFilter(@(X, u)pendCartD(X,u,dt/10), ...
                           @(X) [X(1); X(3)]);
EKF.MeasurementNoise = diag([0.01 0.01]);
EKF.ProcessNoise = 1*eye(4);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X0 = [0 0 0 0]'; %xc dxc alpha dalpha
EKF.State = X;
u = 0;
%nastaveni solveru
options = odeset();

simulationTime = 20;
dt = dt; %samplovaci perioda
kRefreshPlot = 100; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 5; % ^


%predalokace poli pro data
X = zeros(4, simulationTime/dt); %skutecny stav
X(:,1) = X0;
Xest = zeros(4,simulationTime/dt); %estimovany stav
Xest(:,1) = X0;
Ts = zeros(1,simulationTime/dt);   %spojity cas
U = zeros(1,simulationTime/dt);   %vstupy
U(1) = 0;
D = zeros(2,simulationTime/dt); %poruchy
Y = zeros(2,simulationTime/dt); %mereni
Y(:,1) = [X0(1), X0(3)];
computingTimes = [];

d = [0 0]';
d1T = 0;
d1t = 0;
d1a = 0;
d2T = 0;
d2t = 0;
d2a = 0;

yref1 = [0 1];
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
            yref = yref2;
    end
    %% Estimace stavu X; pouziti mereni pro korekci predpovedi
    Xest(:,k) = correct(EKF, Y(:,k));
    %% Regulace
    if(mod(k,10)==0)
        
        %% Vybrat MPC
        alpha = mod(Xest(3,k),2*pi);
        if alpha<(2/6*pi) || alpha>(10/6*pi)
            mpc = 1;
        elseif alpha>(2/6*pi)|| alpha<(4/6*pi)
            mpc = 2;
        elseif alpha>(4/6*pi) || alpha<(8/6*pi)
            mpc = 3;
        elseif alpha>(8/6*pi) || alpha<(10/6*pi)
            mpc = 4;
        end
        
        tic
%         [u, nloptions, info] = nlmpcmove(nlmpc, Xest(:,k), U(k), yref, []);
%         [u, info] = mpcmoveMultiple(MPCarray,states,mpc,[]
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
    [ts, xs] = ode45(@(t, X) pendCartC_d(X,u,d), [(k-1)*dt/10 k*dt/10], X(:,k), options);
        
    X(:,k+1) = xs(end,:)';
    Ts(k+1) = ts(end);
    U(k+1) = u;
    D(:,k+1) = d;
    %% Mereni a predikce EKF
    Y(:,k+1) = C * xs(end,:)' + [randn(1)*0.01 randn(1)*0.01]';  
    predict(EKF, u);

    waitbar(k*dt/simulationTime/10,hbar);
    end

close(hbar);

sol.X = X;
sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.D = D;
sol.Y = Y;
sol.dt = dt;
%sol.INFO = INFO;
% sol.bonked_k = bonked_k;
sol.controller = nlmpc;
sol.computingTimes = computingTimes;

%vytiskne øe¹ení
sol

    figure('Name', 'Computing times')
    bar(Ts(1:10:end-1), computingTimes);
    grid on

save('results/ResultsMPC12.mat', 'sol');
