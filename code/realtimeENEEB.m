%% This scrip is designed to atempt a real time fNIRS dataframe  
clear all; clc;
% Add path folder and subfolders of Nirs Toolbox
addpath(genpath('C:\Users\User\Documents\GitHub\nirs-toolbox'))

%% Load fNIRS data
% Define path for data folder
rootDir = 'C:\Users\User\Documents\GitHub\ENEEB\data\TappingLeftRight';
raw = nirs.io.loadDirectory(fullfile(rootDir), {'subjects', 'runs'});

%% Nirs.realtime
%Available methods ; cant find any demo/video or example online 
dir ('C:\Users\User\Documents\GitHub\nirs-toolbox\+nirs\+realtime')

RealTimeTest= nirs.realtime.rtData();
RealTimeTest =adddata(RealTimeTest, raw(1).data, raw(1).time);
RealTimeTest.probe = raw(1).probe;
RealTimeTest.stimulus = raw(1).stimulus;




