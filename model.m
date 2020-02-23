
eta_g = 0.9 %gearbox efficiency
K_g = 3.71 %gearbox gear ratio
k_t = 7.68e-3 %motor current-torque constant
k_m = 7.68e-3 %motor back-emf constant
R_m = 2.6 %motor armature resistance
r_mp = 6.35e-3 %motor pinion radius (prumer pastorku)
eta_m = 0.69 %motor efficiency
A_m = eta_g * K_g * eta_m * k_t / r_mp / R_m %actuator gain
J_p = 1.2e-3 %moment of inertia about CoM, medium length pendulum
L_p = 0.3365 %full length of the pendulum
l_p = L_p/2
M_p = 0.127 %pendulum mass
%J_p = J_pCoM + M_p * l_p^2
M_c = 0.38 %cart mass
J_m = 3.9e-7 %motor moment of inertia
J_eq = M_c + eta_g*K_g^2*J_m/r_mp^2
B_eq = 4.3 %equivalent viscous damping coefficient (cart)
B_p = 0.0024 %equivalent viscous damping coefficient (pendulum)
g = 9.81

syms x_c(t) alpha(t) V_m u

%sila pusobici na cart
F_c = (eta_g*K_g*k_t/R_m/r_mp)*(-K_g*k_m*diff(x_c,t)/r_mp + eta_m*V_m) %2.11 LinPendulumGantry

%rovnice systemu (2.9 a 2.10 v LinearPendulumGantry)
disp("2.9 a 2.10")
ode1 = (J_eq+M_p)*diff(x_c,t,2) + M_p*l_p*cos(alpha)*diff(alpha,t,2) - M_p*l_p*sin(alpha)*diff(alpha,t)^2 == F_c - B_eq*diff(x_c,t)
ode2 = M_p*l_p*cos(alpha)*diff(x_c,t,2) + (J_p+M_p*l_p^2)*diff(alpha,t,2) + M_p*l_p*g*sin(alpha) == -B_p*diff(alpha,t)

ode1 = subs(ode1, V_m, u);
ode2 = subs(ode2, V_m, u);

odes = [ode1, ode2]
%odes = simplify(odes)


[V, S] = odeToVectorField(odes);
nonlinearSystem = matlabFunction(V, 'vars', {'t', 'Y', 'u'});

fh_tmp = matlabFunction(V, 'vars', {'Y', 'u'});
x = sym('x', [1 4]);
V = fh_tmp(x, u);
V = simplify(V);
V = vpa(V, 2)

A_sym = jacobian(V, x);
B_sym = jacobian(V, u);

disp([transpose(x)  S])
x_operating = [0, 0, 0, 0];
A = subs(A_sym, [x, 0], [x_operating, 0]);
B = subs(B_sym, [x, 0], [x_operating, 0]);

A = double(A)
B = double(B)
C = eye(4)
D = [0; 0; 0; 0]

linearSystem = ss(A,B,C,D);

disp("Poles:")
eigs(A)

disp("Poles of a subsystem without x_C:")
A_sub = A;
A_sub(3,:) = []; %check if x_c is at index 3 in vector S
A_sub(:,3) = [];
eigs(A_sub)

initialCondition = [0, 0, 0, 0] %alpha, Dalpha, xc, Dxc
simulationTime = 20;

solutionNonlinear = ode45(nonlinearSystem, [0 simulationTime], initialCondition);
[y, t, x] = initial(linearSystem, initialCondition, simulationTime);
solutionLinear = struct;
solutionLinear.t = t;
solutionLinear.x = x;


f1 = figure;
sgtitle("Model comparison")
subplot(221);
hold on
grid on
plot(solutionNonlinear.x, solutionNonlinear.y(1,:), "LineWidth", 1)
plot(solutionLinear.t, solutionLinear.x(:,1), "LineWidth", 1, "LineStyle","--")
legend("Nonlinear model", "Linear model")
 xlabel('Time t [$s$]','interpreter','latex')
 ylabel('$\alpha$ [$rad$]', 'Interpreter', 'Latex')
  title('$\alpha$', 'Interpreter', 'Latex')
  
  subplot(222);
hold on
grid on
plot(solutionNonlinear.x, solutionNonlinear.y(2,:), "LineWidth", 1)
plot(solutionLinear.t, solutionLinear.x(:,2), "LineWidth", 1, "LineStyle","--")
legend("Nonlinear model", "Linear model")
 xlabel('Time t [$s$]','interpreter','latex')
 ylabel('$\dot{\alpha}$ [$\frac{rad}{s}$]', 'Interpreter', 'Latex')
  title('$\dot{\alpha}$', 'Interpreter', 'Latex')
  
  subplot(223);
hold on
grid on
plot(solutionNonlinear.x, solutionNonlinear.y(3,:), "LineWidth", 1)
plot(solutionLinear.t, solutionLinear.x(:,3), "LineWidth", 1, "LineStyle","--")
legend("Nonlinear model", "Linear model")
 xlabel('Time t [$s$]','interpreter','latex')
 ylabel('$x_c$ [$m$]', 'Interpreter', 'Latex')
  title('$x_c$', 'Interpreter', 'Latex')
  
  subplot(224);
hold on
grid on
plot(solutionNonlinear.x, solutionNonlinear.y(4,:), "LineWidth", 1)
plot(solutionLinear.t, solutionLinear.x(:,4), "LineWidth", 1, "LineStyle","--")
legend("Nonlinear model", "Linear model")
 xlabel('Time t [$s$]','interpreter','latex')
 ylabel('$\dot{x_c}$ [$\frac{m}{s}$]', 'Interpreter', 'Latex')
  title('$\dot{x_c}$', 'Interpreter', 'Latex')
