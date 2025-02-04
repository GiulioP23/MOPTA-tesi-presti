% Solar Energy: linear regression (Polinomials) Biperiodic model
% In questo caso effettuo la regressione lineare con complessità fissa
% per Quarter (Period). Ordine massimo in Quarter: 1

%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab

%% Data selection and analysis
condititon=logical(df.Generation.^0);  %df.Generation>0; 
instances = df.Instance(condititon);
periods = df.Period(condititon);
generation = df.Generation(condititon);
Ty = 2*365; % (df.Period) yearly period, e sappiamo essere esattamente questo
Td = 2*24; % (df.Instance) daily period. Ancora una volta sappiamo essere esattamente questo a priori

phi = [
    instances.^0 ... % cost
    ... % 1 ord
    cos(1*2*pi/Td*instances) sin(1*2*pi/Td*instances)... %(1, 0)
    cos(1*2*pi/Ty*periods) sin(1*2*pi/Ty*periods)... % (1, 1)
    cos(1*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(1*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
    cos(1*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(1*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    ... % 2 ord
    cos(2*2*pi/Td*instances) sin(2*2*pi/Td*instances)... 
    cos(2*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(2*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
    cos(2*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(2*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    ...% 3 ord
    cos(3*2*pi/Td*instances) sin(3*2*pi/Td*instances)...
    cos(3*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(3*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    cos(3*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(3*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
    ...% 4 ord
    cos(4*2*pi/Td*instances) sin(4*2*pi/Td*instances)...   
    cos(4*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(4*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    cos(4*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(4*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
     ...% 5 ord
    cos(5*2*pi/Td*instances) sin(5*2*pi/Td*instances)...   
    cos(5*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(5*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    cos(5*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(5*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
     ...% 6 ord
    cos(6*2*pi/Td*instances) sin(6*2*pi/Td*instances)...   
    cos(6*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(6*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    cos(6*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(6*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
    ...% 7 ord
    cos(7*2*pi/Td*instances) sin(6*2*pi/Td*instances)...   
    cos(7*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(7*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    cos(7*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(72*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
    ...% 8 ord
    cos(8*2*pi/Td*instances) sin(6*2*pi/Td*instances)...   
    cos(8*2*pi/Td*instances).*cos(1*2*pi/Ty*periods) sin(8*2*pi/Td*instances).*sin(1*2*pi/Ty*periods)...
    cos(8*2*pi/Td*instances).*sin(1*2*pi/Ty*periods) sin(8*2*pi/Td*instances).*cos(1*2*pi/Ty*periods)...
];

%% Lasso shrinkage

[B,FitInfo] = lasso(phi, generation, 'CV', 10); %"PredictorNames", ["c", "h", "p", "h2",  "p2", "hp", "h3", "p3", "h2p", "hp2", "h4", "h5", "h6", "h7", "h8"]

% lassoPlot(B,FitInfo,PlotType="CV");

predictions = phi*B(:, FitInfo.Index1SE)+FitInfo.Intercept(FitInfo.Index1SE);
e = predictions - generation; 
ssr = sum(e.^2);
mse = ssr/384;

regSelect = B(:, FitInfo.Index1SE)~=0;

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
%hold on;
grid on;
plot3(df.Instance, df.Period, df.Generation, 'b.')
hold on;
scatter3(instances, periods, predictions)
%plot3(instances, periods, predictions, 'b.')

%% test
b=B(:, FitInfo.Index1SE)
c=b(b~=0)
length(c)

%% Fit sui regressori selezionati
phi_lasso = [instances.^0 phi(:, regSelect)];
[thetaLS, theta_std] = lscov(phi_lasso, generation);
predictions = phi_lasso*thetaLS;
e = predictions - generation; 
ssr = sum(e.^2);
mse = ssr/384;

% si osserva un miglioramento marginale rispetto al fit Lasso

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);

%hold on;
grid on;


plot3(df.Instance, df.Period, df.Generation, 'b.')
hold on;
title('Solar Energy (Fourier)');
subtitle('Generation vs Instance and Period')
xlabel('Instance (hours)')
ylabel('Period (day)')
zlabel('Generation (MWh)')
scatter3(instances, periods, predictions)

%% Grafico 3D risultati Lasso
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
plot3(instances, df.Period, generation, 'b.')

hold on;
grid on;
title('Solar Energy (Fourier)');
subtitle('Generation vs Instance and Period')

xlabel('Instance (hours)')
ylabel('Period (day)')
zlabel('Generation (MWh)')

periodGrid = linspace(0, 300, 100)'; %365
instanceGrid = linspace(min(instances), max(instances), 100)';

[periodTable, instanceTable] = meshgrid(periodGrid, instanceGrid);

periodVec = periodTable(:);
instanceVec = instanceTable(:);

fullPhiGrid = [
    instanceVec.^0 ... % cost
    ... % 1 ord
    cos(1*2*pi/Td*instanceVec) sin(1*2*pi/Td*instanceVec)...
    cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Ty*periodVec)...
    cos(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    cos(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    ... % 2 ord
    cos(2*2*pi/Td*instanceVec) sin(2*2*pi/Td*instanceVec)... 
    cos(2*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(2*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    cos(2*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(2*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    ...% 3 ord
    cos(3*2*pi/Td*instanceVec) sin(3*2*pi/Td*instanceVec)...
    cos(3*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(3*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(3*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(3*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 4 ord
    cos(4*2*pi/Td*instanceVec), sin(4*2*pi/Td*instanceVec)...   
    cos(4*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(4*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(4*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(4*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 5 ord
    cos(5*2*pi/Td*instanceVec), sin(5*2*pi/Td*instanceVec)...   
    cos(5*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(5*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(5*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(5*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 6 ord
    cos(6*2*pi/Td*instanceVec), sin(6*2*pi/Td*instanceVec)...   
    cos(6*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(6*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(6*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(6*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 7 ord
    cos(7*2*pi/Td*instanceVec), sin(6*2*pi/Td*instanceVec)...   
    cos(7*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(7*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(7*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(7*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 8 ord
    cos(8*2*pi/Td*instanceVec), sin(6*2*pi/Td*instanceVec)...   
    cos(8*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(8*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(8*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(8*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
];

phiGrid = [instanceVec.^0 fullPhiGrid(:, regSelect)];
loadGrid = phiGrid*thetaLS;
loadTable = reshape(loadGrid, size(periodTable));

mesh(instanceTable, periodTable, loadTable, FaceColor="interp", FaceAlpha=0.7)

colormap('cool')

%legend;
pbaspect([2, 1, 1])

%% Test F
% In questo caso utilizzao il test F per determinare l'ordinde del modello.
% Per semplicità parto dal primo ordine invece che dall'oridne zero. 
% In ogni caso sappiamo già che l'ordine zero non è sufficiente a spiegare
% i dati. Poi proseguo incrementando di un ordine alla volta (6 param).
% -> verifica

N=length(generation);

Phi = phi(:, 1:9);  % phi per il primo ordine

[nthetaLS, ntheta_std] = lscov(Phi, generation);
loadLS = Phi*nthetaLS;
e = generation - loadLS;
SSR = sum(e.^2);

for q=15:6:52 % parto da 9 (dopo il primo ordine), e aumento di 6
    display(q)
    Phi = phi(:, 1:q);
    [nthetaLS, ntheta_std] = lscov(Phi, generation);
    loadLS = Phi*nthetaLS;
    e = generation - loadLS;
    ssr = sum(e.^2);
    varEst=ssr/(N-q);
    
    f = (N-q)*(SSR-ssr)/ssr;
    f_alpha = finv(0.95, 6, N-q); % rivedi
    
    if f<f_alpha
        q=q-6;
        break;
    end

    % update values
    SSR=ssr;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
end

%% Grafico 3D risultati Test-F
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
plot3(instances, df.Period, generation, 'b.')

hold on;
grid on;
title('Solar Energy (Test F)');
subtitle(sprintf("First order in Period, %d parameters", q))

xlabel('Instance (hours)')
ylabel('Period (day)')
zlabel('Generation (MWh)')

periodGrid = linspace(0, 300, 100)'; %365
instanceGrid = linspace(min(instances), max(instances), 100)';

[periodTable, instanceTable] = meshgrid(periodGrid, instanceGrid);

periodVec = periodTable(:);
instanceVec = instanceTable(:);

fullPhiGrid = [
    instanceVec.^0 ... % cost
    ... % 1 ord
    cos(1*2*pi/Td*instanceVec) sin(1*2*pi/Td*instanceVec)...
    cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Ty*periodVec)...
    cos(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(1*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    cos(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(1*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    ... % 2 ord
    cos(2*2*pi/Td*instanceVec) sin(2*2*pi/Td*instanceVec)... 
    cos(2*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(2*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    cos(2*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(2*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    ...% 3 ord
    cos(3*2*pi/Td*instanceVec) sin(3*2*pi/Td*instanceVec)...
    cos(3*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(3*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(3*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(3*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 4 ord
    cos(4*2*pi/Td*instanceVec), sin(4*2*pi/Td*instanceVec)...   
    cos(4*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(4*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(4*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(4*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 5 ord
    cos(5*2*pi/Td*instanceVec), sin(5*2*pi/Td*instanceVec)...   
    cos(5*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(5*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(5*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(5*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 6 ord
    cos(6*2*pi/Td*instanceVec), sin(6*2*pi/Td*instanceVec)...   
    cos(6*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(6*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(6*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(6*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 7 ord
    cos(7*2*pi/Td*instanceVec), sin(6*2*pi/Td*instanceVec)...   
    cos(7*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(7*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(7*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(7*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
    ...% 8 ord
    cos(8*2*pi/Td*instanceVec), sin(6*2*pi/Td*instanceVec)...   
    cos(8*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec) sin(8*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec)...
    cos(8*2*pi/Td*instanceVec).*sin(1*2*pi/Ty*periodVec) sin(8*2*pi/Td*instanceVec).*cos(1*2*pi/Ty*periodVec)...
];

phiGrid = fullPhiGrid(:, 1:q);
loadGrid = phiGrid*thetaLS;
loadTable = reshape(loadGrid, size(periodTable));

mesh(instanceTable, periodTable, loadTable, FaceColor="interp", FaceAlpha=0.7)

colormap('cool')

%legend;
pbaspect([2, 1, 1])