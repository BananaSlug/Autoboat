%% Sun position tests
% Sun position library was found online and this file is used to test the
% library and confirm results. Results are confirmed against public 
% experimental data: http://aa.usno.navy.mil/data/docs/AltAz.php

%% Test 1:Santa Cruz at night
% Result should be greater than 90 for zenith.
% Azimuth should be pointing westward where sun sets

% Government zenith/azimuth data can be found here:
time = '27-May-2009 4:00:00'; % UTC (8pm local)

location = [-121.992874 36.955379 0];

% Should be more than 90 degrees zenith to be dark.
sun = sun_position(time,location)