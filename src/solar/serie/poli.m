% Solar Energy: linear regression (Polinomials)
%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab

%% Data selection and analysis
quarters = unique(df.Quarter);

for q=1:4
    quarter = quarters(q);        
    qData = df(df.Quarter==quarter, :);
    qData.Load=qData.Generation; % reuse load function
    [mse, params] = polinomial_tests_1d(qData, sprintf("Solar Energy (%s)", quarter), false, false);
    fprintf("Quarter %s\n\tnparam (F): %d\n\tnparam (FPE): %d\n\tnparam (AIC): %d\n\tnparam (MDL): %d\n\tnparam (Cross): %d\n\n", quarter, params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"));
end
    

%% Test a specific period
% In questa sezione è possibile visualizzare i risultati dei test per una
% specifica serie selezionata di seguito, e i relativi grafici.

quarter = "Q2";

qData = df(df.Quarter==quarter, :);
qData.Load=qData.Generation;
[mse, params] = polinomial_tests_1d(qData, sprintf("Solar Energy (%s)", quarter), true, true);   

fprintf("Quarter %s, Ordine:%d\n\tF: %d\n\tFPE: %d\n\tAIC: %d\n\tMDL: %d\n\tCrossvalidazione: %d\n", quarter, params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"))