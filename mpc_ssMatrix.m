%%%%%    x(k+1) = A x(k) + B u(k)
%%%%%    y(k) = C x(k) + D u(k)     Note: Assumes D=0
%%%%%
%%%%%  Illustrates open-loop prediction
%%%%   yfut = P*x + H*ufut + L*offset   
%%%%   [offset = y(process) - y(model)]



%%%% MIMO model
A =[0.299843671875         0;
      28.110344238         0];
B =[0.010667   0.010667;
    -1         -1];
 C =[1           0;
     0           1];
D=zeros(2,2);


%% Define Plant Model and MPC Controller
% The linear plant model has two inputs and two outputs.
plant = ss(A,B,C,D);
[A,B,C,D] = ssdata(plant);
Ts = 0.1;               % sampling time
plant = c2d(plant,Ts);  % convert to discrete time
%%
% Create MPC controller.
p=5;       % prediction horizon
m=2;        % control horizon 
mpcobj = mpc(plant,Ts,p,m);
%%
% Define constraints on the manipulated variable.
mpcobj.MV = struct('Min',{0;100},'Max',{415;225},'RateMin',{-100;-100},'RateMax',{100;100});

% Define non-diagonal output weight. Note that it is specified inside a
% cell array.
OW = [1 -1]'*[1 -1]; 
% Non-diagonal output weight, corresponding to ((y1-r1)-(y2-r2))^2
mpcobj.Weights.OutputVariables = {OW}; 
% Non-diagonal input weight, corresponding to (u1-u2)^2
mpcobj.Weights.ManipulatedVariables = {0.5*OW};
%% Simulate Using SIM Command
% Specify simulation options.
Tstop = 30;               % simulation time
Tf = round(Tstop/Ts);     % number of simulation steps
r = ones(Tf,1)*[1 2];     % reference trajectory
%%
%Run the closed-loop simulation and plot results.
[y,t,u] = sim(mpcobj,Tf,r);
subplot(211)
plot(t,y(:,1)-r(1,1)-y(:,2)+r(1,2));grid
title('(y_1-r_1)-(y_2-r_2)');
subplot(212)
plot(t,u);grid
title('u');

%%
% Now simulate closed-loop MPC in Simulink(R).
mdl = 'MPC_ssModel';
open_system(mdl);
sim(mdl) 

