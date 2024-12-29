%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% 2. Selezione dati
residential_load=df.Load(df.Location_Electricity.endsWith('r'));

residential_instances=df.Instance(df.Location_Electricity.endsWith('r'));

N = length(residential_instances);
T = max(residential_instances);
full_phiF=[ones(N, 1) ...
     cos(1*2*pi/T*residential_instances) sin(1*2*pi/T*residential_instances)...
     cos(2*2*pi/T*residential_instances) sin(2*2*pi/T*residential_instances)... 
     cos(3*2*pi/T*residential_instances) sin(3*2*pi/T*residential_instances)...
     cos(4*2*pi/T*residential_instances) sin(4*2*pi/T*residential_instances)...
 ];

full_phi=[ones(N, 1) residential_instances residential_instances.^2 residential_instances.^3 residential_instances.^4 residential_instances.^5 residential_instances.^6 residential_instances.^7 residential_instances.^8 residential_instances.^9 residential_instances.^10];

%% 3. Fourier
phi = full_phiF(:, 1:5);
[nthetaLS, ntheta_std] = lscov(phi, residential_load);
loadLS = phi*nthetaLS;


% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Residential Load');
subtitle('Best model');

xlabel("Instance (hours)")
ylabel("Load (MWh)")

X=unique(residential_instances);
phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                      cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                      cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                      cos(4*2*pi/T*X) sin(4*2*pi/T*X)
                      ];

Y_LS = phi_graph(:, 1:5)*nthetaLS;

scatter(residential_instances, residential_load, ".", 'HandleVisibility','off')

plot(X, Y_LS, 'DisplayName', "Fourier (5-param)", 'LineWidth', 1.2);

legend;
pbaspect([2, 1, 1])
%% Polinomial
thetaLS = [mean(residential_load)];
theta_std=[std(residential_load)/sqrt(N)];

SSR=sum((residential_load-thetaLS).^2);
q=9;
phi = full_phi(:, 1:q);
[nthetaLS, ntheta_std] = lscov(phi, residential_load);
loadLS = phi*nthetaLS;
e = residential_load - loadLS;

thetaLS=nthetaLS;

X=unique(residential_instances);
phi_graph = [X.^0, X.^1,X.^2,X.^3,X.^4,X.^5,X.^6, X.^7, X.^8, X.^9, X.^10];
Y_LS = phi_graph(:, 1:q)*thetaLS;

plot(X, Y_LS, 'DisplayName', "Polinomial (9-param)", 'LineWidth', 1.2);

legend;
pbaspect([2, 1, 1])