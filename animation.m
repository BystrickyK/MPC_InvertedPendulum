close all

data = solutionNonlinear.y;
Time = solutionNonlinear.x;

timeSeries = timeseries(data, Time);
dt = 0.01;
timeSeries.resample(timeSeries.Time(1):dt:timeSeries.Time(end));


for t = Time
    
end

rows_ = size(timeSeries.Time);
rows_ = rows_(1);

%
f1 = figure;
% animaci lze zrychlit pomocí úpravy kroku, nap?. p?i 1:3:rows_ se
% vykresluje pouze každý t?etí vzorek
for row = 1:1:rows_    
    alpha = timeSeries.Data(1, 1, row);
    Dalpha = timeSeries.Data(2, 1, row);
    xc = timeSeries.Data(3, 1, row);
    Dxc = timeSeries.Data(4, 1, row);
   
    %poloha kyvadla
    [xp, yp] = pol2cart(alpha-pi/2, L_p);
    %% vykreslovani
    cla
    hold on
    grid on
    
    axis equal
    xlim([-1-L_p*1.5, 1+L_p*1.5])
    ylim([-L_p*1.5, L_p*1.5])
    
    quiver( xc, 0,...
        xp, yp,...
        'Color', 'Black',...
        'LineWidth', 2,...
        'Marker', '*')

    time = Time(row);
    title("T = " + time + "   x = " + xc);

   drawnow
end
