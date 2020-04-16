%%  Zadané hodnoty
clc
clear all 
close all
addpath('functions') % toto pøidá slo¾ku functions do prohlédávaných

%vytvoøení struct pro v¹echny zadané hodnoty systému

p = getParameters();
initializeModel();
%%  Navrh regulatoru
    X_operating = [0 pi 0 0]';
    [A, B] = AB(X_operating, 0);
    Co = [1 0 0 0; 0 1 0 0]; % observed outputs | measuring xc and alpha
    Cr = [1 0 0 0]; % reference outputs
    D = [0; 0];
    
    % Adding an error integrator into the state space description
    % The controller's objective is to follow the reference r
    % with x, where x is the position of the cart
    % The controlled plant already has an integrator, the controller's
    % integrator purpose is to reject constant disturbances, not to
    % remove steady-state error
    Ah = [A, zeros(length(A),1);
         Cr, 0];
    Bh = [B; 0];
 
    Q = diag([25 50 0.1 0.1]);
    R = 0.1;
    K_lqr = lqr(A,B,Q,R);
    disp(eigs(A-B*K_lqr));
    
%     K_lqr = place(A,B,[-1+0.01j, -1-0.01j, -0.5+0.01j, -0.5-0.01j])
%         disp(eigs(A-B*K_lqr));
    
%% Navrh estimatoru
    obsv_ = obsv(A,Co);
    obsvr = rank(obsv_);

    Vd = 1*eye(4); % process noise covariance matrix
    Vd = diag([1 1 1 1]);
    
    Vn = [0.001 0; 0 0.001]; %noise covariance matrix
    
%    L = (lqr(A', Co', Vd, Vn))';
    L = lqe(A,Vd,Co,Vd,Vn);
%     Af = A-Kf*C;
%     Bf = [B Kf];
    Cf = eye(4);
    KF = ss((A-L*Co), B, eye(4), 0);
    disp(eigs(KF.A));

%% Nastaveni pocatecnich hodnot
%pocatecni stav
X0 = [0,pi*19/20,0,0]'; %x, alpha, dx, dalpha
%pozadovany stav
r = 0;
% Wrel = W - X_operating;

%nastaveni solveru
options = odeset();

simulationTime = 5e0;
dt = 0.01; %samplovaci perioda
kRefreshPlot = 100; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 1; % ^

%predalokace poli pro data
X = zeros(4, simulationTime/dt); %skutecny stav
X(:,1) = X0;
DKsi = zeros(1,simulationTime/dt); %odchylka od reference
Ksi = zeros(1,simulationTime/dt);
Xest = zeros(4,simulationTime/dt); %estimovany stav
Xest(:,1) = X0 - X_operating;
Ts = zeros(1,simulationTime/dt);   %spojity cas
U = zeros(1,simulationTime/dt);   %vstupy
U(1) = 0;
u = 0;
R = zeros(1,simulationTime/dt); %reference r
R(1) = r;
D = zeros(2,simulationTime/dt); %poruchy
Y = zeros(2,simulationTime/dt); %mereni
Y(:,1) = X0(1:2) - X_operating(1:2);

%pocatecni porucha
d = [0 0]; %vektor poruch
d1T = 0; %celkove trvani poruchy 1
d1t = 0; %jak dlouho je porucha 1 momentalne aktivni
d1a = 0; %amplituda poruchy 1
d2T = 0;
d2t = 0;
d2a = 0;

%% Simulace
hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt
    % Soucasny stav  
    % Generovani pozadovaneho stavu
    
    %% Generovani poruchy
%     if rand(1) > 0.99      %sila
%         d(1) = randn(1)*5;
%         d1T = randn(1)*2;
%         d1t = 0;
%         d1a = 1;
%         %disp("Porucha d1")
%         %disp(d(1))
%         %disp(d1T)
%     end
%     
%     if rand(1) > 0.99      %moment
%         d(2) = randn(1)*5;
%         d2T = randn(1)*2;
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
               

    %% Regulace
    %definice vstupu a saturace do <-12,12>
    
%     e = [Xest(:,k); Ksi(k)]; %vektor v rozsirenem stavovem prostoru
      x = X(:,k) - X_operating;
%       u = -K_lqr * x;
      u = -K_lqr * Xest(:,k);
%     u = min(12, max(-12, u));
    %% Estimace stavu X
    y_est = Co * Xest(:,k);
    y_msr = Y(:,k);
    y_err = y_msr - y_est;
    Dxe = KF.A*Xest(:,k) + KF.B*u + L*y_err;
    disp("est: " + y_est + "  msr: " + y_msr + "  y_err: " + y_err)
    Xest(:,k+1) = Xest(:,k) + Dxe*dt; % Euler method
    %% Simulace
    
    %"spojite" reseni v intervalu dt, uklada se pouze konecny stav 
    [ts, xs] = ode45(@(t, X_) pendCartC_d(X(:,k),u,d'), [(k-1)*dt k*dt], X(:,k), options);
    
    X(:,k+1) = xs(end,:)';
    Ts(k+1) = ts(end);
    U(k+1) = u;
    R(k+1) = r;
    D(:,k+1) = d;
    
    % mereni Y
    Y(:,k+1) = Co * xs(end,:)' + 0*[ sqrt(Vn(1,1)*randn(1)), sqrt(Vn(2,2)*randn(1)) ]' - X_operating(1:2);

    Dksi(k+1) = r - Y(1,k+1);
    Ksi(k+1) = Ksi(k) + Dksi(k+1);
        

    %% Vizualizace
    
    
    %refresh plotu
    if(mod(k+1,kRefreshPlot)==1)
        %plotRefresh(Ts,Xs,Xest+X_operating,Wx,U,D,Y,k,kRefreshPlot);
    end
    
    %refresh animace
    if(mod(k,kRefreshAnim)==0)
        animRefresh(X(:,k),r);
    end
      
    %progress meter a vypocetni cas na 1000 vzorku
    if (mod(k,1000)==0) 
        disp("Computing time: " + toc)
        disp(k + "/" + simulationTime/dt);
        tic
    end
%     U
%     if(bonked_k ~= -1)
%         k_afterBonk = k_afterBonk + 1;
%     end
    
%     if k_afterBonk>1000
%         break
%     end
    waitbar(k*dt/simulationTime,hbar);
end
close(hbar);



sol.X = X;
sol.Xest = Xest;
sol.T = Ts;
sol.U = U;
sol.R = R;
sol.D = D;
sol.Y = Y;
% sol.bonked_k = bonked_k;
sol.dt = dt;

%vytiskne øe¹ení
sol

save('ResultsLQG1.mat', 'sol');
