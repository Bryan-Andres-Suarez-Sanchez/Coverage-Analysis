clear all;
close all;

% Parámetros generales
fq = 900e6;        % Frecuencia: 150 MHz
txPower = 40;      % Potencia de transmisión: 10 W
rxSensitivity = -100; % Sensibilidad del receptor: -100 dBm

% Estación base - Ubicada en el barrio "Panorama", Pitalito, Huila
tx = txsite("Name","Panorama", ...
    "Latitude",1.84469167, ...         % Latitud DMS: 1° 50' 40.89'' N
    "Longitude",-76.05725, ...         % Longitud DMS: 76° 3' 26.1'' W
    "Antenna",design(dipole,fq), ...   % Antena dipolo
    "AntennaHeight",10, ...            % Altura de la antena: 10 metros
    "TransmitterFrequency",fq, ...     % Frecuencia de transmisión: 150 MHz
    "TransmitterPower",txPower);       % Potencia de transmisión: 10 W

% Sitios de recepción - Móviles ubicados en "Isla" y "Centro"
rxNames = ["Isla", "Centro"];
rxLocations = [...
    1.83444167 -76.05666667; ...  % Isla (Latitud: 1° 50' 3.99'' N, Longitud: 76° 3' 24'' W)
    1.85257778 -76.04874444];     % Centro (Latitud: 1° 51' 9.28'' N, Longitud: 76° 2' 55.48'' W)

% Creación de los sitios de recepción con antenas omnidireccionales
rxs = rxsite("Name",rxNames, ...
    "Latitude",rxLocations(:,1), ...
    "Longitude",rxLocations(:,2), ...
    "Antenna",design(monopole,fq), ...  % Antena omnidireccional en recepción
    "ReceiverSensitivity",rxSensitivity);  % Sensibilidad del receptor

% Altura de las antenas de los móviles (receptores)
rxs(1,1).AntennaHeight = 1.5;  % Altura de la antena en Isla: 1.5 m
rxs(1,2).AntennaHeight = 1.5;  % Altura de la antena en Centro: 1.5 m

% Mostrar los sitios en el visor
viewer = siteviewer("Basemap","openstreetmap");

show(tx)      % Mostrar la estación base
show(rxs)     % Mostrar las antenas receptoras

% Mapa de cobertura - Alcance y Retroalcance
% Se visualiza la cobertura de la estación base considerando la potencia de recepción
coverage(tx,"PropagationModel","longley-rice", ...
    "SignalStrengths", rxSensitivity:5:-60);  % Mostrar desde -100 dBm a -60 dBm

% Enlaces de comunicación entre la estación base y los móviles
link(rxs, tx, "PropagationModel", "longley-rice", "SuccessColor", [0 0.3 0]);

% Mostrar patrón de radiación de la antena de la estación base
pattern(tx, fq);

% Guardar la imagen de la cobertura
saveas(gcf, 'Cobertura_Alcance_Retroalcance.png')
