% Group Search Optimizer algorithm in Matlab
% Copyright (C) 2004-2005 Department of Electricity 
% Engineering and Electronics, The University of Liverpool, UK
% Last modifed 12-May-05

function [fbestval,bestmember,history] = GSO(fname,MaxIter)

% function [fbestval,bestmember] = GSO(fname,NDim,MaxIter)
%
%   Run a Group Search Optimizer algorithm
%
% Input Arguments:
%   fname       - the name of the evaluation .m function
%   NDim        - dimension of the evalation function
%   MaxIter     - maximum iteration
close all
tic%计算程序使用时间，与程序结尾的toc相呼应
global NDim Acnumb
flag=0;
iteration = 0;
%-----------------------------
%MaxIter=10;
Best=zeros(MaxIter,1);
%fname='DShapeweightplane10';
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
    exexutefunction=strcat(fname,'(population)');
    % Evaluate initial population
    fvalue = eval(exexutefunction);
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
while(flag == 0) && (iteration < MaxIter)
    %rand('state',sum(100*clock))
    iteration = iteration +1;

     for j=1:PopSize
        R1=randn(1);
        R2=rand(NDim-1,1);
        R3 = rand(NDim, 1);

        if j==index % Stop and search around

            SamplePosition=zeros(NDim,4);
            SampleAngle=zeros(NDim-1,4);
            SampleValue=zeros(1,4);
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
            end

            SamplePosition(:,1) = population(:,j);
            SampleAngle(:,1) =angle(:,j);
            SampleValue(1) = fvalue(j);
                       
            % Look Straight
            StraightPosition=population(:,j)+distance(:,j).*direction(:,j);
            
            Outflag=(StraightPosition>UpperBound(:,j) | StraightPosition<LowerBound(:,j));
            StraightPosition=StraightPosition-Outflag.*distance(:,j).*direction(:,j);
            %-----------add---------------%
            %if.......%以后这里可以添加，选择处理截面变量离散处理的的方式
            StraightPosition(1:Acnumb)=round(StraightPosition(1:Acnumb)*100000)/100000;%变量离散处理        
            StraightPosition(Acnumb+1:NDim)=round(StraightPosition(Acnumb+1:NDim)*1000)/1000;%变量离散处理
            %-----------------------------%           
            Straightfunction=strcat(fname,'(StraightPosition)');
            Straightfvalue = eval(Straightfunction);
            SamplePosition(:,2) = StraightPosition;
            SampleAngle(:,2) = angle(:,j);
            SampleValue(2) = Straightfvalue;

            % Look left
            direction(1,j)=prod(cos(leftangle(1:NDim-1)));
            for i=2:NDim-1
                direction(i,j)=sin(leftangle(i)).*prod(cos(leftangle(i:NDim-1)));
            end
            direction(NDim,j)=sin(leftangle(NDim-1));

            LeftPosition=population(:,j)+distance(:,j).*direction(:,j);

            Outflag=(LeftPosition>UpperBound(:,j) | LeftPosition<LowerBound(:,j));
            LeftPosition=LeftPosition-Outflag.*distance(:,j).*direction(:,j);
            %-----------add---------------%
            LeftPosition(1:Acnumb)=round(LeftPosition(1:Acnumb)*100000)/100000;%变量离散处理
            LeftPosition(Acnumb+1:NDim)=round(LeftPosition(Acnumb+1:NDim)*1000)/1000;%变量离散处理
            %-----------------------------%
            Leftfunction=strcat(fname,'(LeftPosition)');
            Leftfvalue = eval(Leftfunction);
            SamplePosition(:,3) =LeftPosition;
            SampleAngle(:,3) = leftangle;
            SampleValue(3) = Leftfvalue;

            % Look right
            direction(1,j)=prod(cos(rightangle(1:NDim-1)));
            for i=2:NDim-1
                direction(i,j)=sin(rightangle(i)).*prod(cos(rightangle(i:NDim-1)));
            end
            direction(NDim,j)=sin(rightangle(NDim-1));

            RightPosition=population(:,j)+distance(:,j).*direction(:,j);

            Outflag=(RightPosition>UpperBound(:,j) | RightPosition<LowerBound(:,j));
            RightPosition=RightPosition-Outflag.*distance(:,j).*direction(:,j);
            %-----------add---------------%
            RightPosition(1:Acnumb)=round(RightPosition(1:Acnumb)*100000)/100000;%变量离散处理
            RightPosition(Acnumb+1:NDim)=round(RightPosition(Acnumb+1:NDim)*1000)/1000;%变量离散处理
            %-----------------------------%
            Rightfunction=strcat(fname,'(RightPosition)');
            Rightfvalue = eval(Rightfunction);
            SamplePosition(:,4) = RightPosition;
            SampleAngle(:,4) = rightangle;
            SampleValue(4) = Rightfvalue;
            % sample 3 points

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


        else

            angle(1:NDim-1,j)=pi/(a^2)/2.*R2+angle(1:NDim-1,j);           

            if rand(1)>.2   % Scroungers perform scrounging 
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

    % Prevent members from flying outside search space
    OutFlag = population<LowerBound | population>UpperBound;
    population = population - OutFlag.*distance.*direction;
    %-----------add---------------%
    population(1:Acnumb,:)=round(population(1:Acnumb,:)*100000)/100000;%变量离散处理
    population(Acnumb+1:NDim,:)=round(population(Acnumb+1:NDim,:)*1000)/1000;%变量离散处理
    %-----------------------------%
    % Evaluate the new swarm
    fvalue = eval(exexutefunction);

    % Updating index
    [fbestval, index] = min(fvalue);

    bestmember=population(:,index);
    
    Best(iteration) =fbestval;
    fprintf(1,'%e   ',fbestval);
    if iteration/5==floor(iteration/5)
        fprintf(1,'\n');
    end
end
toc%计算程序使用的时间
history=Best;
plot(Best,'r') 
