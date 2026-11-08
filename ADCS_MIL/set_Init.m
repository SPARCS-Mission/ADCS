close all;
clear;
% =========================================================================
%% Calendar Info: Epoch Date and Decimal Year
% =========================================================================
epoch.Year = 2024;
epoch.Month = 10;
epoch.Day = 12;
epoch.Hour = 12;
epoch.Minute = 24;
epoch.Second = 45;
epoch.DecimalYear = decyear(epoch.Year, epoch.Month, epoch.Day, epoch.Hour, epoch.Minute, epoch.Second);
% =========================================================================
%% Orbital Elements
% =========================================================================
Semi_major_axis = 6871000;                     % (m) - Altitude 500km -> 6371+500
Inclination = 97.4;                            % (deg) - SSO Orbit inclination
RAAN = 45;                                     % (deg) 45
Argument_of_latitude = 55;                     % (deg) 95
simulator.EarthGConst = 3.986004418e14;        % Earth's standard gravitational parameter in m^3/s^2
% =========================================================================
%% Attitude Kinematics & Dynamics
% =========================================================================
% Initial Euler Angles (rad)
rng(1);
EulerUnit = randn(3,1); 
EulerUnit = EulerUnit ./ norm(EulerUnit);
EulerNorm = 45;                                %deg - Initial tip-off uncertainty limit
Euler_Angle = deg2rad(EulerNorm).*EulerUnit;
attitude.Phi0 = Euler_Angle(1);
attitude.Theta0 = Euler_Angle(2);
attitude.Psi0 = Euler_Angle(3);
% Initial Omega in Body (rad/s)
rng(1);
OmegaUnit = randn(3,1);
OmegaUnit = OmegaUnit./norm(OmegaUnit);
OmegaNorm = 30;                              %deg/s - Max tip-off rate
Omega = deg2rad(OmegaNorm).*OmegaUnit;
attitude.P0 = Omega(1);
attitude.Q0 = Omega(2);
attitude.R0 = Omega(3);
% Moment of Inertia
satellite.MOIJ = [0.0055 0 0; 0 0.0055 0; 0 0 0.0028];
satellite.MOI = diag(diag(satellite.MOIJ));
satellite.InvMOI = inv(satellite.MOI);
% =========================================================================
%% Simulation Setup
% =========================================================================
visSampleTime = 0.1; % 10 Hz Control Cycle
% =========================================================================
%% Actuators: MTQ Specifications
% =========================================================================
satellite.MTQ.DPMoment = 0.20;                % Maximum Magnetic Dipole [A.m^2]
satellite.MTQ.Voltage = [3.3 3.3 3.3];        % V
satellite.MTQ.Power = [0.4 0.4 0.4];          % W
satellite.MTQ.Resistance = ((satellite.MTQ.Voltage).^2) ./ (satellite.MTQ.Power);
% =========================================================================
%% Sensor Specifications
% =========================================================================
% 1. GNSS Receiver Specs
% Operational Specs
satellite.GPS.Frequency = 1;                  % Hz
satellite.GPS.NominalVoltage = 3.3;           % V
satellite.GPS.NominalPower = 0.180;           % W
% Position Error Parameters
satellite.GPS.Position.Bias = [0; 0; 0];      % m
satellite.GPS.Position.NoiseSTDDEV = 2.5;     % m
satellite.GPS.Position.CorrelationTime = 300; % s
% Velocity Error Parameters
satellite.GPS.Velocity.Bias = [0; 0; 0];      % m/s
satellite.GPS.Velocity.NoiseSTDDEV = 0.05;    % m/s
satellite.GPS.Velocity.CorrelationTime = 20;  % s
% Quantization Calculation (for Position)
satellite.GPS.NumberOfBits = 32; % Position data is often double precision
satellite.GPS.Position.Range = [-(Semi_major_axis)*1.5, (Semi_major_axis)*1.5];
satellite.GPS.Position.MinOutput = satellite.GPS.Position.Range(1);
satellite.GPS.Position.MaxOutput = satellite.GPS.Position.Range(2);
GPS_Pos_TotalRange = satellite.GPS.Position.MaxOutput - satellite.GPS.Position.MinOutput;
GPS_Pos_NumberOfLevels = 2^satellite.GPS.NumberOfBits;
satellite.GPS.Position.QuantizationInterval = (GPS_Pos_TotalRange) / GPS_Pos_NumberOfLevels;
% Quantization Calculation (for Velocity)
satellite.GPS.Velocity.Range = [-8000, 8000];
satellite.GPS.Velocity.MinOutput = satellite.GPS.Velocity.Range(1);
satellite.GPS.Velocity.MaxOutput = satellite.GPS.Velocity.Range(2);
GPS_Vel_TotalRange = satellite.GPS.Velocity.MaxOutput - satellite.GPS.Velocity.MinOutput;
GPS_Vel_NumberOfLevels = 2^satellite.GPS.NumberOfBits;
satellite.GPS.Velocity.QuantizationInterval = (GPS_Vel_TotalRange) / GPS_Vel_NumberOfLevels;
%*************************************************************************%
% 2. Gyro Specs
% Operational Specs
satellite.Gyro.Frequency = 100;               % Hz
satellite.Gyro.NominalPower = 0.045;          % W
satellite.Gyro.NominalVoltage = 3.3;          % V
% Performance & Error Specs
satellite.Gyro.Range = [-250, 250].*(pi/180);  % deg/s
satellite.Gyro.NoiseVariance = [0.008; 0.008; 0.008];
satellite.Gyro.Bias = 2.5;                     % deg/hr 
satellite.Gyro.AngularRandomWalk = 0.008;      % deg/sqrt(hr) 
satellite.Gyro.RateRandomWalk = 0.0;           % deg/sqrt(hr^3) 
satellite.Gyro.BiasInstability = 2.5;          % deg/h 
% 1. Scale Factor Errors (%)
sf_error_x_percent = 0.1;   % 0.1% error on X-axis
sf_error_y_percent = -0.15; % -0.15% error on Y-axis
sf_error_z_percent = 0.08;  % 0.08% error on Z-axis
% 2. Non-Orthogonality Angles (deg)
non_ortho_yz_deg = 0.2;  % Angle error between Y and Z axes
non_ortho_xz_deg = -0.1; % Angle error between X and Z axes
non_ortho_xy_deg = 0.15; % Angle error between X and Y axes
% 3. Misalignment Angles (deg)
misalignment_x_deg = 0.05;  % Rotation error around the body X-axis
misalignment_y_deg = 0.05;  % Rotation error around the body Y-axis
misalignment_z_deg = 0.05;  % Rotation error around the body Z-axis
% 1. Scale Factor Matrix (S)
S = diag([1 + sf_error_x_percent / 100, ...
          1 + sf_error_y_percent / 100, ...
          1 + sf_error_z_percent / 100]);
% 2. Non-Orthogonality Matrix (N)
nu_yz = deg2rad(non_ortho_yz_deg);
nu_xz = deg2rad(non_ortho_xz_deg);
nu_xy = deg2rad(non_ortho_xy_deg);
N = [1,    -nu_xy,  nu_xz;
     nu_xy,  1,    -nu_yz;
    -nu_xz,  nu_yz,  1   ];
% 3. Misalignment Matrix (M)
dth_x = deg2rad(misalignment_x_deg);
dth_y = deg2rad(misalignment_y_deg);
dth_z = deg2rad(misalignment_z_deg);
M = [1,    dth_z, -dth_y;
    -dth_z, 1,     dth_x;
     dth_y, -dth_x, 1   ];
satellite.Gyro.MeasurementModelDCM = M * N * S;
% Quantization Calculation
satellite.Gyro.NumberOfBits = 16;               
satellite.Gyro.MinOutput = satellite.Gyro.Range(1);           
satellite.Gyro.MaxOutput = satellite.Gyro.Range(2);          
Gyro_TotalRange = satellite.Gyro.MaxOutput - satellite.Gyro.MinOutput;
Gyro_NumberOfLevels = 2^satellite.Gyro.NumberOfBits;
satellite.Gyro.QuantizationInterval = (Gyro_TotalRange) / Gyro_NumberOfLevels;
%*************************************************************************%
% 3. Magnetometer (MM) Specs
% Operational Specs
satellite.MM.Frequency = 20;                  % Hz
satellite.MM.NominalPower = 0.02;             % W
satellite.MM.NominalVoltage = 3.3;            % V
satellite.MM.Temperature = 25;                % Celcius
% Performance & Error Specs
satellite.MM.Accuracy = 0.5;                  % precent (%) 
satellite.MM.Range = [-1, 1].*8e5;            % nT
%Thermal Drift Parameters:
satellite.MM.ScaleFactorDrift = 100;          % ppm/˚C 
satellite.MM.ZeroFieldDrift = 5;              % nT/˚C
%Bias Parameters:
satellite.MM.ZeroFieldBias = [0; 0; 0];       % nT 
satellite.MM.OnboardDistBias = [0; 0; 0];     % nT
%Noise Specification:
satellite.MM.NoiseVariance = [15; 15; 15];    % nT RMS
% Geometric Error Matrix 
mm_misalignment_x_deg = 0.05;  % [deg] 
mm_misalignment_y_deg = 0.05;  % [deg] 
mm_misalignment_z_deg = 0.05;  % [deg] 
mm_dth_x = deg2rad(mm_misalignment_x_deg);
mm_dth_y = deg2rad(mm_misalignment_y_deg);
mm_dth_z = deg2rad(mm_misalignment_z_deg);
satellite.MM.MeasurementModelDCM = [  1,   mm_dth_z, -mm_dth_y;
                                   -mm_dth_z,   1,    mm_dth_x;
                                    mm_dth_y, -mm_dth_x,   1   ];
% Quantization Calculation
satellite.MM.NumberOfBits = 16;               
satellite.MM.MinOutput = satellite.MM.Range(1);           
satellite.MM.MaxOutput = satellite.MM.Range(2);          
MM_TotalRange = satellite.MM.MaxOutput - satellite.MM.MinOutput;
MM_NumberOfLevels = 2^satellite.MM.NumberOfBits;
satellite.MM.QuantizationInterval = (MM_TotalRange) / MM_NumberOfLevels;
%*************************************************************************%
% 4. Sun Sensor (SS) Specs
% Operational Specs
satellite.SS.Frequency = 10;                  % Hz
satellite.SS.NominalPower = 0.005;            % W
satellite.SS.NominalVoltage = 3.3;            % V
% Quantization Interval Calculation
satellite.SS.NumberOfBits = 12;               
satellite.SS.MinOutput = -1;                  
satellite.SS.MaxOutput =  1;                  
TotalRange = satellite.SS.MaxOutput - satellite.SS.MinOutput;
NumberOfLevels = 2^satellite.SS.NumberOfBits;
satellite.SS.QuantizationInterval = (TotalRange) / NumberOfLevels;
% Performance & Error Specs
satellite.SS.AngularNoise_RMS = 0.20;         
ss_misalignment_angle_x_deg = 0.05;           
ss_misalignment_angle_y_deg = 0.05;           
ss_misalignment_angle_z_deg = 0.05;           
ss_dth_x = deg2rad(ss_misalignment_angle_x_deg);
ss_dth_y = deg2rad(ss_misalignment_angle_y_deg);
ss_dth_z = deg2rad(ss_misalignment_angle_z_deg);
satellite.SS.MisalagnmentMatrix = [  1,   ss_dth_z, -ss_dth_y;
                                  -ss_dth_z,   1,    ss_dth_x;
                                   ss_dth_y, -ss_dth_x,   1  ];
% =========================================================================
%% Detumbling Specs
% =========================================================================
J_MOI = diag(satellite.MOI);
k_Bdot = ((4 * pi * 0.5236 * 0.0055) / (5677.2 * (4.5e-5)^2));
% =========================================================================
%% Nadir Pointing LQR Controller Gains
% =========================================================================
satellite.StateMatrix_A = [zeros(3), 0.5 * eye(3); zeros(3), zeros(3)];
satellite.InputMatrix_B = [zeros(3); satellite.InvMOI];
Controller.LQR.Q = diag([10, 10, 10, 1, 1, 1]); 
Controller.LQR.R = diag([1, 1, 1]);             
Controller.LQR.K = lqr(satellite.StateMatrix_A, satellite.InputMatrix_B, Controller.LQR.Q, Controller.LQR.R);
Controller.Desat.K_desat = 0.005; 
Controller.Desat.h_bias = [0; 0; 0]; 
satellite.MTQ.MaxDipole = 0.20; 

%% Attitude Determination
NoiseStd = [0.0035; 0.0012];                  % Sun sensor (0.2 deg ~ 3.5mrad), Mag (0.069 deg ~ 1.2mrad)
signQuat = 1;                                 % Positive scalar convention for quaternion
% =========================================================================
%% System Level Specs
% =========================================================================
% 1. Electrical Power System (EPS)
% 1. Power Bus (Voltage in V)
PowerVoltageBus_01 = 3.3;                     % Alocated to Sun Sensors
PowerVoltageBus_02 = 3.3;                     % Alocated to Gyroscope
PowerVoltageBus_03 = 3.3;                     % Alocated to Magnetometer
PowerVoltageBus_04 = 3.3;                     % Alocated to GNSS
PowerVoltageBus_05 = 3.3;                     % Alocated to RW#1
PowerVoltageBus_06 = 3.3;                     % Alocated to RW#2
PowerVoltageBus_07 = 3.3;                     % Alocated to RW#3
PowerVoltageBus_08 = 3.3;                     % Alocated to RW#4
PowerVoltageBus_09 = 3.3;                     % Alocated to MTQ_X
PowerVoltageBus_10 = 3.3;                     % Alocated to MTQ_Y
PowerVoltageBus_11 = 3.3;                     % Alocated to MTQ_Z
PowerVoltageBus_12 = 0.0;                     % Alocated to {NOT-DEFINED}
PowerVoltageBus_13 = 0.0;                     % Alocated to {NOT-DEFINED}
PowerVoltageBus_14 = 0.0;                     % Alocated to {NOT-DEFINED}
PowerVoltageBus_15 = 0.0;                     % Alocated to {NOT-DEFINED}
%*************************************************************************%
% 2. Command & Data handling (C&DH)
% 1. Switch Commands (0 for OFF, 1 for ON)
Switch_01 = 1;                                % Alocated to Sun Sensors
Switch_02 = 1;                                % Alocated to Gyroscope
Switch_03 = 1;                                % Alocated to Magnetometer
Switch_04 = 1;                                % Alocated to GNSS
Switch_05 = 1;                                % Alocated to RW#1
Switch_06 = 1;                                % Alocated to RW#2
Switch_07 = 1;                                % Alocated to RW#3
Switch_08 = 1;                                % Alocated to RW#4
Switch_09 = 1;                                % Alocated to MTQ_X
Switch_10 = 1;                                % Alocated to MTQ_Y
Switch_11 = 1;                                % Alocated to MTQ_Z
Switch_12 = 0;                                % Alocated to {NOT-DEFINED}
Switch_13 = 0;                                % Alocated to {NOT-DEFINED}
Switch_14 = 0;                                % Alocated to {NOT-DEFINED}
Switch_15 = 0;                                % Alocated to {NOT-DEFINED}
% =========================================================================
%% Disturbance Models
% =========================================================================
% 1. Rediation Pressure (RP) Disturbance Torque (RP=SollarRP+AlbedoRP)
% Unit normal vectors (pointing outward) for each of the N satellite surfaces, expressed in body frame
surface_normals_body = [eye(3) -eye(3)];
% Satellite Dimensions [m]
dimensions = [10 10 15]*1e-2;
% Area of each surface. Should match number of columns in surface_normals_body [m^2]
A_xy = dimensions(1)*dimensions(2);
A_yz = dimensions(2)*dimensions(3);
A_xz = dimensions(1)*dimensions(3);
surface_areas = [A_xy, A_yz, A_xz, A_xy, A_yz, A_xz];  % 6 surfaces
% Reflectivity coefficient of each surface (0 = fully absorbing, 1 = fully reflecting)
surface_reflectivities = [0.9 0.8 0.9 0.9 0.9 0.9]; % e.g. solar panels often 0.8–0.9
% Vector from satellite center of mass to the center of pressure of each surface, in body frame
    % Half-lengths in each dimension
hx = 0.5 * dimensions(1);
hy = 0.5 * dimensions(2);
hz = 0.5 * dimensions(3);
    % Vectors from CoM to center of each face
surface_positions_body = [ ...
     hx,   0,   0;  % +X face
      0,  hy,   0;  % +Y face
      0,   0,  hz;  % +Z face
    -hx,   0,   0;  % -X face
      0, -hy,   0;  % -Y face
      0,   0, -hz   % -Z face
]';
% Solar irradiance (solar constant) at satellite's location. At 1 AU it's ≈ 1361 W/m²
solar_irradiance = 1361;
% Albedo irradiance (typical LEO range: 50–400 W/m²)
albedo_irradiance = 300;
%*************************************************************************%
% 2. Atmospheric Drag Disturbance Toruqe
% Drag coefficient (typically 2.0–2.5 for CubeSats)
Cd = 2.2;
% Atmospheric Density Model Parameters (for exponential model)
rho0 = 3.614e-14;  % [kg/m³] reference density at h0
h0   = 500;        % [km] reference altitude
H    = 88.667;     % [km] scale height
Re_km = 6371;      % [km] Earth radius
%*************************************************************************%
% 3. Magnetic Field Disturbance Torque
% Residual magnetic dipole in A·m²
ressidual_m = [3e-4; -2e-4; 1e-4];
%*************************************************************************%
% 4. Gravity Gradient Disturbance Torque
J_MOI; %[3x3] Satellite inertia tensor [kg*m^2]
% =========================================================================
%% Reaction Wheel (RW) Model
% =========================================================================
K_T  = 0.0022;           % Motor Torque Constant (N.m/A)
K_E  = K_T;              % back EMF (Electromotive Force) constant (V.s/rad)
% Back EMF is a voltage generated by the motor itself when the rotor (or flywheel) spins.
    % It's caused by the interaction of the rotating magnetic field and coils.
    % It's a kind of internal opposing voltage that resists the applied voltage.
% In SI-consistent systems, 𝐾_𝑇 = 𝐾_𝐸 numerically; but the units are different.
R   = 2.0;               % Ohm
b   = 0;              % Nms (=1e-5 -> if we use this, wheels will be stop after a while)
J   = 4.0e-3 / 628;      % kg·m²
% Actuator Allocation Matrix
% 1. Orthogonal 3-Axis Configuration
ActuatorPhysicalMatrix = [1, 0, 0, 0; 
                          0, 1, 0, 0; 
                          0, 0, 1, 0];
ActuatorAllocationMatrix = ActuatorPhysicalMatrix' * inv(ActuatorPhysicalMatrix * ActuatorPhysicalMatrix');

% =========================================================================
%% MEKF Simulation & Conversion Constants for State Estimation
% =========================================================================
dt = 0.01; % simulation time step, based on 100 Hz sensors
DEG2RAD = pi / 180;
HR2SEC = 3600;
% =========================================================================
% 1. Sun Sensor Measurement Noise Matrix (R_sun).
% The MEKF expects R_sun in units of [rad^2]
% =========================================================================
sun_sensor_noise_rms_deg = satellite.SS.AngularNoise_RMS;
sun_sensor_noise_rms_rad = sun_sensor_noise_rms_deg * DEG2RAD;
sun_sensor_variance_rad2 = sun_sensor_noise_rms_rad^2;
R_sun = eye(3) * sun_sensor_variance_rad2;
satellite.SS.measurementNoiseMatrix =  R_sun;
% =========================================================================
% 2. Magnetometer Measurement Noise Matrix (R_mag).
% The MEKF expects R_mag in units of [uT^2]
% =========================================================================
mag_noise_variance_nT2 = 15^2;
% Convert nT^2 to uT^2 by dividing by (1000^2) = 1e6
mag_noise_variance_uT2 = mag_noise_variance_nT2 / 1e6;
R_mag = eye(3) * mag_noise_variance_uT2;
satellite.MM.measurementNoiseMatrix = R_mag;
% =========================================================================
% 3. Process Noise Covariance (Q_v for attitude from ARW, Q_u for bias from RRW)
% Q_v: rad^2/s process noise matrix (3x3)
% Q_u: rad^2/s^3 process noise matrix (3x3)
% =========================================================================
arw_deg_sqrt_hr = satellite.Gyro.AngularRandomWalk;
% Convert ARW to the continuous-time noise spec in (rad/sqrt(s))
arw_rad_sqrt_hr = arw_deg_sqrt_hr * DEG2RAD;
arw_rad_sqrt_s  = arw_rad_sqrt_hr / sqrt(HR2SEC);
% The continuous process noise spectral density is sigma^2
Q_v_variance_rad2_per_s = arw_rad_sqrt_s^2;
Q_v = eye(3) * Q_v_variance_rad2_per_s;
satellite.Gyro.ProcessNoiseCovarianceAtt = Q_v;
rrw_deg_sqrt_hr3 = satellite.Gyro.RateRandomWalk;
% Convert RRW to the continuous-time noise spec in (rad/s^{1.5})
rrw_rad_sqrt_hr3 = rrw_deg_sqrt_hr3 * DEG2RAD;
rrw_rad_sqrt_s3  = rrw_rad_sqrt_hr3 / (HR2SEC^(1.5));
% The continuous process noise spectral density for bias drive
Q_u_variance_rad2_per_s3 = rrw_rad_sqrt_s3^2;
Q_u = eye(3) * Q_u_variance_rad2_per_s3;
satellite.Gyro.ProcessNoiseCovarianceBias = Q_u;
arw_deg_sqrt_hr = satellite.Gyro.AngularRandomWalk;
% Convert ARW to the continuous-time noise spec in (rad/sqrt(s))
arw_rad_sqrt_hr = arw_deg_sqrt_hr * DEG2RAD;
arw_rad_sqrt_s  = arw_rad_sqrt_hr / sqrt(HR2SEC);
% The continuous process noise spectral density is sigma^2
Q_continuous_variance_rad2_per_s = arw_rad_sqrt_s^2;
Q_noise = eye(3) * Q_continuous_variance_rad2_per_s;
satellite.Gyro.ProcessNoiseCovariance = Q_noise;
% =========================================================================
% 4. P0 (Initial Covariance Matrix)
% The MEKF expects P0 in units of [rad^2] for attitude, [rad^2/s^2] for bias (6x6)
% =========================================================================
% We assume a "lost in space" scenario with a large initial uncertainty.
initial_attitude_uncertainty_deg = 45.0; 
initial_attitude_uncertainty_rad = initial_attitude_uncertainty_deg * DEG2RAD;
initial_variance_rad2 = initial_attitude_uncertainty_rad^2;
% Initial bias uncertainty from static bias spec
initial_bias_uncertainty_deg_per_hr = satellite.Gyro.Bias;
initial_bias_uncertainty_rad_per_s = initial_bias_uncertainty_deg_per_hr * DEG2RAD / HR2SEC;
initial_bias_variance_rad2_per_s2 = initial_bias_uncertainty_rad_per_s^2;
P0_att = eye(3) * initial_variance_rad2;
P0_bias = eye(3) * initial_bias_variance_rad2_per_s2;
P0 = blkdiag(P0_att, P0_bias);