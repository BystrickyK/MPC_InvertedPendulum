function [] = animRefresh(Ts, Xs, W, k)
    
    figure(2);
    % animaci lze zrychlit pomocí úpravy kroku, nap?. p?i 1:3:rows_ se
    % vykresluje pouze každý t?etí vzorek
        alpha = Xs(k, 2);
        xc = Xs(k, 1);

        %poloha kyvadla
        [xp, yp] = pol2cart(alpha-pi/2, 0.5);
        %% vykreslovani
        cla
        hold on
        grid on

        axis equal
        %xlim([xc*1-0.1-L_p*0.5, xc*1+0.1+L_p*0.5])
        xlim([-2, 2]);
        ylim([-1, 1]);

        quiver( xc, 0,...
            xp, yp,...
            'Color', 'Black',...
            'LineWidth', 2,...
            'Marker', '*');
        
        plot(W(1), 0.5, 'bO');

        drawnow
    end
