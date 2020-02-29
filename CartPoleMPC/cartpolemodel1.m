function dx=cartpolemodel1(x,u,p)
% cart-pole model

% x=[0;0;0;0]
% u=0.1

xc  =  x(1);
th  =  x(2);
dxc =  x(3);
dth =  x(4);

%pars:
M=p.M;
m=p.m;
l=p.l;
b=p.b;
g=p.g;
a=p.a;

% eqs
sth=sin(th);
cth=cos(th);

ddth = ((M+m)*g*sth-(m*l*dth^2*sth-b*dxc+a*u)*cth)...
        /(M+m*sth^2)/l;

ddxc = (-m*g*sth*cth+m*l*dth^2*sth-b*dxc+a*u)...
        /(M+m*sth^2);

dx=[dxc; dth; ddxc; ddth];
