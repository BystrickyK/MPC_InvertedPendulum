function x = pendCartD(x,u)
    M = 2;
    delta = 0.01/M;
    xk = x;
    for ct=1:M
        xk = xk + delta*pendCartC(xk,u);
    end
    x=xk;
end