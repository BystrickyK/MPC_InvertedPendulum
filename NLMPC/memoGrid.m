clc
clear all 
close all
addpath('functions') 

% Definice parametr? soustavy
p = getParameters();

initializeModel();
%%  Navrh regulatoru    
nx = 4;
ny = 2;
nu = 1;
nlobj = nlmpc(nx, ny, nu);


nlobj.PredictionHorizon = 8;
nlobj.ControlHorizon = 5;
dt = 0.1;
nlobj.Ts = dt;

nlobj.Model.StateFcn = 'pendCartC';
nlobj.Jacobian.StateFcn = 'AB';
nlobj.Model.IsContinuousTime = true;
nlobj.Model.NumberOfParameters = 0;
nlobj.Model.OutputFcn = @(X, u) [X(1); sawtooth(X(3), 0.5)];

nlobj.Weights.OutputVariables = [4 2];
nlobj.Weights.ManipulatedVariablesRate = 0.1;

% nlobj.OV(1).Min = -0.5;
% nlobj.OV(1).Max = 0.5;
 
nlobj.MV.Min = -10;
nlobj.MV.Max = 10;
 
nlobj.Optimization.UseSuboptimalSolution = true;
nlobj.Optimization.SolverOptions.MaxIter = 30;
nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlobj.Optimization.SolverOptions.Display = 'none';

X = [0; 0; 0; 0];
validateFcns(nlobj, X, 0, [])

[~, nloptions] = nlmpcmove(nlobj, [0 0 0 0], 0, [0 1],[]);
u_prev = 0;
%% memo

%Diskretizace
x1p = 6;
x2p = 12;
x3p = 18;
x4p = 15;
yref1p = 2;

x1 = linspace(-1, 1, x1p);
x2 = linspace(-2, 2, x2p);
x3 = linspace(0, 2*pi, x3p);
x4 = linspace(-pi,pi, x4p);
yref1 = [-1, 1];

dim5Grid = ndgrid(x1,x2,x3,x4,yref1);
pointCount = numel(dim5Grid);
pointArray = [];
moveArray = [];

counter = 0;
elapsedTime_ = [];
tic


for i = 1:length(x1)
    for j = 1:length(x2)
        for k = 1:length(x3)
            for l = 1:length(x4)
                for m = 1:length(yref1)
                    counter = counter + 1;
                    
                    x = [x1(i) x2(j) x3(k) x4(l)]; % state space point
                    yref = yref1(m); % reference point
                    
                    %transformation from 5D to 2D
                    %each row consists of 5 columns, where each column
                    %represents a separate dimension and each row a point
                    pointArray = [pointArray; x yref]; 
                    
                    [u, nloptions, ~] = nlmpcmove(nlobj,x,u_prev,[0 yref],[],nloptions);
                    %move array stores calculated action variable at the
                    %respective point in pointArray
                    moveArray = [moveArray; u];
                    u_prev = u;

                    
                    if(mod(counter,100)==0)
                        elapsedTime = toc;
                        elapsedTime_ = [elapsedTime elapsedTime_];
                        averageTime = mean(elapsedTime_);
                        totalTimeEstimate = pointCount/100*averageTime;
                        timeLeft = (pointCount-counter)/100*averageTime;
                        fprintf("Progress: %d / %d \t Time per 100: %f s \t Total time estimate: %f min \t Time left: %f min\n",...
                            counter,pointCount,elapsedTime, totalTimeEstimate/60, timeLeft/60);
                        fprintf("x1: %f x2: %f x3: %f x4: %f yref1: %f \t u: %f\n",...
                            x1(i),x2(j),x3(k),x4(l),yref1(m),u);
                        tic;
                    end  
                    
                end
            end
        end
    end
end

sol.Grid = dim5Grid;
sol.pointArray = pointArray;
sol.moveArary = moveArray;

save('memoGrids/memoGrid3.mat', 'sol');
