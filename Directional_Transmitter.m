clear all;
close all;

% Define sitios de recepción: Isla y Centro
rxNames = ["Isla", "Centro"];
rxLocations = [
    1.83444167 -76.05666667; ...  % Isla (Latitud DMS: 1° 50' 3.99'' N, Longitud DMS: 76° 3' 24'' W)
    1.85257778 -76.04874444];     % Centro (Latitud DMS: 1° 51' 9.28'' N, Longitud DMS: 76° 2' 55.48'' W)

txLocation = [
    1.84469167 -76.05725];

% Calcular las diferencias en latitud y longitud entre el transmisor y los receptores
latDiff = rxLocations(:,1) - txLocation(1);  % Diferencia de latitud
lonDiff = rxLocations(:,2) - txLocation(2);  % Diferencia de longitud

% Calcular el ángulo de inclinación en grados
elevAngle = atan2d(latDiff, lonDiff);   % Elevar la antena para apuntar a los receptores

% Mostrar los ángulos de inclinación para cada receptor
disp('Ángulos de inclinación (Tilt) hacia cada receptor:');
disp(elevAngle);

% Definir la antena de arreglo de dipolos
fq = 900e6;  % Frecuencia de transmisión 900 MHz
antenna = linearArray('Element', dipole, ... % Elemento dipolo
                      'NumElements', 2, ...  % Número de dipolos en el arreglo
                      'ElementSpacing', 0.5);  % Espaciado entre dipolos

% Diseñar la antena
antenna = design(antenna, fq);

% Aplicar la inclinación a la antena para que apunte hacia los receptores
% Promediar los ángulos de inclinación hacia los receptores
avgTilt = mean(elevAngle);
antenna.Tilt = avgTilt;          % Apuntar hacia la media de las inclinaciones
antenna.TiltAxis = "z";          % Eje de inclinación (alrededor del eje 'z')

% Configurar el transmisor con la antena inclinada
tx = txsite("Name", "Panorama", ...
    "Latitude", txLocation(1), ...         % Latitud del transmisor
    "Longitude", txLocation(2), ...        % Longitud del transmisor
    "Antenna", antenna, ...                % Antena directiva con inclinación
    "AntennaHeight", 10, ...               % Altura de la antena
    "TransmitterFrequency", fq, ...        % Frecuencia de transmisión
    "TransmitterPower", 10);               % Potencia de transmisión

% Sensibilidad del receptor
rxSensitivity = -100; % dBm

% Definición de los sitios receptores por separado
rxIsla = rxsite("Name", "Isla", ...
    "Latitude", rxLocations(1,1), ...
    "Longitude", rxLocations(1,2), ...
    "Antenna", design(monopole, fq), ...  % Antena omnidireccional
    "ReceiverSensitivity", rxSensitivity); % Sensibilidad del receptor: -100 dBm

rxCentro = rxsite("Name", "Centro", ...
    "Latitude", rxLocations(2,1), ...
    "Longitude", rxLocations(2,2), ...
    "Antenna", design(monopole, fq), ...  % Antena omnidireccional
    "ReceiverSensitivity", rxSensitivity); % Sensibilidad del receptor: -100 dBm

% Altura de las antenas receptoras
rxIsla.AntennaHeight = 15;  % Altura de la antena receptora en Isla: 15 m
rxCentro.AntennaHeight = 10;  % Altura de la antena receptora en Centro: 10 m

% Mostrar los sitios en un mapa
viewer = siteviewer;
viewer.Basemap = "openstreetmap";

show(tx)          % Mostrar la estación base de transmisión
pattern(tx, fq);   % Mostrar el patrón de radiación de la estación base

% Mostrar los sitios receptores (Isla y Centro)
show(rxIsla);     % Mostrar el sitio receptor en Isla
pattern(rxIsla, fq);  % Mostrar el patrón de radiación del receptor en Isla

show(rxCentro);   % Mostrar el sitio receptor en Centro
pattern(rxCentro, fq);  % Mostrar el patrón de radiación del receptor en Centro

% Mapa de cobertura utilizando el modelo Longley-Rice
coverage(tx, "longley-rice", ...
    "SignalStrengths", rxSensitivity:5:-60)

% Enlace de comunicación entre estación base y los receptores
sc = [0 0.3 0];
link([rxIsla, rxCentro], tx, "longley-rice", "SuccessColor", sc)
