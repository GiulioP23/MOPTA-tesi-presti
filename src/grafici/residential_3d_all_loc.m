% Regressione lineare con regressori polinomiali utilizzando tutti i dati
% di origine RESIDENZIALE.

%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% 2. Selezione dati
residential_load=df.Load(df.Location_Electricity.endsWith('r'));

residential_instances = df.Instance(df.Location_Electricity.endsWith('r'));
residential_periods = df.Quarter(df.Location_Electricity.endsWith('r'));
residential_days=(residential_periods=='Q1')+92*(residential_periods=='Q2')+183*(residential_periods=='Q3')+274*(residential_periods=='Q4');
N = length(residential_instances);

Td = max(residential_instances); % periodo instances
Ty = 365; % periodo quarters

full_phi=[ones(N, 1) ...
     cos(1*2*pi/Td*residential_instances) sin(1*2*pi/Td*residential_instances) cos(1*2*pi/Ty*residential_days) sin(1*2*pi/Ty*residential_days)...
     cos(2*2*pi/Td*residential_instances) sin(2*2*pi/Td*residential_instances) cos(2*2*pi/Ty*residential_days) sin(2*2*pi/Ty*residential_days)... 
     cos(3*2*pi/Td*residential_instances) sin(3*2*pi/Td*residential_instances) cos(1*2*pi/Td*residential_instances).*cos(1*2*pi/Ty*residential_days) cos(1*2*pi/Td*residential_instances).*sin(1*2*pi/Ty*residential_days)...
     cos(4*2*pi/Td*residential_instances) sin(4*2*pi/Td*residential_instances) sin(1*2*pi/Td*residential_instances).*cos(1*2*pi/Ty*residential_days) sin(1*2*pi/Td*residential_instances).*sin(1*2*pi/Ty*residential_days)...
 ];

%% 3. 3D Graph - All Locations

[thetaLS, theta_std] = lscov(full_phi, residential_load);
loadLS = full_phi*thetaLS;
e = residential_load - loadLS;
ssr = sum(e.^2);

% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
plot3(residential_instances, residential_days, residential_load, 'b.')

hold on;
grid on;
title('Residential Load');
subtitle('Load vs Instance and Period')

xlabel('Instance (hours)')
ylabel('Period (day)')
zlabel('Load (MWh)')

periodGrid = linspace(0.9*min(residential_days), 1.1*max(residential_days), 100)';
instanceGrid = linspace(0.9*min(residential_instances), 1.1*max(residential_instances), 100)';

[periodTable, instanceTable] = meshgrid(periodGrid, instanceGrid);

periodVec = periodTable(:);
instanceVec = instanceTable(:);

phiGrid=[instanceVec.^0 ...
     cos(1*2*pi/Td*instanceVec) sin(1*2*pi/Td*instanceVec) cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Ty*periodVec)...
     cos(2*2*pi/Td*instanceVec) sin(2*2*pi/Td*instanceVec) cos(2*2*pi/Ty*periodVec) sin(2*2*pi/Ty*periodVec)... 
     cos(3*2*pi/Td*instanceVec) sin(3*2*pi/Td*instanceVec) cos(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) cos(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
     cos(4*2*pi/Td*instanceVec) sin(4*2*pi/Td*instanceVec) sin(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
 ];
loadGrid = phiGrid*thetaLS;
loadTable = reshape(loadGrid, size(periodTable));

mesh(instanceTable, periodTable, loadTable, FaceColor="interp", FaceAlpha=0.7)
colormap('cool')

%legend;
pbaspect([2, 1, 1])

%% 2. Selezione dati 1_r
residential_load=df.Load(df.Location_Electricity=='1_r');

residential_instances = df.Instance(df.Location_Electricity=='1_r');
residential_periods = df.Quarter(df.Location_Electricity=='1_r');
residential_days=(residential_periods=='Q1')+92*(residential_periods=='Q2')+183*(residential_periods=='Q3')+274*(residential_periods=='Q4');
N = length(residential_instances);

Td = max(residential_instances); % periodo instances
Ty = 365; % periodo quarters

full_phi=[ones(N, 1) ...
     cos(1*2*pi/Td*residential_instances) sin(1*2*pi/Td*residential_instances) cos(1*2*pi/Ty*residential_days) sin(1*2*pi/Ty*residential_days)...
     cos(2*2*pi/Td*residential_instances) sin(2*2*pi/Td*residential_instances) cos(2*2*pi/Ty*residential_days) sin(2*2*pi/Ty*residential_days)...  
     cos(3*2*pi/Td*residential_instances) sin(3*2*pi/Td*residential_instances) cos(1*3*pi/Ty*residential_days) sin(1*3*pi/Ty*residential_days)...
     cos(4*2*pi/Td*residential_instances) sin(4*2*pi/Td*residential_instances) cos(1*4*pi/Ty*residential_days) sin(1*4*pi/Ty*residential_days)...
     cos(1*2*pi/Td*residential_instances).*cos(1*2*pi/Ty*residential_days) cos(1*2*pi/Td*residential_instances).*sin(1*2*pi/Ty*residential_days)...
     sin(1*2*pi/Td*residential_instances).*cos(1*2*pi/Ty*residential_days) sin(1*2*pi/Td*residential_instances).*sin(1*2*pi/Ty*residential_days)...
 ];
%% 3. 3D Graph - location 1_r

[thetaLS, theta_std] = lscov(full_phi, residential_load);
loadLS = full_phi*thetaLS;
e = residential_load - loadLS;
ssr = sum(e.^2);

% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
plot3(residential_instances, residential_days, residential_load, 'b.')

hold on;
grid on;
title('Residential Load');
subtitle('Load vs Instance and Period')

xlabel('Instance (hours)')
ylabel('Period (day)')
zlabel('Load (MWh)')

periodGrid = linspace(0.9*min(residential_days), 1.1*max(residential_days), 100)';
instanceGrid = linspace(0.9*min(residential_instances), 1.1*max(residential_instances), 100)';

[periodTable, instanceTable] = meshgrid(periodGrid, instanceGrid);

periodVec = periodTable(:);
instanceVec = instanceTable(:);

phiGrid=[instanceVec.^0 ...
     cos(1*2*pi/Td*instanceVec) sin(1*2*pi/Td*instanceVec) cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Ty*periodVec)...
     cos(2*2*pi/Td*instanceVec) sin(2*2*pi/Td*instanceVec) cos(2*2*pi/Ty*periodVec) sin(2*2*pi/Ty*periodVec)...      
     cos(3*2*pi/Td*instanceVec) sin(3*2*pi/Td*instanceVec) cos(1*3*pi/Ty*periodVec) sin(1*3*pi/Ty*periodVec)...
     cos(4*2*pi/Td*instanceVec) sin(4*2*pi/Td*instanceVec) cos(1*4*pi/Ty*periodVec) sin(1*4*pi/Ty*periodVec)...
     cos(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) cos(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
     sin(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
 ];
loadGrid = phiGrid*thetaLS;
loadTable = reshape(loadGrid, size(periodTable));

mesh(instanceTable, periodTable, loadTable, FaceColor="interp", FaceAlpha=0.5)
colormap('cool')

%legend;
pbaspect([2, 1, 1])