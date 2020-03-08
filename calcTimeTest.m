addpath('functions')
clc

ts1 = zeros(1,1000);
ts2 = zeros(1,1000);
ts3 = zeros(1,1000);
ts4 = zeros(1,1000);
ts5 = zeros(1,1000);
ts6 = zeros(1,1000);

fh_ABCD = @(X,u) ABCD(X,u,p);
fh_pendCart = @(X,u,d) pendulumCart(X,u,d,p);

for i = 1:1000
    tic;
    Asol = fh_ABCD([0 i/1000 0 0], 0);
    ts1(i) = toc;
    tic;
    Asol = ABCD([0 i/1000 0 0], 0, p);
    ts2(i) = toc;
    tic;
    Asol = A_fh([0; i/1000; 0; 0], 0);
    ts5(i) = toc;
    tic;
    XSol = fh_pendCart([0 i/100 i/1000 0], i/10000, [0 0]);
    ts3(i) = toc;
    tic;
    XSol = pendulumCart([0 i/100 i/1000 0], i/10000, [0 0], p);
    ts4(i) = toc;
    tic;
    XSol = pendCart_fh([0; i/100; i/1000; 0], i/10000, [0; 0]);
    ts6(i) = toc;
end

disp("A fh:" + sum(ts1) + "s");
disp("A:" + sum(ts2) + "s");
disp("A no p:" + sum(ts5) + "s")
disp("dX fh:" + sum(ts3) + "s");
disp("dX:" + sum(ts4) + "s")
disp("dX no p:" + sum(ts6) + "s")

