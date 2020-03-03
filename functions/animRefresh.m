function [] = animRefresh(Ts, Xs, Wx, k)
    
    figure(2);
    % animaci lze zrychlit pomocí úpravy kroku, napø. p?i 1:3:rows_ se
    % vykresluje pouze každý t?etí vzorek
        alpha = Xs(k, 2);
        xc = Xs(k, 1);

        %poloha kyvadla
        [xp, yp] = pol2cart(alpha-pi/2, 0.45);
        %% vykreslovani
        cla
        hold on
        grid on

        axis equal
        %xlim([xc*1-0.1-L_p*0.5, xc*1+0.1+L_p*0.5])
        xlim([-1.1, 1.1]);
        ylim([-0.6, 0.6]);

        quiver( xc, 0,...
            xp, yp,...
            'Color', 'Black',...
            'Marker', 'O',...
            'LineWidth',4,...
            'MarkerSize',8,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor',[0.3,0.1,0.5]',...
            'ShowArrowHead', 'off');
        
        if (length(Wx) == 0)
            [];
        else
            plot(Wx(k,1), 0.45, 'bO');
        end

        drawnow
    end
