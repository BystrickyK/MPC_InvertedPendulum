clc
close all
addpath('functions')


data = load('ResultsMPC.mat');
data = data.sol;

samples = length(data.X);

Xs = data.X;
%Xest = data.Xest;
Ts = data.T;
U = data.U;
%Wx = data.Wx;
D = data.D;
Y = data.Y;
bonked_k = data.bonked_k

kRefreshPlot = 10; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 1; % ^


tic

for k = 1:1:samples
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0)
        plotRefresh(Ts,Xs,[],[],U,D,Y,k,kRefreshPlot);
    end
    if(mod(k,kRefreshAnim)==0)
        animRefresh(Ts,Xs,[],k);
    end
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
        tic
    end
end