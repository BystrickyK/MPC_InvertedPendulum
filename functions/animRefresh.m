function [] = animRefresh(X, r)
    
    figure(2);
    xc = X(1);
    alpha = X(2);
        %poloha kyvadla
        [xp, yp] = pol2cart(alpha-pi/2, 0.45);
        %% vykreslovani
        cla
        hold on
        grid on

        axis equal
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
        
        if (length(r) == 0)
            [];
        else
            plot(r, 0.45, 'bO');
        end

        drawnow
    end
