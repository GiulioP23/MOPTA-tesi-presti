function [mse_vec, n_params_vec] = fourier_tests_1d(data, data_desc, verbose, pics)
    testNames = ["F", "FPE", "AIC", "MDL", "CROSS"];
    testMSE = [0,0,0,0,0];
    testParam = [0,0,0,0,0];
    
    markd=false; % display in md format
    data_load=data.Load;
    
    data_instances=data.Instance;
    
    N = length(data_instances);
    T = max(data_instances);
    full_phi=[ones(N, 1) ...
         cos(1*2*pi/T*data_instances) sin(1*2*pi/T*data_instances)...
         cos(2*2*pi/T*data_instances) sin(2*2*pi/T*data_instances)... 
         cos(3*2*pi/T*data_instances) sin(3*2*pi/T*data_instances)...
         cos(4*2*pi/T*data_instances) sin(4*2*pi/T*data_instances)...
         cos(5*2*pi/T*data_instances) sin(5*2*pi/T*data_instances)...
         cos(6*2*pi/T*data_instances) sin(6*2*pi/T*data_instances)...
         cos(7*2*pi/T*data_instances) sin(7*2*pi/T*data_instances)...
         cos(8*2*pi/T*data_instances) sin(8*2*pi/T*data_instances)...
         cos(9*2*pi/T*data_instances) sin(9*2*pi/T*data_instances)...
     ];
    
    % Regression and Model Selection
    %% 3. Test F
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    TSS=sum((data_load-thetaLS).^2);
    SSR=TSS;
    for q=3:2:19 % discutere con p. incremento di 2, per includere sen e cos per ogni frequenza
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
        ssr = sum(e.^2);
        varEst=ssr/(N-q);
        
        f = (N-q)*(SSR-ssr)/ssr;
        f_alpha = finv(0.95, 2, N-q);
        
        if f<f_alpha
            q=q-2;
            break;
        end
    
        % update values
        SSR=ssr;
        thetaLS=nthetaLS;
        theta_std=ntheta_std;
    end
    if verbose
        % best model
        if markd
            md_test_result('Modello migliore (test F)', thetaLS, theta_std, SSR/N)
        else
            disp("Modello migliore (test F)")
            disp(q+" parametri:")
            for n=1:q
                disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
            end
            fprintf("MSE=%.2e R2=%.4f\n", SSR/N, 1-SSR/TSS)
        end
    end
    testMSE(1) = SSR/N;
    testParam(1) = q;
    if pics
        % display
        figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
        hold on;
        title(data_desc);
        subtitle('F Prediction');
        
        xlabel("Instance (hours)")
        ylabel("Load (MWh)")
        
        X=unique(data_instances);
        phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                              cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                              cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                              cos(4*2*pi/T*X) sin(4*2*pi/T*X)...
                              cos(5*2*pi/T*X) sin(5*2*pi/T*X)...
                              cos(6*2*pi/T*X) sin(6*2*pi/T*X)...
                              cos(7*2*pi/T*X) sin(7*2*pi/T*X)...
                              cos(8*2*pi/T*X) sin(8*2*pi/T*X)...
                              cos(9*2*pi/T*X) sin(9*2*pi/T*X)...
                              ];
        Y_LS = phi_graph(:, 1:q)*thetaLS;
        
        scatter(data_instances, data_load, ".", 'HandleVisibility','off')
        plot(X, Y_LS, 'DisplayName', "F-best fit ("+q+"-param)", 'LineWidth', 1.2);
        
        legend;
        pbaspect([2, 1, 1])
    end
    
    %% 4. FPE
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    TSS = sum((data_load-thetaLS).^2);
    SSR=TSS;

    FPE = (N+1)/(N-1)*SSR;
    for q=3:2:19
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std, mse] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
        ssr = sum(e.^2);
        varEst=ssr/(N-q); % stima varianza
        
        fpe = ssr*((N+q)/(N-q));
        if fpe>FPE
            q = q-2;
            break;
        end
    
        % update values
        SSR=ssr;
        thetaLS=nthetaLS;
        theta_std=ntheta_std;
        FPE=fpe;
    end
    if verbose
        % best model
        disp("Modello migliore (FPE)")
        disp(q+" parametri:")
        for n=1:q
            disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
        end
        fprintf("MSE=%.2e R2=%.4f\n", SSR/N, 1-SSR/TSS)
    end
    testMSE(2) = SSR/N;
    testParam(2) = q;

    if pics
        % display
        figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
        hold on;
        title(data_desc);
        subtitle('FPE Prediction');
        
        xlabel("Instance (hours)")
        ylabel("Load (MWh)")
        
        X=unique(data_instances);
        phi_graph=[X.^0 ...
            cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
            cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
            cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
            cos(4*2*pi/T*X) sin(4*2*pi/T*X)...
            cos(5*2*pi/T*X) sin(5*2*pi/T*X)...
            cos(6*2*pi/T*X) sin(6*2*pi/T*X)...
            cos(7*2*pi/T*X) sin(7*2*pi/T*X)...
            cos(8*2*pi/T*X) sin(8*2*pi/T*X)...
            cos(9*2*pi/T*X) sin(9*2*pi/T*X)...
        ];
        Y_LS = phi_graph(:, 1:q)*thetaLS;
        
        scatter(data_instances, data_load, ".", 'HandleVisibility','off')
        plot(X, Y_LS, 'DisplayName', "FPE-best fit ("+q+"-param)", 'LineWidth', 1.2);
        
        legend;
        pbaspect([2, 1, 1])
    end

    %% 5. AIC
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    TSS = sum((data_load-thetaLS).^2);
    SSR=TSS;

    AIC = 2/N+log(SSR);
    
    for q=3:2:19
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
        ssr = sum(e.^2);
        varEst=ssr/(N-q); % stima varianza
        
        aic = 2*q/N+log(ssr);
        
        if aic>AIC
            q = q-2;
            break;
        end
    
        % update values
        SSR=ssr;
        thetaLS=nthetaLS;
        theta_std=ntheta_std;
        AIC=aic;
    end
    
    if verbose
        % best model
        disp("Modello migliore (AIC)")
        disp(q+" parametri:")
        for n=1:q
            disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
        end
        fprintf("MSE=%.2e R2=%.4f\n", SSR/N, 1-SSR/TSS)
    end
    testMSE(3) = SSR/N;
    testParam(3) = q;
    
    if pics
        % display
        figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
        hold on;
        title(data_desc);
        subtitle('AIC Prediction (Akaike Information Criterion)');
        
        xlabel("Instance (hours)")
        ylabel("Load (MWh)")
        
        X=unique(data_instances);
        phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                              cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                              cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                              cos(4*2*pi/T*X) sin(4*2*pi/T*X)...
                              cos(5*2*pi/T*X) sin(5*2*pi/T*X)...
                              cos(6*2*pi/T*X) sin(6*2*pi/T*X)...
                              cos(7*2*pi/T*X) sin(7*2*pi/T*X)...
                              cos(8*2*pi/T*X) sin(8*2*pi/T*X)...
                              cos(9*2*pi/T*X) sin(9*2*pi/T*X)...
                              ];
        Y_LS = phi_graph(:, 1:q)*thetaLS;
        
        scatter(data_instances, data_load, ".", 'HandleVisibility','off')
        plot(X, Y_LS, 'DisplayName', "AIC-best fit ("+q+"-param)", 'LineWidth', 1.2);
        
        legend;
        pbaspect([2, 1, 1])
    end

    %% 6. MDL
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    TSS = sum((data_load-thetaLS).^2);
    SSR=TSS;

    MDL = log(N)/N+log(SSR);
    
    for q=3:2:19
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
        ssr = sum(e.^2);
        varEst=ssr/(N-q); % stima varianza
        
        mdl = log(N)/N*q+log(ssr);
        
        if mdl>MDL
            q = q-2;
            break;
        end
    
        % update values
        SSR=ssr;
        thetaLS=nthetaLS;
        theta_std=ntheta_std;
        MDL=mdl;
    end
    
    if verbose
        % best model
        disp("Modello migliore (MDL)")
        disp(q+" parametri:")
        for n=1:q
            disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
        end
        fprintf("MSE=%.2e R2=%.4f\n", SSR/N, 1-SSR/TSS)
    end
    testMSE(4) = SSR/N;
    testParam(4) = q;
    
    if pics
        % display
        figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
        hold on;
        title(data_desc);
        subtitle('MDL Prediction');
        
        xlabel("Instance (hours)")
        ylabel("Load (MWh)")
        
        X=unique(data_instances);
        phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                              cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                              cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                              cos(4*2*pi/T*X) sin(4*2*pi/T*X)...
                              cos(5*2*pi/T*X) sin(5*2*pi/T*X)...
                              cos(6*2*pi/T*X) sin(6*2*pi/T*X)...
                              cos(7*2*pi/T*X) sin(7*2*pi/T*X)...
                              cos(8*2*pi/T*X) sin(8*2*pi/T*X)...
                              cos(9*2*pi/T*X) sin(9*2*pi/T*X)...
                              ];
        Y_LS = phi_graph(:, 1:q)*thetaLS;
        
        scatter(data_instances, data_load, ".", 'HandleVisibility','off')
        plot(X, Y_LS, 'DisplayName', "MDL-best fit ("+q+"-param)", 'LineWidth', 1.2);
        
        legend;
        pbaspect([2, 1, 1])
    end

    %% Crossvalidazione k-fold
    K=4; % Divisione 75% train - 25% test
    c = cvpartition(N, 'KFold', K);
    
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    TSS = sum((data_load-thetaLS).^2);
    SSR=TSS;
    MSE = SSR/N*10; %?
    
    for q=3:2:19
        mse=0;
        for k=1:K
            trainIds = training(c, k);
        
            XTrain = data_instances(trainIds);
            YTrain = data_load(trainIds);
            
            XTest = data_instances(~trainIds);
            YTest = data_load(~trainIds);
            
            n_k = length(YTest);
    
            full_phi_train = [XTrain.^0 ...
                 cos(1*2*pi/T*XTrain) sin(1*2*pi/T*XTrain)...
                 cos(2*2*pi/T*XTrain) sin(2*2*pi/T*XTrain)... 
                 cos(3*2*pi/T*XTrain) sin(3*2*pi/T*XTrain)...
                 cos(4*2*pi/T*XTrain) sin(4*2*pi/T*XTrain)...
                 cos(5*2*pi/T*XTrain) sin(5*2*pi/T*XTrain)...
                 cos(6*2*pi/T*XTrain) sin(6*2*pi/T*XTrain)...
                 cos(7*2*pi/T*XTrain) sin(7*2*pi/T*XTrain)...
                 cos(8*2*pi/T*XTrain) sin(8*2*pi/T*XTrain)...
                 cos(9*2*pi/T*XTrain) sin(9*2*pi/T*XTrain)...
            ];
            full_phi_test = [XTest.^0 ...
                 cos(1*2*pi/T*XTest) sin(1*2*pi/T*XTest)...
                 cos(2*2*pi/T*XTest) sin(2*2*pi/T*XTest)... 
                 cos(3*2*pi/T*XTest) sin(3*2*pi/T*XTest)...
                 cos(4*2*pi/T*XTest) sin(4*2*pi/T*XTest)...
                 cos(5*2*pi/T*XTest) sin(5*2*pi/T*XTest)...
                 cos(6*2*pi/T*XTest) sin(6*2*pi/T*XTest)...
                 cos(7*2*pi/T*XTest) sin(7*2*pi/T*XTest)...
                 cos(8*2*pi/T*XTest) sin(8*2*pi/T*XTest)...
                 cos(9*2*pi/T*XTest) sin(9*2*pi/T*XTest)...
            ];
            [nthetaLS, ntheta_std] = lscov(full_phi_train(:, 1:q), YTrain);
            loadLSTest = full_phi_test(:, 1:q)*nthetaLS;
            
            e = YTest - loadLSTest;
            ssr = sum(e.^2);
            mse_k = ssr/n_k;
            mse=mse+n_k/N*mse_k;
        end
    
        if mse>MSE
            q = q-2;
            break;
        end
    
        % update values
        SSR=ssr;
        MSE=mse;
        thetaLS=nthetaLS;
        theta_std=ntheta_std;
    end
    
    if verbose
        % best model
        disp("Modello migliore (Crossvalidazione K="+K+"-fold)")
        disp(q+" parametri:")
        for n=1:q
            disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
        end
        fprintf("MSE=%.2e\n", MSE) % tolgo R2 perchè andrebbe ricalcolato l'SSR con tutti i valori
    end
    testMSE(5) = MSE;
    testParam(5) = q;
    
    %% Fourier Armoniche
    phi = full_phi(:, 1:q);
    [nthetaLS, ntheta_std] = lscov(phi, data_load);
    loadLS = phi*nthetaLS;
    if pics
        % display
        figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
        hold on;
        title(data_desc);
        subtitle('Fourier components');
        
        xlabel("Instance (hours)")
        ylabel("Load (MWh)")
        
        X=unique(data_instances)+1;
        phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                              cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                              cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                              cos(4*2*pi/T*X) sin(4*2*pi/T*X)...
                              cos(5*2*pi/T*X) sin(5*2*pi/T*X)...
                              cos(6*2*pi/T*X) sin(6*2*pi/T*X)...
                              cos(7*2*pi/T*X) sin(7*2*pi/T*X)...
                              cos(8*2*pi/T*X) sin(8*2*pi/T*X)...
                              cos(9*2*pi/T*X) sin(9*2*pi/T*X)...
                              ];
        scatter(data_instances+1, data_load, ".", 'HandleVisibility','off')
        
        Y_LS = phi_graph(:, 1:q)*nthetaLS;
        
        Y0=phi_graph(:, 1:1)*nthetaLS(1);
        
        for n=2:length(nthetaLS)
            Y=phi_graph(:, n:n)*nthetaLS(n) + Y0;
            plot(X, Y, 'DisplayName', "componente "+(n-1), 'LineWidth', 1.2);
        end
        
        legend;
        pbaspect([2, 1, 1])
    end
    mse_vec = dictionary(testNames, testMSE);
    n_params_vec = dictionary(testNames, testParam);

    %% Plotregression 
    % grafico che rappresenta l'andamento delle previsioni rispetto ai
    % valori misurati
    if pics
        figure()
        phi = full_phi(:, 1:q);
        [nthetaLS] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        plotregression(data_load, loadLS, data_desc)
        subtitle(sprintf("%d params model (cv selected)", q))
    end
    
end
