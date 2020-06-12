function X = pendCartD(X,u)
    M = 2;
    delta = 0.01/M;
    xk = X;
    for ct=1:M
        xk = xk + delta*pendCartC(xk,u);
    end
    X=xk;
end