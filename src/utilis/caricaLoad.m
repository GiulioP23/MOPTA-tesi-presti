function [outputArg] = caricaLoad()
%caricaLoad Summary legge i dati da file per il figlio "Electricity Load"
    opts = detectImportOptions('data.xlsx', 'FileType','spreadsheet', 'Sheet','Electricity Load');  % Detect import options based on the file
    opts.VariableTypes = {'string', 'string', 'double', 'double'};  % Specify the types for each column
    
    df = readtable('data.xlsx', opts);  % Read the table with specified column types
    df.Industrial=df.Location_Electricity.endsWith('i');
    df.Instance = df.Instance/4; % convert instance to hours
    df.Period = 1*(df.Quarter=='Q1')+92*(df.Quarter=='Q2')+183*(df.Quarter=='Q3')+274*(df.Quarter=='Q4'); % convert quarter to period
    outputArg = df;
end

