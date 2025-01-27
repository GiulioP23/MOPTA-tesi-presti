clear 
clc
close all

%% lettura dati:
load()
% opts = detectImportOptions('data.xlsx', 'FileType','spreadsheet', 'Sheet','Electricity Load');  % Detect import options based on the file
% opts.VariableTypes = {'string', 'string', 'double', 'double'};  % Specify the types for each column
% 
% df = readtable('data.xlsx', opts);  % Read the table with specified column types
% df.industrial=df.Location_Electricity.endsWith('i');
%% tests

% df(df.Quarter=='Q1', ["Generation"])

%% residential figure
%figure()
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Residential Load');
subtitle('Generation vs Instance');
xlabel("Instance (local time)")
ylabel("Load (MWh)")
periods = unique(df.Quarter);
for n=1:4
    X=duration(0, df.Instance(all([~df.industrial, df.Quarter==periods(n)], 2))*15, 0);
    X.Format="hh:mm";
    Y=df.Load(all([~df.industrial, df.Quarter==periods(n)], 2));
    scatter(X, Y, '.', DisplayName=periods(n))
end
legend;
pbaspect([2, 1, 1])

%X=df.Instance(~df.industrial);
%Y=df.Load(~df.industrial);
%scatter(X, Y, '.')

%% Figure
figure(1)
title("Generation vs Instance")
grid on;
hold on;
scatter(df{df.Quarter=='Q1', "Instance"}*15, df{df.Quarter=='Q1', "Load"}, '.')
scatter(df{df.Quarter=='Q2', "Instance"}*15, df{df.Quarter=='Q2', "Load"}, '.')
scatter(df{df.Quarter=='Q3', "Instance"}*15, df{df.Quarter=='Q3', "Load"}, '.')
scatter(df{df.Quarter=='Q4', "Instance"}*15, df{df.Quarter=='Q4', "Load"}, '.')

axis([0 96*15 0 max(df{:, "Generation"})])
xlabel('Minuti')
ylabel('Energia prodotta')

%% daily fit

%% test day length

% [(~df.Generation==0) , df.Quarter=='Q1', all([(~df.Generation==0) , df.Quarter=='Q1'], 2)]

log_nn = @(q) all([df.Quarter==q, (~df.Generation==0)], 2);

q1_nn = df{log_nn('Q1'), "Instance"};
q2_nn = df{log_nn('Q2'), "Instance"};
q3_nn = df{log_nn('Q3'), "Instance"};
q4_nn = df{log_nn('Q4'), "Instance"};

% (q1_nn(length(q1_nn))-q1_nn(1))*15
% (q2_nn(length(q2_nn))-q2_nn(1))*15
% (q3_nn(length(q3_nn))-q3_nn(1))*15
% (q4_nn(length(q4_nn))-q4_nn(1))*15

(q1_nn(length(q1_nn))+q1_nn(1))/2.
(q2_nn(length(q2_nn))+q2_nn(1))/2.
(q3_nn(length(q3_nn))+q3_nn(1))/2.
(q4_nn(length(q4_nn))+q4_nn(1))/2.


%% tests
df = caricaSolar();

length(df.Quarter)

length(unique(df.Quarter))

length(unique(df.Instance))

length(df.Instance(df.Instance==1, :))