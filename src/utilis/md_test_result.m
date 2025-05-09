function [] = md_test_result(header, theta, std, mse)
    fprintf('%s \n', header)
    fprintf('| Ordine | MSE |\n')
    fprintf('|:----------: |:----------: |\n')
    fprintf('| %d | %8.2e |\n\n', length(theta), mse)

    fprintf('| $\\theta$ | $\\sigma$ | \n')
    fprintf('|:----------: |:----------: |\n')
    for n=1:length(theta)
        fprintf('| %8.2e | %8.2e | \n', theta(n), std(n))
    end
end

