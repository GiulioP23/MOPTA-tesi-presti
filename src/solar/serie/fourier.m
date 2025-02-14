% Solar Energy: linear regression (Fourier)
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
    [mse, params] = fourier_tests_1d(qData, sprintf("Solar Energy (%s)", quarter), false, false);
    fprintf("Quarter %s\n\tnparam (F): %d\n\tnparam (FPE): %d\n\tnparam (AIC): %d\n\tnparam (MDL): %d\n\tnparam (Cross): %d\n\n", quarter, params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"));
end
    

%% Test a specific period
% In questa sezione è possibile visualizzare i risultati dei test per una
% specifica serie selezionata di seguito, e i relativi grafici.

quarter = "Q1";

qData = df(df.Quarter==quarter, :);
qData.Load=qData.Generation;
[mse, params] = fourier_tests_1d(qData, sprintf("Solar Energy (%s)", quarter), true, true);   

fprintf("Quarter %s, Ordine:%d\n\tF: %d\n\tFPE: %d\n\tAIC: %d\n\tMDL: %d\n\tCrossvalidazione: %d\n", quarter, params("F"), params("FPE"), params("AIC"), params("MDL"), params("CROSS"))

%% Not Null - Fourier
% In quest sezione effettuo l'ottimizzazione soltanto sui dati positivi
% di generazione

quarter = "Q1";

inst_1 = min(df.Instance(all([df.Quarter==quarter, df.Generation~=0], 2)));
inst_2 = max(df.Instance(all([df.Quarter==quarter, df.Generation~=0], 2)));

data_instances=qData.Instance(all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
null_instances = qData.Instance(~all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
null_load = qData.Generation(~all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
X=data_instances-inst_1+0.25;

data_load = qData.Generation(all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
N = length(X);
T = 2*max(X); % impongo che il primo e ultimo valore siano nulli

full_phi=[... % rimosso il termine costante
         sin(1*2*pi/T*X)...
         sin(2*2*pi/T*X)... 
         sin(3*2*pi/T*X)...
         sin(4*2*pi/T*X)...
         sin(5*2*pi/T*X)...
         sin(6*2*pi/T*X)...
         ];

thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    SSR = sum((data_load-thetaLS).^2);
    
    FPE = (N+1)/(N-1)*SSR;
    for q=1:1:13 % parto dal primo ordine a salire
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std, mse] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
        ssr = sum(e.^2);
        varEst=ssr/(N-q);
        
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

    data_instances = X+inst_1-0.25;
    % best model
    disp("Modello migliore (FPE)")
    disp(q+" parametri:")
    for n=1:q
        disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
    end
    disp("MSE="+SSR/N)
    
    testMSE(2) = SSR/N;
    testParam(2) = q;


    % display
    figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    title("3-Knot Spline (Q1)");
    subtitle('FPE Prediction');
    xlim([5, 23]);
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    %X=unique(data_instances);

    Y_LS = full_phi(:, 1:q)*thetaLS;
    
    scatter(data_instances, data_load, ".", 'HandleVisibility','off')
    scatter(null_instances, null_load, ".", 'HandleVisibility','off')
    plot(data_instances, Y_LS, 'DisplayName', "FPE-best fit ("+q+"-param)", 'LineWidth', 1.2);
    
    legend;
    pbaspect([2, 1, 1])

%% Not Null - Polinomial
% In quest sezione effettuo l'ottimizzazione soltanto sui dati positivi
% di generazione

quarter = "Q1";

inst_1 = min(df.Instance(all([df.Quarter==quarter, df.Generation~=0], 2)));
inst_2 = max(df.Instance(all([df.Quarter==quarter, df.Generation~=0], 2)));

data_instances=qData.Instance(all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
null_instances = qData.Instance(~all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
null_load = qData.Generation(~all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
X=data_instances-inst_1+0.25;

data_load = qData.Generation(all([qData.Instance>=inst_1-0.25, qData.Instance<=inst_2+0.25], 2));
N = length(X);
T = 2*max(X); % impongo che il primo e ultimo valore siano nulli

full_phi=[X.^0 X X.^2 X.^3 X.^4 X.^5 X.^6 X.^7];

thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    SSR = sum((data_load-thetaLS).^2);
    
    FPE = (N+1)/(N-1)*SSR;
    for q=2:1:7
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std, mse] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
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

    data_instances = X+inst_1-0.25;
    % best model
    disp("Modello migliore (FPE)")
    disp(q+" parametri:")
    for n=1:q
        disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
    end
    disp("MSE="+SSR/N)
    
    testMSE(2) = SSR/N;
    testParam(2) = q;


    % display
    figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    title("Positive Generation Fit (Q1)");
    subtitle('FPE Prediction');
    xlim([5, 23]);
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    %X=unique(data_instances);

    Y_LS = full_phi(:, 1:q)*thetaLS;
    
    scatter(data_instances, data_load, ".", 'HandleVisibility','off')
    %scatter(null_instances, null_load, ".", 'HandleVisibility','off')
    plot(data_instances, Y_LS, 'DisplayName', "FPE-best fit ("+q+"-param)", 'LineWidth', 1.2);
    
    legend;
    pbaspect([2, 1, 1])
    
