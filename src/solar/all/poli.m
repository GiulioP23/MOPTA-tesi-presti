% Solar Energy: linear regression (Polinomials) 3D
%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab
% df.Period = 1*(df.Quarter=='Q1')+92*(df.Quarter=='Q2')+183*(df.Quarter=='Q3')+274*(df.Quarter=='Q4');

%% Data selection and analysis

instances = df.Instance;
periods = df.Period;
generation = df.Generation;
phifun = @(instances, periods)[
    instances.^0 instances periods... // 0
    instances.^2 periods.^2 periods.*instances... // 1
    instances.^3 periods.^3 periods.*instances.^2 instances.*periods.^2 ...
    instances.^4 periods.*instances.^3 instances.*periods.^3 (periods.^2).*instances.^2 ...
    instances.^5 instances.^6 instances.^7 instances.^8 % aumento flessibilità sulle instances, h3 non è suff
];

df.Load = df.Generation;

% Lasso, backward/forward stepwise
[mse, nparams, sel] = tests_2d(df, phifun, "Solar Generation", "Generation (MWh)", true, true);
