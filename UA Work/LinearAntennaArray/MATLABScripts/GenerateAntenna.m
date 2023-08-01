function [antenna_locations,channel_names] = GenerateAntenna( ...
    dx, num_chan, y_dim)
%GENERATEANTENNA Generates antenna locations & channel names
%   Inputs
%       -> dx:          conveyor belt increments
%       -> num_chan:    number of scans
%       -> y_dim:       dist between antenna
%   Outputs
%       <- antenna_locations:   matrix of (X,Y,Z) locations of each antenna
%       <- channel_names:       order of scans

x_dim = dx * (num_chan - 1);
xmin = -1*x_dim/2;  % Conveyor start
xmax = x_dim/2;     % Conveyor end

% Generate antenna locations ->
ant_xloc = xmin:dx:xmax;
ant_xloc = repelem(ant_xloc,2);
ant_yloc = (y_dim/2)*ones(size(ant_xloc));
ant_yloc(1:2:end) = -1*ant_yloc(1:2:end);
ant_zloc = zeros(size(ant_xloc));
antenna_loc = cat(2,ant_xloc',ant_yloc');
antenna_loc = cat(2,antenna_loc,ant_zloc');
antenna_locations = antenna_loc;
% Generate antenna locations <-

% Generate channel names ->
channel_a = 1:2:(2*num_chan)-1;
channel_b = 2:2:2*num_chan;
chan_names = cat(2,channel_b',channel_a');
chan_names = flip(chan_names);
channel_names = chan_names;
% Generate channel names <-
end