% Physical parameters
g = 9.81;

% Controller parameters
Ts = 0.005;  % Sample rate of discrete controller
Kp = 1200;
Ki = 100000;
Kd = 0;
dPole = 1000;  % Pole of non-idealized derivative

% Vehicle parameters
Td = 1500; % Desired Brake Moment 1500Nm
Rr = 0.32; % Wheel radius
Jr = 1;  % wheel moment 
v0 = 50; % initial velocity
m = 450; % 1/4 car mass
m0 = m; % Initial mass (used in the EKF mass estimation)

% Actuator parameters
actuatorPole = 70;
actuatorSat = 4000;
actuatorDelay = 0.005;

% Road surface parameters
% Pacejka model for dry asphelt
roadCoeffs = [1.28 23.99 0.52];
