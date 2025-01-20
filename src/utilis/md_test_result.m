function [] = md_test_result(header, theta, std, mse)
    fprintf('%s \n', header)
    fprintf('| Ordine | MSE |\n')
    fprintf('|:----------: |:----------: |\n')
    fprintf('| %d | %8.2f |\n\n', length(theta), mse)

    fprintf('| $\\theta$ | $\\sigma$ | \n')
    fprintf('|:----------: |:----------: |\n')
    for n=1:length(theta)
        fprintf('| %8.2f | %8.2f | \n', theta(n), std(n))
    end
end

