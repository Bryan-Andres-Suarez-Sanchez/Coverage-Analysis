# Coverage Analysis Project

## Overview
This project aims to analyze the coverage of two types of transmitters: a directional transmitter and an omnidirectional transmitter, both located in "Panorama", Pitalito, Huila, Colombia. The analysis includes the calculation of elevation angles, antenna design, and coverage mapping using the Longley-Rice propagation model.

## Directing Transmitter Code

### Description
The code for the directional transmitter defines the reception sites at "Isla" and "Centro". It calculates elevation angles to point the antenna towards the receivers and creates a linear array of dipoles.

### Code
```matlab
clear all;
close all;

% Define reception sites: Isla and Centro
rxNames = ["Isla", "Centro"];
rxLocations = [
    1.83444167 -76.05666667; ...  % Isla (Lat: 1° 50' 3.99'' N, Lon: 76° 3' 24'' W)
    1.85257778 -76.04874444];     % Centro (Lat: 1° 51' 9.28'' N, Lon: 76° 2' 55.48'' W)

txLocation = [
    1.84469167 -76.05725];

% Calculate latitude and longitude differences between transmitter and receivers
latDiff = rxLocations(:,1) - txLocation(1);  % Latitude difference
lonDiff = rxLocations(:,2) - txLocation(2);  % Longitude difference

% Calculate tilt angles in degrees
elevAngle = atan2d(latDiff, lonDiff);   % Elevate the antenna to point to the receivers

% Display tilt angles for each receiver
disp('Tilt angles towards each receiver:');
disp(elevAngle);

% Define dipole array antenna
fq = 900e6;  % Transmission frequency 900 MHz
antenna = linearArray('Element', dipole, ... % Dipole element
                      'NumElements', 2, ...  % Number of dipoles in the array
                      'ElementSpacing', 0.5);  % Spacing between dipoles

% Design the antenna
antenna = design(antenna, fq);

% Apply tilt to the antenna to point towards the receivers
avgTilt = mean(elevAngle);
antenna.Tilt = avgTilt;          % Point towards the average tilt
antenna.TiltAxis = "z";          % Tilt axis (around the 'z' axis)

% Configure the transmitter with the tilted antenna
tx = txsite("Name", "Panorama", ...
    "Latitude", txLocation(1), ...         % Transmitter latitude
    "Longitude", txLocation(2), ...        % Transmitter longitude
    "Antenna", antenna, ...                % Directional antenna with tilt
    "AntennaHeight", 10, ...               % Antenna height
    "TransmitterFrequency", fq, ...        % Transmission frequency
    "TransmitterPower", 10);               % Transmission power

% Receiver sensitivity
rxSensitivity = -100; % dBm

% Define reception sites separately
rxIsla = rxsite("Name", "Isla", ...
    "Latitude", rxLocations(1,1), ...
    "Longitude", rxLocations(1,2), ...
    "Antenna", design(monopole, fq), ...  % Omnidirectional antenna
    "ReceiverSensitivity", rxSensitivity); % Receiver sensitivity: -100 dBm

rxCentro = rxsite("Name", "Centro", ...
    "Latitude", rxLocations(2,1), ...
    "Longitude", rxLocations(2,2), ...
    "Antenna", design(monopole, fq), ...  % Omnidirectional antenna
    "ReceiverSensitivity", rxSensitivity); % Receiver sensitivity: -100 dBm

% Receiver antenna heights
rxIsla.AntennaHeight = 15;  % Receiver antenna height in Isla: 15 m
rxCentro.AntennaHeight = 10;  % Receiver antenna height in Centro: 10 m

% Display sites on a map
viewer = siteviewer;
viewer.Basemap = "openstreetmap";

show(tx)          % Show the base station
pattern(tx, fq);   % Show the radiation pattern of the base station

% Show reception sites (Isla and Centro)
show(rxIsla);     % Show the reception site in Isla
pattern(rxIsla, fq);  % Show the radiation pattern of the receiver in Isla

show(rxCentro);   % Show the reception site in Centro
pattern(rxCentro, fq);  % Show the radiation pattern of the receiver in Centro

% Coverage map using Longley-Rice model
coverage(tx, "longley-rice", ...
    "SignalStrengths", rxSensitivity:5:-60)

% Communication link between base station and receivers
sc = [0 0.3 0];
link([rxIsla, rxCentro], tx, "longley-rice", "SuccessColor", sc)

