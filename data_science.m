%% Let's explore the training set.

% Load data.
% This dataset represents the output of the acquisition equipment.

addpath('data')
load('DatasetENEEB.mat')

% What we know about the data:
sampling_freq=4;

% You should see TRAIN, TEST1, TEST2 and chans_label 
% in MATLAB's Workspace.
%% Let's see what is inside each variable.
% traindata is a 41x1280

[train_rows, train_cols]=size(TRAIN);
[num_chans]=numel(chans_labels);

fprintf('Our training set has %i samples, and %i channels.\n', train_cols, num_chans);
%% Checking the training data.
% First we have to select a channel.

chan_idx=2;
%% 
% Now we can plot it over time.

figure, 
plot(TRAIN(chan_idx,:))
%% 
% Re-arrange the plot considering what we know.
% 
% Sampling_Freq=4Hz.
% 
% If possible , make a "prettier" plot.

int_t=100;
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:int_t:train_cols+int_t, ...
  'XTickLabel'  , 0:int_t/sampling_freq:(train_cols+int_t)/sampling_freq, ...
  'LineWidth'   , 1         );

ylim=get(gca, 'ylim');

xlabel('data over time (seconds)')

title(sprintf('plot of channel %s \n', chans_labels{chan_idx}))
%% 
% If you look closely, the matrix TRAIN has 41 lines. The last one represents 
% the task.
% 
% Let's edit the figure and add the condition.

hold on;

idxs=find(diff(TRAIN(end,:)));
st_int=1;
colors=[255, 255, 255;
    190, 190, 190;
    90, 90, 90]/255;

for i=1:numel(idxs)
    end_int=idxs(i);
    
    p=patch([st_int end_int end_int st_int],...
        [ylim(1) ylim(1)  ylim(2) ylim(2)],...
        colors(TRAIN(end,st_int)+1,:));
    set(p, 'FaceAlpha', 0.1,...
           'EdgeColor', 'none')   
    st_int=end_int+1;
end

%% 
% There are several moments that represent outliers (data points that differ 
% significantly from other observations).
% 
% How can we identify them? clean them?


ch_idx=3
outlcoef=3
                
% outlier detection.
datasegment=TRAIN(ch_idx,:);

% compute sliding window mean.
m_data=mean(datasegment);
std_data=std(datasegment);

outliers_idxs=find(abs(m_data-datasegment)>outlcoef*std_data);
if(~isempty(outliers_idxs))
    fprintf('found outliers in ch %i \n', ch)
end

for i =1:length(outliers_idxs)
    if datasegment(outliers_idxs(i)) > m_data
        datasegment(outliers_idxs(i))=m_data+std_data*2.5;
    else
        datasegment(outliers_idxs(i))=m_data-std_data*2.5;
    end
end

%%

plot(datasegment, 'r')
%%

movingavwindow=5;

% low pass filter - moving average of x samples (pr channel)
datasegmentcleaned=movmean(datasegment,movingavwindow)

plot(datasegmentcleaned, 'g')

%% APRESENTAÇÃO CLASSIFICAÇÃO


% Treinar modelo de classificação


% output: modelo já treinado.

addpath('functions')
%% Organize dataset

load('DatasetENEEB.mat')

nFeatures = 40;

dataTrain=Run1(:,1:40);
labelsTrain=Run1(:,41);

dataTest=[Run2(:,1:40) ; Run3(:,1:40)];
labelsTest=[Run2(:,41) ; Run3(:,41)];

featNames = cellstr(string([1:20 1:20]));

clear Run2 Run3

%% Feature Selection

nTopFeatures = 10;

% Feature Selection using two criteria - Fisher score,  Kruskal Wallis     
[ ~ , ~ , fs1] = FS_kruskal( dataTrain , labelsTrain , featNames , nTopFeatures );
[ ~ , ~ , fs2] = FS_fisher( dataTrain , labelsTrain , featNames , nTopFeatures );

% Plot intersection of feature selection methods
plotFSfig(fs1,fs2,nFeatures,featNames)
%% Train model

[trainedClassifier, validationAccuracy] = trainSVMClassifier(Run1)

save classifier.mat trainedClassifier