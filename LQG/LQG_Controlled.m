%% Init
clc
clear all 
close all

tmp = cd('..\');
parentDir = cd('.\LQG');
addpath(strcat(parentDir,'\functions')); %enables access to scripts in the folder

%%  Model
    X_operating = [0 0 pi 0]';
    [A, B] = AB(X_operating, 0);
    Co = [1 0 0 0; 0 0 1 0]; % observed outputs | measuring xc and alpha
    Cr = [1 0 0 0]; % reference outputs
    D = [0; 0];
    
    % Adding an error integrator into the state space description
    % The controller's objective is to follow the reference r
    % with the variable x_c, where x_c is the position of the cart
    % The controlled plant already has an integrator, the controller's
    % integrator purpose is to reject constant disturbances, not to
    % remove steady-state error. 
    Ah = [A, zeros(length(A),1);
         -Cr, 0];
    Bh = [B; 0];
    Cho = [1 0 0 0 0; 0 0 1 0 0];
    Dh = [0;0];
    
    Gi = ss(Ah,Bh,Cho,Dh,...
        'StateName', {'x1','x2','x3','x4','Ksi'},...
        'OutputName', {'x_c','alpha'}); %added integrator
    G = ss(A,B,Co,D,...
        'StateName', {'x1','x2','x3','x4'},...
        'OutputName', {'x_c','alpha'}); %original system
    Go = ss(A,B,eye(4),zeros(4,1),...
        'StateName', {'x1','x2','x3','x4'},...
        'OutputName', {'x_c','dx_c','alpha','dalpha'}); %fully observed system
    
    figure;
    iopzmap(Go);
    title("Pole-zero map of the plant");
%%  Navrh regulatoru
    ctrb_ = ctrb(G.A,G.B);
    ctrbr = rank(ctrb_)

    Q = diag([5 0.1 1 0.1]); %P
%     Q = diag([1 0.1 1 0.1 5]); %I  / PI
    R = 0.1;
    [K,S,e] = lqr(G.A,G.B,Q,R);
    K = lqr(G,Q,R);
    
    % Plotting open loop poles and zeros
    Ksys = tf(K);
    ol = G;
    eigs(ol.A)
    figure;
    subplot(121);
    iopzmap(ol);
    title("Open loop system pole-zero map");
    subplot(122);
    nyquist(ol);
    
    % Plotting closed loop poles and zeros
    cl = feedback(Go,Ksys); %using the fully observed system
    eigs(cl.A)
    figure;
    iopzmap(cl);
    title("Closed loop system pole-zero map");
    
    % Sensitivity functions
    loopsens_ = loopsens(Go,-Ksys);
    S = loopsens_.Si;
    T = loopsens_.Ti;
    KS = K*S;
    
    % Calculate M_S and M_T
    [svH, wH] = sigma(S);
    Ms = max(svH(1,:));
    [svH, wH] = sigma(T);
    Mt = max(svH(1,:));
    fprintf("Ms = %f dB \n Mt = %f dB\n",mag2db(Ms), mag2db(Mt));

    % Plotting sensitivity functions
    figure
    p = sigmaplot(S,'b',K*S,'r',T,'g');
    hold on
    yline(0);
    popt = getoptions(p);
    popt.Title.String = 'Sensitivity functions';
    popt.Grid = 'on';
    setoptions(p,popt)
    legend("S", "KS", "T", "0 dB");
    
%% Navrh estimatoru
    obsv_ = obsv(G.A,G.C);
    obsvr = rank(obsv_)

    % process noise covariance matrix
    Vd = diag([5 10 5 10]);
    % noise covariance matrix
    Vn = [0.02 0; 0 0.05];
    
%     [kest,L,P] = kalman(Ge,Vd,Vn);
     L = lqe(G.A,Vd,G.C,Vd,Vn);
%   L = (lqr(A', Co', Vd, Vn))';

    Cf = eye(4);
    KF = ss((G.A-L*G.C), [G.B L], Cf, 0);
   
    eigs(KF.A)
    figure;
    pzplot(KF);
    title("Estimator pole-zero map")
%% Nastaveni pocatecnich hodnot
%pocatecni stav
X0 = [0,0,pi,0]'; %x, alpha, dx, dalpha
%pozadovany stav x_cr
r = 1;

%nastaveni solveru
options = odeset();

simulationTime = 10;
dt = 0.01; %samplovaci perioda
kRefreshPlot = 10; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 2; % ^

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
d = [0 0]'; %vektor poruch
d1T = 0; %celkove trvani poruchy 1
d1t = 0; %jak dlouho je porucha 1 momentalne aktivni
d1a = 0; %amplituda poruchy 1

%% Simulace
uiwait(msgbox('Start simulation?'));

hbar = waitbar(0,'Simulation Progress');
tic
disp("1000 samples = " + 1000*dt + "s");
for k = 1:simulationTime/dt
    
    % Generovani pozadovane reference
%     if rand(1) > 0.995
%         r = (2*rand(1)-1)*1
%     end               

    %% Regulace
    %definice vstupu a saturace do <-6,6>
    
      e = [Xest(:,k)]; %vektor v rozsirenem stavovem prostoru
      e(1) = -r + e(1); % adds proportional ref tracking
      u = -K * e;
      u = min(12, max(-12, u));
     
      if mod(k,500)==0
          for i = 1:length(e)
              str = sprintf("k%d * e%d = %f", i,i,-K(i)*e(i));
              disp(str);
          end
        str = sprintf("u = %f \n",u);
        disp(str);
      end
    %% Estimace stavu X
    y_msr = Y(:,k);
    Dxe = KF.A*Xest(:,k) + KF.B*[u ;y_msr];
%     disp("est: " + y_est + "  msr: " + y_msr + "  y_err: " + y_err)
    Xest(:,k+1) = Xest(:,k) + Dxe*dt; % Euler method
    %% Simulace
    
    % Krok simulace o dt
    [ts, xs] = ode45(@(t, X_) pendCartC_d(X(:,k),u,d), [(k-1)*dt k*dt], X(:,k));
    
    % Ukladaji se pouze hodnoty na konci simulacniho kroku
    X(:,k+1) = xs(end,:)';
    Ts(k+1) = ts(end);
    U(k+1) = u;
    R(k+1) = r;
    D(:,k+1) = d;
    
    % mereni Y
    Y(:,k+1) = Co * xs(end,:)' - [X_operating(1), X_operating(3)]';

    % error integration
    Dksi(k+1) = r - Y(1,k+1);
    Ksi(k+1) = Ksi(k) + dt*Dksi(k); %euler method
        

    %% Vizualizace
     
    %refresh plotu
    if(mod(k+1,kRefreshPlot)==1)
%         plotRefresh(Ts,X,Xest+X_operating,R,U,D,Y,k,kRefreshPlot);
    end
       
    %progress meter a vypocetni cas na 1000 vzorku
    if (mod(k,1000)==0) 
        disp("Computing time: " + toc)
        disp(k + "/" + simulationTime/dt);
        tic
    end

    waitbar(k*dt/simulationTime,hbar);
    
    %%
    if abs(X(1, k)) > 10 || abs(X(3,k)-pi) > pi
        break;
    end
    
end
close(hbar);



sol.X = X;
sol.Xest = Xest+X_operating;
sol.T = Ts;
sol.U = U;
sol.R = R;
sol.D = D;
sol.Y = Y;
sol.dt = dt;
sol.info.Q = Q;
sol.info.R = R;
sol.info.K = K;
sol.info.Vn = Vn;
sol.info.Vd = Vd;
sol.info.L = L;

sol

save(strcat(parentDir,'/results/LQG-PI-Test.mat'), 'sol');
