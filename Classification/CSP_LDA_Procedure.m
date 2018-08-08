%%%%%%%%% CSP LDA PROCEDURE for comparing SS between C3C4 and CSP CLassification Accuracy %%%%%%%%%%%

% Load data 
DataStruct=load('C:\Users\l32yao\Desktop\Analysis Mei\Senior\Senior2.mat'); % Load data - Note: loads as a struct
Data=DataStruct.Data;
newData=Data(:,[1:32]);     %Select only 1:32 of the data for the 32 channels (row = signals; column = 
Fs = 250;

for i=1:size(newData,1)     %Loop from 1 to the size of DataT (which is row, column), but only row is wanted, so it's 689710
    if Data(i,37)~=6        %Data column 37 is the state. When state is not 7 (meaning when it's
        newData(i,33)=0;    %7 means the data is not useful
    elseif Data(i-1,37)==5 && Data(i,37)==6     %find the location where the state changes with channel 37 - indicates start of trial
        if i+1.6*Fs<=size(newData,1)
            if Data(i+1.6*Fs,38)==0             %if channel 38 is 0 that means it's left hand
                newData(i,33)=1;
            elseif Data(i+1.6*Fs,38)==1         %if channel 38 is 1 = right hand
                newData(i,33)=2;
            end
        end
    end
end
newData = newData'; 

IdxT = find(newData(end,:)~=0);   %find the trials where it's NOT right or left hand
ssEndIdx = IdxT(81);    % Index where SS runs end and SAO start

% Separate data into SS and SAO runs
SSData = newData(1:33, 1:ssEndIdx);
SAOData = newData(1:33, ssEndIdx+1:end);

%Open data in EEGLab (Optional - just for viewing)
EEGData = SAOData;
Fs=250;

save Data-S102.set newData;

% 
% EEG = pop_importdata('dataformat','array','nbchan',0,'data','EEGData','setname','Temp','srate',250,'pnts',0,'xmin',0);
% EEG = eeg_checkset( EEG );
% EEG = pop_chanevent(EEG, size(newData,1),'edge','leading','edgelen',0);
% EEG = eeg_checkset( EEG );
% EEG = pop_chanedit(EEG, 'load',{'ch_32_wireless.asc' 'filetype' 'autodetect'});
% EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename','test.set','filepath','C:\\Users\\d24fu\\Desktop\\');
% EEG = eeg_checkset( EEG );
% eeglab redraw;

addpath(genpath('C:\Users\l32yao\Desktop\Analysis Mei\eeglab13_6_5b'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_importdata('dataformat','array','nbchan',0,'data','EEGData','setname','Temp','srate',250,'pnts',0,'xmin',0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','SSData-102','gui','off'); 
EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\l32yao\\Desktop\\Analysis Mei\\ch_32_wireless.asc');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 8, 20, 414, 0, [], 1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','SAO-102.set','filepath','C:\\Users\\l32yao\\Desktop\\Analysis Mei\\Senior\\LDA CSP\\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;




%% Compute CSP in BCIlab

addpath(genpath('C:\Users\l32yao\Desktop\Analysis Mei\BCILAB-devel'));
CSPData = io_loadset('C:\Users\l32yao\Desktop\Analysis Mei\Senior\LDA CSP\SS-102.set'); % Change if needed
myapproach = {'CSP' ...
    'SignalProcessing', { ...
    'EOGRemoval', { ...
    'ReferenceChannels', [1 2] ...
    'RemoveReferenceChannels', false} ...
    'Resampling', 'off' ...
    'FIRFilter', 'off'}};
[trainloss,model,laststats] = bci_train('Data', CSPData,'Approach',myapproach,'TargetMarkers',{'1','2'}); % learn model

% Put data through filters from BCIlab CSP  
filter1 = model.featuremodel.filters(:,1);
filter2 = model.featuremodel.filters(:,6);
filterMatrix = horzcat(filter1,filter2);
filterMatrixT = filterMatrix';
filteredSignal = filterMatrixT*SSData(1:32,:);


%% LDA Cross Validation

C3C4 = pop_select( EEG,'channel',{'C3' 'C4'});
C3C4 = eeg_checkset( C3C4 );
C3C4Data = C3C4.data;

labels = Data(33, 1:251501); % Labels -1 and 1, 0
%labels = Data(1:251501, 38);
cp = cvpartition(labels,'KFold',10);

%Mdl = fitcdiscr(X,Y) returns a discriminant analysis classifier based on the input variables X and response Y.
% Each row of Y represents the classification of the corresponding row of X.
% Each column of X represents one variable, and each row represents one observation.

Mdl = fitcdiscr(C3C4Data', labels, 'DiscrimType','linear');
cvlda = crossval(Mdl,'CVPartition',cp); 
L = kfoldLoss(cvlda);
accuracyLDA=1-L;












