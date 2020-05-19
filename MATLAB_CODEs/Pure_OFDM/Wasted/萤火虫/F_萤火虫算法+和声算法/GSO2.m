function[fbestval,BEST,bestmember]=GSO2(fname,NDim,MaxIter)  
popsize=51;
%定义上下界
Bound=eval(fname);
LowerBound=zeros(NDim,1)+Bound(:,1);
UpperBound=zeros(NDim,1)+Bound(:,2);
population=rand(NDim,Popsize)*(repmat(UpperBound-Lowerbound,1,Popsize))+repmat(LowerBound,1,Popsize);%初始化群成员
step=4;%设定步长
%计算代价，找出最好的成员
fvalue=eval(strcat(fname,'(population)'));
[fbestval,index]=min(fvalue);
bestmember=population(:,index);
v=zeros(NDim,51);%初始化经验值
preindex=index;
prebestmember=bestmember;
iteration=1;
while iteration<=MaxIter
    for j=1:Popsize
        if j~=index
            if(index~=preindex)&&(rand(1)<1)
                %积累经验并预测
                v(:,j)=0.6*v(:,j)+6*rand(NDim,1).*(bestmember-prebest-member);
                population(:,j)=bestmember+rand(NDim,1).*v(:,j);
                %防止出界
                population(:,j)=min(population(:,j),UpperBound);
                population(:,j)=max(population(:,j),LowerBound);
            elseif rand(1)<.8  %加入者向发现者靠近
                R=rand(NDim,1);
                population(:,j)=population(:,j)+R.*(bestmember-population(:,j));
            else  %游荡者朝任意方向移动
       changflag=rand(NDim,1)<(1.5/NDim+((NDim*4)/iteration)^2);
       if~any(changflag)
           changflag(fix(rand(1)*NDim+1)=1;
       end
       addr=step.*randn(NDim,1).*changflag;
       population(:,j)=population(:,j)+addr;
       population(:,j)=min(population(:,j),UpperBound);
       population(:,j)=max(population(:,j),LowerBound);
            end
        end
    end
    preindex=index;
    prebestmember=bestmember;
    fvalue=eval(strcat(fname,'(population)'));
    [fbestval,index]=min(value);
    bestmember=population(:,index);
    Best(iteration)=fbestval;
    iteration=iteration+1;
end
    
                




