%% Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% Residential Load - All data
% Rappresenta tutti i carichi residenziali, indipendentemente dal periodo,
% in funzione del tempo

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Residential Load');
subtitle('Generation vs Instance');

xlabel("Instance (local time)")
ylabel("Load (MWh)")

X=duration(df.Instance(~df.Industrial), 0, 0);
X.Format="hh:mm";
Y=df.Load(~df.Industrial);
scatter(X, Y, '.')

pbaspect([2, 1, 1])


%% Residential Load - All data (by Period)
% Rappresenta in funzione del tempo tutti i carichi industriali, 
% rappresentando con colori diversi i carichi relativi a diversi periodi.
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Residential Load');
subtitle('Generation vs Instance');

xlabel("Instance (local time)")
ylabel("Load (MWh)")

colors = [
    0.0000, 0.4470, 0.7410;  % blue
    0.8500, 0.3250, 0.0980;  % orange
    0.9290, 0.6940, 0.1250;  % yellow
    0.4940, 0.1840, 0.5560   % purple
];
ylim=[0, 45];
periods = unique(df.Quarter);
location = unique(df.Location_Electricity(~df.Industrial));
for n=1:4    
    for nl=1:5
        X=duration(df.Instance(all([df.Quarter==periods(n), df.Location_Electricity==location(nl)], 2)), 0, 0);
        X.Format="hh:mm";
        Y=df.Load(all([df.Quarter==periods(n), df.Location_Electricity==location(nl)], 2));

        plot(X, Y, 'Color', [colors(n, :), 0.5], 'LineWidth', 0.5, 'HandleVisibility', 'off');
    end
    X_all=duration(df.Instance(all([df.Quarter==periods(n), ~df.Industrial], 2)), 0, 0);
    Y_all=df.Load(all([df.Quarter==periods(n), ~df.Industrial], 2));
    scatter(X_all, Y_all, '.', 'MarkerEdgeColor', colors(n, :), DisplayName=periods(n))
    lgd=legend();
    lgd.Title.String='Period';
    w=0;
end

pbaspect([2, 1, 1])

%% Varianza per instance
% Grafico che rappresenta la varianza della variabile "Load" per ogni
% "instance" (tempo).
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;

title('Residential Load Variance');
subtitle('Variance vs Instance');

xlabel("Instance (id)")
ylabel("Variance (MWh^2)")

instances = unique(df.Instance(~df.Industrial));

X=instances;
Y=ones(length(instances), 1);

for n=1:length(instances)
    Y(n)=var(df.Load(all([~df.Industrial, df.Instance==instances(n)], 2)));
end

scatter(X, Y, 'x')

pbaspect([2, 1, 1])

%% Period comparison by location

location='1_r';

figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Residential Load');
subtitle('Location 3\_r');

xlabel("Instance (local time)")
ylabel("Load (MWh)")

periods = unique(df.Quarter);
for n=1:4
    X=duration(df.Instance(all([df.Quarter==periods(n), df.Location_Electricity==location], 2)), 0, 0);
    X.Format="hh:mm";
    Y=df.Load(all([df.Quarter==periods(n), df.Location_Electricity==location], 2));
    scatter(X, Y, '.', DisplayName=periods(n))
end

lgd=legend();
lgd.Title.String='Period';

pbaspect([2, 1, 1])



location='2_r';
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Residential Load');
subtitle('Location 4\_r');

xlabel("Instance (local time)")
ylabel("Load (MWh)")

periods = unique(df.Quarter);
for n=1:4
    X=duration(df.Instance(all([df.Quarter==periods(n), df.Location_Electricity==location], 2)), 0, 0);
    X.Format="hh:mm";
    Y=df.Load(all([df.Quarter==periods(n), df.Location_Electricity==location], 2));
    scatter(X, Y, '.', DisplayName=periods(n))
end

lgd=legend();
lgd.Title.String='Period';

pbaspect([2, 1, 1])