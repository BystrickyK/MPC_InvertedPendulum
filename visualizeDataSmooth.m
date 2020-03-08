clc
close all

addpath('functions')
addpath('gifs_results')


data = load('ResultsMPC10.mat');
data = data.sol;
Xc = data.Xc;
Tc = data.Tc;
computingTimes = data.computingTimes;

samples = length(Tc);

kRefreshPlot = 10; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 1; % ^

% figure("Name", "Computing times")
% bar(Ts(1:end-1), computingTimes);

animRefresh(Xc(1,:), []);
%gif('NLMPC_Swingup_dt10_sawtooth_vhighV.gif')
for k = 2:15:samples
    %% Vizualizace
    
    if(mod(k,kRefreshAnim)==0)
        animRefresh(Xc(k,:),[]);
        title(Tc(k))
        %gif
    end   
    
end