
function [score]=superScore(superFrames,frameScore)
%superFrames�洢���Ƿָ�㣬��framesScore�洢����ÿһ֡�ĵ÷� 
n=size(superFrames,1);
I=zeros(n,1);
for i=1:n
    change=superFrames(i,:);
    for j=change(1):change(2)
        I(i)=I(i)+frameScore(j);
    end
end
score=I;
end



        
        
        
        