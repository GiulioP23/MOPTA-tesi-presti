% Solar Graph script
%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab

%% Solar - All data (by Period)
% Rappresenta in funzione del tempo tutti i carichi industriali, 
% rappresentando con colori diversi i carichi relativi a diversi periodi.
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Solar Energy');
subtitle('Generation vs Instance');

xlabel("Instance (local time)")
ylabel("Generation (MWh)")

periods = unique(df.Quarter);
for n=1:4
    X=duration(df.Instance(df.Quarter==periods(n)), 0, 0);
    X.Format="hh:mm";
    Y=df.Generation(df.Quarter==periods(n));
    scatter(X, Y, '.', DisplayName=periods(n))
end

lgd=legend();
lgd.Title.String='Period';

pbaspect([2, 1, 1])

%% 3D Graph - Solar vs instance and quarter
generation=df.Generation;

instances = df.Instance;
periods = df.Quarter;
days=(periods=='Q1')+92*(periods=='Q2')+183*(periods=='Q3')+274*(periods=='Q4');
N = length(instances);

Td = max(instances); % periodo instances
Ty = 365; % periodo quarters

full_phi=[ones(N, 1) ...
     cos(1*2*pi/Td*instances) sin(1*2*pi/Td*instances) cos(1*2*pi/Ty*days) sin(1*2*pi/Ty*days)...
     cos(2*2*pi/Td*instances) sin(2*2*pi/Td*instances) cos(2*2*pi/Ty*days) sin(2*2*pi/Ty*days)... 
     cos(3*2*pi/Td*instances) sin(3*2*pi/Td*instances) cos(1*2*pi/Td*instances).*cos(1*2*pi/Ty*days) cos(1*2*pi/Td*instances).*sin(1*2*pi/Ty*days)...
     cos(4*2*pi/Td*instances) sin(4*2*pi/Td*instances) sin(1*2*pi/Td*instances).*cos(1*2*pi/Ty*days) sin(1*2*pi/Td*instances).*sin(1*2*pi/Ty*days)...
 ];

[thetaLS, theta_std] = lscov(full_phi, generation);
loadLS = full_phi*thetaLS;
e = generation - loadLS;
ssr = sum(e.^2);

% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
plot3(instances, days, generation, 'b.')

hold on;
grid on;
title('Solar Energy');
subtitle('Generation vs Instance and Period')

xlabel('Instance (hours)')
ylabel('Period (day)')
zlabel('Generation (MWh)')

periodGrid = linspace(0.9*min(days), 1.1*max(days), 100)';
instanceGrid = linspace(0.9*min(instances), 1.1*max(instances), 100)';

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

%% day length
quarters = unique(df.Quarter);

for q=1:4
    quarter = quarters(q);
    inst_1 = min(df.Instance(all([df.Quarter==quarter, df.Generation~=0], 2)));
    inst_2 = max(df.Instance(all([df.Quarter==quarter, df.Generation~=0], 2)));

    fprintf("- Quarter: %s: %2.2fh\n", quarter, inst_2-inst_1)
end

%% Instance over period - samples
% Rappresentazione dell'andamento di Generation al variare di Quarter per
% diverse instances, in modo da evidenziare possibili problematiche con il
% fit lungo quarter

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Solar Energy');
subtitle('Generation vs Quarter (by Instance)');

xlabel("Quarter (day)")
ylabel("Generation (kWh)")
ytickformat('%.1f')
instances = unique(df.Instance);

for n=26:15:80    
    X = df.Period(df.Instance==instances(n));
    Y = 1000*df.Generation(df.Instance==instances(n));
   
    plot(X, Y, '.-', DisplayName=sprintf('Instance %d', n))
end

lgd=legend();
lgd.Title.String='Period';

pbaspect([2, 1, 1])

%% FFT
