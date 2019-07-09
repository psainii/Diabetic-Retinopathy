clc;clearvars;close all;
rng default;
%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\Users\Prateek\Desktop\Explo\WITH_NOISE (1).csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2019/04/14 20:22:56

%% Initialize variables.
filename = '..\..\Datasets\WITH_NOISE (1).csv';
delimiter = ',';

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
WITHNOISE1 = [dataArray{1:end-1}];
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;
%Populating the data
WITHNOISE1=vertcat(WITHNOISE1,WITHNOISE1,WITHNOISE1,WITHNOISE1,WITHNOISE1);
WITHNOISE1=vertcat(WITHNOISE1,WITHNOISE1);
[M,N]=size(WITHNOISE1);
avgaccu=0;
avgtime=0;
%Specifying the seed value
s = RandStream('mt19937ar','Seed',0);
for i=1:10
    rand_pos = randperm(M); %array of random positions
    % new array with original data randomly distributed
    data=zeros(M,N);
    for k = 1:M
        data(k,:) = WITHNOISE1(rand_pos(k),:);
    end

    features=data(:,1:end-1);
    labels=data(:,end);
    % Normalize labels
    features=zscore(features);
    labels(labels==0)=-1;
    % Normalize labels


    % Separate training and test data (80:20 split)
    total_samples=size(features,1);
    train_samples=round(0.8*total_samples);

    % Define training and test samples
    xTrain=features(1:train_samples,:);
    yTrain=labels(1:train_samples,:);
    xTest=features(train_samples+1:end,:);
    yTest=labels(train_samples+1:end,:);
    yTest(yTest==-1)=0;
    %Defining Hyperparameters
    C=0.0625;
    
    [w,b,time]=SVM(xTrain, yTrain, C );
    avgtime=avgtime+time;
    [n,m]=size(xTest);
    yPred=(xTest*w'+b*ones(n,1))>0;
    accuracy=(sum(yPred==yTest)/length(yTest))*100;   
    if(accuracy<50)
        accuracy=100-accuracy;
    end
    avgaccu=avgaccu+accuracy;
end
%Display time and accuracy
disp('Accuracy is');
disp(avgaccu/10);
disp('Time taken is');
disp(avgtime/10);