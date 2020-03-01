function [] = plotRefresh(Ts, Xs, Xest, Wx, U, D, Y, k, Ka)
  
figure(1);
    if(k-Ka == 0)
        Ka = Ka - 1;
    end
    
    xlims = [Ts(k)-20, Ts(k)];
    time = Ts(k-Ka:k);
    
    subplot(221);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 1), "LineWidth", 2, 'Color', 'b');
    plot(time, Wx(k-Ka:k), "LineWidth", 2, 'LineStyle', '-.', 'Color', 'g');
    plot(time, Xest(k-Ka:k, 1), "LineWidth", 2, 'LineStyle', ':', 'Color', 'r');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$x_c$ [$m$]', 'Interpreter', 'Latex')
%     title('$x_c$', 'Interpreter', 'Latex')
    xlim(xlims);
    
    subplot(222);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 2), "LineWidth", 2, 'Color', 'b');
    plot(time, Xest(k-Ka:k, 2), "LineWidth", 2, 'LineStyle', ':', 'Color', 'r');
%     xlabel('Time t [$s$]','interpreter','latex')
     xlim(xlims);

%     ylabel('$\alpha$ [$rad$]', 'Interpreter', 'Latex')
%     title('$\alpha$', 'Interpreter', 'Latex')
     xlim(xlims);
    
    subplot(223);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 3), "LineWidth", 2, 'Color', 'b');
    plot(time, Xest(k-Ka:k, 3), "LineWidth", 2, 'LineStyle', ':', 'Color', 'r');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$\dot{x_c}$ [$\frac{m}{s}$]', 'Interpreter', 'Latex')
%     title('$\dot{x_c}$', 'Interpreter', 'Latex')
     xlim(xlims);

    subplot(224);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 4), "LineWidth", 2, 'Color', 'b');
    plot(time, Xest(k-Ka:k, 4), "LineWidth", 2, 'LineStyle', ':', 'Color', 'r');
%     xlabel('Time t [$s$]','interpreter','latex')
%     ylabel('$\dot{\alpha}$ [$\frac{rad}{s}$]', 'Interpreter', 'Latex')
%     title('$\dot{\alpha}$', 'Interpreter', 'Latex')
     xlim(xlims);    
    
figure(3)
    subplot(511)
    hold on 
    grid on
    plot(time, D(k-Ka:k, 1), 'LineWidth', 1, 'Color', 'r');
    xlim(xlims);
    
    subplot(512)
    hold on 
    grid on
    plot(time, D(k-Ka:k, 2), 'LineWidth', 1, 'Color', 'r');
    xlim(xlims);
    
    subplot(513);
    hold on
    grid on
    stairs(time, U(k-Ka:k), "LineWidth", 2, 'Color', 'k');
    xlim(xlims);
    
    subplot(514);
    hold on
    grid on
    stairs(time, Y(k-Ka:k, 1), "LineWidth", 2, 'Color', 'b');
    xlim(xlims);
    
    subplot(515);
    hold on
    grid on
    stairs(time, Y(k-Ka:k, 2), "LineWidth", 2, 'Color', 'b');
    xlim(xlims);
    
drawnow

    