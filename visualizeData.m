
close all
addpath('functions')
addpath('gif')
addpath('results')


data = load('ResultsNLMPC.mat');
data = data.sol;

samples = length(data.X);

X = data.X;
Xest = data.Xest;
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


kRefreshPlot = 50; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 8; % ~ ^

for k = 2:1:samples-1
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0)
%         plotRefresh(Ts,X,Xest,R,U,D,Y,k,kRefreshPlot); %LQG
%         plotRefresh(Ts,X,Xest,[],U,D,Y,k,kRefreshPlot); %MPC
    end
    
    if(mod(k,kRefreshAnim)==0)
%         animRefresh(X(:,k), Xest(:,k), R(k), U(k), D(k)); %LQG
        animRefresh(X(:,k), Xest(:,k), [], U(k), D(1,k)); %MPC
        title(k)
    end
        
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
    end
    
end
