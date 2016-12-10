function [ score,score_Add_left,score_Rem_left, score_Add_right,score_Rem_right ] = summe_scoreSuperframes( superFrames,movementScore,FPS, delta, Params )
%������������ƽ������superframe�Ļ����ϣ������߽�����������ƶ��������¼�������Ч�����þ��������档���ܻ��֮ǰ�ľ�����жԱȡ�
%summe_scoreSuperframes function scoring boundary movements
    nbOfSuperFrames=size(superFrames,1);
    score=zeros(nbOfSuperFrames,1);
    score_Add_left=zeros(nbOfSuperFrames,1);
    score_Rem_left=zeros(nbOfSuperFrames,1);
    score_Add_right=zeros(nbOfSuperFrames,1);
    score_Rem_right=zeros(nbOfSuperFrames,1);

    for sfIdx=1:nbOfSuperFrames
        
        beginFrame=superFrames(sfIdx,1);
        endFrame=superFrames(sfIdx,2);
        
        lengthProb=getProb((endFrame-beginFrame+1),FPS);
        C_movement=movementScore(beginFrame)+movementScore(endFrame);
        
        
        score(sfIdx)=getScore(lengthProb,C_movement,Params.gamma);

        % Score if we make it longer on the right side�ұ߽�����������delta��֡
        if endFrame+delta > max(superFrames(:,2)) % an impossible movement, as it would go over the end of the video
            score_Add_right(sfIdx)=-1;
        else
            newLength=(endFrame-beginFrame+delta+1);
            lengthProb=getProb(newLength,FPS);
            C_movement=movementScore(beginFrame)+movementScore(endFrame+delta);
            score_Add_right(sfIdx)=getScore(lengthProb,C_movement,Params.gamma);
        end

        % Score if we make it shorter on the right side�ұ߽�����������delta��֡
        if sfIdx==nbOfSuperFrames || endFrame-delta < beginFrame
            score_Rem_right(sfIdx)=-1;
        else        
            newLength=(superFrames(sfIdx,2)-superFrames(sfIdx,1)-delta)+1;
            lengthProb=getProb(newLength,FPS);
            C_movement=movementScore(beginFrame)+movementScore(endFrame-delta);
            score_Rem_right(sfIdx)=getScore(lengthProb,C_movement,Params.gamma);
        end
        
        % Score if we make it longer on the left side ��߽�����������delta��֡
        if sfIdx==1
            score_Add_left(sfIdx)=-1;
        else  
            newLength=(endFrame-(beginFrame-delta)+1);
            lengthProb=getProb(newLength,FPS);
            C_movement=movementScore(beginFrame-delta)+movementScore(endFrame);
            score_Add_left(sfIdx)=getScore(lengthProb,C_movement,Params.gamma);
        end
        
        % Score if we make it shorter on the left side��߽�����������delta��֡
        if beginFrame+delta >=endFrame 
            score_Rem_left(sfIdx)=-1;
        else
            newLength=(endFrame-(beginFrame+delta)+1);
            lengthProb=getProb(newLength,FPS);
            C_movement=movementScore(beginFrame+delta)+movementScore(endFrame);
            score_Rem_left(sfIdx)=getScore(lengthProb,C_movement,Params.gamma);    
        end
        
    end
end

    
%% Function to compute the "goodness" of a SF
% �������quality of a super-frame ���õ������ϵĹ�ʽ
function [score] = getScore(lengthProb,C_movement,gamma)
    score = (lengthProb) ./ (1+gamma*C_movement);
end

%% Probability of a certain length
function [prob] = getProb(nFrames,FPS)
    global lookupT;
    if lookupT(nFrames)>=0
        prob=lookupT(nFrames);
    else
        prob = getLengthPrior(nFrames/FPS);
        lookupT(nFrames)=prob;
    end
end