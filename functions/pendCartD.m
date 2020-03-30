function Yk1 = pendCartD(Yk0,uk,Ts)
    M = 100;
    delta = Ts/M;
    Yk1 = Yk0;
    for ct=1:M
        Yk1 = Yk1 + delta*pendCartC(Yk1,uk);
    end
end