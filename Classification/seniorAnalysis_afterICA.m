%% Selective Sensation left/right
%Load the data
% %For piecing together separate segments of data
TempData1=load('F:\UMyao\CalibrationTrainingOnline_gCp\CalibrationTrainingOnlineTwo\3. data-2017.06.05_11.57 (S103_run1-4)\Data-2017.06.05_11.57.txt');
TempData2=load('F:\UMyao\CalibrationTrainingOnline_gCp\CalibrationTrainingOnlineTwo\3. data-2017.06.05_12.35 (S103_run5)\Data-2017.06.05_12.35.txt');
% TempData3=load('F:\UMyao\StudyMoreData\StimBetweenSAO\data-2017.05.16_17.31_5th\Data-2017.05.16_17.31.txt');
% TempData4=load('F:\UMyao\StudyMoreData\StimBetweenSAO\data-2017.05.16_17.44_6th\Data-2017.05.16_17.44.txt');

Data=[TempData1; TempData2;];
Data=SSData;
Data=load('C:\Users\l32yao\Desktop\Senior\12. S112 (run1-5)\Data-2017.08.03_09.57.txt');
newData=Data(:,[1:32]);     %Select only 1:32 of the data for the 32 channels (row = signals; column = 
Fs = 250;                   %Define the frequency

%newData(end, IdxT(1:160)) = 0;
%% Label newData
for i=1:size(newData,1)   %Loop from 1 to the size of newData (which is row, column), but only row is wanted, so it's 689710
    if Data(i,37)~=6    %Data column 37 is the state. When state is not 7 (meaning when it's
        newData(i,33)=0; %7 means the data is not useful
    elseif Data(i-1,37)==5 && Data(i,37)==6 %find the location where the state changes with channel 37 - indicates start of trial
        if i+1.6*Fs<=size(newData,1) %to make sure it's not out of bound
            if Data(i+1.6*Fs,38)==0                    %if channel 38 is 0 that means it's left hand
                newData(i,33)=1;
            elseif Data(i+1.6*Fs,38)==1                %if channel 38 is 1 = right hand
                newData(i,33)=2;
            end
        end
    end
end
newData = newData';                     %transpose
%IdxT = find(newData(end,:)~=0);         %find the trials where it's NOT right or left hand
%newData(end, IdxT(241:end)) = 0;        %delete the ones that are the extra ones based on the indexT above

IdxT = find(newData(end,:)~=0); %Find trials where it's not left or right hand 
ssEndIdx = IdxT(80); %Index where SS runs end and SAO start

%Separate data into SS and SAO runs 
SSData = newData(1:33,1:ssEndIdx+250*5);
SAOData = newData(1:33,1:ssEndIdx+250*5+1:end);

%% Replace channel 28 with average of 23, 24, 29

for i=1:size(SSData,2)
    SSData(28,i) = (SSData(23,i) + SSData(24,i) + SSData(29,i))/3;
end

%save S112ss.mat SSData

LeftIdx = find(SSData(33,:)==1);       
RightIdx = find(SSData(33,:)==2);

% newData(end,IdxT(81:end)) = 0;  %Last two runs
% newData(end, IdxT(1:160)) = 0; %This crops the newData to ONLY the first two runs 
% figure;plot(newData(end,:))     %visualize croped data


%% Select frequency band
FreqBands=[6 8;8 10;10 13;13 20;20 26;8 13;13 26;8 26;10 16];
mTypeOne={};mTypeTwo={};
Channels = 1:32;
%Channels(28)=[]; %take away channel if it's broken

%put data from subjec 1 into matrix
LeftData = double(EEG(1).data);
RightData = double(EEG(1).data); 

LeftData = LeftData(:,:,1:34);
RightData = RightData(:,:,1:34);

%delete channel 28  
LeftData(28,:,:)=[];
RightData(28,:,:)=[];

for indx = 1:length(LeftData(1,1,:))
    mTypeOne{1,indx}=LeftData(:,:,indx);
end

for indx = 1:length(RightData(1,1,:))
    mTypeTwo{1,indx}=RightData(:,:,indx);
end

addpath('C:\Users\l32yao\Desktop\Analysis Mei','C:\Users\l32yao\Desktop\Analysis Mei\eeglab13_6_5b')
% [Result ReCell]=CSP_DifferentFrequencyBand(mTypeOne,mTypeTwo,[-2 0],FreqBands);
[Result ReCell]=CSP_DifferentFrequencyBand(mTypeOne,mTypeTwo,[0 2],FreqBands);

