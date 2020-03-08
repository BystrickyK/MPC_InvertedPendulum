Vsub = V(2:4);
Vsub = subs(Vsub, u, 0)
fhsub = matlabFunction(Vsub, 'vars', {'x2', 'x3', 'x4', 't'})

%[X2, X3, X4] = meshgrid(-1:0.1:1, -10:1:10, -10:1:10);
[X2, X3] = meshgrid(-1:0.1:1, -10:1:10);

n1=length(X2);
n2=length(X3);
%n3=length(X4);
DX1=zeros(n1,n2);
DX2=zeros(n1,n2);
%DX3=zeros(n1,n2,n3);
for i=1:n1
  for j=1:n2
      %for k=1:n3
        %DX = fhsub(X2(i),X3(j),X4(k), t);
        DX = fhsub(X2(i),X3(j), t);
        DX1(i,j) = DX(1);
        DX2(i,j) = DX(2);
        %DX3(i,j,k) = DX(3);
      %end
  end
end

quiver(X2,X3,DX1,DX2,0.3)
xlabel('X2')
ylabel('X3')