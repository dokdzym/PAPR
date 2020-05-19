clc
clear all
tic
m=2;%维数
n=50;%萤火虫个数
a=3;
b=-3;
jis=0;
L0=5;%荧光素初值

beta=0.08;%动态决策域的更新率
nt=5;% 领域个数阈值
s=0.05;%步长
%s=0.03;%步长
gama=0.6;%荧光素更新率
p=0.4;%荧光素消失率
t=2;%次数初值  
iter_max=200;%最大迭代次数
R0=3;%动态决策域Rd的初值
Rs=5;%感知域RS>=Rd
L=zeros(n,iter_max);
Rd=zeros(n);
P=zeros(n,n);

Nei=cell(n,iter_max);

%随机分配个体荧光素及动态决策域
for i=1:n
    L(i,1)=L0;
    Rd(i)=R0;
end


%第i萤火虫在t时刻的位置初始化



for i=1:n  
   X(i,1:m)=(a-b)*rand(1,m)+b;  
   plot(X(i,1),X(i,2),'sk');
    hold on
end

while t<iter_max
%荧光素的更新
for i=1:n
    L(i,t)=(1-p)*L(i,(t-1))+gama*J1(X(i,1:m));
end
    
%位置移动规则
for i=1:n
    for j=1:n
    if (norm(X(j,1:m)-X(i,1:m))<Rd(i))&&(L(i,t)<L(j,t))
       Nei{i,t}=[j,Nei{i,t}];%获取邻域Nei
    end
    end
end


tempsum=zeros(n);
for i=1:n
    for j=Nei{i,t}
       tempsum(i)=L(j,t)-L(i,t)+tempsum(i);
    end
end

%移动概率的计算
for i=1:n
    for j=Nei{i,t}
        P(i,j)=(L(j,t)-L(i,t))/tempsum(i);
    end
end

for i=1:n
    if isempty(Nei{i,t})
        X(i,1:m)= X(i,1:m);
        Rd(i)=min(Rs,max(0,Rd(i)+beta*(nt-length(Nei{i,t})))); 
         plot(X(i,1),X(i,2),'*k');
       hold on
    else     
    for j=Nei{i,t}
       if  P(i,j)==max(P(i,:))&&P(i,j)~=0
           SeJ=j;%选择最好的移动方向
          %位置更新
           X(i,1:m)= X(i,1:m)+s.*(X(SeJ,1:m)-X(i,1:m))/norm(X(SeJ,1:m)-X(i,1:m)); 
         %动态决策域更新
         Rd(i)=min(Rs,max(0,Rd(i)+beta*(nt-length(Nei{i,t})))); 
         
         plot(X(i,1),X(i,2),'*k');
     hold on
       end
    end
     P(i,:)=zeros(1,n);
    end
end
if t<=150
s=s-0.0003;
end
t=t+1

end
%取值
for i=1:n
    num=0;
    for j=i+1:n
      if norm(X(i,1:m)-X(j,1:m))<0.05
          num=num+1;
          if num<=1
             jis=jis+1; 
              if J1(X(i,1:m))<J1(X(j,1:m))
                 fuzhu(jis,1:m)=X(j,1:m);
                 
              else
                 fuzhu(jis,1:m)=X(i,1:m);
              end
              X(j,1:m)=[inf];
          else
              if J1(X(i,1:m))<J1(X(j,1:m))
                 fuzhu(jis,1:m)=X(j,1:m);
              end
              X(j,1:m)=[inf];
              
          end
      end
    end
end

fuzhu
%画图
toc
for i=1:n
plot(X(i,1),X(i,2),'or');
hold on
end
grid on


