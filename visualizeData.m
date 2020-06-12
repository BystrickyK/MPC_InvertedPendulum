
close all
addpath('functions')
addpath('results')

% nazev souboru dat, ktery se ma vizualizovat
datafile = "ResultsHinf"
data = load(strcat(datafile,".mat"));
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


kRefreshPlot = 24; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 3; % ~ ^

 filename = strcat(datafile,".gif");
%     fig = figure('visible','off'); % getframe function for gif creation
%     runs 4x slower if figure is invisible
%     animRefresh(X(:,1), Xest(:,1), R(1), U(1), D(1)); %LQG
%     frame = getframe(gcf);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    
for k = 2:1:samples-1
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0)
        plotRefresh(Ts,X,Xest,R,U,D,Y,k,kRefreshPlot); %LQG
%         plotRefresh(Ts,X,Xest,[],U,D,Y,k,kRefreshPlot); %MPC
    end
    
    if(mod(k,kRefreshAnim)==0)
        animRefresh(X(:,k), Xest(:,k), R(k), U(k), D(k)); %LQG
% %         animRefresh(X(:,k), Xest(:,k), [], U(k), D(1,k)); %MPC
        titleString = strcat("Time: ", string(Ts(k)), " s");
        title(titleString);
%         
%         frame = getframe(gcf);
%         im = frame2im(frame);
%         [imind,cm] = rgb2ind(im,256);
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
    end
        
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
    end
    
        %%
    if abs(X(1, k)) > 10 || abs(X(3,k)-pi) > pi/2
        break;
    end
    
end
