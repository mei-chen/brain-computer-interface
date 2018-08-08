numSub = 11; %CHANGE THIS
mTypeOne={};mTypeTwo={}; %new matrix for event 1,2
count = 0;
typeOne15 = []; typeOne17 = []; typeTwo15 = []; typeTwo17 = [];


for subIdx=1:2:(numSub*2-1) %count which subject # currently at
    count=count+1; ERDSrow=count; %count for the row looping throw
    subName = EEG(subIdx).filename; subName = subName(1:4); %take the subject's id

    % Loop through each trial
    DataL = EEG(subIdx).data; %Temporarily put the data for Left hand in DataL (for current subject)
    DataR = EEG(subIdx+1).data; %Temporarily put the data for right hand in DataR (for current subject)

    for tL=1:length(DataL(1,1,:)) %for however many clean epochs it has:
        mTypeOne{ERDSrow,tL}=DataL(:,:,tL) %this is the epoched trials, put into mTypeOne
    end

    for tR=1:length(DataR(1,1,:)) %same for tR (trial Right)
        mTypeTwo{ERDSrow,tR}=DataR(:,:,tR)
    end
        %% Small laplace around C3 and C4
    for trialL=1:length(DataL(1,1,:))
        mTypeOne{ERDSrow,trialL}(15,:) = mTypeOne{ERDSrow,trialL}(15,:) - ((mTypeOne{ERDSrow,trialL}(10,:) + mTypeOne{ERDSrow,trialL}(11,:) + mTypeOne{ERDSrow,trialL}(19,:) + mTypeOne{ERDSrow,trialL}(20,:))/4);
        mTypeOne{ERDSrow,trialL}(17,:) = mTypeOne{ERDSrow,trialL}(17,:) - ((mTypeOne{ERDSrow,trialL}(12,:) + mTypeOne{ERDSrow,trialL}(13,:) + mTypeOne{ERDSrow,trialL}(21,:) + mTypeOne{ERDSrow,trialL}(22,:))/4);
    end

    for trialR=1:length(DataR(1,1,:))
        mTypeTwo{ERDSrow,trialR}(15,:) = mTypeTwo{ERDSrow,trialR}(15,:) - ((mTypeTwo{ERDSrow,trialR}(10,:) + mTypeTwo{ERDSrow,trialR}(11,:) + mTypeTwo{ERDSrow,trialR}(19,:) + mTypeTwo{ERDSrow,trialR}(20,:))/4);
        mTypeTwo{ERDSrow,trialR}(17,:) = mTypeTwo{ERDSrow,trialR}(17,:) - ((mTypeTwo{ERDSrow,trialR}(12,:) + mTypeTwo{ERDSrow,trialR}(13,:) + mTypeTwo{ERDSrow,trialR}(21,:) + mTypeTwo{ERDSrow,trialR}(22,:))/4);
    end

    %% Set parameters
    %this time parameter will stay the same because the epoch trials are consistent
    %FreqBands=[8 10;8 12;10 13;13 20;20 26;8 13;13 26;8 26]; %define the frequency bands
    FreqBands=[8 26]; %define the frequency bands

    TrialTimePoints = (EEG(subIdx).times/1000); %the time points for each epoch
    Baseline=[-2 -1.2]; %baseline from -2 seconds to -1.2 seconds
    [~,BaselineStart]=min(abs(TrialTimePoints-Baseline(1))); %[row,column] = ... finds the row and column of the value.
    [~,BaselineEnd]=min(abs(TrialTimePoints-Baseline(2))); %since both only have 1 row we don't need the first row value, only the column value

 %% Filtering
    for freqIdx=1:size(FreqBands,1) %loop through the frequency bands
        FrequencyPoint=FreqBands(freqIdx,:); %take the first frequency point pair i.e. [8 10]
        Fs=250; % NeedToChange
        n =2; %Butterworth filter order
        Wn=[FrequencyPoint(1) FrequencyPoint(2)]/(Fs/2); %[8/125 10/125] = [0.064 0.208]
        [b,a]=butter(n,Wn); %[b,a] = butter(n,Wn) returns the trnasfer function coefficient of nth order low pass digitl butterworth filter with normalized cut off frequency Wn

        % FOR LEFT HAND ---------------------------------------------------
        data_squred=0;
        for t=1:length(mTypeOne) %loop through the mTypeOne
            data_filter=filter(b,a,mTypeOne{t},[],2); %y = filter(b,a,x,zi,dim) filters input data x using rational transfer function defined by numerator and denominator coefficients b and a
            %set the zi to [] to make filter delay zero. if x is a matrix, filter(b,a,x,zi,2) returns filtered data for each row
            data_squred=data_squred+data_filter.^2; %Add up the square of each result
        end

        data_squred=data_squred/length(mTypeOne); %Take the mean of the sum of all results
        BaselinePowerL=repmat(mean(data_squred(:,BaselineStart:BaselineEnd),2),[1 size(data_squred,2)]); %Here, we are taking a baseline power
        %repmap function replicates a matrix by [row column] times. We have [1 size(data_squared,2)] because we need to extend the baseline mean to
        %the entire data value set, in order to subtract it from the data values in the next step
        leftERD=(data_squred-BaselinePowerL)./BaselinePowerL; %the '.' gives an element-wise operation. the baseline power is subtracted from data_squared and divided
        %to determine the percent of baseline power there are left
        mTypeOneERD{ERDSrow,freqIdx}=leftERD;


        % SAME THING FOR RIGHT HAND ---------------------------------------
        data_squred=0; %clear the data
        for n=1:length(mTypeTwo)
            data_filter=filter(b,a,mTypeTwo{n},[],2);
            data_squred=data_squred+data_filter.^2;
        end
        data_squred=data_squred/length(mTypeTwo);
        BaselinePowerR=repmat(mean(data_squred(:,BaselineStart:BaselineEnd),2),[1 size(data_squred,2)]);
        rightERD=(data_squred-BaselinePowerR)./BaselinePowerR;
        mTypeTwoERD{ERDSrow,freqIdx}=rightERD;
    end

    %% Generate figure results
    figure('Color','white')
    ax1 = subplot(1,2,1)
    plot(ax1,TrialTimePoints(1,:),smooth(mTypeOneERD{ERDSrow,1}(15,:),100),'r')
    title('ERD/S of Event 1-left hand')
    xlabel('time') % x-axis label
    ylabel('ERD/S') % y-axis label
    hold on
    plot(ax1,TrialTimePoints(1,:),smooth(mTypeOneERD{ERDSrow,1}(17,:),100),'c')
    legend('channel 15','channel 17')
    xlim([-2 5]);
    ax2 = subplot(1,2,2)
    plot(ax2,TrialTimePoints(1,:),smooth(mTypeTwoERD{ERDSrow,1}(15,:),100),'r')
    title('ERD/S of Event 2-right hand')
    xlabel('time') % x-axis label
    ylabel('ERD/S') % y-axis label
    hold on
    plot(ax2,TrialTimePoints(1,:),smooth(mTypeTwoERD{ERDSrow,1}(17,:),100),'c')
    legend('channel 15','channel 17')
    xlim([-2 5]);

    %suptitle([int2str(EEG(1).filename)])
    suptitle([subName]);
    %savefig(subName);
end

%% Average Results
avgLeft=zeros(32,2250);avgRight=zeros(32,2250);
LeftC3vertcat = []; RightC3vertcat = []; LeftC4vertcat = []; RightC4vertcat = [];

for i = 1:numSub
  %for average calculation
  avgLeft = avgLeft + mTypeOneERD{i,1};
  avgRight = avgRight + mTypeTwoERD{i,1};

  %place each subject's C3 C4 into vertcat variables - for p calculation
  LeftC3vertcat = vertcat(LeftC3vertcat, mTypeOneERD{i,1}(15,:));
  LeftC4vertcat = vertcat(LeftC4vertcat, mTypeOneERD{i,1}(17,:));
  RightC3vertcat = vertcat(RightC3vertcat, mTypeTwoERD{i,1}(15,:));
  RightC4vertcat = vertcat(RightC4vertcat, mTypeTwoERD{i,1}(17,:));
end

smoothLvl = 300;
avgLeftC4 = smooth(avgLeft(17,:)/numSub,smoothLvl);
avgLeftC3 = smooth(avgLeft(15,:)/numSub,smoothLvl);
avgRightC4 = smooth(avgRight(17,:)/numSub,smoothLvl);
avgRightC3 = smooth(avgRight(15,:)/numSub,smoothLvl);

%% Calculate Standard Error
typeOne15SD = std(LeftC3vertcat,0,1); typeOne15SE = smooth(typeOne15SD/sqrt(numSub),smoothLvl);
typeOne17SD = std(LeftC4vertcat,0,1); typeOne17SE = smooth(typeOne17SD/sqrt(numSub),smoothLvl);
typeTwo15SD = std(RightC3vertcat,0,1); typeTwo15SE = smooth(typeTwo15SD/sqrt(numSub),smoothLvl);
typeTwo17SD = std(RightC4vertcat,0,1); typeTwo17SE = smooth(typeTwo17SD/sqrt(numSub),smoothLvl);

typeOne15SD = smooth(typeOne15SD,smoothLvl);
typeOne17SD = smooth(typeOne17SD,smoothLvl);
typeTwo15SD = smooth(typeTwo15SD,smoothLvl);
typeTwo17SD = smooth(typeTwo17SD,smoothLvl);



%% Plot Average Values
figure('Color','white')
ax1 = subplot(1,2,1)
plot(ax1,avgLeftC3,'r')
title('Average ERD/S of Event 1-Left hand')
xlabel('point number') % x-axis label
ylabel('ERD/S') % y-axis label
hold on
plot(ax1,avgLeftC4,'c')
legend('Channel C3','Channel C4')
xlim([250 1750]);

ax1 = subplot(1,2,2)
plot(ax1,avgRightC3,'r')
title('Average ERD/S of Event 2-Right hand')
xlabel('point number') % x-axis label
ylabel('ERD/S') % y-axis label
hold on
plot(ax1,avgRightC4,'c')
legend('Channel C3','Channel C4')
xlim([250 1750]);
savefig('Average Young ERDS');

%% Plot Topoplot
% average over a certain time, then plot the topo  FreqBands=[8 10;8 12;10 13;13 20;20 26;8 13;13 26;8 26];
load('channlocs.mat');
topoST = 0.25; topoET = 1;
for num = 1:numSub
    figure('Color','white')
    subplot(1,2,1)
    topoL = mTypeOneERD{num,1};
    topoLcrop = topoL(:,(750+topoST*250):(750+topoET*250));
    topoLmean = mean(topoLcrop,2);
    topoplot(squeeze(topoLmean),EEGchanlocs); title('ERD/S of Event 1-left hand')
    cbar('vert',0,[-6 6]);
    hold on
    subplot(1,2,2)
    topoR = mTypeTwoERD{num,1};
    topoRcrop = topoR(:,(750+topoST*250):(750+topoET*250));
    topoRmean = mean(topoRcrop,2);
    topoplot(squeeze(topoRmean),EEGchanlocs); title('ERD/S of Event 2-right hand')
    cbar('vert',0,[-6 6]);
    suptitle(int2str(num));
    %savefig(int2str(num));
end

%% Topo Average
    figure('Color','white')
    subplot(1,2,1)
    topoLcrop = avgLeft(:,(750+topoST*250):(750+topoET*250));
    topoLmean = mean(topoLcrop,2);
    topoplot(squeeze(topoLmean),EEGchanlocs, 'whitebk','on'); %title('Average ERD/S of Left Wrist Stimulation')
    set(gca,'fontsize',20)
    set(gcf,'color','white')
    hold on
    subplot(1,2,2)
    topoR = mTypeTwoERD{num,1};
    topoRcrop = avgRight(:,(750+topoST*250):(750+topoET*250));
    topoRmean = mean(topoRcrop,2);
    topoplot(squeeze(topoRmean),EEGchanlocs,'whitebk','on'); %title('Average ERD/S of Right Wrist Stimulation')
    cbar('vert',0,[-6 6]);
    %savefig('Average Young');
    set(gca,'fontsize',20)
    get(0,'Factory')

%% Combined stim topograph
Start = -0.4; End = -0.1;
figure('Color','white')
totalTopo = (avgLeft + avgRight)/2;
totalCrop = totalTopo(:,(750+Start*250):(750+End*250));
topoLmean = mean(totalCrop,2);
topoplot(squeeze(topoLmean),EEGchanlocs,'whitebk','on');
title('Younger Adults','fontsize',20)
cbar('vert',0,[-6 6]);
set(gca,'fontsize',20)
