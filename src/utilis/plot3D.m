function [] = plot3D(data, phi, theta, titolo, sottotitolo, z_l, selectors)
% Disegna il grafico in 3D con i dati indicati
    figure('Units','normalized', 'Position', [0.1, 0.1, 0.6, 0.5]);
    plot3(data.Instance, data.Period, data.Load, 'b.')  % for solar must create a new property "Load" alias of "Generation"
    
    hold on;
    grid on;
    title(titolo);
    subtitle(sottotitolo)
    
    xlabel('Instance (hours)') % in this project we only use this configuration in 3D
    ylabel('Period (day)')
    zlabel(z_l)
    
    periodGrid = linspace(0, 300, 100)'; %365
    instanceGrid = linspace(min(data.Instance), max(data.Instance), 100)';
    
    [periodTable, instanceTable] = meshgrid(periodGrid, instanceGrid);
    
    periodVec = periodTable(:);
    instanceVec = instanceTable(:);  
   
    
    phiGrid = phi(instanceVec, periodVec);
    if nargin==7
        phiGrid = phiGrid(:, selectors);
    end
    loadGrid = phiGrid*theta;
    loadTable = reshape(loadGrid, size(periodTable));
    
    mesh(instanceTable, periodTable, loadTable, FaceColor="interp", FaceAlpha=0.7)
    
    colormap('cool')
    
    %legend;
    pbaspect([2, 1, 1])
end