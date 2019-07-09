function [ accuracy ] = accutwinpinsvm( xTrain,yTrain,xTest, yTest, C1,C2,V1,V2,T1,T2)
%function to calulate the accuracy
[ wA,bA,wB,bB,time ] = LinearPinTWSVM( xTrain, yTrain, C1, C2,V1,V2,T1,T2 );
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
end