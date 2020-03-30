function [] = initializeModel()
    % Vytvori .m files s dosazenými parametry modelu pro urychlení výpo?t?
    % pendCartC.m -> spojitý, nelineární model soustavy
    % AB.m -> symbolické A a B matice -> pro linearizaci v libovolném
    % bod? stavového prostoru
    
    % Definice parametr? soustavy
    p = getParameters();

    % Dosazení známých parametr? do stavových rovnic nelineárního modelu
    % Neznámé "?ídící" prom?nné jako stavový vektor |Y|, poruchy |d|, a ak?ní
    % veli?ina |u| se dosadí jako symbolické.
    syms Y [4 1] %   Y [1 4] = stavový vektor, sloupcový 4x1 
    syms d [2 1]
    syms u
    % Vytvo?íme symbolické rovnice s dosazenými parametry
    dXdt = pendulumCart_symbolicPars(Y,u,d,p);
    % Za poruchu dosazuji 0. Poruchy jsou dve, jedna pro sílu a jedna pro
    % moment -> porucha d je vektor 2x1
    dXdt_incl_d = dXdt;
    dXdt = subs(dXdt, d, [0 0]');
    % Ze symbolické rovnice vytvo?íme function handler, který uložíme jako .m
    % file do složky functions. Vytvo?ená funkce vrací 4x1 vektor dY.
    matlabFunction(dXdt,...
        'file','functions/pendCartC',...
        'vars', {[Y1; Y2; Y3; Y4], u});
    
        matlabFunction(dXdt_incl_d,...
        'file','functions/pendCartC_d',...
        'vars', {[Y1; Y2; Y3; Y4], u, [d1; d2]});

    % Podobn? se postupuje p?i dosazování parametr? do rovnice linearizovaného
    % popisu. Vytvo?ená funkce vrací dv? matice, A a B.
    [A,B] = AB_symbolicPars(Y,u,p);
    % AX + BU -> dXdt linearizované
    matlabFunction(A, B,...
        'file', 'functions/AB',...
        'vars', {[Y1; Y2; Y3; Y4], u});    
end