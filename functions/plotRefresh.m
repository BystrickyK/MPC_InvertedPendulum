function [] = plotRefresh(Ts, Xs, Xest, Wx, U, D, Y, k, Ka)
  
    if(k-Ka == 0)
        Ka = Ka - 1;
    end
    
    xlims = [Ts(k)-8, Ts(k)];
    time = Ts(k-Ka:k);
    
    if(~isempty(Xest))
        Xs = Xs(1:end-1, :);
    end
    
    %% State variables
    figure(1);
    subplot(221);
    hold on
    grid on
    plot(time, Xs(k-Ka:k, 1), "LineWidth", 2, 'Color', 'b', 'Marker', 'o');
    if(~isempty(Wx))
        plot(time, Wx(k-Ka:k), "LineWidth", 2, 'LineStyle', '-.', 'Color', 'g');
    end
    if(~isempty(Xest))
        plot(time, Xest(k-Ka:k, 1), "LineWidth", 2, 'LineStyle', ':', 'Color', 'r', 'Marker', 'x');
    end
    xlim(xlims);
    
    for i = 2:4
        subplot(2,2,i);
        hold on;
        grid on;
        plot(time, Xs(k-Ka:k, i), "LineWidth", 2, 'Color', 'b', 'Marker', 'o');
        if(~isempty(Xest))
            plot(time, Xest(k-Ka:k, i), "LineWidth", 2,...
                'LineStyle', ':', 'Color', 'r', 'Marker', 'x');
        end
        xlim(xlims);
    end
    
    %% Plotting distrbances, inputs and measurements

data = [D U Y];
figure(3)
    for i = 1:5
        subplot(5,1,i);
        hold on 
        grid on
        stairs(time, data(k-Ka:k, i),...
            'LineWidth', 1, 'Color', 'r', 'Marker', 'x');
        xlim(xlims);

    end
%     subplot(511)
%     hold on 
%     grid on
%     plot(time, D(k-Ka:k, 1), 'LineWidth', 1, 'Color', 'r');
%     xlim(xlims);
%     
%     subplot(512)
%     hold on 
%     grid on
%     plot(time, D(k-Ka:k, 2), 'LineWidth', 1, 'Color', 'r');
%     xlim(xlims);
%     
%     subplot(513);
%     hold on
%     grid on
%     stairs(time, U(k-Ka:k), "LineWidth", 2, 'Color', 'k');
%     xlim(xlims);
%     
%     subplot(514);
%     hold on
%     grid on
%     stairs(time, Y(k-Ka:k, 1), "LineWidth", 2, 'Color', 'b');
%     xlim(xlims);
%     
%     subplot(515);
%     hold on
%     grid on
%     stairs(time, Y(k-Ka:k, 2), "LineWidth", 2, 'Color', 'b');
%     xlim(xlims);
    
drawnow

    