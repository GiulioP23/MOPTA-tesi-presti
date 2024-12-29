function [outputArg] = caricaLoad()
%LOAD Summary of this function goes here
%   Detailed explanation goes here
opts = detectImportOptions('data.xlsx', 'FileType','spreadsheet', 'Sheet','Electricity Load');  % Detect import options based on the file
opts.VariableTypes = {'string', 'string', 'double', 'double'};  % Specify the types for each column

df = readtable('data.xlsx', opts);  % Read the table with specified column types
df.Industrial=df.Location_Electricity.endsWith('i');
df.Instance = df.Instance/4; % convert instance to hours
outputArg = df;
end

