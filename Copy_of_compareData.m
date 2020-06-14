%%  Init
clc
clear all 
close all

addpath('measurementData');
addpath('functions');
data = load('msrDataSwingup1.mat');
data = load('msrData1noU.mat');
p = getParameters();
%%
data = data.Data
Ts = data.Time;
X = data.Data(:,:)';
X1 = X(2:5,:);
X1(3,:) = X1(3,:) - 0.3384;
X2 = X(6:9,:);
X2(3,:) = X2(3,:) - 0.3384;
% X2 = zeros(size(X));
% T2 = zeros(size(Ts));
% U = data.Data(:,5);
samples = length(Ts)

%% uprava parametru
p.J_p = p.J_p
p.l_P = p.l_p
p.M_p = 0.127
p.l_p = p.l_p
p.M_c = 0.68;
%%

dt = 0.002;
% hbar = waitbar(0,'Simulation Progress');
% for k = 1:samples
%     
%     [ts, x] = ode45(@(t,X) pendCartC_symbolicPars(X,0,[0 0],p), [(k-1)*dt, k*dt], X2(:,k));
%     T2(k) = ts(end);
%     X2(:,k+1) = x(end,:)';
%     
%     
%     waitbar(k/samples,hbar);
% end
% 
% close(hbar);
% for i=1:10
%     sound(30);
%     pause(0.1);
% end
%%
kRefreshPlot = 100;
kRefreshAnim = 20;
X1 = single(X1);
X2 = single(X2);
Ts = single(Ts);

figure;
hAx = gobjects(2*4,1);
for i=1:4
hAx(i) = subplot(2,4,i);
plot(Ts,X1(i,:),'b');
hAx(i+4) = subplot(2,4,i+4);
plot(Ts,X2(i,:),'r');
end
% 
% 
%  filename = strcat('comparison',".gif");
%     fig = figure('visible','off'); % getframe function for gif creation
% %    runs 4x slower if figure is invisible
%     animRefresh(X(:,1), X2(:,1), 0, U(1), 0);
%     frame = getframe(gcf);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 

figure;
for k = 2:1:samples
if(mod(k,kRefreshAnim)==0)
    animRefresh(X1(:,k), X2(:,k), 0, 0, 0); 
    titleString = strcat("Time: ", string(Ts(k)), " s");
    title(titleString)
    xlim(hAx,[k*dt-10 k*dt]);
%     
%         frame = getframe(gcf);
%         im = frame2im(frame);
%         [imind,cm] = rgb2ind(im,256);
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
end   
end