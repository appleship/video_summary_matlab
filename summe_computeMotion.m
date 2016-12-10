function [ motion_magnitude,motion_magnitude_back ] = summe_computeMotion(imageList,frameRange,FPS,Params )
%summe_computeMotion Computes the motion magnitude over a range of frames   

    fprintf('Compute forward motion\n');    
    frames=imageList(frameRange(1):frameRange(2));
    %motion��ָһ֡һ֡ͬһ���λ�ñ任����������һ�飬�ٷ�����һ�飬why
    motion_magnitude=getMagnitude(frames,Params,FPS);
    
    fprintf('Compute backward motion\n')    
    frames=imageList(frameRange(2):-1:frameRange(1));  
    %������
    motion_magnitude_back=getMagnitude(frames,Params,FPS);
    motion_magnitude_back=flip(motion_magnitude_back);
    
end
    
function [motion_magnitude]=getMagnitude(imageList,Params,FPS)
    motion_magnitude=zeros(length(imageList),1);
    for startFrame=1:Params.stepSize:length(imageList)-Params.stepSize
        % Load the first image
        frame = imread(imageList{startFrame});
        
        %������ϴ�׷�ٵĵ㣬�ʹ��ϴ�׷�ٵĵ㿪ʼ�����û�Ļ��ʹӣ�0��0����ʼ
        if ~exist('frameSize','var')
            frameSize=sqrt(size(frame,1)*size(frame,2));
        end
        if ~exist('new_points','var')
            old_points=zeros(0,2);
        else
            old_points=new_points(points_validity,:);
        end


        % Detect points
        minQual=Params.minQual;
        points=[];
        tries=0;
        %��������
        while (size(old_points,1)+size(points,1)) < Params.num_tracks*0.95 && tries<5 % we reinitialize only, if we have too little points
            %minqual��ʾ�ɽ��ܵĽǵ�����������ֵΪ���ڵ���ͼ�����������ֵ�ı������ϴ�ʱ���Լ������.����minqualԽ�󣬼�⵽�Ľ�
            %��Խ�٣����ܾʹﲻ��Ҫ���track�ĵ�����
            points=detectFASTFeatures(rgb2gray(frame),'MinQuality',minQual);
            minQual=minQual/5;
            tries=tries+1;
        end        
        if numel(points) > 0
            old_points=[old_points; points.Location];
        end
    %������ͦ���ʱ��Ҳֻȡnum_tracks����
        if size(old_points,1) > Params.num_tracks
            indices=randperm(size(old_points,1));
            old_points=old_points(indices(1:Params.num_tracks),:);
        end


        % Compute
        % magnitude�˴��õ���klt�㷨����׷�٣����Ǵ������㿪ʼ������һ֡��Ѱ����һ֡�������㣬
        %������һ֡���������λ�ã�points_validity��ָ�������û�б�����
        if (length(old_points) >= Params.min_tracks) % if at least k points are detected
            % Initialize tracker
            pointTracker = vision.PointTracker;
            initialize(pointTracker,old_points,frame);
            for frameNr=1:Params.stepSize-1
                frame = imread(imageList{startFrame+frameNr});
                %������һ֡���������λ�ã�points_validity��ָ�������û�б�����
                [new_points,points_validity] = step(pointTracker,frame);
            end

            diff=new_points(points_validity,:)-old_points(points_validity,:);
            diff=mean(norm(diff));
            %����Params.stepSize��ÿParams.stepSize֮�丳��ֵͬ��
            % add it to the array and normalize by frame size
            motion_magnitude(startFrame:startFrame+Params.stepSize-1)=(FPS/Params.stepSize)*diff./frameSize;
        end
    end
end

