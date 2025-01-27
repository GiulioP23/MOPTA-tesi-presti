% Solar Energy: linear regression (Polinomials) 3D
%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab
df.Period = 1*(df.Quarter=='Q1')+92*(df.Quarter=='Q2')+183*(df.Quarter=='Q3')+274*(df.Quarter=='Q4');

%% Data selection and analysis

instances = df.Instance(df.Generation>0);
periods = df.Period(df.Generation>0);
generation = df.Generation(df.Generation>0);
phi = [
    instances.^0 instances periods... // 0
    instances.^2 periods.^2 periods.*instances... // 1
    instances.^3 periods.^3 periods.*instances.^2 instances.*periods.^2 ...
    instances.^4 instances.^5 instances.^6 instances.^7 instances.^8 % aumento flessibilità sulle instances, h3 non è suff
];

%[thetaLS, theta_std] = lscov(phi, df.Generation);
%loadLS = phi*thetaLS;
%e = df.Generation - loadLS;
%ssr = sum(e.^2);

%% Lasso

[B,FitInfo] = lasso(phi, generation, 'CV', 10); %"PredictorNames", ["c", "h", "p", "h2",  "p2", "hp", "h3", "p3", "h2p", "hp2", "h4", "h5", "h6", "h7", "h8"]

lassoPlot(B,FitInfo,PlotType="CV");
legend("show")

% FitInfo.PredictorNames(B(:, 75)~=0)
% B(B(:, 75)~=0, 75)
%%
[thetaLS, theta_std] = lscov(phi, generation);
thetaLS=B(:, FitInfo.IndexMinMSE);
predictions = phi*thetaLS;
e = predictions - generation; 
ssr = sum(e.^2);

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
%hold on;
grid on;
plot3(instances, periods, generation, 'b.')
hold on;
scatter3(instances, periods, predictions)
%plot3(instances, periods, predictions, 'b.')


% mdlLasso = stepwiselm(datiLassoTrain, grassoCorporeoTrain, 'constant', 'PRemove', 1, 'Upper', 'quadratic');  
