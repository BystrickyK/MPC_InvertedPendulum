function Xkk = pendCartD(Xk,uk)
    M = 2;
    delta = 0.01/M;
    Xkk = Xk;
    for ct=1:M
        Xkk = Xkk + delta*pendCartC(Xkk,uk);
    end
end