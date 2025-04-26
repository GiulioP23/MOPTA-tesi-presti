function [mse_vec, n_params_vec, select_vec] = tests_2d_w(data, phifun, weigths, data_desc, zlabel, verbose, pics)
%This function uses weigths to perform regularization and feature selection    
testNames = ["lasso", "forward", "backward"];
    testMSE = [0,0,0];
    testNParam = [0,0,0];

    data_load=data.Load; %target

    data_period=data.Period;
    data_instances=data.Instance;
    
    N = length(data_instances);

    TSS=sum((data_load-mean(data_load)).^2);

    full_phi=phifun(data_instances, data_period);

    stepPhi=full_phi(:, 2:end); % remove the constant term, that will be added back by stepwiselm
    
    P=size(full_phi, 2); % feature number

    testSelect = [zeros(P, 1, 'logical'),zeros(P, 1, 'logical'),zeros(P, 1, 'logical')]; % bolean vector to select the identified features


    % Regression and Model Selection
    %% Lasso shrinkage
    % Feature selection
    [B,FitInfo] = lasso(full_phi, data_load, 'CV', 10, 'Weights', weigths); %"PredictorNames", ["c", "h", "p", "h2",  "p2", "hp", "h3", "p3", "h2p", "hp2", "h4", "h5", "h6", "h7", "h8"]

    regSelect = B(:, FitInfo.Index1SE)~=0;
    regSelect(1)=true; % constant term present
    q = sum(regSelect); % numero parametri
    phi_lasso = full_phi(:, regSelect);

    % fit
    [thetaLS, theta_std] = lscov(phi_lasso, data_load, weigths);

    predictions = phi_lasso*thetaLS;
    e = predictions - data_load; 
    SSR = sum(e.^2);
    MSE = SSR/(N-q);
    R2 = 1-SSR/TSS;

    testMSE(1) = MSE;
    testNParam(1) = q;
    testSelect(:, 1)=regSelect;
    if pics   
        positiveplot3D(data, phifun, thetaLS, data_desc, "(Lasso)", zlabel, regSelect)
        
        figure()
        plotregression(data.Load, predictions, data_desc)
        subtitle(sprintf("%d params model (lasso)", q))
    end
    if verbose
        disp("Modello migliore (lasso)")
        disp(q+" parametri:")
        n=1; % index for theta, parameter
        for p=1:P
            if regSelect(p)
                fprintf("  b_%d = %.2e std = %.2e\n", p-1, thetaLS(n), theta_std(n))
                n=n+1;
            end
        end
        fprintf("MSE=%.2e R2=%.4f\n", MSE, R2)
    end

   %% StepWise Forward regression

    mdl = stepwiselm(stepPhi, data_load, "constant", 'Upper', 'linear', "Criterion", "bic", "PRemove", Inf, "Verbose", 0, "Weights", weigths);

    regSelect = [true; mdl.VariableInfo.InModel(1:end-1)]; % constant, true to add the full_phi first column. Last one is target variable

    predictions = mdl.predict(stepPhi);
    thetaLS=mdl.Coefficients.Estimate;
    theta_std=mdl.Coefficients.SE;

    e = predictions - data_load;
    q = mdl.NumCoefficients;
    SSR = sum(e.^2);
    MSE = SSR/(N-q);
    R2 = 1-SSR/TSS;

    testMSE(2) = MSE;
    testNParam(2) = q;
    testSelect(:, 2)=regSelect;

    if pics   
        positiveplot3D(data, phifun, thetaLS, data_desc, "Forward Stepwise", zlabel, regSelect);

        figure();
        plotregression(data_load, predictions, data_desc);
        subtitle(sprintf("%d params model (forward stepwise)", sum(regSelect)));
    end
    if verbose
        disp("Modello migliore (forward stepwise)")
        disp(q+" parametri:")
        n=1; % index for theta, parameter
        for p=1:P
            if regSelect(p)
                fprintf("  b_%d = %.2e std = %.2e\n", p-1, thetaLS(n), theta_std(n))
                n=n+1;
            end
        end
        fprintf("MSE=%.2e R2=%.4f\n", MSE, R2)
    end    

    %% StepWise Backward regression

    mdl = stepwiselm(stepPhi, data_load,'linear', "Criterion", "adjrsquared", "PEnter", Inf, "PRemove", 0, "Verbose", 0,  "Weights", weigths);

    regSelect = [true; mdl.VariableInfo.InModel(1:end-1)]; % constant, true to add the full_phi first column

    predictions = mdl.predict(stepPhi) ;
    thetaLS=mdl.Coefficients.Estimate;
    theta_std=mdl.Coefficients.SE;

    e = predictions - data_load;
    q = mdl.NumCoefficients;
    SSR = sum(e.^2);
    MSE = SSR/(N-q);
    R2 = 1-SSR/TSS;
    
    testMSE(3) = MSE;
    testNParam(3) = q;
    testSelect(:, 3)=regSelect;

    if pics   
        positiveplot3D(data, phifun, thetaLS, data_desc, "Backward Stepwise", zlabel, regSelect);

        figure();
        plotregression(data_load, predictions, data_desc);
        subtitle(sprintf("%d params model (backward stepwise)", sum(regSelect)));
    end
    if verbose
        disp("Modello migliore (backward stepwise)")
        disp(q+" parametri:")
        n=1; % index for theta, parameter
        for p=1:P
            if regSelect(p)
                fprintf("  b_%d = %.2e std = %.2e\n", p-1, thetaLS(n), theta_std(n))
                n=n+1;
            end
        end
        fprintf("MSE=%.2e R2=%.4f\n", MSE, R2)
    end   

    %% end func
    mse_vec = dictionary(testNames, testMSE);
    n_params_vec = dictionary(testNames, testNParam);
    select_vec = dictionary(testNames, num2cell(testSelect, 1));
end