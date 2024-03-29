function [] = visualizeData(datafile)

close all
addpath('functions')
addpath('results')

% nazev souboru dat, ktery se ma vizualizovat
% datafile = "ResultsNLMPC"
data = load(strcat(datafile,".mat"));
data = data.sol;

samples = length(data.X)

X = data.X;
Xest = data.Xest;
Ts = data.T;
U = data.U;
D = data.D;
Y = data.Y;

if (isfield(data, 'R'))
    Rf = data.R;
else
    Rf = zeros(length(U));
end

dt = Ts(2)-Ts(1);
% if (isfield(data, 'computingTimes'))
%     computingTimes = data.computingTimes;
%     figure("Name", "Computing times")
%     bar(Ts(1:10:end-1), computingTimes);
%     grid on
% end


kRefreshPlot = 20; %vykresluje se pouze po kazdych 'kRefreshPlot" samplech
kRefreshAnim = 2 % ~ ^

%  filename = strcat(datafile,".gif");
%     fig = figure('visible','off'); % getframe function for gif creation
%     runs 4x slower if figure is invisible
%     animRefresh(X(:,1), Xest(:,1), R(1), U(1), D(1)); %LQG
%     frame = getframe(gcf);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%% Vytvoreni grafu
figure;
% hAx = gobjects(2*4,1);
hAx = gobjects(4,1);
titlestrings = ["$x_c \; [m]$", "$\dot{x_c} \; [\frac{m}{s}]$",...
    "$\alpha \; [rad]$", "$\dot{\alpha} \; [\frac{rad}{s}$]"];
ylabelstrings = titlestrings;
xlabelstring = "$Time \; [s]$"

for i=1:4

    hAx(i) = subplot(2,2,i);
    plot(Ts,X(i,:),'b');
    hold on;
    plot(Ts(1:end-1),Xest(i,:),'r:');
    
    % set titles and labels
    hAx(i).Title.String = titlestrings(i);
    hAx(i).Title.Interpreter = 'latex';
    hAx(i).Title.FontSize = 14;

    hAx(i).XLabel.String = xlabelstring;
    hAx(i).XLabel.Interpreter = 'latex';
    hAx(i).XLabel.FontSize = 12;

    hAx(i).YLabel.String = ylabelstrings(i);
    hAx(i).YLabel.Interpreter = 'latex';
    hAx(i).YLabel.FontSize = 12;

end
plot(Ts,Rf(:,1),'g-.', 'Parent', hAx(1));

for k = 2:1:samples-1
    %% Vizualizace
    if(mod(k,kRefreshPlot)==0) xlim(hAx,[k*dt-10 k*dt]); end
    
    if(mod(k,kRefreshAnim)==0)
        animRefresh(X(:,k), Xest(:,k), Rf(k,1), U(k), D(k));
        titleString = strcat("Time: ", string(Ts(k)), " s");
        title(titleString)      
%         frame = getframe(gcf);
%         im = frame2im(frame);
%         [imind,cm] = rgb2ind(im,256);
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
    end
        
    if(mod(k,10000)==0)
        disp("Time for 10000 samples:" + toc)
    end
      
end
