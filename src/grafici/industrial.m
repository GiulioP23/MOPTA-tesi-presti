%% Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% Industrial Load - All data
% Rappresenta tutti i carichi industriali, indipendentemente dal periodo,
% in funzione del tempo

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Industrial Load');
subtitle('Generation vs Instance');

xlabel("Instance (local time)")
ylabel("Load (MWh)")

X=duration(df.Instance(df.Industrial), 0, 0);
X.Format="hh:mm";
Y=df.Load(df.Industrial);
scatter(X, Y, '.')

pbaspect([2, 1, 1])


%% Industrial Load - All data (by Period)
% Rappresenta in funzione del tempo tutti i carichi industriali, 
% rappresentando con colori diversi i carichi relativi a diversi periodi.
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Industrial Load');
subtitle('Generation vs Instance');

xlabel("Instance (local time)")
ylabel("Load (MWh)")

periods = unique(df.Quarter);
for n=1:4
    X=duration(df.Instance(all([df.Industrial, df.Quarter==periods(n)], 2)), 0, 0);
    X.Format="hh:mm";
    Y=df.Load(all([df.Industrial, df.Quarter==periods(n)], 2));
    scatter(X, Y, '.', DisplayName=periods(n))
end

lgd=legend();
lgd.Title.String='Period';

pbaspect([2, 1, 1])

%% Varianza per instance
% Grafico che rappresenta la varianza della variabile "Load" per ogni
% "instance" (tempo).
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Industrial Load Variance');
subtitle('Variance vs Instance');

xlabel("Instance")
ylabel("Variance (MWh^2)")

instances = unique(df.Instance(df.Industrial));

X=instances;
Y=ones(length(instances), 1);

for n=1:length(instances)
    Y(n)=var(df.Load(all([df.Industrial, df.Instance==instances(n)], 2)));
end

scatter(X, Y, 'x')

pbaspect([2, 1, 1])
