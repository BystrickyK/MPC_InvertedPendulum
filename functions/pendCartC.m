function dXdt = pendCartC(in1,u)
%PENDCARTC
%    DXDT = PENDCARTC(IN1,U)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    16-Apr-2020 22:30:14

Y2 = in1(2,:);
Y3 = in1(3,:);
Y4 = in1(4,:);
t2 = cos(Y2);
t3 = sin(Y2);
t4 = Y4.^2;
t5 = t2.^2;
t6 = t5.*1.1871099241625e-3;
t7 = t6-7.814691838067285e-3;
t8 = 1.0./t7;
dXdt = [Y3;Y4;-t8.*(Y3.*(-1.404985568136286e-1)+u.*1.336142693695975e-2+Y4.*t2.*1.3333476e-4+t2.*t3.*1.164554835603413e-2+t3.*t4.*2.663986247403407e-4);t8.*(Y4.*3.911319218401637e-3+t3.*3.416172728985441e-1-Y3.*t2.*6.260814269838489e-1+t2.*u.*5.954040691200001e-2+t2.*t3.*t4.*1.187109924162501e-3)];
