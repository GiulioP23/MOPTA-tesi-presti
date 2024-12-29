%% Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% selezione dati
industrial_load=df.Load(df.Location_Electricity.endsWith('i'));

industrial_instances=df.Instance(df.Location_Electricity.endsWith('i'));

N = length(industrial_instances);

%% Neighborhood
% Nota: dal momento che il numero di dati per ciascun instance è lo stesso
% e gli elementi di Instance sono distribuiti uniformemente può risultare 
% utile utilizzare la media per ciascun instance piuttosto che un intorno più ampio.

X=unique(industrial_instances);
Y=X;
y_std=X;
count = length(industrial_load(industrial_instances==1));
for n=1:length(X)
    Y(n) = mean(industrial_load(industrial_instances==n));
    y_std(n)=std(industrial_load(industrial_instances==n));
end

%% alpha-Neighborhood (e.g. 10%)
n_k=round(0.1*N);

