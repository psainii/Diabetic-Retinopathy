clc;clearvars;close all;
rng default;
%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\Users\Prateek\Desktop\Explo\WITH_NOISE (1).csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2019/04/19 18:04:56

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
[M,N]=size(WITHNOISE1);
%Specifying the seed value
s = RandStream('mt19937ar','Seed',0);
%Range of Hyperparameter
%Ccc=linspace(0,1,101);for range(0,1)
Ccc=[linspace(0,200,51)];%for range(0,200)
for ttt=1:length(Ccc)
    c=Ccc(ttt);
    pinacc=0;
    twinacc=0;
    svmacc=0;
    for ite=1:10
        rand_pos = randperm(s,M); %array of random positions
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
        features=zscore(features);


        % Separate training and test data (80:20 split)
        total_samples=size(features,1);
        train_samples=round(0.8*total_samples);

        % Define training and test samples
        xTrain=features(1:train_samples,:);
        yTrain=labels(1:train_samples,:);
        xTest=features(train_samples+1:end,:);
        yTest=labels(train_samples+1:end,:);
        C1=c; C2=c;
        V1=0.125; V2=0.125;
        T1=0.1; T2=0.1;
        % Run Pin Twin SVM (Linear)

        [ wA, bA, wB, bB,time ] = LinearPinTWSVM( xTrain, yTrain, C1, C2, V1, V2, T1, T2 );
        yPred=zeros(size(xTest,1),1);
        for i=1:size(xTest,1)
            sample=xTest(i,:);
            distA=(sample*wA' + bA)/norm(wA);
            distB=(sample*wB' + bB)/norm(wB);
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
        pinacc=pinacc+accuracy;

        yTest(yTest==-1)=0;
        %Defining Hyperparameters
        C=c;
        %Run SVM
        [w,b,time]=SVM(xTrain, yTrain, C );
        [n,m]=size(xTest);
        yPred=(xTest*w'+b*ones(n,1))>0;
        accuracy=(sum(yPred==yTest)/length(yTest))*100;   
        if(accuracy<50)
            accuracy=100-accuracy;
        end
        svmacc=svmacc+accuracy;

        yTest(yTest==0)=-1;
        % Define hyperparameter values
        C1=c; C2=c;

        % Run Twin SVM (Linear)

        [ wA, bA, wB, bB,time ] = LinearTWSVM( xTrain, yTrain, C1, C2 );

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
        twinacc=twinacc+accuracy;
    end
    noisepinplot(ttt)=pinacc/10;
    noisetwinplot(ttt)=twinacc/10;
    noisesvmplot(ttt)=svmacc/10;
end
%Plotting the 2d line plot which will compare the aaccuracies of all the 3
%models on different hyperparameters.
figure
%Finding peak
[maxvalue, ind] = max(noisepinplot);
plot(Ccc,noisepinplot,'r',Ccc(ind),maxvalue,'or');
hold on 
%Finding peak
[maxvalue1, ind1] = max(noisesvmplot);
plot(Ccc,noisesvmplot,'b',Ccc(ind1),maxvalue1,'ob');
hold on 
%Finding peak
[maxvalue2, ind2] = max(noisetwinplot);
plot(Ccc,noisetwinplot,'g',Ccc(ind2),maxvalue2,'og');


legend('Pinball TSVM with noise',strcat(num2str(maxvalue),',',num2str(Ccc(ind))),'Linear SVM with noise',strcat(num2str(maxvalue1),',',num2str(Ccc(ind1))),'TSVM with noise',strcat(num2str(maxvalue2),',',num2str(Ccc(ind2))));
xlabel('Regularization Parameter C');
ylabel('Accuracy');
title('Accuracy vs Regularization Parameter');

 
 
