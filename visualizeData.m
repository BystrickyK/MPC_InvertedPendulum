clc
close all

data = load('Results.mat');
data = data.sol;

samples = length(data.X);

Xs = data.X;
Xest = data.Xest;
Ts = data.T;
U = data.U;
Wx = data.Wx;
D = data.D;
Y = data.Y;
bonked_k = data.bonked_k

kRefreshPlot = 100; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 5; % ^


tic

for k = 1:1:samples
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0)
        plotRefresh(Ts,Xs,Xest+[0 pi 0 0],Wx,U,D,Y,k,kRefreshPlot);
    end
    if(mod(k,kRefreshAnim)==0)
        %animRefresh(Ts,Xs,Wx,k);
    end
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
        tic
    end
end