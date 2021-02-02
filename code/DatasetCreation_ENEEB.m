%% This scrip is designed to change stim info 
clear all; clc;
addpath(genpath('C:\Users\User\Documents\GitHub\nirs-toolbox'))

%% Load fNIRS data
rootDir = fullfile(pwd, 'data','TappingLeftRight');
raw = nirs.io.loadDirectory(fullfile(rootDir), {'subjects', 'runs'});

job = nirs.modules.RenameStims();
job.listOfChanges = {
    'channel_1', 'Baseline'; 
    'channel_2', 'Left'; 
    'channel_3', 'Right'
    };
raw = job.run( raw );
job = nirs.modules.Resample( );
job.Fs= 4;
raw =job.run(raw);

%% Data Segmentation
% This function will extract all the stim info from the data variable
stimTable=nirs.createStimulusTable(raw);
disp(stimTable);

NumberOfRuns = size(raw,1);

%Baseline Condition
BaselineDurationSeq = [14,16];
BasTemp=repmat(BaselineDurationSeq,6)';
for i=1:NumberOfRuns
    stimTable.Baseline(i).dur = [20; BasTemp(:,1)];
    stimTable.Baseline(i).onset = [4;34;58;84;108;134;158;184;208;234;258;284;308];
end
NumOfBaselineStim = size(stimTable.Baseline(1).onset,1);
for i=1:NumberOfRuns
    stimTable.Baseline(i).amp = ones(NumOfBaselineStim,1);
end

%Left Condition
Leftdur=10;
NumOfLeftStim = size(stimTable.Left(2).onset,1);

for i=1:NumberOfRuns
    stimTable.Left(i).dur = repmat(10,[NumOfLeftStim,1]);
    stimTable.Left(i).onset = [24;74;124;174;224;274];
    stimTable.Left(i).amp = ones(NumOfLeftStim,1);
end

%Right Condition
Rightdur=10;
NumOfRightStim = size(stimTable.Right(2).onset,1);
for i=1:NumberOfRuns
    stimTable.Right(i).dur =repmat(10,[NumOfRightStim,1]);
    stimTable.Right(i).onset = [48;98;148;198;248;298];
    stimTable.Right(i).amp = ones(NumOfRightStim,1);
end

% To implement the changes, we use the ChangeStimulusInfo job
j = nirs.modules.ChangeStimulusInfo();
j.ChangeTable = stimTable;

% Now, run the actual job
rawChanged = j.run(raw);

figure;
rawChanged(1).draw;

%% Data Preprocessing
job = nirs.modules.OpticalDensity(  );  
job = nirs.modules.BeerLambertLaw( job); 
hb = job.run(rawChanged);

%BaselineCorrection - Attemps a very conservative motion correction to remove DC-shifts.
%Options:  tune - number of standard deviations to define an outlier
job = nirs.modules.BaselinePCAFilter; % Default tune = 5
hb1 = job.run(hb);

%'Remove Trend & Motion w/ Wavelets'
job = nirs.modules.WaveletFilter; 
hb2 = job.run(hb1);

%Low pass Filter
%y = lowpass(x,fpass,fs) specifies that x has been sampled at a rate of fs hertz. 
% fpass is the passband frequency of the filter in hertz.
hb3 = hb2;
hb3(1).data = lowpass(hb2(1).data, 0.2 , 4);
hb3(2).data = lowpass(hb2(2).data, 0.2 , 4);
hb3(3).data = lowpass(hb2(3).data, 0.2 , 4);

%% Dataset Creation
% Clipping data  - Exclude timepoints w/condition atributed 
for jj=1:size(hb,1)
    for i=1:size(hb(1).stimulus.values,2)
        tempMin(jj,i) = floor(min(hb(jj).stimulus.values{i}.onset)); %[hb, condition] 
        tempMax(jj,i) = floor(max(hb(jj).stimulus.values{i}.onset));
    end
end
endblockDur = 16 ;
MinOnset = min(tempMin');
MaxOffset = max(tempMax') + endblockDur;

for jj=1:size(hb,1)
    IDxi(jj) = find(hb(jj).time == MinOnset(jj));
    IDXf(jj)=  find(hb(jj).time == MaxOffset(jj));
end

ClippedData1 = hb3(1).data(IDxi(1):IDXf(1)-1,:);
ClippedData2 = hb3(2).data(IDxi(2):IDXf(2)-1,:);
ClippedData3 = hb3(3).data(IDxi(3):IDXf(3)-1,:);

InitialData1 = hb(1).data(IDxi(1):IDXf(1)-1,:);
InitialData2 = hb(2).data(IDxi(1):IDXf(1)-1,:);
InitialData3 = hb(3).data(IDxi(1):IDXf(1)-1,:);

RawWL1 = raw(1).data(IDxi(1):IDXf(1)-1,:);
RawWL2 = raw(2).data(IDxi(1):IDXf(1)-1,:);
RawWL3 = raw(3).data(IDxi(1):IDXf(1)-1,:);

%Create array of labels
%left 1 ; right 2, baseline 0
fs =hb3.Fs;
AddedBaseline = zeros(20*fs,1);
seq = [ones(10*fs,1);zeros(14*fs,1);2*ones(10*fs,1);zeros(16*fs,1)];
condArray = repmat(seq, 6);
Labels = [AddedBaseline;condArray(:,1)];

Run1=[ClippedData1,Labels];
Run2=[ClippedData2,Labels];
Run3=[ClippedData3,Labels];

%% Plot figures of different preprocessing stages
figure;
subplot(3,1,1)
plot (RawWL2(:,6))
title('Raw WL data')

subplot(3,1,2)
plot (InitialData2(:,6))
title('Non preprocessed hbo data')

subplot(3,1,3)
plot(ClippedData2(:,6))
title('Preprocessed hbo data')

%%  Save Data
save('DatasetENEEB.mat', 'Run1', 'Run2', 'Run3')
