% Physical parameters
g = 9.81;

% Vehicle parameters
Td = 1500; % Desired Brake Moment 1500Nm
R  = 0.32; % Wheel radius
J  = 1;  % wheel moment 
v  = 36; % initial velocity
a = -11.3994; % a = -u(0.2)*g max Verz?gung
m = 450; % 1/4 car mass
mu_max = 1.1632; % max Reibwert
K_mu = 5.8160; % slope of s-u kurve
m0 = m; % Initial mass (used in the EKF mass estimation)
Fz = 4410; % Fz = m*g Nm

% Actuator parameters
%actuatorPole = 70;
%actuatorSat = 4000;
%actuatorDelay = 0.005;

% Road surface parameters
% Pacejka model for dry asphelt
%roadCoeffs = [1.28 23.99 0.52];
