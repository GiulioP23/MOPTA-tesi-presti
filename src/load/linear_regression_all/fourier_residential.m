% Utilizzo della serie di Fourier per identificare i modelli più adatti a
% descrivere tutti i dati resideziali (per instance)

%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% Analisi
data = df(df.Location_Electricity.endsWith('r'), :);

[mse, params] = fourier_tests_1d(data, "Residential Load - All Locations", true, true);   

fprintf("Ordine:\n\tF: %d\n\tFPE: %d\n\tAIC: %d\n\tMDL: %d\n\tCrossvalidazione: %d\n", params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"))