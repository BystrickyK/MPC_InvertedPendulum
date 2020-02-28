function [] = plotRefresh(Ts, Xs, Wx, U, k, Ka)
    figure(1);

    xlims = [Ts(end)-15, Ts(end)];
    
    subplot(221);
    hold on
    grid on
    plot(Ts(k-Ka+1:k), Xs(k-Ka+1:k, 1), "LineWidth", 2, 'Color', 'b');
    plot(Ts(k-Ka+1:k), Wx(k-Ka+1:k), "LineWidth", 2, 'LineStyle', '-.', 'Color', 'g');
    xlabel('Time t [$s$]','interpreter','latex')
    ylabel('$x_c$ [$m$]', 'Interpreter', 'Latex')
    title('$x_c$', 'Interpreter', 'Latex')
    xlim(xlims);
    
    subplot(222);
    hold on
    grid on
    plot(Ts(k-Ka+1:k), U(k-Ka+1:k), "LineWidth", 2, 'Color', 'k');
    xlabel('Time t [$s$]','interpreter','latex')
    ylabel('$\dot{x_c}$ [$\frac{m}{s}$]', 'Interpreter', 'Latex')
    title('$\dot{x_c}$', 'Interpreter', 'Latex') 
    xlim(xlims);
    
    subplot(234);
    hold on
    grid on
    plot(Ts(k-Ka+1:k), Xs(k-Ka+1:k, 2), "LineWidth", 2, 'Color', 'b');
    xlabel('Time t [$s$]','interpreter','latex')
    xlim(xlims);

    ylabel('$\alpha$ [$rad$]', 'Interpreter', 'Latex')
    title('$\alpha$', 'Interpreter', 'Latex')
    xlim(xlims);
    
    subplot(235);
    hold on
    grid on
    plot(Ts(k-Ka+1:k), Xs(k-Ka+1:k, 3), "LineWidth", 2, 'Color', 'b');
    xlabel('Time t [$s$]','interpreter','latex')
    ylabel('$\dot{x_c}$ [$\frac{m}{s}$]', 'Interpreter', 'Latex')
    title('$\dot{x_c}$', 'Interpreter', 'Latex')
    xlim(xlims);

    subplot(236);
    hold on
    grid on
    plot(Ts(k-Ka+1:k), Xs(k-Ka+1:k, 4), "LineWidth", 2, 'Color', 'b');
    xlabel('Time t [$s$]','interpreter','latex')
    ylabel('$\dot{\alpha}$ [$\frac{rad}{s}$]', 'Interpreter', 'Latex')
    title('$\dot{\alpha}$', 'Interpreter', 'Latex')
    xlim(xlims);    
    
    drawnow

    