# MPC_InvertedPendulum
Control of a cart-pendulum system from Quanser. Includes swing-up using nonlinear MPC and LQR for stabilization. Simulations are done purely in Matlab. The interface for real system control is implemented in Simulink.

Controller with +- 10V inputs on a simulated system:
![NLMPC_Swingup_dt10_sawtooth_highV](https://user-images.githubusercontent.com/55796835/75823830-bb7f7900-5da2-11ea-9c2a-49d6cd6d4858.gif)

Controller with +- 20V inputs on a simulated system:
![NLMPC_Swingup_dt10_sawtooth_vhighV](https://user-images.githubusercontent.com/55796835/75827242-7d398800-5da9-11ea-9e12-e757b41f4ef9.gif)

Controller on a physical laboratory system:
 https://www.youtube.com/watch?v=D_lewvvNofU
