function [outputArg] = caricaSolar()
    opts = detectImportOptions('data.xlsx', 'FileType','spreadsheet', 'Sheet','Solar');  % Detect import options based on the file
    opts.VariableTypes = {'string', 'double', 'double'};  % Specify the types for each column
    
    df = readtable('data.xlsx', opts);  % Read the table with specified column types
    df.Instance = df.Instance/4; % convert instance to hours
    outputArg = df;
end

