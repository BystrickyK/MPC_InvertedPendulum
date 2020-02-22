close all

data = sol.y;
Time = sol.x;

rows_ = size(Time);
rows_ = rows_(2);

%
f1 = figure;
% animaci lze zrychlit pomocí úpravy kroku, nap?. p?i 1:3:rows_ se
% vykresluje pouze každý t?etí vzorek
for row = 1:1:rows_    
    alpha = data(1, row)
    Dalpha = data(2, row)
    xc = data(3, row)
    Dxc = data(4, row)
   
    %poloha kyvadla
    [xp, yp] = pol2cart(alpha-pi/2, 5)
    %% vykreslovani
    cla
    hold on
    grid on
    
    quiver( xc, 0,...
        xp, yp,...
        'Color', 'Black',...
        'LineWidth', 2,...
        'Marker', '*')

    time = Time(row);
    title("T = " + time);
    
    xlim([-8, 8])
    ylim([-7, 7])
    axis equal

   drawnow
end
