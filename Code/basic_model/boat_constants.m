%% Declare boat constants

% Initial conditions

% Initial latitude & longitude. This provides the baseline for the plant
% to generate GPS data.
initial_LL = [36.80611 -121.79639];
phi_0 = 0;              % Initial heading (radians, eastward positive from north)
v_0 = 0;                % Initial speed (m/s)
battery_tray_angle = 0; % Initial battery tray angle
T_step = 0.01;          % Simulation timestep
telemetryDataRate = 0.02;    % Set the transmission rate for the telemetry sent via UART1
initial_charge = 2851200;    % Initial boat charge, 60% of 6V battery rail (J)
start_time = clock;
%start_time =   1279069200; % 6/13/2010 @ 20:00pm UTC (12pm pacific)
%start_time = 1271205603;% 04/13/2010 @ 7:40pm (TODO: Change to MATLAB commands to capture current time)

% Physical input/output parameters

OC2max = 49999; % Parameter used for calculating up-time & period for output compare 2.

% Waypoint stuff
% Waypoints are all defined within a local tangent plane in meters North,
% East, Down. Three waypoint tracks have been defined below in the
% test_waypoints, figure8_waypoints, and sampling_waypoints matrices. The
% commented-out matrices are the original test ones. Overrides are
% implemented below for the in-harbor boat test.

test_waypoints = int32([0    0    0;
                        25   -36  0;
                        145  -44  0;
                        220  -37  0;
                        253  -57  0;
                        312  -56  0;
                        -1   -1   -1;
                        -1   -1   -1;
                        -1   -1   -1;
                        -1   -1   -1;
                        -1   -1   -1;
                       ]);

figure8_waypoints = int32([0    0    0;
                           -35  19   0;
                           -93  21   0;
                           -156 13   0;
                           -186 33   0;
                           -244 34   0;
                           -249 77   0;
                           -1   -1   -1;
                           -1   -1   -1;
                           -1   -1   -1;
                           -1   -1   -1;
                          ]);

sampling_waypoints = int32([0    0    0;
                            2    -45  0;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                            -1   -1   -1;
                           ]);

% Original waypoints
% test_waypoints = int32([
%              0   0   0;
%              450 100 0;
%              600 600 0;
%              150 300 0;
%              -1  -1  -1;
%              -1  -1  -1;
%              -1  -1  -1;
%              -1  -1  -1;
%              -1  -1  -1;
%              -1  -1  -1;
%              -1  -1  -1;
%             ]);
% % Figure eight
% figure8_waypoints = int32([
%              0   0   0;
%              30  60  0;
%              0   90  0;
%              -30 60  0;
%              0   0   0;
%              30  -60 0;
%              0   -90 0;
%              -30 -60 0;
%              -1  -1  -1;
%              -1  -1  -1;
%              -1  -1  -1;
%             ]);
% % Sampling pattern
% sampling_waypoints = int32([
%              0    0    0;
%              0    210  0;
%              -30  210  0;
%              -30  0    0;
%              -60  0    0;
%              -60  210  0;
%              -90  210  0;
%              -90  0    0;
%              -120 0    0;
%              -120 210  0;
%              -1   -1   -1;
%             ]);

% Known constants

rho_w = 1.03e3;         % Density of saltwater
d_prop = .4572;         % Propeller diameter:18" (m)
mass = 550;             % Boat mass (kg)
wheelbase = 3.27;       % Distance from mid-keel to mid-rudder (m)
m_battery = 108.86;     % Weight of ballast batteries (kg)
d_battery = .3048;      % Distance of batteries from rotation axis (m)
disp_vessel = 612.35;   % Vessel displacement:1350 lbs (kg)
max_batt_angle = 1.309; % Maximum angle for the battery tray: 75 degrees(radians)
max_sea_state = 12;     % The maximum value of the Beaufort Scale
rudder_angle_max = 1;   % Maximum angle of the rudder (radians)
throttle_max = 1;       % Maximum throttle value (% of maximum amps)

% Experimental constants

K_t = 0.5;              % Thrust coefficient
C_d_sea_surge = 340;    % Coefficient of drag for forward motion through water
cg_x = .0508;           % Center of gravity relative to boat center: 1/6' (m)
cg_z = .0508;           % Center of gravity relative to boat center: 1/6' (m)
% Boat center is at 6.5' by the waterline by the axis of symmetry
rudder_angle_dot_max = 10;   % Maximum rate of change of rudder angle (radians/s)
throttle_dot_max = 1;   % Maximum rate of change of throttle (%/s)
proportional_band = .5;      % Proportional band of the rudder response (radians)
roll_period = 3;        % Periodicity of roll. (s)
power_coefficients = [5.6667 9.6667 0]; % Power coefficients for use in the motor current draw calculations

% L2+ constants
TStar = single(4.5);
IPStar = 0;
InitialPoint = 0;
Turn2Track = 0;
MaxDwnPthStar = 1;
tanIntercept = tan( 45*pi/180 );
ISA_g     = 9.815;          % Gravity               (m/s/s)
switchDistance = 4; % Meters before reaching a waypoint that you will then switch over to the next waypoint