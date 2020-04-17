function [] = plotRefresh(Ts, X, Xest, R, U, D, Y, k, Ka)
  
    if(k-Ka == 0)
        Ka = Ka - 1;
    end
    
    xlims = [Ts(k)-8, Ts(k)];
    time = Ts(k-Ka:k);
    
    if(~isempty(Xest))
        X = X(:, 1:end-1);
    end
    
    %% State variables
    figure(1);
    subplot(221);
    hold on
    grid on
    plot(time, X(1, k-Ka:k), "LineWidth", 2, 'Color', 'b', 'Marker', 'o');
    if(~isempty(R))
        plot(time, R(k-Ka:k), "LineWidth", 2, 'LineStyle', '-.', 'Color', 'g');
    end
    if(~isempty(Xest))
        plot(time, Xest(1, k-Ka:k), "LineWidth", 2, 'LineStyle', ':', 'Color', 'r', 'Marker', 'x');
    end
    xlim(xlims);
    
    for i = 2:4
        subplot(2,2,i);
        hold on;
        grid on;
        plot(time, X(i, k-Ka:k), "LineWidth", 2, 'Color', 'b', 'Marker', 'o');
        if(~isempty(Xest))
            plot(time, Xest(i, k-Ka:k), "LineWidth", 2,...
                'LineStyle', ':', 'Color', 'r', 'Marker', 'x');
        end
        xlim(xlims);
    end
    
    %% Plotting distrbances, inputs and measurements

data = [D; U; Y];
figure(3)
    for i = 1:5
        subplot(5,1,i);
        hold on 
        grid on
        stairs(time, data(i, k-Ka:k),...
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

    