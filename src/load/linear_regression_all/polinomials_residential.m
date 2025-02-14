% Regressione lineare con regressori polinomiali utilizzando tutti i dati
% di origine RESIDENZIALE.

%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% Analisi
data = df(df.Location_Electricity.endsWith('r'), :);

[mse, params] = polinomial_tests_1d(data, "Residential Load - All locations", true, true);   

fprintf("Ordine:\n\tF: %d\n\tFPE: %d\n\tAIC: %d\n\tMDL: %d\n\tCrossvalidazione: %d\n", params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"))