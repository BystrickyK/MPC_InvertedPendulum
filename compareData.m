%%  Init
clc
clear all 
close all

addpath('measurementData');
addpath('functions');
data = load('msrDataSwingup1.mat');
p = getParameters();
%%
data = data.Data
Ts = data.Time;
X = data.Data(:,[1 3 2 4])';
X(3,:) = X(3,:)+pi;
X2 = zeros(size(X));
T2 = zeros(size(Ts));
U = data.Data(:,5);
samples = length(Ts)

%% uprava parametru
p.J_p = p.J_p*0.8
p.l_P = p.l_p*0.9
p.M_p = p.M_p*0.9
%%

dt = 0.002;
hbar = waitbar(0,'Simulation Progress');
for k = 1:samples
    
    u = U(k);
    [ts, x] = ode45(@(t,X) pendCartC_symbolicPars(X,u,[0 0],p), [(k-1)*dt, k*dt], X2(:,k));
    T2(k) = ts(end);
    X2(:,k+1) = x(end,:)';
    
    
    waitbar(k/samples,hbar);
end
close(hbar);
for i=1:10
    sound(30);
    pause(0.1);
end
%%
kRefreshPlot = 100;
kRefreshAnim = 20;
X = single(X);
X2 = single(X2);
Ts = single(Ts);
U = single(U);

figure;
hAx = gobjects(2*4,1);
for i=1:4
hAx(i) = subplot(2,4,i);
plot(Ts,X(i,:),'b');
hAx(i+4) = subplot(2,4,i+4);
plot(T2,X2(i,1:end-1),'r');
end

figure;
for k = 3000:1:samples-1
if(mod(k,kRefreshAnim)==0)
    animRefresh(X(:,k), X2(:,k), 0, U(k), 0); 
    titleString = strcat("Time: ", string(Ts(k)), " s");
    title(titleString)
    xlim(hAx,[k*dt-10 k*dt]);
end   
end