%%%%%    x(k+1) = A x(k) + B u(k)
%%%%%    y(k) = C x(k) + D u(k)     Note: Assumes D=0
%%%%%
%%%%%  Illustrates open-loop prediction
%%%%   yfut = P*x + H*ufut + L*offset   
%%%%   [offset = y(process) - y(model)]



%% Fahrzeugparameter f¨¹r MPC Controller Design
% Physical parameters
g = 9.81;
Pi = 3.1416;

% E-Motor parameters
T_sollrb = 100; % Desired Brake Moment von Rekuperation(max. T_rb ist 225Nm)
k_motor = -51; % Slope of the n-M Kennlinie, bei max. Torque 15,1A/mm^2
iG = 10; % Getriebe¨¹bersetzung zwischen Rad und Motor
k_reifen = k_motor*iG/(2*Pi); % Kennziffer von w-T_rb Linear
SOC  = 1;   % State of Charge (AKKU)

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
%  State Space Modell

% A = nxn = 3x3
A = [-a/v  1/v 0;
     (a*R^2*Fz*K_mu)/(J*v)   -(Fz*K_mu*R^2)/(J*v)  0;
     0     1/R   0];
% B = nxu = 3x2 
B = [R/J 0;
     0 R/J;
     0 0];
% C = yxn = 3x3 
C = [0     0    k_reifen;
    Fz*K_mu*R  J  -k_reifen;
    Fz*K_mu*R  J  0];

% D = yxu = 3x2
D = [0 0;
     0 0;
     0 0];

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
%mpcobj.MV = struct('Min',{-3;-2;-2},'Max',{3;2;2},'RateMin',{-1000;-1000;-1000});
mpcobj.MV = struct('Min',{0,0},'Max',{225,1500},'RateMin',{-100,-100},'RateMax',{100,100});
mpcobj.OV = struct('Min',{0;0;0},'Max',{225;1275;1500});

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
%[y,t,u] = sim(mpcobj,Tf,r);
%subplot(211)
%plot(t,r-y);grid
%title('Ref(t)-yIst(t)');
%subplot(212)
%plot(t,u);grid
%title('u(t)');

%%
% Now simulate closed-loop MPC in Simulink(R).
mdl = 'ABS_mpccontroller';
open_system(mdl);
sim(mdl) 

