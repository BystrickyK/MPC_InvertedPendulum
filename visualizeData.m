clc
close all
addpath('functions')
addpath('gif')
addpath('results')


data = load('ResultsMPC11.mat');
data = data.sol;

samples = length(data.X);

Xs = data.X;
Xest = data.Xest;
Ts = data.T;
U = data.U;
D = data.D;
Y = data.Y;
if (isfield(data, 'Wx'))
    Wx = data.Wx;   
end

if (isfield(data, 'computingTimes'))
    computingTimes = data.computingTimes;
    figure("Name", "Computing times")
    bar(Ts(1:end-1), computingTimes);
    grid on
end


kRefreshPlot = 5; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 1; % ^

        %animRefresh(Ts,Xs,[],1);
        %gif('NLMPC_Swingup_dt10_sawtooth_highV.gif')
for k = 2:1:samples-1
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0)
       plotRefresh(Ts,Xs,Xest,[],U,D,Y,k,kRefreshPlot);
    end
    
    if(mod(k,kRefreshAnim)==0)
        animRefresh(Ts,Xs,[],k);
        title(k)
        %gif
    end
        
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
        tic
    end
    
    pause(0.05)
end
