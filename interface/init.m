global K_EC K_EP
    % Cart Encoder Resolution (m/count)
    K_EC = Pr * N_pp / ( 4 * 1024 ); % = 22.7485 um/count
    % Pendulum Encoder Resolution (rad/count)
    % K_EP is positive, since CCW is the positive sense of rotation
    K_EP = 2 * pi / ( 4 * 1024 ); % = 0.0015
   
K_AMP = 1;

X_LIM_ENABLE = 1;

KF_Ts = 0.01;