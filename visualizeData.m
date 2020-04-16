clc
close all
addpath('functions')
addpath('gif')
addpath('results')


data = load('ResultsLQG1.mat');
data = data.sol;

samples = length(data.X);

X = data.X;
%Xest = data.Xest;
Ts = data.T;
U = data.U;
D = data.D;
Y = data.Y;
if (isfield(data, 'R'))
    R = data.R;   
end

if (isfield(data, 'computingTimes'))
    computingTimes = data.computingTimes;
    figure("Name", "Computing times")
    bar(Ts(1:10:end-1), computingTimes);
    grid on
end


kRefreshPlot = 25; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 1; % ~ ^

for k = 2:1:samples-1
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0)
%        plotRefresh(Ts,Xs,Xest,[],U,D,Y,k,kRefreshPlot); % MPC
%        plotRefresh(Ts,Xs,Xest+X_operating,Wx,U,D,Y,k,kRefreshPlot); %LQG
%        plotRefresh(Ts,Xs,[],[],U,D,Y,k,kRefreshPlot); % Hinf
    end
    
    if(mod(k,kRefreshAnim)==0)
%         animRefresh(Xs,[],k); %MPC
%         animRefresh(Xs,Wx,k); %LQG
    animRefresh(X(:,k), R(k)); % Hinf
        title(k)
    end
        
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
    end
    
end
