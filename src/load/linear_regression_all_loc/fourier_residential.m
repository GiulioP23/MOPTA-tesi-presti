%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% 2. Selezione dati
residential_locations = unique(df.Location_Electricity(df.Location_Electricity.endsWith('r')));
periods = unique(df.Quarter);
for n=1:length(residential_locations)
    data = df(df.Location_Electricity==residential_locations(n), :);
    for q = 1:length(periods)
        fprintf('Location: '+residential_locations(n)+', Quarter: '+periods(1)+'\n')
        fourier_analyze_location(data(data.Quarter==periods(q), :))
    end    
    fprintf('\n\n\n')
    break
end

%% test
fourier_tests_1d(df(all([df.Quarter=='Q3', df.Location_Electricity=='1_r'], 2), :))