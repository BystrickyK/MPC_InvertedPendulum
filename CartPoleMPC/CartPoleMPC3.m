% Cart-pole (inverted pendulum) MPC 

%% model

M=0.40;
m=0.20;
l=0.30;
b=0.002;
g=9.81;
a=10;

p.M=M;
p.m=m;
p.l=l;
p.b=b;
p.g=g;
p.a=a;

x=[0;pi/8;0;0];
%x=[0;pi;0;0];
u=0;

dx=cartpolemodel1(x,u,p)

%% sim

dt=0.01;

w=0.1; % width
xxmin=-0.8;
xxmax=0.8;


Ni=1e3;

for i=1:Ni

        
%     if(rand>0.98)
%         u=0.5*(2*rand-1);
%     end
    
    
    [th,xh] = ode45(@(t,x)cartpolemodel1(x,u,p),[0 dt],x);
    x=xh(end,:)';
    
    xx=x(1);
    th=x(2);
    if(xx>xxmax || xx<xxmin)
%          x(1)=min(xx,xxmax*0.99);
%          x(1)=max(xx,xxmin*0.99);
        x(3)=-1*x(3);
    end
    
    plot([xx xx+l*2*sin(th)],[0 l*2*cos(th)],'b')
    hold on
    plot(x(1)+w*[-1 +1 +1 -1 -1]/2,w*[-1 -1 1 1 -1]/4,'k')
    plot(x(1)+[0 0],-w/4*[-1 1],'k')
    plot(x(1)+[0 u],[0 0],'r')
    
    hold off
    axis equal;
    xlim([-2 2]); ylim([-1 1]); grid on;   
    
    drawnow
%     i
  break
end

%   return

%% linear model

% dxx
% dth
% (-m*g*th-b*dxx+a*u)/M;
% ((M+m)*g*th+b*dxx-a*u )/M/l;

A=[ 0	0           1       0
    0	0           0       1
    0	-m*g/M      -b/M	0 
    0   (M+m)*g/M/l	b/M/l	0 ];

B=[ 0
    0
    a/M
    -a/M/l ];

C=[ 1 0 0 0
    0 1 0 0 ];
    
x0=[0;0;0;0];
u0=0;

% num jac:
% [~,~,~,~,~,~,jacx] = lsqnonlin(@(x)cartpolemodel1(x,u0,p),x0);
% An=full(jacx)
% 
% [~,~,~,~,~,~,jacu] = lsqnonlin(@(u)cartpolemodel1(x0,u,p),u0);
% Bn=full(jacu)

% [e1 e2]=eig(A);

sysc=ss(A,B,C,[]);

%% LQR :
% Qr=diag([1 10 1 100])
Qr=diag([1 10 0 1e-1])
% Rr=1e-3
Rr=1

[Sc,ec,Kc]=care(sysc.A,sysc.B,Qr,Rr);

% u=-Kc*x
sysclqr=ss(sysc.A-sysc.B*Kc,sysc.B*0,C,[]);

dt1=dt;0.05;

t1=[0:dt1:5]';
u1=t1*0;
x1=[0;pi/4;0;0];

% lsim(sysclqr,u1,t1,x1)


% time discrete
sysd=c2d(sysc,dt1);
[Sd,ed,Kd]=dare(sysd.A,sysd.B,Qr,Rr); % should be Qrd,Rrd
%  [Kd,Sd,Ed] = lqrd(A,B,Qr,Rr,[],dt1)

sysdlqr=ss(sysd.A-sysd.B*Kd,sysd.B*0,C,[],dt1);

lsim(sysclqr,sysdlqr,u1,t1,x1)

% [ych,tch,xch] = lsim(sysclqr,u1,t1,x1) 
% plot(tch,xch*C',tch, [ xch*Kc'],'k')
% 
% [ydh,tdh,xdh] = lsim(sysdlqr,u1,t1,x1) 
% plot(tdh,xdh*C',tdh, [ xdh*Kd'],'k')


%% sim with LQR

x=[0;pi/4;0;0];

umin=-10;
umax=+10;

% close;
% figure(1);

Ni=5/dt;

Nx=4;
uh=zeros(Ni,1);
xh=zeros(Ni,Nx);

for i=1:Ni

    u=-Kd*x;
    
    uh(i)=u;
    
%     if(u>umax || u<umin)
%         u
%     end
    u=min(max(u,umin),umax); % limits
    
    [tt,xt] = ode45(@(t,x)cartpolemodel1(x,u,p),[0 dt],x);
    x=xt(end,:)';
    
    xh(i,:)=x';
    
    % bounds:
    xx=x(1);
    th=x(2);
    if(xx>xxmax || xx<xxmin)
%          x(1)=min(xx,xxmax*0.99);
%          x(1)=max(xx,xxmin*0.99);
        x(3)=-1*x(3);
    end
    
    plot([xx xx+2*l*sin(th)],[0 2*l*cos(th)],'b')
    hold on
    plot(x(1)+w*[-1 +1 +1 -1 -1]/2,w*[-1 -1 1 1 -1]/4,'k')
    plot(x(1)+[0 0],-w/4*[-1 1],'k')
    plot(x(1)+[0 u],[0 0],'r')
    
    hold off
    axis equal;
    xlim([-2 2]); ylim([-1 1]); grid on;   
    pause(dt)
    drawnow
%     i
 break
end


stairs((1:Ni)*dt,uh,'k-')
hold on
plot((1:Ni)*dt,xh)
hold off
grid on

% return

%% estimator

Qe=1e0*diag([1;1;10;10]);
Re=1e2*diag([1;1]);

% Qe=Bd*Qd*Bd'

[Sed,eed,Ked]=dare(sysd.A',sysd.C',Qe,Re);
Led=Ked';

% sim with LQR

x=[0;0;0;0];

% close;
% figure(1);

Ni=20/dt;

uh=zeros(Ni,1);
xh=zeros(Ni,Nx);

rxc=0;
r=[rxc;0;0;0];
rh=zeros(Ni,Nx);

xe=[0;0;0;0];
xeh=zeros(Ni,Nx);

for i=1:Ni
    
    if(mod(i*dt,.1)==0 && rand>0.95)
        rxc=0.5*(2*rand-1);
        r=[rxc;0;0;0];
    end
    rh(i,:)=rxc;
    
    u=-Kd*(xe-r);
    
    uh(i)=u;
    
%     if(u>umax || u<umin)
%         u
%     end
    u=min(max(u,umin),umax); % limits
    
    [tt,xt] = ode15s(@(t,x)cartpolemodel1(x,u,p),[0 dt],x);
    x=xt(end,:)';
    xh(i,:)=x';
    
%     x=x+diag([0;0;1e-4;1e-3])*randn(4,1);% disturbance
    
    % estimation:
    xe=sysd.A*xe+sysd.B*u;
    ym=C*x +diag([1e-3;1e-3])*randn(2,1); % meas+ noise
    xe=xe+Led*(ym-C*xe);
    xeh(i,:)=xe';
    
    
    
    % bounds:
    xx=x(1);
    th=x(2);
    if(xx>xxmax || xx<xxmin)
%          x(1)=min(xx,xxmax*0.99);
%          x(1)=max(xx,xxmin*0.99);
        x(3)=-1*x(3);
    end
    
    if(mod(i*dt,.1)==0)
    figure(1);
    plot([xx xx+2*l*sin(th)],[0 2*l*cos(th)],'b')
    hold on
    plot(x(1)+w*[-1 +1 +1 -1 -1]/2,w*[-1 -1 1 1 -1]/4,'k')
    plot(x(1)+[0 0],-w/4*[-1 1],'k')
    plot(x(1)+[0 u],[0 0],'r')
    
    plot(rxc,2*l,'mo')
    
    hold off
    axis equal;
    xlim([-2 2]); ylim([-1 1]); grid on;   
%     pause(dt)

    figure(2);
    stairs((1:i)*dt,uh(1:i),'k-')
    hold on
    set(gca,'ColorOrderIndex',1)
    plot((1:i)*dt,xh(1:i,:))
    set(gca,'ColorOrderIndex',1)
    plot((1:i)*dt,xeh(1:i,:),'.')
    plot((1:i)*dt,rh(1:i,:),'b--')
    hold off
    grid on
    xlim([0 Ni*dt])

    drawnow
    end
%     i
end


% stairs((1:Ni)*dt,uh,'k-')
% hold on
% set(gca,'ColorOrderIndex',1)
% plot((1:Ni)*dt,xh)
% set(gca,'ColorOrderIndex',1)
% plot((1:Ni)*dt,xeh,'.')
% hold off
% grid on

