%import without noise file
filename = '..\..\Datasets\WITHOUT_NOISE (1).csv';
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
WITHOUTNOISE1 = [dataArray{1:end-1}];
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;
[M,N]=size(WITHOUTNOISE1);
avgtime=0;
avgaccu=0;
boxpl=zeros(10,2);
for q=1:10
    rand_pos = randperm(M); %array of random positions
    % new array with original data randomly distributed
    data=zeros(M,N);
    for k = 1:M
        data(k,:) = WITHOUTNOISE1(rand_pos(k),:);
    end
    % Get Data and Labels
    features=data(:,1:end-1);
    labels=data(:,end);

    % Normalize labels
    labels(labels==0)=-1;
    % Normalize features
    features=zscore(features);


    % Separate training and test data (80:20 split)
    total_samples=size(features,1);
    train_samples=round(0.8*total_samples);

    % Define training and test samples
    xTrain=features(1:train_samples,:);
    yTrain=labels(1:train_samples,:);
    xTest=features(train_samples+1:end,:);
    yTest=labels(train_samples+1:end,:);

    % Define hyperparameter values
    C1=0.0625; C2=8;

    % Run Twin SVM (Linear)
    [ wA, bA, wB, bB,time] = LinearTWSVM( xTrain, yTrain, C1, C2 );
    avgtime=avgtime+time;
    yPred=zeros(size(xTest,1),1);
    for i=1:size(xTest,1)
        sample=xTest(i,:);
        distA=(sample*wA + bA)/norm(wA);
        distB=(sample*wB + bB)/norm(wB);
        if (distA>distB)
            yPred(i)=-1;
        else
            yPred(i)=1;
        end
    end

    accuracy=(sum(yPred==yTest)/length(yTest))*100;

    % Sanity check - if labels are predicted wrongly then flip
    if (accuracy<50)
        yPred=-1*yPred;
        accuracy=(sum(yPred==yTest)/length(yTest))*100;
    end
    boxpl(q,1)=accuracy;
end
%import with noise file
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
[M,N]=size(WITHNOISE1);
avgaccu=0;
avgtime=0;
for q=1:10
    rand_pos = randperm(M); %array of random positions
    % new array with original data randomly distributed
    data=zeros(M,N);
    for k = 1:M
        data(k,:) = WITHNOISE1(rand_pos(k),:);
    end
    % Get Data and Labels
    features=data(:,1:end-1);
    labels=data(:,end);

    % Normalize labels
    labels(labels==0)=-1;
    % Normalize features
    features=zscore(features);


    % Separate training and test data (80:20 split)
    total_samples=size(features,1);
    train_samples=round(0.8*total_samples);

    % Define training and test samples
    xTrain=features(1:train_samples,:);
    yTrain=labels(1:train_samples,:);
    xTest=features(train_samples+1:end,:);
    yTest=labels(train_samples+1:end,:);
    % Define hyperparameter values
    C1=0.0625; C2=.125;

    % Run Twin SVM (Linear)
    
    [ wA, bA, wB, bB,time ] = LinearTWSVM( xTrain, yTrain, C1, C2 );
    
    avgtime=avgtime+time;
    yPred=zeros(size(xTest,1),1);
    for i=1:size(xTest,1)
        sample=xTest(i,:);
        distA=(sample*wA + bA)/norm(wA);
        distB=(sample*wB + bB)/norm(wB);
        if (distA>distB)
            yPred(i)=-1;
        else
            yPred(i)=1;
        end
    end

    accuracy=(sum(yPred==yTest)/length(yTest))*100;

    % Sanity check - if labels are predicted wrongly then flip
    if (accuracy<50)
        yPred=-1*yPred;
        accuracy=(sum(yPred==yTest)/length(yTest))*100;
    end
    boxpl(q,2)=accuracy;
end
figure
boxplot(boxpl,'Labels',{'C1=0.0625,C2=8(without_noise)','C1=0.0625,C2=0.0625(with_noise)'});
xlabel('C(hyperparameter)');
ylabel('Accuracy');
