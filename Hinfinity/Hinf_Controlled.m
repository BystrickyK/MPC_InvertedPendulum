%%  Zadané hodnoty
clc
clear all 
close all

cd('../');
parentDir = cd('./Hinfinity');
addpath(strcat(parentDir,'/functions')); %enables access to scripts in the folder

p = getParameters();
s = tf('s');
% initializeModel();

%%  Model
    X_operating = [0 0 pi 0]';
    [A, B] = AB(X_operating, 0);
    Co = [1 0 0 0; 0 0 1 0]; % observed outputs | measuring xc and alpha
    Cr = [1 0 0 0]; % reference outputs
    Cf = eye(4); % fully observed outputs
    D = [0; 0];
    Df = [0;0;0;0];

    sys = ss(A,B,Co,D); %plant
    syso = ss(A,B,Cf,Df); %fully observed plant
%% Synteza H-inf kontroleru
% Weight functions 
W1 = makeweight(10,[1 1],0.1);
% W2 = makeweight(0.001, [1 0.0005],0.0001);
W3 = makeweight(0.1,[1 1],10);

% [K,CL,gamma] = mixsyn(sys,W1,W2,W3);
P = augw(sys,W1,0,W3); %create augmented system
[K, CL, gamma] = hinfsyn(P,2,1); %hinf controller synthesis
Controller = @(x,u) K.A*x + K.B*u;

loopsens_ = loopsens(sys,K);
S = loopsens_.Si;
T = loopsens_.Ti;

% vypocet Ms a Mt
[svH, wH] = sigma(S);
Ms = max(svH(1,:));
[svH, wH] = sigma(T);
Mt = max(svH(1,:));
fprintf("Ms = %f dB \n Mt = %f dB\n",mag2db(Ms), mag2db(Mt));
%%
figure
p = sigmaplot(S,'b',K*S,'r',T,'g',gamma/W1,'b-.', gamma/W3, 'g-.');
popt = getoptions(p);
popt.Title.String = 'Sensitivity functions';
popt.Grid = 'on';
setoptions(p,popt)
legend("S", "KS", "T", "gamma/W1", "gamma/W3");

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X0 = [0,0,pi*15/16,0]'; %x, alpha, dx, dalpha
r = -0.2; %reference

simulationTime = 10;
dt = 0.01; %samplovaci perioda

%predalokace poli pro data
X = zeros(4, simulationTime/dt); %skutecny stav
X(:,1) = X0;
T = zeros(1,simulationTime/dt);   %spojity cas
U = zeros(1,simulationTime/dt);   %vstupy
U(1) = 0;
UX = zeros(length(K.A), simulationTime/dt); %vnitrni stav kontroleru
u = 0;
R = zeros(1,simulationTime/dt); %reference r
R(1) = r;
D = zeros(2,simulationTime/dt); %poruchy
Y = zeros(2,simulationTime/dt); %mereni
Y(:,1) = X0(1:2) - X_operating(1:2);

computingTimes = zeros(simulationTime/dt, 1);

d = [0 0];
d1T = 0;
d1t = 0;
d1a = 0;
d2T = 0;
d2t = 0;
d2a = 0;

%% Simulace
uiwait(msgbox('Start simulation?'));

hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt
    
    % Generovani pozadovane reference
%     if rand(1) > 0.999      
%         r = (2*rand(1)-1)*0.50;
%     end         

    %% Regulace
    w = [r 0]';
    e = w-Y(:,k);    
    [~, ux] = ode45(@(t,x) Controller(UX(:,k),e), [(k-1)*dt k*dt], UX(:,k));
    UX(:,k+1) = ux(end,:)';
    u = K.C * UX(:,k+1);
%     u = min(15, max(-15, u)); %saturation
   %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X_) pendCartC_d(X(:,k),u,d'), [(k-1)*dt k*dt], X(:,k));
    
    X(:,k+1) = xs(end,:)';
    T(k+1) = ts(end);
    R(k+1) = r;
    U(k+1) = u;
    
    % measurements Y -> mereni jsou "zkalibrovany" tak, at pro operacni bod
    % jsou vsechny mereni nulova
    Y(:,k+1) = Co * xs(end,:)' - [X_operating(1), X_operating(3)]';

        

    %% Vizualizace
     
    %progress meter a vypocetni cas na 1000 vzorku
    if (mod(k,1000)==0) 
        disp("Computing time: " + toc)
        disp(k + "/" + simulationTime/dt);
        tic
    end

    waitbar(k*dt/simulationTime,hbar);   
    
        %%
    if abs(X(1, k)) > 10 || abs(X(3,k)-pi) > pi/2
        break;
    end
end

close(hbar);

sol.X = X;
sol.R = R;
sol.Xest = X;
sol.T = T;
sol.U = U;
sol.UX = UX;
sol.D = D;
sol.Y = Y;

sol

save(strcat(parentDir,'/results/ResultsHinf.mat'), 'sol');

%% visualize UX vector norm in time
uxnorm = [];
for ux = UX
    uxnorm(end+1) = norm(ux);
end
figure;
plot(uxnorm);
