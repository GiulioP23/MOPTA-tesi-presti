function [outputArg1,outputArg2] = standard_tests_1d(data)
    markd=true; % display in md format
    data_load=data.Load;
    
    data_instances=data.Instance;
    
    N = length(data_instances);
    T = max(data_instances);
    full_phi=[ones(N, 1) ...
         cos(1*2*pi/T*data_instances) sin(1*2*pi/T*data_instances)...
         cos(2*2*pi/T*data_instances) sin(2*2*pi/T*data_instances)... 
         cos(3*2*pi/T*data_instances) sin(3*2*pi/T*data_instances)...
         cos(4*2*pi/T*data_instances) sin(4*2*pi/T*data_instances)...
     ];
    
    % Regression and Model Selection
    %% 3. Test F
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    SSR=sum((data_load-thetaLS).^2);
    
    for q=3:2:9 % discutere con p. incremento di 2, per includere sen e cos per ogni frequenza
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
        ssr = sum(e.^2);
        varEst=ssr/(N-q);
        
        f = (N-q)*(SSR-ssr)/ssr;
        f_alpha = finv(0.95, 1, N-q);
        
        if f<f_alpha
            q=q-2;
            break;
        end
    
        % update values
        SSR=ssr;
        thetaLS=nthetaLS;
        theta_std=ntheta_std;
    end
    
    % best model
    if markd
        md_test_result('Modello migliore (test F)', thetaLS, theta_std, SSR/N)
    else
        disp("Modello migliore (test F)")
        disp(q+" parametri:")
        for n=1:q
            disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
        end
        disp("MSE="+SSR/N)
    end    
    
    % display
    figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    title('Residential Load');
    subtitle('F Prediction');
    
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    X=unique(data_instances);
    phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                          cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                          cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                          cos(4*2*pi/T*X) sin(4*2*pi/T*X)
                          ];
    Y_LS = phi_graph(:, 1:q)*thetaLS;
    
    scatter(data_instances, data_load, ".", 'HandleVisibility','off')
    plot(X, Y_LS, 'DisplayName', "F-best fit ("+q+"-param)", 'LineWidth', 1.2);
    
    legend;
    pbaspect([2, 1, 1])
    
    %% 4. FPE
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    SSR = sum((data_load-thetaLS).^2);
    
    FPE = (N+1)/(N-1)*SSR;
    for q=2:10
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
    title('Residential Load');
    subtitle('FPE Prediction');
    
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    X=unique(data_instances);
    phi_graph=[X.^0 ...
        cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
        cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
        cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
        cos(4*2*pi/T*X) sin(4*2*pi/T*X)...
    ];
    Y_LS = phi_graph(:, 1:q)*thetaLS;
    
    scatter(data_instances, data_load, ".", 'HandleVisibility','off')
    plot(X, Y_LS, 'DisplayName', "FPE-best fit ("+q+"-param)", 'LineWidth', 1.2);
    
    legend;
    pbaspect([2, 1, 1])
    
    %% 5. AIC
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    SSR = sum((data_load-thetaLS).^2);
    
    AIC = 2/N+log(SSR);
    
    for q=2:10
        phi = full_phi(:, 1:q);
        [nthetaLS, ntheta_std] = lscov(phi, data_load);
        loadLS = phi*nthetaLS;
        e = data_load - loadLS;
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
    title('Residential Load');
    subtitle('AIC Prediction (Akaike Information Criterion)');
    
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    X=unique(data_instances);
    phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                          cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                          cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                          cos(4*2*pi/T*X) sin(4*2*pi/T*X)
                          ];
    Y_LS = phi_graph(:, 1:q)*thetaLS;
    
    scatter(data_instances, data_load, ".", 'HandleVisibility','off')
    plot(X, Y_LS, 'DisplayName', "AIC-best fit ("+q+"-param)", 'LineWidth', 1.2);
    
    legend;
    pbaspect([2, 1, 1])
    
    %% 6. MDL
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    
    SSR = sum((data_load-thetaLS).^2);
    
    MDL = log(N)/N+log(SSR);
    
    for q=3:2:9
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
    title('Residential Load');
    subtitle('MDL Prediction');
    
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    X=unique(data_instances);
    phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                          cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                          cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                          cos(4*2*pi/T*X) sin(4*2*pi/T*X)
                          ];
    Y_LS = phi_graph(:, 1:q)*thetaLS;
    
    scatter(data_instances, data_load, ".", 'HandleVisibility','off')
    plot(X, Y_LS, 'DisplayName', "MDL-best fit ("+q+"-param)", 'LineWidth', 1.2);
    
    legend;
    pbaspect([2, 1, 1])
    
    %% Crossvalidazione k-fold
    K=4; % Divisione 75% train - 25% test
    c = cvpartition(N, 'KFold', K);
    
    thetaLS = [mean(data_load)];
    theta_std = [std(data_load)/sqrt(N)];
    SSR = sum((data_load-thetaLS).^2);
    MSE = SSR/N*10;
    
    for q=2:9
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
            ];
            full_phi_test = [XTest.^0 ...
                 cos(1*2*pi/T*XTest) sin(1*2*pi/T*XTest)...
                 cos(2*2*pi/T*XTest) sin(2*2*pi/T*XTest)... 
                 cos(3*2*pi/T*XTest) sin(3*2*pi/T*XTest)...
                 cos(4*2*pi/T*XTest) sin(4*2*pi/T*XTest)...
            ];
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
    disp("Modello migliore (Crossvalidazione K="+K+"-fold)")
    disp(q+" parametri:")
    for n=1:q
        disp("  b_"+(n-1) +" = " + thetaLS(n)+" std="+theta_std(n))
    end
    disp("MSE="+MSE)
    
    %% Fourier Armoniche
    phi = full_phi(:, 1:5);
    [nthetaLS, ntheta_std] = lscov(phi, data_load);
    loadLS = phi*nthetaLS;
    
    % display
    figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    hold on;
    title('Residential Load');
    subtitle('Fourier components');
    
    xlabel("Instance (hours)")
    ylabel("Load (MWh)")
    
    X=unique(data_instances)+1;
    phi_graph=[X.^0 cos(1*2*pi/T*X) sin(1*2*pi/T*X)...
                          cos(2*2*pi/T*X) sin(2*2*pi/T*X)... 
                          cos(3*2*pi/T*X) sin(3*2*pi/T*X)...
                          cos(4*2*pi/T*X) sin(4*2*pi/T*X)
                          ];
    scatter(data_instances+1, data_load, ".", 'HandleVisibility','off')
    
    Y_LS = phi_graph(:, 1:5)*nthetaLS;
    
    Y0=phi_graph(:, 1:1)*nthetaLS(1);
    
    for n=2:length(nthetaLS)
        Y=3.2*phi_graph(:, n:n)*nthetaLS(n) + Y0;
        plot(X, Y, 'DisplayName', "componente "+(n-1), 'LineWidth', 1.2);
    end
    
    legend;
    pbaspect([2, 1, 1])
end

