%vectfield  vector field for system of 2 first order ODEs
%   vectfield(func,y1val,y2val) plots the vector field for the system of 
%   two first order ODEs given by func, using the grid of y1val and 
%   y2 values given by the vectors y1val and y2val. func is either a 
%   the name of an inline function of two variables, or a string 
%   with the name of an m-file.
%   By default, t=0 is used in func. A t value can be specified as an
%   additional argument: vectfield(func,y1val,y2val,t)
function vectfield(func,y1val,y2val,y3val,t)
if nargin==3
  t=0;
end
n1=length(y1val)
n2=length(y2val)
n3=length(y3val)
yp1=zeros(n1,n2,n3)
yp2=zeros(n1,n2,n3)
yp3=zeros(n1,n2,n3)
for i=1:n1
  for j=1:n2
      for k=1:n3
        ypv = func(y1val(i),y2val(j),y3val(k), t);
        yp1(i,j,k) = ypv(1);
        yp2(i,j,k) = ypv(2);
        yp3(i,j,k) = ypv(3);
      end
  end
end
size(y1val)
size(y2val)
size(y3val)
size(yp1)
size(yp2)
size(yp3)

quiver3(y1val,y2val,y3val,yp1,yp2,yp3);