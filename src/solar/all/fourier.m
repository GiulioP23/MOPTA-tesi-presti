% Solar Energy: linear regression (Polinomials) Biperiodic model
%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab

%% Data selection and analysis
condititon=logical(df.Generation.^0); %df.Generation>0;
instances = df.Instance(condititon);
periods = df.Period(condititon);
generation = df.Generation(condititon);
Ty = 2*365; % (df.Period) yearly period, e sappiamo essere esattamente questo
Td = 2*24; % (df.Instance) daily period. Ancora una volta sappiamo essere esattamente questo a priori

phi = [
    instances.^0 ... % cost
    ... % 1 ord
    cos(1*2*pi/Td*instances) sin(1*2*pi/Td*instances)...
    cos(1*2*pi/Ty*periods) sin(1*2*pi/Ty*periods)...
    ... % 2 ord
    cos(2*2*pi/Td*instances) sin(2*2*pi/Td*instances)... 
    cos(2*2*pi/Ty*periods) sin(2*2*pi/Ty*periods) ...
    cos(2*2*pi/Td*instances).*cos(2*2*pi/Ty*periods) sin(2*2*pi/Td*instances).*cos(2*2*pi/Ty*periods)... 
    cos(2*2*pi/Td*instances).*sin(2*2*pi/Ty*periods) sin(2*2*pi/Td*instances).*cos(2*2*pi/Ty*periods)...
    ... % 3 ord, senza interazioni
    cos(3*2*pi/Td*instances) sin(3*2*pi/Td*instances)...
    cos(3*2*pi/Ty*periods) sin(3*2*pi/Ty*periods)...
    ... % ordini superiori per instance
    cos(4*2*pi/Td*instances) sin(4*2*pi/Td*instances)...
    cos(5*2*pi/Td*instances) sin(5*2*pi/Td*instances)...
    cos(6*2*pi/Td*instances) sin(6*2*pi/Td*instances)...
    cos(7*2*pi/Td*instances) sin(7*2*pi/Td*instances)...
    cos(8*2*pi/Td*instances) sin(8*2*pi/Td*instances)...
    cos(9*2*pi/Td*instances) sin(9*2*pi/Td*instances)...
    cos(10*2*pi/Td*instances) sin(10*2*pi/Td*instances)...
    cos(11*2*pi/Td*instances) sin(11*2*pi/Td*instances)...
    ... % ordini superiori per period
    cos(4*2*pi/Ty*periods) sin(4*2*pi/Ty*periods) ...
    cos(5*2*pi/Ty*periods) sin(5*2*pi/Ty*periods) ...
    cos(6*2*pi/Ty*periods) sin(6*2*pi/Ty*periods) ...
];
% 
% [thetaLS, theta_std] = lscov(phi, df.Generation);
% loadLS = phi*thetaLS;
% e = df.Generation - loadLS;
% ssr = sum(e.^2);

%% Lasso

[B,FitInfo] = lasso(phi, generation, 'CV', 10); %"PredictorNames", ["c", "h", "p", "h2",  "p2", "hp", "h3", "p3", "h2p", "hp2", "h4", "h5", "h6", "h7", "h8"]

% lassoPlot(B,FitInfo,PlotType="CV");
% legend("show")

% FitInfo.PredictorNames(B(:, 75)~=0)
% B(B(:, 75)~=0, 75)
%%
phi_lasso = [instances.^0 phi(:, B(:, FitInfo.Index1SE)~=0)];
[thetaLS, theta_std] = lscov(phi_lasso, generation);
predictions = phi_lasso*thetaLS;
e = predictions - generation; 
ssr = sum(e.^2);

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
%hold on;
grid on;
plot3(df.Instance, df.Period, df.Generation, 'b.')
hold on;
scatter3(instances, periods, predictions)
%plot3(instances, periods, predictions, 'b.')


% mdlLasso = stepwiselm(datiLassoTrain, grassoCorporeoTrain, 'constant', 'PRemove', 1, 'Upper', 'quadratic');  
