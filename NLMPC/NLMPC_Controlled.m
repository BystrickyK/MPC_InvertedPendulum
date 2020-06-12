%%  Init
clc
clear all 
close all

cd('../');
parentDir = cd('./NLMPC');
addpath(strcat(parentDir,'/functions')); %enables access to scripts in the folder
C = [1 0 0 0; 0 0 1 0];
%%  Navrh regulatoru    
nx = 4;
ny = 2;
nu = 1;
nlobj = nlmpc(nx, ny, nu);


nlobj.PredictionHorizon = 15;
nlobj.ControlHorizon = 5;
dt = 0.1;
nlobj.Ts = dt;

nlobj.Model.StateFcn = 'pendCartC';
nlobj.Jacobian.StateFcn = 'AB';
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;
% nlobj.Model.OutputFcn = @(X, u) [X(1); sawtooth(X(3), 0.5)];
triangleWaveFourier3 = @(x) 8/pi^2 * (sin(x) - 1/9*sin(3*x) + 1/25*sin(5*x));
nlobj.Model.OutputFcn = @(X, u) [X(1); triangleWaveFourier3(X(3)-pi/2)];

nlobj.Weights.OutputVariables = [8 4];
nlobj.Weights.ManipulatedVariablesRate = 0.05;

%  nlobj.OV(1).Min = -0.33;
%  nlobj.OV(1).Max = 0.33;
%  
nlobj.MV.Min = -5;
nlobj.MV.Max = 5;
 
nlobj.Optimization.UseSuboptimalSolution = true;
nlobj.Optimization.SolverOptions.MaxIter = 7;
% nlobj.Optimization.SolverOptions.UseParallel = true;
nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlobj.Optimization.SolverOptions.Display = 'none';

X = [0; 0; 0; 0];
validateFcns(nlobj, X, 0, [])

%% Navrh EKF

EKF = extendedKalmanFilter(@(X,u) pendCartD(X,u), ...
                           @(X) [X(1); X(3)]);
EKF.MeasurementNoise = diag([1 1]);
EKF.ProcessNoise = diag([1 5 1 5]);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X0 = [0 0 0 0]'; %xc dxc alpha dalpha
EKF.State = X;
u = 0;
%nastaveni solveru
options = odeset();

simulationTime = 15;
dt = dt; %samplovaci perioda

%predalokace poli pro data
X = zeros(4, simulationTime/dt); %skutecny stav
X(:,1) = X0;
Xest = zeros(4,simulationTime/dt); %estimovany stav
Xest(:,1) = X0;
Ts = zeros(1,simulationTime/dt);   %spojity cas
U = zeros(1,simulationTime/dt);   %vstupy
U(1) = u;
D = zeros(2,simulationTime/dt); %poruchy
Y = zeros(2,simulationTime/dt); %mereni
Y(:,1) = [X0(1), X0(3)];
computingTimes = [];
computingTimes2 = [];
INFO = [];

d = [0 0]';
d1T = 0;
d1t = 0;
d1a = 0;
d2T = 0;
d2t = 0;
d2a = 0;

yref1 = [0 1];
[~, nloptions_ref1] = nlmpcmove(nlobj, [0 0 0 0], 0, yref1,[]);
yref2 = [0 -1];


yref = yref1;

nloptions = nloptions_ref1; %initial guess
%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt*10
    %% Generovani pozadovaneho stavu
    T = mod(k*dt/10, 15);
    
    if( T == 0)
            yref = yref1;
    elseif( T == 12)
            yref = yref2;
    end
       
%         %% Generovani poruchy
%     if rand(1) > 0.99      %sila
%         d(1) = randn(1)*3;
%         d1T = randn(1)*30;
%         d1t = 0;
%         d1a = 1;
%         %disp("Porucha d1")
%         %disp(d(1))
%         %disp(d1T)
%     end
%     
%     if d1a==1
%         d1t = d1t + 1;
%         if (d1t >= d1T)
%             d(1) = 0;
%         end
%     end
    %% Estimace stavu X; pouziti mereni pro korekci predpovedi
    Xest(:,k) = correct(EKF, Y(:,k));
    %% Regulace
    if(mod(k,10)==0)
        tic
        [u, nloptions, info] = nlmpcmove(nlobj,Xest(:,k),U(k),yref,[],nloptions);
        computingTime = toc
        computingTimes = [computingTimes, computingTime];
        INFO = [INFO info];
%               %Vizualizace predikce
%               figure(4)
%               for i = 1:4
%                   subplot(3,2,i)
%                   plot(info.Topt, info.Xopt(:,i), 'ko-')
%                   grid on
%               end
%               subplot(313)
%               stairs(info.Topt, info.MVopt(:,1), 'ko-');
%               grid on
% 
%               %Vypocetni cas
%               disp("Computing time: " + computingTimes(end))
%               disp(k + "/" + simulationTime/dt*10);
    end
    
    u = min(10, max(-10, u));
     

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendCartC_d(X,u,d), [(k-1)*dt/10 k*dt/10], X(:,k), options);
    X(:,k+1) = xs(end,:)';
    Ts(k+1) = ts(end);
    U(k+1) = u;
    D(:,k+1) = d;
    %% Mereni a predikce EKF
    Y(:,k+1) = C * xs(end,:)' + [randn(1)*0.002 randn(1)*0.002]';  
    predict(EKF, u);

    waitbar(k*dt/simulationTime/10,hbar);
    end

close(hbar);

sol.X = X;
sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.R = yref;
sol.D = D;
sol.Y = Y;
sol.dt = dt;
sol.INFO = INFO;
sol.controller = nlobj;
sol.computingTimes = computingTimes;

%vytiskne øe¹ení
sol

    figure('Name', 'Computing times')
    bar(Ts(1:10:end-1), computingTimes);
    grid on

save(strcat(parentDir,'/results/ResultsNLMPC.mat'), 'sol');
