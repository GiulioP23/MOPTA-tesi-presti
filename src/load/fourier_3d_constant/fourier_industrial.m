% Analisi delle location residenziali come somma di una costante dipendente
% da Quarter e un polinomio per Instance.
%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di 

% Data selection
data = df(df.Industrial,:);

pics=true;
write=true;

%% periodic c(t) - Lasso, backward/forward selection
% identificazione modello c(d)+f(i) (day, instance), con c(d) "costante" di
% tipo serie fourier in days
fprintf("\n\nFourier c(t)\n")
Ty = 365; % (df.Period) yearly period,

phifunf = @(instances, periods) [
    instances.^0 ... % cost
    ... % c(y) - cost dependent on time of the year
    cos(1*2*pi/Ty*periods) sin(1*2*pi/Ty*periods)...
    ... % cos(2*2*pi/Ty*periods) sin(2*2*pi/Ty*periods)... % troppo flesibile
    instances instances.^2 ...
    instances.^3 instances.^4 ...
    instances.^5 instances.^6 ...
    instances.^7 instances.^8 ...
    instances.^9 instances.^10 ...
    % instances.^11 instances.^12 ...
    % instances.^13 instances.^14 ...
];

% Lasso, backward/forward stepwise
[msef, nparamsf, self] = tests_2d(data, phifunf, "Industrial Load", "Load (MWh)", write, pics);

%% Graph c(t)
if pics % all_residential_lasso_const_graph_fourier
    phi=phifunf(data.Instance, data.Period);
    regSelect = self{"lasso"};
    lsphi = phi(:, regSelect);
    [thetaLS] = lscov(lsphi, data.Load); % get full thetaLS

    dperiods = linspace(1, 365, 365)';
    dinstances = zeros(1, 365)'; % set instances to zero so they don't contribute but for a constant

    picphi = phifunf(dinstances, dperiods);
    picphi = picphi(:, regSelect);

    predictions = picphi*thetaLS;

    a=figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    title("C(t)");
    subtitle('Periodic model');
    
    xlabel("Period (day)")
    ylabel("C (MWh)")

    plot(dperiods, predictions, 'DisplayName', "model offset (Period)", 'LineWidth', 1.2);
        
    % legend;
    pbaspect([2, 1, 1])
end

%% polinomial c(t) - Lasso, backward/forward selection
% identificazione modello c(d)+f(i) (day, instance), con c(d) "costante" di
% tipo polinomiale, 4 punti - polinomio di terzo grado
fprintf("\n\nPolinomial c(t)\n")
Td = 2*24; % (df.Instance) daily period. Utilizzo periodo doppio per tener conto dela non-periodicità (e.g. trnd, meteo, ecc)
phifunp = @(instances, periods) [
    instances.^0 ... % cost
    ... % c(y) - cost dependent on time of the year
    periods periods.^2 periods.^3 ...
    ... % instance model
    instances instances.^2 ...
    instances.^3 instances.^4 ...
    instances.^5 instances.^6 ...
    instances.^7 instances.^8 ...
    instances.^9 instances.^10 ... % termini non compatibili con lasso senza regolarizzazione
    % instances.^11 instances.^12 ...
    % instances.^13 instances.^14 ...
];

% Lasso, backward/forward stepwise
[msep, nparamsp, selp] = tests_2d(data, phifunp, "Industrial Load", "Load (MWh)", write, pics);

%% Graph c(t)
if pics % all_residential_lasso_const_graph_poli
    phi=phifunp(data.Instance, data.Period);
    regSelect = selp{"lasso"};
    lsphi = phi(:, regSelect);
    [thetaLS] = lscov(lsphi, data.Load); % get full thetaLS

    dperiods = linspace(1, 365, 365)';
    dinstances = zeros(1, 365)'; % set instances to zero so they don't contribute but for a constant

    picphi = phifunp(dinstances, dperiods);
    picphi = picphi(:, regSelect);

    predictions = picphi*thetaLS;

    a=figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    title("C(t)");
    subtitle('Polinomial model');

    xlabel("Period (day)")
    ylabel("C (MWh)")

    plot(dperiods, predictions, 'DisplayName', "model offset (Period)", 'LineWidth', 1.2);
        
    % legend;
    pbaspect([2, 1, 1])
end

%% Overlap c(t)
phip=phifunp(data.Instance, data.Period); % all_residential_lasso_const_graph_both
regSelect = selp{"forward"};
lsphi = phip(:, regSelect);
[thetaLS] = lscov(lsphi, data.Load); % get full thetaLS

dperiods = linspace(1, 365, 365)';
dinstances = zeros(1, 365)'; % set instances to zero so they don't contribute but for a constant

picphi = phifunp(dinstances, dperiods);
picphi = picphi(:, regSelect);

predictionsp = picphi*thetaLS;

phi=phifunf(data.Instance, data.Period);
regSelect = self{"forward"};
lsphi = phi(:, regSelect);
[thetaLS] = lscov(lsphi, data.Load); % get full thetaLS

dperiods = linspace(1, 365, 365)';
dinstances = zeros(1, 365)'; % set instances to zero so they don't contribute but for a constant

picphi = phifunf(dinstances, dperiods);
picphi = picphi(:, regSelect);

predictionsf = picphi*thetaLS;

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title("C(t)");
subtitle('Comparison');

xlabel("Period (day)")
ylabel("C (MWh)")

plot(dperiods, predictionsp, 'DisplayName', "model offset (polinomial)", 'LineWidth', 1.2);
plot(dperiods, predictionsf, 'DisplayName', "model offset (fourier)", 'LineWidth', 1.2);  
legend;
pbaspect([2, 1, 1])