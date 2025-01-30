function [outputArg] = caricaSolar()
    opts = detectImportOptions('data.xlsx', 'FileType','spreadsheet', 'Sheet','Solar');  % Detect import options based on the file
    opts.VariableTypes = {'string', 'double', 'double'};  % Specify the types for each column
    
    df = readtable('data.xlsx', opts);  % Read the table with specified column types
    df.Instance = df.Instance/4; % convert instance to hours
    df.Period = 1*(df.Quarter=='Q1')+92*(df.Quarter=='Q2')+183*(df.Quarter=='Q3')+274*(df.Quarter=='Q4'); % trasforma in giorni la variabile quarter
    outputArg = df;
end

