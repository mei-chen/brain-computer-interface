%% Selective Sensation left/right

%Load the data
% %For piecing together separate segments of data
TempData1=load('F:\UMyao\CalibrationTrainingOnline_gCp\CalibrationTrainingOnlineTwo\3. data-2017.06.05_11.57 (S103_run1-4)\Data-2017.06.05_11.57.txt');
TempData2=load('F:\UMyao\CalibrationTrainingOnline_gCp\CalibrationTrainingOnlineTwo\3. data-2017.06.05_12.35 (S103_run5)\Data-2017.06.05_12.35.txt');
% TempData3=load('F:\UMyao\StudyMoreData\StimBetweenSAO\data-2017.05.16_17.31_5th\Data-2017.05.16_17.31.txt');
% TempData4=load('F:\UMyao\StudyMoreData\StimBetweenSAO\data-2017.05.16_17.44_6th\Data-2017.05.16_17.44.txt');

Data=[TempData1; TempData2;];

Data=load('C:\Users\l32yao\Desktop\Senior\4. S104 (run1-5)\Data-2017.06.12_11.10.txt');
newData=Data(:,[1:32]);     %Select only 1:32 of the data for the 32 channels (row = signals; column = 
Fs = 250;                   %Define the frequency
save Senior6.mat  Data                     %Save the data to save time 

save Senior6-32channels.mat  newData                     %Save the data to save time 

%newData(end, IdxT(1:160)) = 0;

for i=1:size(newData,1)   %Loop from 1 to the size of DataT (which is row, column), but only row is wanted, so it's 689710
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

%% START HERE 

newData = SSData;

LeftIdx = find(newData(33,:)==1);       
RightIdx = find(newData(33,:)==2);

% newData(end,IdxT(81:end)) = 0;  %Last two runs
% newData(end, IdxT(1:160)) = 0; %This crops the newData to ONLY the first two runs 
% figure;plot(newData(end,:))     %visualize croped data



FreqBands=[6 8;8 10;10 13;13 20;20 26;8 13;13 26;8 26;10 16];
mTypeOne={};mTypeTwo={};
Channels = 1:32;
%Channels(28)=[]; %take away channel if it's broken

IdxT = LeftIdx(1:40);
for i=1:length(IdxT)
    mTypeOne{1,i}=newData(Channels,IdxT(i)-250*2+1:IdxT(i)+250*5);
end

IdxT = RightIdx(1:40);
for i=1:length(IdxT)
    mTypeTwo{1,i}=newData(Channels,IdxT(i)-250*2+1:IdxT(i)+250*5);
end

[Result ReCell]=CSP_DifferentFrequencyBand(mTypeOne,mTypeTwo,[0 2],FreqBands);

[M,I]=max(Result)
FreqBands(I,:)

% standard deviation
mean(ReCell{1,I},2)
std(ans)


%%
senior =[0.5887,0.6575,0.6375,0.6775,0.6125,0.5513,0.5975,0.6700,0.8387,0.5800 ,0.6787 ];
mean(senior)
young = [0.8925 ,0.9933,0.8050,0.9950 ,0.5225 ,0.8650 ,0.9950 ,0.9375 ,0.9962 ,0.9450 ,0.7175 ,0.9750 ,0.7887 ,0.8763 ];
mean(young)

%%
%update the epochs used
mTypeOne = [];
IdxT = size(EEG.data, 3);
for i=1:IdxT
    mTypeOne{1,i} = double(EEG.data(:,:,i));
end

mTypeTwo = [];
IdxT = size(EEG.data, 3);
for i=1:IdxT
    mTypeTwo{1,i} = double(EEG.data(:,:,i));
end

MMtypeone = mTypeOne(1:36);
MMtypetwo = mTypeTwo(1:36);

%addpath('C:\Users\l32yao\Desktop\Analysis Mei','C:\Users\l32yao\Desktop\Analysis Mei\eeglab13_6_5b')
addpath('C:\Users\l32yao\Desktop\Analysis Mei','C:\Users\d24fu\Documents\MATLAB\eeglab14_1_1b')

% [Result ReCell]=CSP_DifferentFrequencyBand(mTypeOne,mTypeTwo,[-2 0],FreqBands);
[Result ReCell]=CSP_DifferentFrequencyBand(MMtypeone,MMtypetwo,[0.25 1],FreqBands);


%% EEGLAB
DataT = SSData;
Fs=250;
addpath(genpath('G:\Senior\eeglab13_6_5b'));
EEG = pop_importdata('dataformat','array','nbchan',0,'data','DataT','setname','Temp','srate',250,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
EEG = pop_chanevent(EEG, size(SSData,1),'edge','leading','edgelen',0);
EEG = eeg_checkset( EEG );
EEG = pop_chanedit(EEG, 'load',{'ch_32_wireless.asc' 'filetype' 'autodetect'});
EEG = eeg_checkset( EEG );
eeglab redraw;

EEG = pop_epoch( EEG, {  '4'  }, [-3  5], 'newname', 'Epoched', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-2000     -1200]);
EEG = eeg_checkset( EEG );

load('ch62position.mat');
Th = pi/180*(Th-270);
[x,y] = pol2cart(Th,Rd);
LocationX=x';LocationY=y';
LocationX=-LocationX;
SqueezeFactor=0.8;
LocationX=LocationX*SqueezeFactor;
LocationY=LocationY*0.7;
LocationX = LocationX+0.45;
LocationY = LocationY+0.49;
LocationX = LocationX([1 3 4 5 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 51 53 55 57 62]);
LocationY = LocationY([1 3 4 5 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 51 53 55 57 62]);
