% Group Search Optimizer algorithm in Matlab
function [fbestval,bestmember,history] = HGSO(fname,MaxIter)
close all
tic%计算程序使用时间，与程序结尾的toc相呼应
global NDim Acnumb
flag=0;
iteration = 0;
%-----------------------------
%MaxIter=10;
Best=zeros(MaxIter,1);
%fname='Shapeweightspace15';
Bound=eval(fname);
PopSize=48;     % population of members
angle=pi/4.*ones(NDim-1,PopSize);   % Initialize head angle
%leftangle=angle; 
%rightangle=angle;

% Defined lower bound and upper bound.
LowerBound = zeros(NDim,PopSize);
UpperBound = zeros(NDim,PopSize);
for i=1:PopSize
    LowerBound(:,i)=Bound(:,1);
    UpperBound(:,i)=Bound(:,2);
end
%------------------黏附时用的边界---------------------%
TheLowerBound=LowerBound;
TheUpperBound=UpperBound;
%DResult = 1e-1;    % Desired results
%-----------------------------%
vmax = ones(NDim,PopSize);
for i=1:NDim
    vmax(i,:)=(UpperBound(i,:)-LowerBound(i,:));
end
r=norm(vmax(:,1));
distance=r*repmat(ones(1,PopSize),NDim,1);
a= round(((NDim+1)^.5));
direction=zeros(NDim,PopSize);
for j=1:PopSize
    direction(1,j)=(cos(angle(1,j)));
    for i=2:NDim-1
        direction(i,j)=cos(angle(i,j)).*prod(sin(angle(i:NDim-1,j)));
    end
    direction(NDim,j)=prod(sin(angle(1:NDim-1,j)));
end
initialization=1;
while initialization==1
    initialization=0;
    %---------包含初始设计值-------%
    population =  rand(NDim, PopSize).*(UpperBound-LowerBound) + LowerBound;     % Initialize swarm population
    %population(:,1)
    %-----------------------------%
    %-----------add---------------%
    population(1:Acnumb,:)=round(population(1:Acnumb,:)*100000)/100000;%
    population(Acnumb+1:NDim,:)=round(population(Acnumb+1:NDim,:)*1000)/1000;%
    executefunction=strcat(fname,'(population)');
    % Evaluate initial population
    fvalue = eval(executefunction);
    if min(fvalue) == inf
        initialization=1;
    end
end

% Finding best member in initial population
[fbestval,index] = min(fvalue);    
bestmember=population(:,index);
oldangle=angle;
oldindex=index; %#ok<NASGU>
badcounter=0;
HarmMemory=population;
Harmfvalue=fvalue;
%==========================================================================
while(flag == 0) && (iteration < MaxIter)
    %rand('state',sum(100*clock))
    iteration = iteration +1;
    if iteration>1  
        if  Best(iteration)<Best(iteration-1)
            ik=0;
            Rr=0.2; 
        else
            ik=ik+1;
            if ik>=5
            Rr=0.5;
            end
        end
    else
        Rr=0.2;
    end
    for j=1:PopSize
        R1=randn(1);
        R2=rand(NDim-1,1);
        R3=rand(NDim, 1);

        if j==index % Stop and search around

            SamplePosition=zeros(NDim,4);
            SampleAngle=zeros(NDim-1,4);
            Sampledirection=zeros(NDim,4);
            leftangle=(pi/(a^2)).*R2+angle(:,j);  %trun left, the angle range between new and old direction is \in [0,pi/a^2]
            rightangle=-(pi/(a^2)).*R2+angle(:,j); %trun right, the angle range between new and old direction is \in [0,pi/a^2]
            
            distance(:,j)=r*R1;
            direction(1,j)=prod(cos(angle(1:NDim-1,j)));
            for i=2:NDim-1
                direction(i,j)=sin(angle(i,j)).*prod(cos(angle(i:NDim-1,j)));
            end
            direction(NDim,j)=sin(angle(NDim-1,j));

            if badcounter>=a    % If the producer can not find a better area after $a$ iterations 
                angle(:,j)=oldangle(:,j);   %it will turn its head back to zero degree
                badcounter=0;
            end
            Sampledirection(:,1)=direction(:,j);
            SamplePosition(:,1) = population(:,j);
            SampleAngle(:,1) =angle(:,j);
            %--------------------------------------------------------------       
            % Look Straight
            StraightPosition=population(:,j)+distance(:,j).*direction(:,j);
            SamplePosition(:,2) =StraightPosition;
            SampleAngle(:,2) = angle(:,j);  
            Sampledirection(:,2)=direction(:,j);
            % Look left
            direction(1,j)=prod(cos(leftangle(1:NDim-1)));
            for i=2:NDim-1
                direction(i,j)=sin(leftangle(i)).*prod(cos(leftangle(i:NDim-1)));
            end
            direction(NDim,j)=sin(leftangle(NDim-1));
            LeftPosition=population(:,j)+distance(:,j).*direction(:,j);
            SamplePosition(:,3) =LeftPosition;
            SampleAngle(:,3) = leftangle;
            Sampledirection(:,3)=direction(:,j);
            % Look right
            direction(1,j)=prod(cos(rightangle(1:NDim-1)));
            for i=2:NDim-1
                direction(i,j)=sin(rightangle(i)).*prod(cos(rightangle(i:NDim-1)));
            end
            direction(NDim,j)=sin(rightangle(NDim-1));
            RightPosition=population(:,j)+distance(:,j).*direction(:,j);
            SamplePosition(:,4) = RightPosition;
            SampleAngle(:,4) = rightangle;
            Sampledirection(:,4)=direction(:,j);
            %--------------------------------------------------------------
            % sample 3 points
            for jj=2:4
                Upperoutflag=(SamplePosition(:,jj)>UpperBound(:,j)) ;
                Loweroutflag=(SamplePosition(:,jj)<LowerBound(:,j));   
                Ouflag=Upperoutflag+Loweroutflag;
                rf=rand(1);
                if rf <= 0.1
                    SamplePosition(:,jj)=SamplePosition(:,jj).*(1-Ouflag)+Upperoutflag.*TheUpperBound(:,j)+Loweroutflag.*TheLowerBound(:,j);
                elseif rf > 0.1 && rf <=0.6
                    SamplePosition(:,jj)=SamplePosition(:,jj).*(1-Ouflag)+Ouflag.*HarmMemory(:,round(rand*size(HarmMemory,2)+0.5));
                else
                    SamplePosition(:,jj)=SamplePosition(:,jj)-Ouflag.*distance(:,j).*Sampledirection(:,jj);
                end
            end
            %-------------变量处理---------------%
            SamplePosition(1:Acnumb,:)=round(SamplePosition(1:Acnumb,:)*100000)/100000;%变量离散处理
            SamplePosition(Acnumb+1:NDim,:)=round(SamplePosition(Acnumb+1:NDim,:)*1000)/1000;%变量离散处理
            %-----------------------------------%
            Samplefunction=strcat(fname,'(SamplePosition)');
            SampleValue = eval(Samplefunction);
            SampleValue(1)=fvalue(j);
            [fbestdirctionval, bestdirection]=min(SampleValue);
            population(:,j)=SamplePosition(:,bestdirection);

            if bestdirection ~= 1   % if the member find a better place
                angle(:,j)=SampleAngle(:,bestdirection);
                oldangle(:,j)=angle(:,j);
                badcounter=0;
            else                    % if the member stays
                badcounter=badcounter+1;
                angle(:,j) =  (pi/(a^2)/8).*R2+angle(:,j); % Turn pi/(a^2)/2 and sample a new direction
            end
        %==================================================================
        else%漫游者
        %==================================================================
            angle(1:NDim-1,j)=pi/(a^2)/2.*R2+angle(1:NDim-1,j);           

            if rand(1)>Rr   % Scroungers perform scrounging 
                distance(:,j)=R3.*(bestmember-population(:,j));
                population(:,j) = population(:,j) + distance(:,j);
            else    % Rangers perform ranging 
                distance(:,j)=r*repmat(a*R1,NDim,1);
                % direction calculation
                direction(1,j)=(cos(angle(1,j)));
                for i=2:NDim-1
                    direction(i,j)=cos(angle(i,j)).*prod(sin(angle(i:NDim-1,j)));
                end
                direction(NDim,j)=prod(sin(angle(1:NDim-1,j)));
                population(:,j) = population(:,j) + distance(:,j).*direction(:,j);
            end
        end
    end
    %Prevent members from flying outside search space
    for j=1:PopSize
        Upperoutflag=(population(:,j)>UpperBound(:,j)) ;
        Loweroutflag=(population(:,j)<LowerBound(:,j));   
        Ouflag=Upperoutflag+Loweroutflag;
        rf=rand(1);
        if rf <= 0.1
            population(:,j)=population(:,j).*(1-Ouflag)+Upperoutflag.*TheUpperBound(:,j)+Loweroutflag.*TheLowerBound(:,j);
        elseif rf > 0.1 && rf <=0.6
            population(:,j)=population(:,j).*(1-Ouflag)+ Ouflag.*HarmMemory(:,round(rand*size(HarmMemory,2)+0.5));
        else
            population(:,j)=population(:,j)-Ouflag.*distance(:,j).*direction(:,j);
        end
    end
    %-----------add---------------%
    population(1:Acnumb,:)=round(population(1:Acnumb,:)*100000)/100000;%变量离散处理
    population(Acnumb+1:NDim,:)=round(population(Acnumb+1:NDim,:)*1000)/1000;%变量离散处理
    %-----------------------------%
    % Evaluate the new swarm
    fvalue = eval(executefunction);
    % Updating index
    [fbestval, index] = min(fvalue);
    bestmember=population(:,index);
    Best(iteration) =fbestval;
    %----------------------------------------------------%
    isgood=fvalue<Harmfvalue;
    Harmfvalue=Harmfvalue.*(1-isgood)+fvalue.*isgood;
    isgood=repmat(isgood,NDim,1);
    HarmMemory=HarmMemory.*(1-isgood)+population.*isgood;
    %----------------------------------------------------%
    fprintf(1,'%e   ',fbestval);
    if iteration/5==floor(iteration/5)
        fprintf(1,'\n');
    end
end
toc%计算程序使用的时间
history=Best;
plot(Best,'r') 
