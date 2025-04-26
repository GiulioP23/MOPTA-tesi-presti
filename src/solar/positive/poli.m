% Solar Gpositive-restricted data analysis using polinomial models
%% Startup
clear 
clc
close all

df = caricaSolar(); % nota: la funzione deve essere aggiunta al path di matlab

% positive generation selection
pgen=df.Generation>0; % positive generation locatio 
sel=any([circshift(pgen, 1), circshift(pgen, -1)], 2); % all conditions here
wmax = sum(df.Generation==0); % max weigth, number of zeroes values
weigths = wmax*sel - (wmax-1)*pgen;

% select data
data = df(sel, :);
weigths = weigths(sel);

phifun=@(instances, periods)[
    instances.^0 ... % cost
    instances periods...
    instances.^2 periods.^2 instances.*periods ...
    instances.^3 periods.^3 instances.*periods.^2 periods.*instances.^2 ...
    instances.^4 periods.^4 instances.*periods.^3 periods.*instances.^3 (instances.^2).*periods.^2 ...
    instances.^5 periods.^5 ...
    instances.^6 periods.^6 ...
    instances.^7 instances.^8
];

data.Load=data.Generation;
tests_2d_w(data, phifun, weigths, "Solar Generation (+)", "Generation(MWh)", true, true);