%%%%%    x(k+1) = A x(k) + B u(k)
%%%%%    y(k) = C x(k) + D u(k)     Note: Assumes D=0
%%%%%
%%%%%  Illustrates open-loop prediction
%%%%   yfut = P*x + H*ufut + L*offset   
%%%%   [offset = y(process) - y(model)]



%% Fahrzeugparameter f¨¹r MPC Controller Design
% Physical parameters
g = 9.81;

% Fahrzeug parameters
Td = 1500; % Desired Brake Moment 1500Nm
R  = 0.32; % Wheel radius m
J  = 1;  % wheel moment m/s
v  = 36; % initial velocity
a = -11.3994; % a = -u(0.2)*g max Verzoegung
m = 450; % 1/4 car mass
mu_max = 1.1632; % max Reibwert
K_mu = 5.8160; % slope of s-u kurve
m0 = m; % Initial mass (used in the EKF mass estimation)
Fz = 4410; % Vertical Kraft Fz = m*g N
%% Input/State/Output continuous time form(LTI)
%  State Space Model
A = [-a/v  1/v;
     (a*R^2*Fz*K_mu)/(J*v)   -(Fz*K_mu*R^2)/(J*v)];
B = [0;
    R/J];
C = [Fz*K_mu*R  J];
D = [0];

%% Define Plant Model and MPC Controller
% The linear plant model has two inputs and two outputs.
plant = ss(A,B,C,D);
[A,B,C,D] = ssdata(plant);
Ts = 0.1;               % sampling time
plant = c2d(plant,Ts);  % convert to discrete time
%% Design MPC Controller
% Define type of input signals: the first signal is a manipulated variable,
% the second signal is a measured disturbance, the third one is an
% unmeasured disturbance.
%plant = setmpcsignals(plant,'MV',1,'MD',2);
% Create the controller object with sampling period, prediction and control
% horizons:
p = 10;  % prediction horizon
m = 2;   % control horizon 
mpcobj = mpc(plant,Ts,p,m);
%%
% Define constraints on the manipulated variable.
mpcobj.MV = struct('Min',0,'Max',1530,'RateMin',-100,'RateMax',100);
mpcobj.OV = struct('Min',0,'Max',2000);

% Define non-diagonal output weight. Note that it is specified inside a
% cell array.
%OW = [1 -1]'*[1 -1]; 
% Non-diagonal output weight, corresponding to ((y1-r1)-(y2-r2))^2
%mpcobj.Weights.OutputVariables = {OW}; 
% Non-diagonal input weight, corresponding to (u1-u2)^2
%mpcobj.Weights.ManipulatedVariables = {0.5*OW};
%% Simulate Using SIM Command
% Specify simulation options.
Tstop = 30;               % simulation time
Tf = round(Tstop/Ts);     % number of simulation steps
%r = ones(Tf,1)*Td;     % reference trajectory
r = Td;
%%
%Run the closed-loop simulation and plot results.
[y,t,u] = sim(mpcobj,Tf,r);
subplot(211)
plot(t,r-y);grid
title('Ref(t)-yIst(t)');
subplot(212)
plot(t,u);grid
title('u(t)');

%%
% Now simulate closed-loop MPC in Simulink(R).
mdl = 'ABS_mpccontroller';
open_system(mdl);
sim(mdl) 

