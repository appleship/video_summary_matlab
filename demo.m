addpath('./dof/lowdof')
addpath('../superframes_v01')
addpath('../SumMe/matlab');
HOMEDATA='../SumMe/GT/';
HOMEVIDEOS='../SumMe/videos/';
HOMEFRAMES='./frame/';
HOMEIMAGES='../test/frame';

%videoName='Uncut_Evening_Flight';
%% Take a random video
videoList=dir([HOMEVIDEOS '/*.mp4']);
[~,videoName]=fileparts(videoList(round(rand()*24+1)).name)
fileName = [HOMEVIDEOS videoName '.mp4']; 
obj = VideoReader(fileName);
numFrames = obj.NumberOfFrames;% ֡������
frameScore=zeros(numFrames,1);
 for k = 1 : numFrames% ��ȡ����
     frame = read(obj,k);
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����score
     feature_vector = low_depth_of_field_indicators(frame);
     frameScore(k,:)=sum(feature_vector,2)*3;
     frameScore=round(frameScore);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % imshow(frame);%��ʾ֡
     imwrite(frame,strcat(HOMEFRAMES,num2str(k),'.jpg'));% ����֡
 end
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����superframe
 default_parameters;
 FPS=29;
Params.lognormal.mu=1.16571;
Params.lognormal.sigma=0.742374;
%��ȡͼƬ����Ϣ������ʲô���ڣ���С������֮���
images=dir(fullfile(HOMEIMAGES,'*.jpg'));
%�õ�ͼƬ��·��
imageList=cellfun(@(X)(fullfile(HOMEIMAGES,X)),{images(:).name},'UniformOutput',false);

%% Run Superframe segmentation
tic
[superFrames,motion_magnitude_of] = summe_superframeSegmentation(imageList,FPS,Params);
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ÿһ��εĵ÷֣��ٽ����������
% load('superFrames.mat');
% load('framescore.mat');
su_score=superScore(superFrames,frameScore);
[score,list]=beibao(superFrames,su_score);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����F
summary_selection=evaluate(list,frameScore,superFrames);
[f_measure,summary_length]=summe_evaluateSummary(summary_selection,videoName,HOMEDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
show_summary(list,imageList,superFrames);


figure