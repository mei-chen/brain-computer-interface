function [Allaccu,R]=CSP_ClassificationExtentTenFold(TypeOne,TypeTwo,TimePoint,FrequencyPoint)
DATA_CHANNEL=size(TypeOne{1},1);
Fs=250; % NeedToChange
filt_n =4;
Wn=[FrequencyPoint(1) FrequencyPoint(2)]/(Fs/2);
[filter_b,filter_a]=butter(filt_n,Wn);
StartTimePoint=floor((3+TimePoint(1))*Fs)+1;
EndTimePoint=floor((3+TimePoint(2))*Fs);
FoldNum=10;

for i=1:length(TypeOne)
    data_filter=filter(filter_b,filter_a,TypeOne{i},[],2);
    Dr=data_filter(:,StartTimePoint:EndTimePoint);
    Cov1{i}=Dr*Dr';
    data_filter=filter(filter_b,filter_a,TypeTwo{i},[],2);
    Dr=data_filter(:,StartTimePoint:EndTimePoint);
    Cov2{i}=Dr*Dr';
end
Allaccu=zeros(1,FoldNum+1);
R=zeros(FoldNum,FoldNum);
for FoldTime=1:10
    len=length(TypeOne);
%     Labels=1:len;
%     rng('shuffle')
%     Labels=shuffle(Labels);
    Labels=randperm(len);
    EveryFold=floor(len/FoldNum);
    for Fold=1:FoldNum
        if Fold~=FoldNum
            TestIndex=Labels((Fold-1)*EveryFold+1:(Fold-1)*EveryFold+EveryFold);
            LabelsTemp=Labels;
            LabelsTemp((Fold-1)*EveryFold+1:(Fold-1)*EveryFold+EveryFold)=[];
            TrainIndex=LabelsTemp;
        else
            TestIndex=Labels((Fold-1)*EveryFold+1:end);
            LabelsTemp=Labels;
            LabelsTemp((Fold-1)*EveryFold+1:end)=[];
            TrainIndex=LabelsTemp;
        end
        TrainSet1=Cov1(TrainIndex);
        TrainSet2=Cov2(TrainIndex);
        TestSet1=Cov1(TestIndex);
        TestSet2=Cov2(TestIndex);
        
        R1=zeros(DATA_CHANNEL,DATA_CHANNEL);
        R2=zeros(DATA_CHANNEL,DATA_CHANNEL);
        
        for i=1:length(TrainSet1)
            R1=R1+TrainSet1{i};
            R2=R2+TrainSet2{i};
        end
        R1=R1/trace(R1);
        R2=R2/trace(R2);
        R3=R1+R2;
        N=3;
        [U0,Sigma]=eig(R3);
        P=Sigma^(-0.5)*U0';
        YL=P*R1*P';
        [UL,SigmaL]=eig(YL);
        [Y,I]=sort(diag(SigmaL), 'descend');
        F=P'*UL(:,I([1:N,DATA_CHANNEL-N+1:DATA_CHANNEL]));
        
        f1=[];f2=[];f=zeros(2*N,1);
        for i=1:length(TrainSet1)
            for j=1:2*N
                f(j)=log(F(:,j)'*TrainSet1{i}*F(:,j));
            end
            f1=[f1,f];
            for j=1:2*N
                f(j)=log(F(:,j)'*TrainSet2{i}*F(:,j));
            end
            f2=[f2,f];
        end
        
        F1=f1';F2=f2';
        M1=mean(F1,1)';M2=mean(F2,1)';
        count1=size(f1,2)-1;count2=size(f2,2)-1;
        w=(inv((count1*cov(F1)+count2*cov(F2))/(count1+count2))*(M2-M1))';
        b=-w*(M1+M2)/2;
        TypeOneSign=w*M1+b;
        TypeTwoSign=w*M2+b;
        
        Right=0;
        y1=[];
        y2=[];
        for i=1:length(TestSet1)
            Rtest=TestSet1{i};
            for j=1:2*N
                f(j)=log(F(:,j)'*Rtest*F(:,j));
            end
            y=w*f+b;
            y1=[y1 y];
            if TypeOneSign*y>=0
                Right=Right+1;
            end
        end
        
        for i=1:length(TestSet2)
            Rtest=TestSet2{i};
            for j=1:2*N
                f(j)=log(F(:,j)'*Rtest*F(:,j));
            end
            y=w*f+b;
            y2=[y2 y];
            if TypeTwoSign*y>=0
                Right=Right+1;
            end
        end
        
        Accu(Fold)=Right/(2*length(TestSet1));
    end
    Accu(Fold+1)=mean(Accu(1:Fold));
    Allaccu=Allaccu+Accu;
    R(FoldTime,:)=Accu(1:Fold);
end
Allaccu=Allaccu/FoldTime;