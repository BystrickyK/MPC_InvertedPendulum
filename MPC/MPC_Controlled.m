%%  Init
clc
clear all 
close all

cd('../');
parentDir = cd('./MPC');
addpath(parentDir);
addpath(strcat(parentDir,'/functions')); 
addpath(strcat(parentDir,'/results')); 
C = [1 0 0 0; 0 0 1 0];
p = getParameters();
%%  Navrh NLMPC  
nx = 4;
ny = 2;
nu = 1;
nlmpcobj = nlmpc(nx, ny, nu);

nlmpcobj.PredictionHorizon = 20;
nlmpcobj.ControlHorizon = 10;
MPC_Ts = 0.05;
nlmpcobj.Ts = MPC_Ts;

nlmpcobj.Model.StateFcn = 'pendCartC';
nlmpcobj.Jacobian.StateFcn = 'AB';
nlmpcobj.Model.IsContinuousTime = true;
nlmpcobj.Model.OutputFcn = @(X, u) [X(1); X(3)];

nlmpcobj.Weights.OutputVariables = [1 2];
nlmpcobj.Weights.ManipulatedVariablesRate = 0.0001;

nlmpcobj.OutputVariables(1).Min = -0.35;
nlmpcobj.OutputVariables(1).Max = 0.35;



nlmpcobj.MV.Min = -8;
nlmpcobj.MV.Max = 8;
 
% nlmpcobj.Optimization.UseSuboptimalSolution = true;
% nlmpcobj.Optimization.SolverOptions.MaxIter = 50;
% nlobj.Optimization.SolverOptions.UseParallel = true;
nlmpcobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlmpcobj.Optimization.SolverOptions.Display = 'none';

X = [0; 0; 0; 0];
validateFcns(nlmpcobj, X, 0, [])

%% Prevod na linearni MPC v pracovnim bode X_operating
X_operating = [0, 0, pi, 0];
mpcobj = convertToMPC(nlmpcobj, X_operating, 0);
%% Navrh EKF

EKF = extendedKalmanFilter(@(X,u) pendCartD(X,u), ...
                           @(X) [X(1); X(3)]);
EKF.MeasurementNoise = diag([1 1]);
EKF.ProcessNoise = diag([1 5 1 5]);

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X0 = [0 0 pi*31/32 0]'; %xc dxc alpha dalpha
EKF.State = X0;
u = 0;
%nastaveni solveru
options = odeset();

simulationTime = 20;
MPC_Ts = MPC_Ts; %samplovaci perioda

%predalokace poli pro data
X = zeros(4, simulationTime/MPC_Ts); %skutecny stav
X(:,1) = X0;
Xest = zeros(4,simulationTime/MPC_Ts); %estimovany stav
Xest(:,1) = X0;
Ts = zeros(1,simulationTime/MPC_Ts);   %spojity cas
U = zeros(1,simulationTime/MPC_Ts);   %vstupy
U(1) = u;
D = zeros(2,simulationTime/MPC_Ts); %poruchy
Y = zeros(2,simulationTime/MPC_Ts); %mereni
Y(:,1) = [X0(1), X0(3)];
Rf = zeros(2,simulationTime/MPC_Ts); %reference
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

yref1 = [0 pi];
yref2 = [0 pi];

mpc_state = mpcstate;
mpc_state.Plant = X_operating;
mpc_state.LastMove = 0;
[~, info] = mpcmove(mpcobj, mpc_state, [], yref1,[]);

yref = yref1;

%% Uprava parametru
inertia_coeff = 1;
p.J_p = p.J_p*inertia_coeff %moment setrvacnosti kyvadla
p.M_p = p.M_p*inertia_coeff %hmotnost kyvadla
p.l_p = p.l_p*inertia_coeff %polovina delky kyvadla
p.k_m = p.k_m * 1; %torque coefficient
p.k_t = p.k_m;
p.J_eq = p.J_eq * inertia_coeff; %equivalent LINEAR cart inertia

%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*MPC_Ts + "s");
for k = 1:simulationTime/MPC_Ts
    %% Generovani pozadovaneho stavu
    T = mod(k*MPC_Ts, 20);
    
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
        tic
        mpc_state.Plant = X(:,k);
%         mpc_state.LastMove = U(:,k);
        [u, info] = mpcmove(mpcobj,mpc_state,[],yref,[]);
        computingTime = toc;
        computingTimes = [computingTimes, computingTime];
        INFO = [INFO info];
% %               %Vizualizace predikce
%               figure(4)
%               for i = 1:2
%                   subplot(4,2,i)
%                   plot(info.Topt, info.Yopt(:,i), 'ko-')
%                   grid on
%               end
%               for i = 3:6
%                   subplot(4,2,i)
%                   plot(info.Topt, info.Xopt(:,i-2), 'ko-')
%                   grid on
%               end
%               subplot(414)
%               stairs(info.Topt, info.Uopt(:,1), 'ko-');
%               grid on

              %Vypocetni cas
%               disp("Computing time: " + computingTimes(end))
%               disp(k + "/" + simulationTime/MPC_Ts); 

    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X) pendCartC_symbolicPars(X,u,d,p), [(k-1)*MPC_Ts k*MPC_Ts], X(:,k), options);
    X(:,k+1) = xs(end,:)';
    Ts(k+1) = ts(end);
    U(k+1) = u;
    D(:,k+1) = d;
    Rf(:,k+1) = yref;
    %% Mereni a predikce EKF
    Y(:,k+1) = C * xs(end,:)' + [randn(1)*0.002 randn(1)*0.002]';  
    predict(EKF, u);

    waitbar(k*MPC_Ts/simulationTime,hbar);
 end

close(hbar);

sol.X = X;
sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.R = Rf';
sol.D = D;
sol.Y = Y;
sol.dt = MPC_Ts;
sol.INFO = INFO;
sol.controller = mpcobj;
sol.computingTimes = computingTimes;

%vytiskne øe¹ení
sol

    figure('Name', 'Computing times')
    bar(Ts(1:end-1), computingTimes);
    grid on

save(strcat(parentDir,'/results/ResultsMPC.mat'), 'sol');

%% Vizualizace vysledku
visualizeData('ResultsMPC');

