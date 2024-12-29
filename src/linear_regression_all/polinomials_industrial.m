% Regressione lineare con regressori polinomiali utilizzando tutti i dati
% di origine INDUSTRIALE.

% - Sezioni:
% 1. Startup
% 2. Selezione dati
% 3. Test F
% 4. FPE
% 5. AIC
% 6. MDL
% 7. Crossvalidazione 2-fold
% 8. Crossvalidazione k-fold (4 by defautl)
% 9-12 Cp, BIC, adjusted R2 (da aggiungere)

%% 1. Startup
clear 
clc
close all

df = caricaLoad(); % nota: la funzione deve essere aggiunta al path di matlab

%% 2. Selezione dati
industrial_load=df.Load(df.Location_Electricity.endsWith('i'));

industrial_instances=df.Instance(df.Location_Electricity.endsWith('i'));

N = length(industrial_instances);

full_phi=[ones(N, 1) industrial_instances industrial_instances.^2 industrial_instances.^3 industrial_instances.^4 industrial_instances.^5 industrial_instances.^6];

% Regression and Model Selection
%% 3. Test F
thetaLS = [mean(industrial_load)];
theta_std=[std(industrial_load)/sqrt(N)];

SSR=sum((industrial_load-thetaLS).^2);

for q=2:6
    phi = full_phi(:, 1:q);
    [nthetaLS, ntheta_std] = lscov(phi, industrial_load);
    loadLS = phi*nthetaLS;
    e = industrial_load - loadLS;
    ssr = sum(e.^2);
    varEst=ssr/(N-q);
    
    % disp("Modello a q="+q+" parametri");
    % disp("- SSR="+SSR+" thetaLS="+nthetaLS+" theta_std="+ntheta_std);
    
    f = (N-q)*(SSR-ssr)/ssr;
    f_alpha = finv(0.95, 1, N-q);
    
    if f<f_alpha
        q = q-1;
        break;
    end

    % update values
    SSR=ssr;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
end

% best model
disp("Modello migliore (test F)")
disp(q+" parametri:")
for n=1:q
    disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
end
disp("MSE="+SSR/N)

% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Industrial Load');
subtitle('F Prediction');

xlabel("Instance (hours)")
ylabel("Load (MWh)")

X=unique(industrial_instances);
phi_graph = [X.^0, X.^1,X.^2,X.^3,X.^4,X.^5,X.^6];
Y_LS = phi_graph(:, 1:q)*thetaLS;

scatter(industrial_instances, industrial_load, ".", 'HandleVisibility','off')
plot(X, Y_LS, 'DisplayName', "F-best fit ("+q+"-param)", 'LineWidth', 1.2);

legend;
pbaspect([2, 1, 1])

%% 4. FPE
thetaLS = [mean(industrial_load)];
theta_std = [std(industrial_load)/sqrt(N)];

SSR = sum((industrial_load-thetaLS).^2);

FPE = SSR;

for q=2:6
    phi = full_phi(:, 1:q);
    [nthetaLS, ntheta_std] = lscov(phi, industrial_load);
    loadLS = phi*nthetaLS;
    e = industrial_load - loadLS;
    ssr = sum(e.^2);
    varEst=ssr/(N-q); % stima varianza
    
    fpe = ssr*((N+q)/(N-q));
    
    if fpe>FPE
        q = q-1;
        break;
    end

    % update values
    SSR=ssr;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
    FPE=fpe;
end

% best model
disp("Modello migliore (FPE)")
disp(q+" parametri:")
for n=1:q
    disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
end
disp("MSE="+SSR/N)
% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Industrial Load');
subtitle('FPE Prediction');

xlabel("Instance (hours)")
ylabel("Load (MWh)")

X=unique(industrial_instances);
phi_graph = [X.^0, X.^1,X.^2,X.^3,X.^4,X.^5,X.^6];
Y_LS = phi_graph(:, 1:q)*thetaLS;

scatter(industrial_instances, industrial_load, ".", 'HandleVisibility','off')
plot(X, Y_LS, 'DisplayName', "FPE-best fit ("+q+"-param)", 'LineWidth', 1.2);

legend;
pbaspect([2, 1, 1])

%% 5. AIC
thetaLS = [mean(industrial_load)];
theta_std = [std(industrial_load)/sqrt(N)];

SSR = sum((industrial_load-thetaLS).^2);

AIC = 2/N+log(SSR);

for q=2:6
    phi = full_phi(:, 1:q);
    [nthetaLS, ntheta_std] = lscov(phi, industrial_load);
    loadLS = phi*nthetaLS;
    e = industrial_load - loadLS;
    ssr = sum(e.^2);
    varEst=ssr/(N-q); % stima varianza
    
    aic = 2*q/N+log(ssr);
    
    if aic>AIC
        q = q-1;
        break;
    end

    % update values
    SSR=ssr;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
    AIC=aic;
end

% best model
disp("Modello migliore (AIC)")
disp(q+" parametri:")
for n=1:q
    disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
end
disp("MSE="+SSR/N)

% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Industrial Load');
subtitle('AIC Prediction (Akaike Information Criterion)');

xlabel("Instance (hours)")
ylabel("Load (MWh)")

X=unique(industrial_instances);
phi_graph = [X.^0, X.^1,X.^2,X.^3,X.^4,X.^5,X.^6];
Y_LS = phi_graph(:, 1:q)*thetaLS;

scatter(industrial_instances, industrial_load, ".", 'HandleVisibility','off')
plot(X, Y_LS, 'DisplayName', "AIC-best fit ("+q+"-param)", 'LineWidth', 1.2);

legend;
pbaspect([2, 1, 1])

%% 6. MDL
thetaLS = [mean(industrial_load)];
theta_std = [std(industrial_load)/sqrt(N)];

SSR = sum((industrial_load-thetaLS).^2);

MDL = log(N)/N+log(SSR);

for q=2:6
    phi = full_phi(:, 1:q);
    [nthetaLS, ntheta_std] = lscov(phi, industrial_load);
    loadLS = phi*nthetaLS;
    e = industrial_load - loadLS;
    ssr = sum(e.^2);
    varEst=ssr/(N-q); % stima varianza
    
    mdl = log(N)/N*q+log(ssr);
    
    if mdl>MDL
        q = q-1;
        break;
    end

    % update values
    SSR=ssr;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
    MDL=mdl;
end

% best model
disp("Modello migliore (MDL)")
disp(q+" parametri:")
for n=1:q
    disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
end
disp("MSE="+SSR/N)

% display
figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
hold on;
title('Industrial Load');
subtitle('MDL Prediction');

xlabel("Instance (hours)")
ylabel("Load (MWh)")

X=unique(industrial_instances);
phi_graph = [X.^0, X.^1,X.^2,X.^3,X.^4,X.^5,X.^6];
Y_LS = phi_graph(:, 1:q)*thetaLS;

scatter(industrial_instances, industrial_load, ".", 'HandleVisibility','off')
plot(X, Y_LS, 'DisplayName', "AIC-best fit ("+q+"-param)", 'LineWidth', 1.2);

legend;
pbaspect([2, 1, 1])

%% Crossvalidazione 2-fold
% Divisione 50-50
c = cvpartition(N, 'HoldOut', 0.5);
trainIds = training(c, 1);

XTrain = industrial_instances(trainIds);
YTrain = industrial_load(trainIds);

XTest = industrial_instances(~trainIds);
YTest = industrial_load(~trainIds);

full_phi_train = [XTrain.^0, XTrain.^1, XTrain.^2, XTrain.^3, XTrain.^4, XTrain.^5, XTrain.^6];
full_phi_test = [XTest.^0, XTest.^1, XTest.^2, XTest.^3, XTest.^4, XTest.^5, XTest.^6];

thetaLS = [mean(industrial_load)];
theta_std = [std(industrial_load)/sqrt(N)];
SSR = sum((industrial_load-thetaLS).^2);

for q=1:6
    [nthetaLS, ntheta_std] = lscov(full_phi_train(:, 1:q), YTrain);
    loadLSTest = full_phi_test(:, 1:q)*nthetaLS;
    
    e = loadLSTest - YTest;
    ssr = sum(e.^2);
    
    if ssr>SSR
        q = q-1;
        break;
    end

    % update values
    SSR=ssr;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
end

% best model
disp("Modello migliore (Crossvalidazione 50-50)")
disp(q+" parametri:")
for n=1:q
    disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
end
disp("MSE="+SSR/N*2) % uso la metà dei dati in validazione

%% Crossvalidazione k-fold
K=4; % Divisione 75% train - 25% test
c = cvpartition(N, 'KFold', K);

thetaLS = [mean(industrial_load)];
theta_std = [std(industrial_load)/sqrt(N)];
SSR = sum((industrial_load-thetaLS).^2);
MSE = SSR/N;

for q=2:6
    mse=0;
    for k=1:K
        trainIds = training(c, k);
    
        XTrain = industrial_instances(trainIds);
        YTrain = industrial_load(trainIds);
        
        XTest = industrial_instances(~trainIds);
        YTest = industrial_load(~trainIds);
        
        n_k = length(YTest);

        full_phi_train = [XTrain.^0, XTrain.^1, XTrain.^2, XTrain.^3, XTrain.^4, XTrain.^5, XTrain.^6];
        full_phi_test = [XTest.^0, XTest.^1, XTest.^2, XTest.^3, XTest.^4, XTest.^5, XTest.^6];

        [nthetaLS, ntheta_std] = lscov(full_phi_train(:, 1:q), YTrain);
        loadLSTest = full_phi_test(:, 1:q)*nthetaLS;
        
        e = YTest - loadLSTest;
        ssr = sum(e.^2);
        mse_k = ssr/n_k;
        mse=mse+n_k/N*mse_k;
    end
    
    if mse>MSE
        q = q-1;
        break;
    end

    % update values
    SSR=ssr;
    MSE=mse;
    thetaLS=nthetaLS;
    theta_std=ntheta_std;
end

% best model
disp("Modello migliore (Crossvalidazione k-fold)")
disp(q+" parametri:")
for n=1:q
    disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
end
disp("MSE="+MSE)
