%% 1. Startup
clear 
clc
close all

%% Data selection and analysis
df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab
locations = unique(df.Location_Electricity(df.Location_Electricity.endsWith('r')));
quarters = unique(df.Quarter);

for n=1:length(locations)
    location = locations(n);    

    locData = df(df.Location_Electricity==location, :);
    for q=1:4
        quarter = quarters(q);        
        qData = locData(locData.Quarter==quarter, :);
        [mse, params] = fourier_tests_1d(qData, sprintf("Location %s (%s)", location.replace('_', ''), quarter), false, false);
        fprintf("Location %s, Quarter %s\n\tFPE-nparam: %d\n\tFPE-MSE: %3.2f\n", location, quarter, params('FPE'), mse('FPE'));
    end
    
end

%% Test a specific location and period
% In questa sezione è possibile visualizzare i risultati dei test per una
% specifica serie selezionata di seguito, e i relativi grafici.

quarter = "Q3";
location = "1_r";

locData = df(df.Location_Electricity==location, :);
qData = locData(locData.Quarter==quarter, :);
[mse, params] = fourier_tests_1d(qData, sprintf("Location %s (%s)", location.replace('_', ''), quarter), true, true);   

fprintf("Quarter %s, Location: %s\nOrdine:\n\tF: %d\n\tFPE: %d\n\tAIC: %d\n\tMDL: %d\n\tCrossvalidazione: %d\n", quarter, location, params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"))