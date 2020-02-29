function [] = plotRefresh(Ts, Xs, Wx, U, k, Ka)
    figure(1);


    
    if(k-Ka == 0)
        Ka = Ka - 1;
    end
    
    xlims = [Ts(k)-30, Ts(k)];
    time = Ts(k-Ka:k);
    
    subplot(221);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 1), "LineWidth", 1.2, 'Color', 'r');
    plot(time, Wx(k-Ka:k), "LineWidth", 1.2, 'LineStyle', '-.', 'Color', 'g');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$x_c$ [$m$]', 'Interpreter', 'Latex')
%     title('$x_c$', 'Interpreter', 'Latex')
    xlim(xlims);
    
    subplot(222);
    hold on
    grid on
    stairs(time, U(k-Ka:k), "LineWidth", 1.2, 'Color', 'k');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$\dot{x_c}$ [$\frac{m}{s}$]', 'Interpreter', 'Latex')
%     title('$\dot{x_c}$', 'Interpreter', 'Latex') 
     xlim(xlims);
    
    subplot(234);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 2), "LineWidth", 1.2, 'Color', 'r');
%     xlabel('Time t [$s$]','interpreter','latex')
     xlim(xlims);

%     ylabel('$\alpha$ [$rad$]', 'Interpreter', 'Latex')
%     title('$\alpha$', 'Interpreter', 'Latex')
     xlim(xlims);
    
    subplot(235);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 3), "LineWidth", 1.2, 'Color', 'b');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$\dot{x_c}$ [$\frac{m}{s}$]', 'Interpreter', 'Latex')
%     title('$\dot{x_c}$', 'Interpreter', 'Latex')
     xlim(xlims);

    subplot(236);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 4), "LineWidth", 1.2, 'Color', 'b');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$\dot{\alpha}$ [$\frac{rad}{s}$]', 'Interpreter', 'Latex')
%     title('$\dot{\alpha}$', 'Interpreter', 'Latex')
     xlim(xlims);    
    
    drawnow

    