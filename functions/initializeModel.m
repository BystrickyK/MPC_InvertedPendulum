function [] = initializeModel()
    % Vytvori .m files s dosazenými parametry modelu pro urychlení výpo?t?
    % pendCartC.m -> spojitý, nelineární model soustavy
    % AB.m -> symbolické A a B matice -> pro linearizaci v libovolném
    % bod? stavového prostoru
    
    % Definice parametr? soustavy
    p = getParameters();
    
    p_real = p;
    p_real ...
    % Dosazení známých parametr? do stavových rovnic nelineárního modelu
    % Neznámé "?ídící" prom?nné jako stavový vektor |X|, poruchy |d|, a ak?ní
    % veli?ina |u| se dosadí jako symbolické.
    syms X [4 1] %   X [1 4] = stavový vektor, sloupcový 4x1 
    syms d [2 1]
    syms u
    % Vytvo?íme symbolické rovnice s dosazenými parametry
    dXdt = pendCartC_symbolicPars(X,u,d,p);
    % Za poruchu dosazuji 0. Poruchy jsou dve, jedna pro sílu a jedna pro
    % moment -> porucha d je vektor 2x1
    dXdt_incl_d = dXdt;
    dXdt = subs(dXdt, d, [0 0]');
    % Ze symbolické rovnice vytvo?íme function handler, který uložíme jako .m
    % file do složky functions. Vytvo?ená funkce vrací 4x1 vektor dY.
    matlabFunction(dXdt,...
        'file','functions/pendCartC',...
        'vars', {[X1; X2; X3; X4], u});
    
        matlabFunction(dXdt_incl_d,...
        'file','functions/pendCartC_d',...
        'vars', {[X1; X2; X3; X4], u, [d1; d2]});

    % Podobn? se postupuje p?i dosazování parametr? do rovnice linearizovaného
    % popisu. Vytvo?ená funkce vrací dv? matice, A a B.
    [A,B] = AB_symbolicPars(X,u,p);
    % AX + BU -> dXdt linearizované
    matlabFunction(A, B,...
        'file', 'functions/AB',...
        'vars', {[X1; X2; X3; X4], u});    
end